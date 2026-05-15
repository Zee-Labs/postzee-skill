# Carousel Visual Preview (Stage 7a)

This file is the protocol for **stage 7a of the carousel workflow** — the visual preview the user iterates on before any Postzee credit is spent. Stage 7b (the actual `POSTZEE_RENDER_CAROUSEL` call) is covered in `carousel-mastery.md` §9.

> **Single HTML, two surfaces.** The exact same slide HTML you output as a Claude artifact for preview is what you later send to `POSTZEE_RENDER_CAROUSEL` for the real render. Zero divergence between what the user approved and what gets shipped.

---

## 1. Why this stage exists

Before v3.6, stage 7 went straight from "user approved the script text" to "call `POSTZEE_RENDER_CAROUSEL`" — and any visual tweak after that ("muda cor de fundo do slide 3 pra preto") required a fresh `REPLACE_CAROUSEL_SLIDE` call, which costs credits and queues another Puppeteer render. A user iterating 4 times on the visuals would burn 4 server renders + minutes of latency for changes they could have seen in their browser instantly.

Stage 7a moves that iteration loop into the Claude artifact. The user sees the full carousel, requests changes verbally, the agent edits the HTML and re-outputs the artifact. **No Postzee call.** When the visual is final, one `POSTZEE_RENDER_CAROUSEL` ships everything atomically.

Result: iteration in 7a is free and instant; the render in 7b happens exactly once.

---

## 2. The artifact structure

The artifact is a single self-contained HTML document that displays all N slides stacked vertically. Each slide is wrapped in an `<iframe srcdoc>` so its CSS is isolated from the wrapper and from sibling slides — what you see in the preview is pixel-equivalent to what the server-side Puppeteer will produce.

```html
<!doctype html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <style>
    body {
      background: #111;
      padding: 24px;
      font-family: system-ui, -apple-system, sans-serif;
      color: #999;
      margin: 0;
    }
    .carousel {
      display: grid;
      gap: 32px;
      grid-template-columns: 1fr;
      max-width: 600px;
      margin: 0 auto;
    }
    .slide {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }
    .label {
      font-size: 13px;
      letter-spacing: 0.04em;
      text-transform: uppercase;
    }
    .frame {
      width: 540px;
      height: 675px;
      border: 0;
      border-radius: 12px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.4);
      display: block;
    }
  </style>
</head>
<body>
  <div class="carousel">
    <div class="slide">
      <div class="label">Slide 1 / 9 — Capa</div>
      <iframe class="frame" srcdoc='&lt;!doctype html&gt;... full slide 1 HTML with base64 images ...'></iframe>
    </div>
    <div class="slide">
      <div class="label">Slide 2 / 9</div>
      <iframe class="frame" srcdoc='&lt;!doctype html&gt;... full slide 2 HTML ...'></iframe>
    </div>
    <!-- ... slides 3-9 ... -->
  </div>
</body>
</html>
```

**Layout rationale:**
- **Single column, 540×675** (50% of the real 1080×1350): fits comfortably in Claude's artifact pane on most viewports; user scrolls vertically to see all slides at once.
- **`srcdoc` instead of `src`**: each slide is fully self-contained HTML — no cross-frame asset fetching, no CSP issues, no load order dependency.
- **HTML-entity-encoded srcdoc content**: `<` → `&lt;`, `"` → `&quot;`. The agent must escape the inner slide HTML correctly when interpolating into the wrapper.

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
| "tá ótimo, renderiza" / "ship it" / "approved" | **Exit 7a, enter 7b.** Call `POSTZEE_RENDER_CAROUSEL` with the final HTML. |

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
2. Extract each slide's HTML from the master (the same HTML strings used
   inside the iframe srcdoc wrappers — strip the wrapper, keep the inner
   <!doctype html>...</html> for each slide).
3. POSTZEE_RENDER_CAROUSEL({
     slides: [{ html, width: 1080, height: 1350 }, ...],
     aspectRatio: "4:5",
     name: "<short, derived from the brief — what would the agent call this carousel?>"
   })
4. Save the returned mediaGroupId.
5. Confirm to the user: "Renderizado! N slides prontos no Postzee."
6. Offer the publish step (POSTZEE_CREATE_POST), if applicable.
```

The exact same HTML the user saw in the artifact is what gets rendered. Pixel fidelity by construction.

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

2. Output the complete preview HTML (the artifact wrapper + iframe srcdocs)
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

Watch the cumulative artifact size as you build it (sum of all `srcdoc` payloads + the wrapper). If the cumulative size approaches 5MB, choose ONE of these strategies (do not mix):

**Strategy A — Compress aggressively, single HTML preserved:** drop image quality across the board until everything fits. Try JPEG q70, then q55, then resize to 1620px (75% of max dimension). The compressed base64 stays in the HTML — the same HTML that gets sent to RENDER. **Trade-off**: render quality matches the compressed preview (which is fine — user sees what they get). Tell the user: "Comprimi as imagens pra caber no preview da artifact. O render final usa essa mesma compressão."

**Strategy B — CDN-URL fallback for heaviest slides, render keeps full quality:** for the 1-2 heaviest image slides, swap the base64 data URI for the original CDN URL inside the slide HTML. **Same HTML for both preview and render** — but: the artifact preview shows a placeholder for those slides (Claude CSP blocks the CDN fetch), while Postzee's server-side Puppeteer fetches the URL at full quality during render. Tell the user: "Slides X e Y vão aparecer com placeholder no preview (imagens grandes demais pra embutir), mas o render no Postzee puxa as imagens originais e fica na qualidade cheia."

Pick the strategy that fits the user's intent: if quality matters most, go B and accept the preview-fidelity gap on a couple of slides; if preview-fidelity matters most, go A and accept the compression at render. **Don't mix** — that recreates the dual-HTML source-of-truth problem the single-HTML architecture was designed to avoid.

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
| Source of truth | master HTML in agent's working context | same master HTML — submitted to backend |
| User signals advance via | `renderiza` / `ship it` / `aprovado` | post-render: gallery card, ready to publish |
| Failure recovery | edit HTML, re-output artifact | surface raw error, ask user (SKILL.md §8.5.C) |
