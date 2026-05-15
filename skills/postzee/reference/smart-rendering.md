# Smart Rendering — Path A vs Path B

This file is the agent's protocol for choosing **how to turn approved HTML into PNG bytes** when the user moves from stage 7a (preview) to stage 7b (render).

Two paths, same output:

```
┌────────────────────────────────────────────────────────────────┐
│ PATH A — Postzee renders (Puppeteer, server-side)              │
│                                                                │
│   Agent → POSTZEE_RENDER_IMAGE or POSTZEE_RENDER_CAROUSEL      │
│           (sends HTML, Postzee returns mediaUrl)               │
│                                                                │
│   Latency: 5-30s (queue wait + render)                         │
│   Works on: every surface (no client capability required)      │
│   Default: yes                                                 │
├────────────────────────────────────────────────────────────────┤
│ PATH B — Agent renders locally, uploads bytes (Path B)         │
│                                                                │
│   Agent → Bash → Playwright local render → PNG →               │
│           POSTZEE_UPLOAD_RENDERED_IMAGE / _CAROUSEL            │
│           (sends bytes, Postzee returns mediaUrl)              │
│                                                                │
│   Latency: 2-8s (local compute + upload)                       │
│   Works on: Claude Code with Bash + npm/playwright             │
│   Default: PREFERRED when capability exists                    │
└────────────────────────────────────────────────────────────────┘
```

Both paths produce the same `{ mediaId, mediaUrl, width, height }` shape. The agent picks based on capability; the rest of the flow doesn't care which was used.

---

## 1. Why Path B exists

The Postzee Puppeteer pool is parallel (4 workers, ~5-15s per slide). It works for everyone. But on Claude Code with shell access, the agent has a local Chromium it can drive — saving 5-30s of queue wait time per render, plus making iteration on slow days (when the pool is busy) instant.

Trade-offs accepted:

- **Path B only works on a fraction of surfaces** — Claude Code + Bash + ability to install playwright. Probably 20-30% of the user base.
- **Compute moves to the user's machine** — minor; the render is bounded (few seconds, modest memory).
- **Postzee never sees the source HTML for Path B renders** — operationally fine (we never inspected source HTML anyway), and a privacy improvement for sensitive content.
- **Final pixels might differ subtly** between Path A and Path B (different Chromium versions, different font rendering). Acceptable: the difference is sub-pixel and never user-visible at carousel scale.

The skill prefers Path B when usable but never blocks shipping on it — Path A is the universal fallback.

---

## 2. Capability detection protocol

The agent runs detection ONCE per conversation and caches the result. Three states:

```
state ∈ { 'unknown', 'path-b-ready', 'path-a-only' }
```

Detection flow (run once, at the first time the agent reaches stage 7b in a session):

### 2.1 Quick capability check

```bash
# 1. Is there a shell at all?
#    If Bash tool isn't available, agent can't run shell commands.
#    → state = 'path-a-only'. Skip the rest.

# 2. Does the shell have node + npm?
which node && which npm
# Exit 0 = yes; non-zero = no.
# → On non-zero: state = 'path-a-only'. Tell user once: "Tô em path-a (Postzee renderiza). Pra acelerar, instale Node + npm."

# 3. Is playwright already installed (globally or in a known location)?
which playwright || npx --quiet playwright --version 2>/dev/null
# Exit 0 = yes.
# → On non-zero: optionally try to install ONCE.
```

### 2.2 Optional one-time install

If node + npm exist but playwright isn't installed, the agent can try a ONE-TIME install:

```bash
# Tell the user before installing — don't surprise them with a long-running command.
# Example surface: "Pra acelerar os renders nessa conversa, instalo o Playwright local? 
#                  Leva ~30s e usa ~150MB de disco."

# On user "sim":
npm install -g playwright 2>&1 | tail -5
npx playwright install chromium --with-deps 2>&1 | tail -5
```

If install succeeds → `state = 'path-b-ready'`. Cache for the session.

If install fails (permission, network, disk) → `state = 'path-a-only'`. Cache. Tell the user: *"Playwright não instalou (motivo: X). Vou seguir com Path A — renders pelo Postzee, ~10-20s a mais por imagem."*

### 2.3 The render script

When `state === 'path-b-ready'`, the agent uses this script template to render HTML to PNG:

```javascript
// File: /tmp/postzee-render-<sessionid>.mjs
// Run with: node /tmp/postzee-render-<sessionid>.mjs <input-html-path> <output-png-path> <width> <height>

import { chromium } from 'playwright';
import fs from 'fs/promises';

const [,, inputPath, outputPath, w, h] = process.argv;
const width = parseInt(w, 10);
const height = parseInt(h, 10);

const html = await fs.readFile(inputPath, 'utf8');

const browser = await chromium.launch({ headless: true });
const ctx = await browser.newContext({
  viewport: { width, height },
  deviceScaleFactor: 1,
  // Disable JS — same as Postzee Puppeteer for parity + security
  javaScriptEnabled: false,
});
const page = await ctx.newPage();

// Use setContent with `wait: 'networkidle'` so any base64 data URIs settle
await page.setContent(html, { waitUntil: 'networkidle', timeout: 30_000 });

// Screenshot exactly the viewport — no full-page
await page.screenshot({
  path: outputPath,
  type: 'png',
  fullPage: false,
  clip: { x: 0, y: 0, width, height },
});

await ctx.close();
await browser.close();
```

Save the script once per session under `/tmp/postzee-render-<sessionid>.mjs`, reuse for every render.

### 2.4 The full Path B flow

```
1. User approves visual in stage 7a (says "renderiza").

2. Detection check:
   - If state === 'unknown', run §2.1 + §2.2 first.
   - If state === 'path-a-only', skip to Path A.
   - If state === 'path-b-ready', continue.

3. For each slide/image to render:
   a. Write the master HTML to /tmp/postzee-slide-N.html
   b. Run `node /tmp/postzee-render-<session>.mjs <html-path> <png-path> <w> <h>`
   c. Read the PNG bytes
   d. base64-encode
   e. Hold in memory for the final upload call

4. Single image:
   POSTZEE_UPLOAD_RENDERED_IMAGE({
     imageBase64,
     mimeType: 'image/png',
     width, height,
     name: '<title from session context>'
   })
   → { mediaId, mediaUrl, width, height }

   Carousel:
   POSTZEE_UPLOAD_RENDERED_CAROUSEL({
     slides: [{ imageBase64, mimeType, width, height }, ...],
     aspectRatio,
     name
   })
   → { mediaGroupId, totalSlides, mediaUrls }

5. Cleanup: rm /tmp/postzee-slide-*.html and /tmp/postzee-slide-*.png.

6. Surface success: "Renderizei localmente em Ns. Imagem(ns) prontas: <url>."
```

### 2.5 Fallback on Path B failure

If any step in Path B fails (script errors, timeout, render produces 0-byte file, upload returns error):

1. Don't retry Path B — go straight to Path A.
2. Tell the user once: *"Falhou local (motivo: X). Vou pelo Postzee — chega em ~Ns."*
3. Cache `state = 'path-a-only'` for the REST of this session so the agent doesn't waste another attempt.

A Path B failure is NOT user-facing as an error — it's an internal optimization that fell back. The user shouldn't see anything except the final mediaUrl arriving slightly later than the optimistic case.

---

## 3. Surface heuristics — when to expect Path B

| Surface | Bash tool? | Likely playwright-capable? | Default state |
|---|---|---|---|
| Claude Code | Yes | Yes (usually has dev tooling) | Try Path B |
| Claude Desktop | Sometimes via MCP servers | Usually no | Path A |
| Claude Web (claude.ai) | No | No | Path A |
| openclaw | Depends on adapters | Rarely | Path A |
| hermes | Depends on adapters | Rarely | Path A |

The agent doesn't need to memorize this table — it just runs §2.1 detection. The table just helps the agent set expectations when telling the user what's happening.

---

## 4. When to NOT use Path B even if available

Path B is the default WHEN capability exists, but there are 3 cases where Path A wins:

### 4.1 Carousel with 10+ slides

For very large carousels, Path B renders SEQUENTIALLY (one slide at a time on the local Chromium) while Path A renders 4 in parallel. At slide count 10+, the parallelism wins:

- Path A 10 slides: 4 workers × 3 batches × ~10s = ~30s
- Path B 10 slides: 10 × ~5s sequential = ~50s

The agent does the math and picks. Threshold: ≤6 slides go Path B if available; ≥7 slides usually Path A (unless Postzee pool is empirically slow).

### 4.2 Network upload is slow

Path B uploads the rendered bytes (1-2MB per slide). On slow upload connections (mobile tethering, congested networks), 10 slides × 2MB = 20MB upload could take 30s — erasing the Path B speed advantage. If detected, fall back.

The agent can detect this implicitly: if the FIRST Path B upload takes >8s, cache `state = 'path-a-only'` for the rest of the session.

### 4.3 User has historically preferred Path A

If the user has previously told the agent "renderiza pelo Postzee mesmo" in the session, respect that. Cache the preference. Don't keep proposing Path B.

---

## 5. The user-facing surface

The agent's job is to make path selection INVISIBLE to the user. The surface during render:

**Path B happy case (~3-8s)**:
```
🎨 Renderizando localmente... (3s)
✅ Pronto! Imagem em 2160×2700 disponível.
   mediaUrl: https://cdn.postzee.app/...
```

**Path A normal case (~10-20s)**:
```
🎨 Mandando pro Postzee renderizar... (~15s)
✅ Pronto! Imagem em 2160×2700 disponível.
   mediaUrl: https://cdn.postzee.app/...
```

**Path B failed → Path A fallback**:
```
🎨 Local falhou (motivo: chromium não inicializou). Vou pelo Postzee — chega em ~15s.
✅ Pronto!
   mediaUrl: https://cdn.postzee.app/...
```

**First-time install proposal (only on first render of a Path-B-capable session)**:
```
🚀 Posso instalar Playwright local pra acelerar os renders dessa sessão?
   Custa ~30s de instalação + ~150MB de disco, ganha 10-20s por render daqui pra frente.
   
   "sim" / "não" / "depois"
```

If user says "não" or "depois" → state = 'path-a-only' for the session. Don't keep asking.

---

## 6. Security + privacy notes

### 6.1 The render script runs on the user's machine

Path B uses the user's machine to render HTML. The HTML is composed by the AGENT (Claude). If the agent is being attacked by a malicious user via prompt injection to render hostile HTML — the script disables JavaScript (`javaScriptEnabled: false` in §2.3), which neutralizes the main vector.

Don't ENABLE JavaScript in the render script. Don't add `--allow-file-access` flags. Don't render HTML from untrusted external sources. Just render what the user approved in stage 7a.

### 6.2 Postzee gets bytes, not source

Path A: Postzee servers see the source HTML (briefly, to render).
Path B: Postzee servers see only the rendered PNG bytes.

This is a minor privacy improvement for sensitive content — Postzee never holds the source. If user explicitly cares (rare), they should prefer Path B.

### 6.3 R2 storage

Both paths end at the same R2 bucket via the same `UploadFactory.createStorage()` → `saveFile()` pipeline. Same access patterns, same lifecycle, same org-scoping. No difference downstream.

### 6.4 Idempotency

- Path A idempotency: hash of `(orgId, aspectRatio, name, slides[].html)`. Same HTML → same group.
- Path B idempotency: hash of `(orgId, dimensions, name, slides[].pngBytes)`. Same bytes → same media/group.

The two caches are DISJOINT. A Path A render of HTML X and a Path B upload of the resulting PNG do NOT collide (different keys). This is intentional: if a user iterates and re-renders via the same path twice, idempotency catches it; if they switch paths, that's a fresh render.

---

## 7. Cross-references

- `carousel-visual-preview.md` §5 — hand-off from stage 7a to stage 7b (this doc applies inside that hand-off)
- `image-mastery.md` §8 — single-image render step
- `carousel-mastery.md` §9 — carousel render step
- Backend MCP tools (defined in `dashboard/apps/backend/src/mcp/main.mcp.ts`):
  - `POSTZEE_RENDER_IMAGE` (Path A — single)
  - `POSTZEE_RENDER_CAROUSEL` (Path A — carousel)
  - `POSTZEE_UPLOAD_RENDERED_IMAGE` (Path B — single)
  - `POSTZEE_UPLOAD_RENDERED_CAROUSEL` (Path B — carousel)
- Backend service: `dashboard/libraries/nestjs-libraries/src/slide-render/slide-render.service.ts` (both paths internally)

The smart-rendering decision is invisible to the user but compounds across a session — every render that picks Path B saves 5-30s. Over a 10-render session, that's minutes back to the user. Worth getting right.
