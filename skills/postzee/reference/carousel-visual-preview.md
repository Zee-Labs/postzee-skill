# Carousel Visual Preview (Stage 7a — Steps 1 + 2)

This file is the protocol for **Steps 1 (compose) and 2 (iterate) of stage 7a** — the visual preview the user iterates on before Postzee renders.

**Stage 7a runs in three steps** (full workflow in `carousel-mastery.md` §9.0):

- **Step 0 — Image Strategy** (`carousel-mastery.md` §9.1, NEW in v3.8.0): agent proactively proposes background images for slides that lose editorial force without them. Runs BEFORE this file's Step 1. The mediaUrls returned by `POSTZEE_GENERATE_IMAGE` feed Step 1's image inlining.
- **Step 1 — Compose the preview HTML artifact** (§2 of this file): aggregate slides into a single document, base64-inline images (including the ones from Step 0), output the artifact.
- **Step 2 — Iterate** (§4 of this file): user edits via natural language, agent updates the master HTML, re-outputs the artifact. No Postzee call.

Stage 7b (the actual `POSTZEE_RENDER_CAROUSEL` call) is covered in `carousel-mastery.md` §9.2.

> **Two shapes, one source of truth.** The preview is a single aggregated document optimized for the Claude artifact CSP. The render is per-slide HTML optimized for server-side Puppeteer. Source of truth is the **content + design system** — the agent applies a mechanical conversion at hand-off (see §3a). Trying to use literally the same HTML for both surfaces causes invisible-text bugs (see §2 rationale).

---

## 1. Why this stage exists

Before v3.6, stage 7 went straight from "user approved the script text" to "call `POSTZEE_RENDER_CAROUSEL`" — and any visual tweak after that ("muda cor de fundo do slide 3 pra preto") required a fresh `REPLACE_CAROUSEL_SLIDE` call, which costs credits and queues another Puppeteer render. A user iterating 4 times on the visuals would burn 4 server renders + minutes of latency for changes they could have seen in their browser instantly.

Stage 7a moves that iteration loop into the Claude artifact. The user sees the full carousel, requests changes verbally, the agent edits the HTML and re-outputs the artifact. **No Postzee call.** When the visual is final, one `POSTZEE_RENDER_CAROUSEL` ships everything atomically.

Result: iteration in 7a is free and instant; the render in 7b happens exactly once.

---

## 2. The artifact structure

The artifact is a **single self-contained HTML document**. All N slides live in ONE document, each as a scaled `<section class="slide-N">`. Fonts load ONCE in the wrapper's `<head>`. **No iframes.**

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <style>
    /* === Fonts: load ONCE for the whole preview === */
    @font-face {
      font-family: 'Anton';
      font-weight: 400;
      src: url(data:font/woff2;base64,...) format('woff2');
      /* CRITICAL: `swap`, NOT `block`. Artifact CSP may block data: URI
         fonts; with `block` the text stays invisible forever. With `swap`,
         text appears immediately with the fallback chain. Render-time uses
         `block` instead (Puppeteer waits) — see §3a conversion. */
      font-display: swap;
    }

    body {
      background: #111;
      padding: 24px;
      margin: 0;
      font-family: system-ui, -apple-system, sans-serif;
      color: #999;
    }
    .carousel {
      display: grid;
      gap: 32px;
      grid-template-columns: 1fr;
      max-width: 600px;
      margin: 0 auto;
    }
    .slide-wrap {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    .label {
      font-size: 13px;
      letter-spacing: 0.04em;
      text-transform: uppercase;
    }
    /* === Slide container: scaled, isolated via scoped class === */
    .slide {
      width: 540px;
      height: 675px;
      overflow: hidden;
      border-radius: 12px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
      position: relative;
      /* Slides are authored at 1080×1350 in their own coordinate system;
         we scale the inner content by 0.5 to fit the 540×675 box. */
    }
    .slide > .inner {
      width: 1080px;
      height: 1350px;
      transform: scale(0.5);
      transform-origin: top left;
    }

    /* === Per-slide styles, scoped via `.slide-N` === */
    /* Use scoped selectors so slide 1's CSS can't bleed into slide 2.
       Example: `.slide-1 .headline { ... }` (NEVER bare `.headline { ... }`). */
    .slide-1 .headline { font-family: 'Anton', Impact, "Arial Black", sans-serif; font-size: 120px; color: #fff; }
    /* ... per-slide blocks ... */
  </style>
</head>
<body>
  <div class="carousel">
    <div class="slide-wrap">
      <div class="label">Slide 1 / 9 — Capa</div>
      <section class="slide slide-1">
        <div class="inner">
          <!-- slide 1 content here, using `.slide-1`-scoped classes -->
          <h1 class="headline">A morte do gosto pessoal.</h1>
        </div>
      </section>
    </div>
    <div class="slide-wrap">
      <div class="label">Slide 2 / 9</div>
      <section class="slide slide-2">
        <div class="inner"><!-- ... --></div>
      </section>
    </div>
    <!-- ... slides 3-9 ... -->
  </div>
</body>
</html>
```

**Layout rationale:**
- **Single column, 540×675** (50% of the real 1080×1350): fits comfortably in Claude's artifact pane on most viewports; user scrolls vertically to see all slides at once.
- **No iframes** — bug history: iframe `srcdoc` in Claude artifacts inherits a strict sandbox where `@font-face` with `data:` URIs is unreliably blocked. Combined with the default `font-display: block`, the text rendered invisible (fonts never load → block hides text indefinitely). Single document eliminates the sandbox path.
- **Fonts loaded once** in the wrapper's `<head>` — 9× less memory than per-iframe duplication, faster parse, single point of `font-display: swap` discipline.
- **CSS isolation via scoped classes** (`.slide-N .selector`) — sufficient when slides share a design system (CSS variables, font set) by construction. No iframe boundary needed.
- **`.slide > .inner` with `transform: scale(0.5)`** — slides are authored at full 1080×1350 in their own coordinate system, then visually downscaled. Same coordinate math as the render, just a transform applied.

---

## 2.1 Pre-flight checklist — VALIDATE BEFORE EVERY ARTIFACT OUTPUT

Before showing the preview to the user, check every item:

- [ ] Every `@font-face` block uses **`font-display: swap`** (NEVER `block`, NEVER `auto`, NEVER omitted)
- [ ] Every `font-family` declaration has a **system fallback chain**
  - ✅ `font-family: 'Anton', Impact, "Arial Black", sans-serif`
  - ❌ `font-family: 'Anton'` ← if Anton fails, text disappears
- [ ] **Zero `<iframe>`** in the preview document
- [ ] **Zero `<link href="https://fonts.googleapis.com/...">`** (artifact CSP blocks external font fetches)
- [ ] All images use **`data:` URIs** (not CDN URLs) — see §3
- [ ] Every slide root has **explicit width/height + scale transform** (`.slide > .inner` with `transform: scale(0.5)`)
- [ ] Per-slide CSS uses **scoped selectors** (`.slide-N .headline`, never bare `.headline`)

If any item fails, fix it before output. Failures here become user-visible invisible-text or broken-layout bugs that look like the carousel is broken.

---

## 3. Image inlining protocol

Slides reference images via `<img src="...">` or `background: url(...)`. For the artifact preview to render correctly, **every image must be a `data:image/...;base64,...` URI** — external URLs are blocked by the Claude artifact CSP and render as broken icons.

`carousel-mastery.md` §10.1.5 has the rule. Here's the operational decision tree the agent runs for every image referenced by any slide:

```
1. Where is the image?
   a) Already a data: URI in the brief / context → use as-is
   b) A URL (CDN, R2, public web, POSTZEE_GENERATE_IMAGE output)
      → fetch via WebFetch / available HTTP tool
      → check Content-Type and byte length
      → step 2
   c) A file path on disk → read bytes, infer mime, base64 encode

2. Is it too large?
   - If raw > 5MB:
     → resize to max 2160px on the longest dimension
     → recompress as JPEG quality 80-85 (or keep PNG if transparency matters)
     → recheck size
   - If still > 5MB after compression:
     → fall back: use the CDN URL (NOT base64) and tell the user:
       "A imagem do slide N é grande demais pra embutir no preview —
        o preview vai mostrar um placeholder ali, mas o render final
        funciona normal. Quer que eu reduza a imagem ou seguimos?"
     → do NOT silently use the URL — the user must know the preview
       slide will not match the final render

3. Failed to fetch (HTTP 401/403/404/timeout/CORS/network):
   - Fall back to the CDN URL with the same warning as step 2 fallback
   - The server-side Puppeteer can still fetch the URL during render
     (its network context is different from the artifact's CSP)
   - But the artifact preview slide will show a placeholder

4. NO fetch capability available on the current surface:
   - Some minimal surfaces (stripped MCP clients, restricted embedded
     contexts) expose ZERO HTTP fetch capability to the agent — no
     WebFetch, no shell with curl, nothing
   - Skip base64 inlining entirely. Use the original CDN URLs in the
     slide HTML and tell the user upfront:
       "Não tenho fetch HTTP nessa superfície — o preview do artifact
        vai mostrar placeholders pras imagens, mas o RENDER final no
        Postzee funciona normal (Puppeteer fetcha server-side)."
   - Do not fabricate a base64 payload. Do not hallucinate image bytes.
   - Iteration still works for everything except the image-bearing
     slides' visual fidelity in the preview.

5. Successfully fetched and sized:
   - Encode bytes as base64
   - Build the data URI: `data:<mime>;base64,<payload>`
   - Substitute into the slide HTML: replace the original src/url with the data URI
   - Continue to the next image
```

**Cache during a session:** the same image referenced by multiple slides should be fetched once. Keep a map of `url → base64` for the duration of stage 7a. Avoids re-fetching when the user says "use a mesma foto do slide 1 no slide 6" (an inline copy in the HTML, not a second fetch).

---

## 4. Iteration loop

After the first artifact is rendered, the user issues changes in natural language. Edit the master HTML, re-output the artifact — the Claude runtime updates the existing artifact in place. No Postzee call.

**Vocabulary mapping** (extend organically; these are the common patterns):

| User says (PT/EN) | Agent does |
|---|---|
| "muda cor de fundo do slide 3 pra preto" | Edit slide 3's CSS background → re-output artifact |
| "headline do slide 1 maior" / "bigger headline on slide 1" | Adjust `font-size` in slide 1's headline element → re-output |
| "troca slide 4 e 5 de posição" / "swap 4 and 5" | Reorder the slides array → re-output |
| "remove slide 7" / "delete slide 7" | Remove slide 7 from the array, relabel slide N/N totals → re-output |
| "insere um slide entre 2 e 3 sobre X" / "insert a slide between 2 and 3" | Compose a new slide HTML for X, splice into position → re-output |
| "troca a imagem do slide 6 por essa: \<url>" | Fetch new URL → base64 → swap the data URI in slide 6 → re-output |
| "deixa todos os fundos mais escuros" | Bulk edit: walk every slide, adjust background var → re-output |
| "muda a fonte de display pra Anton" | Replace `--F-HEAD` and the associated `@font-face` block across all slides → re-output |
| "tá ótimo, renderiza" / "ship it" / "approved" | **Exit 7a, enter 7b.** Apply preview→render conversion (§5.1), then call `POSTZEE_RENDER_CAROUSEL`. |

**What the agent never does in 7a:**
- Call `POSTZEE_RENDER_CAROUSEL` / `POSTZEE_REPLACE_CAROUSEL_SLIDE` / `POSTZEE_APPEND_CAROUSEL_SLIDE`. **Any of these in 7a is a discipline break.**
- Re-fetch images already in the per-session cache.
- Ask the user "Posso renderizar agora?" without an explicit approval phrase. Iteration in 7a is open-ended; the user decides when they're done.

---

## 5. The hand-off to stage 7b

Stage 7b is triggered by **explicit visual approval**. Listen for these phrases (case-insensitive, match anywhere in the message):

| Language | Phrases |
|---|---|
| PT | `renderiza`, `pode publicar`, `tá pronto`, `aprovado`, `vai`, `pode mandar`, `manda ver` |
| EN | `render`, `render it`, `ship it`, `let's go`, `approved`, `looks good`, `good to go` |

**On approval:**

```
1. POSTZEE_GET_CONTEXT (verify credits + plan can support N slides)
2. Convert preview shape → render shape (see §5.1 below).
3. POSTZEE_RENDER_CAROUSEL({
     slides: [{ html, width: 1080, height: 1350 }, ...],
     aspectRatio: "4:5",
     name: "<short, derived from the brief — what would the agent call this carousel?>"
   })
4. Save the returned mediaGroupId.
5. Confirm to the user: "Renderizado! N slides prontos no Postzee."
6. Offer the publish step (POSTZEE_CREATE_POST), if applicable.
```

### 5.1.0 Decisions pre-made — DO NOT deliberate at conversion time

Before reaching §5.1 step-by-step, **these decisions are already taken by the skill**. The agent has no license to re-decide or re-optimize them in the moment of conversion:

| Decision | Pre-made value | Source |
|---|---|---|
| **Image source** | base64 (preview) → CDN URL (render) when URL exists in IMAGE_REGISTRY; KEEP base64 only if no URL | `media-memory.md` §8 IMAGE_REGISTRY |
| **Font delivery** | base64 `@font-face` (preview) → Google Fonts `<link>` (render) for fonts in the pre-approved set | `carousel-mastery.md` §11.1 + §11.5 |
| **font-display** | `swap` (preview) → `block` (render). Never `auto`, never omitted | `carousel-mastery.md` §11.3 |
| **Aspect ratio** | Whatever was decided at briefing | brief context |

**If the conversion is feeling tight on size, the bug is upstream — not at the conversion table:**

- IMAGE_REGISTRY missing a URL for a slide → an upload step was skipped. Go back, run the user-uploaded asset routine (`media-memory.md` §8.2), or run Step 0 image generation if it was deferred.
- Slide skeleton bloated → cut at the design level (fewer weights, simpler composition). NOT at the asset level.
- A font is not in the pre-approved set (§11.5) → consult the fallback chain (§11.6), do not improvise a "system stack" substitution mid-conversion.

⛔ **Discipline-break signals — STOP if you find yourself thinking any of these:**

- *"Vou cortar fontes pra economizar tokens"* → NO. Google Fonts `<link>` is already cheap. Re-read §11.1.
- *"Vou trocar pra system stack (Helvetica/Arial)"* → NO. The user approved a specific typography. System fallback is for when the brand-custom font is genuinely unavailable, not a token-saving tactic.
- *"Vou comprimir ainda mais as imagens"* / *"compress further"* → NO. Image compression was decided at Step 0 (image strategy) or at the §7(f) edge case. Re-compressing at conversion time means the render PNG differs from the approved preview.
- *"Vou inventar uma URL CDN pra essa imagem"* → ABSOLUTELY NO. Fabricated paths cause the avatar-empty bug. Run `media-memory.md` §8.2 to upload the asset and get the real URL.
- *"Vou pular o slide N pra caber"* → NO. The user approved every slide. If size is the problem, fix upstream (image swap, font swap) — never drop slides silently.
- *"Vou trocar a engine de render pra wkhtmltoimage / weasyprint / outra"* → NO. `smart-rendering.md` §1.1 is a hard rule: Path B is Playwright + Chromium or it's not Path B; fallback to Path A is the only correct alternative.

The §5.1 step-by-step below is **mechanical**. Execute the decisions above without re-evaluating them.

---

### 5.1 Preview shape → Render shape conversion

The preview is **one aggregated document** with all slides scaled to 540×675. The render expects **per-slide independent HTML documents** at full 1080×1350. The agent does this mechanical conversion at hand-off:

```
For each <section class="slide-N"> in the preview master:

1. Take the inner content (everything inside `.slide-N > .inner`) WITHOUT
   the scale transform — Puppeteer renders at full 1080×1350.

2. Build an independent <!doctype html>...</html> document for the slide:
   a. New <head> with font delivery (step 3) + per-slide scoped CSS
      — keep the `.slide-N` class on body/wrapper so selectors still match
   b. <body> with the slide's content at full 1080×1350

3. Font delivery swap — PREFERRED: Google Fonts <link>
   Replace preview's base64 @font-face declarations with a Google Fonts
   <link> in <head>:

     <link rel="preconnect" href="https://fonts.googleapis.com">
     <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
     <link rel="stylesheet"
       href="https://fonts.googleapis.com/css2?family=Anton&family=Inter:wght@500;700&display=block">

   The backend Puppeteer waits for `document.fonts.ready` after
   `networkidle0` before screenshotting — fonts always arrive.

   FALLBACK to base64 @font-face when:
   - The font isn't on Google Fonts (e.g. brand-custom face)
   - The agent already has base64 in hand and the carousel total HTML
     is comfortably small (rare since we just dropped most of it)
   Keep the fallback's `font-display: block` (see step 4).

4. font-display swap → block (any @font-face that remains)
   - Preview: `swap` — text appears immediately with fallback if data:
     URI fonts blocked by artifact CSP
   - Render: `block` — Puppeteer waits for the font before capturing.
     Network fetches in Puppeteer have no CSP, so external font fetches
     succeed; we want crisp typography, not fallback.

5. Image source swap — CRITICAL (eliminates the Path A token-budget bug)
   For each <img src="..."> and background-image: url(...) in the slide:
   - If the agent has ANY public URL for the image — Postzee CDN
     (POSTZEE_GENERATE_IMAGE output, POSTZEE_UPLOAD_MEDIA result),
     user-provided external URL (the link the user pasted in the brief),
     or any URL the agent successfully WebFetch'd to inline as base64
     for the preview — REPLACE the base64 data: URI with that URL.
   - If the image only exists as inline base64 the user pasted directly
     (no URL ever existed): KEEP base64.

   The backend Puppeteer's URL allowlist (`isUrlAllowed` in
   `canvas/src/services/html-render.service.ts:153-193`) is permissive
   — it only blocks loopback / cloud-metadata IPs. Any public http(s)
   URL passes. The agent doesn't need to verify the URL works during
   render — Puppeteer fetches it server-side.

   Why: the artifact preview NEEDS base64 (CSP blocks externals), but
   the render Puppeteer has no CSP. A 120KB base64 cover becomes a
   ~50-char URL. Saves ~30K output tokens per image per slide. See
   `carousel-mastery.md` §11.4 for the full token-budget breakdown.

6. Submit the N HTML strings as `slides: [{ html, width: 1080, height: 1350 }, ...]`.
```

**Worked example** — a 9-slide carousel with the cover repeated on every slide and 4 font weights:

| | Naive (no swaps) | After swaps |
|---|---|---|
| Per-slide HTML size | ~270 KB (150 KB fonts + 120 KB cover) | ~10 KB (link + URL ref) |
| Total tool-call payload | ~2.4 MB | ~90 KB |
| Output tokens needed | ~600 K (impossible) | ~22 K (comfortable) |

**Source of truth is the content + design system**, not the literal HTML envelope. The agent treats preview and render as two emissions of the same underlying carousel definition. Each emission gets the asset-delivery mode appropriate for its surface — that's why the two shapes diverge on image/font source AND on `font-display` AND on aggregated-vs-per-slide structure.

**Partial approval ("o slide 4 ainda tá fraco, ajusta")** is NOT a visual approval. Stay in 7a, iterate.

**Non-committal ("hmm tá bom")** is NOT an approval either. Ask once: "Posso renderizar?" If the user confirms, advance. Otherwise stay in 7a.

---

## 6. Graceful degradation for surfaces without artifact rendering

Some surfaces don't render Claude artifacts visually (Claude Code, hermes, custom MCP clients). In those cases, the agent falls back to a textual variant of stage 7a:

```
1. Tell the user (in their language):
   "Preview HTML pronto — copia o bloco abaixo num arquivo
   `carousel-preview.html` e abre no seu navegador pra ver visualmente.
   Os comandos de iteração funcionam normalmente daqui."

2. Output the complete preview HTML (single aggregated document, see §2)
   inside a fenced ```html ... ``` block. The user can copy-paste once.

3. Below the block, output a textual slide-by-slide summary so the user
   can iterate even without opening the file:
       Slide 1 (capa): "<headline>"
       Slide 2: "<block 2 short summary>"
       ...
       Slide N (CTA): "<CTA phrasing>"

4. Iteration commands work exactly the same — when the user says
   "muda fundo do slide 3 pra preto", edit the master HTML, re-output
   the full HTML block and the summary. The user opens the new file
   (or refreshes the browser tab pointed at it) to see the change.

5. Visual approval triggers 7b identically.
```

**Detecting the surface:** in practice, the agent doesn't need to detect — output the artifact format always. Surfaces that render artifacts will show them. Surfaces that don't will fall back to showing the HTML text inline. The fallback summary is what bridges the two — surface it whenever the artifact output happens, and any client can work with it.

---

## 7. Edge cases

**(a) User wants to add 5 more slides during 7a.** Generate new HTML, splice into the master, re-output the artifact. The 50MB total payload cap is enforced server-side at 7b; if the carousel grows enough during 7a to exceed 50MB, warn the user at the size threshold (e.g. 45MB) so they can compress images before approval.

**(b) Stage 7a session is interrupted (long pause, new tab, etc.).** The master HTML lives in the agent's working context. If the context is lost, the carousel is lost — there is no server-side persistence of 7a state. Treat 7a as ephemeral: encourage approval flow within the session.

**(c) User pastes a competitor's carousel as inspiration mid-7a.** That's a brief revision, not an iteration. Either restart stage 4 (script) with the new direction, or layer the new direction onto the current visual ("inspirado nesse, mas com nosso brand"). Don't try to compose mid-7a.

**(d) Two images, one very large, one small.** Apply the per-image fallback independently — slide 3 can show a placeholder (image too large) while slide 5 shows the real photo. The user knows from the warning which slide is degraded.

**(e) Image is animated (GIF/WebP animation).** Carousels render to static PNG. The agent embeds the first frame as a static image and warns the user: "Carrosséis renderizam estáticos — usei o primeiro frame da animação no slide N."

**(f) Artifact total size approaches the surface rendering limit.** Claude artifacts have a size ceiling that varies by surface — typically ~5MB for Claude Desktop, similar for Claude Web. A 9-slide carousel with full-bleed images at JPEG q85 can sit around 6-9MB total, which can fail to render or get truncated in the artifact pane.

Watch the cumulative artifact size as you build it (sum of all slide content + inlined fonts + the wrapper). If the cumulative size approaches 5MB, choose ONE of these strategies (do not mix):

**Baseline reminder**: after the §5.1 swaps (image base64 → URL when available; fonts base64 → Google Fonts `<link>`), the **render shape** is already ~10 KB/slide and never the binding constraint. Edge case (f) is exclusively about the **preview shape** exceeding the artifact pane's render budget. Two responses:

**Strategy A — Compress aggressively (preview only):** drop image quality across the board until the preview fits. Try JPEG q70, then q55, then resize to 1620px (75% of max dimension). The compressed bytes go into the preview shape only. The render shape uses the original CDN URL via §5.1 step 5, so quality at render isn't affected. Tell the user: "Comprimi as imagens só pro preview caber. O render no Postzee usa as originais em qualidade cheia."

**Strategy B — Upload-first to get a URL:** if the only reason an image lacks a URL is that the user pasted raw bytes / a data: URI, the agent can call `POSTZEE_UPLOAD_MEDIA` BEFORE building the preview. That gives a Postzee CDN URL the agent uses in render via §5.1 step 5. The preview can still use compressed base64 (Strategy A) for pane fit. Tell the user: "Subi a imagem do slide N pro Postzee primeiro — ganhei a URL e o preview ficou leve."

The two strategies are complementary, not alternatives. Strategy A keeps the preview viewable; Strategy B widens the image-swap rule's coverage. Apply both when needed. The single failure mode to avoid is shipping the render with worse-than-necessary image bytes — if you compressed for preview, make sure the render still references the original URL.

---

## 8. What stage 7a is NOT

- **Not a server render.** Zero `POSTZEE_*` tool calls during 7a (except the optional `POSTZEE_GET_CONTEXT` immediately before transitioning to 7b).
- **Not the place to validate editorial quality.** The 5 final tests and 7-parameter scoring already passed in stage 5. 7a is about visual polish — color, hierarchy, image placement.
- **Not for adding new content blocks.** If the user wants new content ("preciso de mais um dado nesse slide"), that's a stage 4 revision — go back, update the script, re-approve, regenerate the artifact.
- **Not where the user types `aprovado`.** Stage 6 covers text approval; "aprovado" there moves to 7a. Inside 7a, approval needs a visual-flavored phrase (`renderiza` / `ship it`) to advance to 7b. This avoids ambiguity — the user always knows which gate they're at.

---

## 9. Quick reference

| | Stage 7a | Stage 7b |
|---|---|---|
| Postzee tool calls | NONE | `POSTZEE_RENDER_CAROUSEL` (one call) |
| Iteration cost | free, instant | each `REPLACE` = credits + queue time |
| Source of truth | content + design system (preview shape: aggregated, scaled, base64 images, base64 @font-face, `font-display: swap`) | same content + design system (render shape: per-slide, full 1080×1350, CDN URLs for images when available, Google Fonts `<link>` for fonts when available, `font-display: block`) — converted via §5.1 |
| User signals advance via | `renderiza` / `ship it` / `aprovado` | post-render: gallery card, ready to publish |
| Failure recovery | edit HTML, re-output artifact | surface raw error, ask user (SKILL.md §8.5.C) |
