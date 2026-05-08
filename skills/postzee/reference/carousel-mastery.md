# Carousel Mastery — HTML Render Edition

Skill v3.4+ uses a single carousel pipeline: **you compose HTML, Postzee renders to PNG.** This file has two roles:

1. **The design system** you draw from when crafting HTML (§5-§8 below).
2. **The workflow playbook** for everything that happens *around* the rendering — the script you write before generating, the strategic positioning when there's a competitor, the iteration tools when the user asks for changes (§A-§E below).

The mandatory 6-phase workflow lives in SKILL.md §8.0. Don't skip it. Below are the artifacts each phase produces.

---

## 0. Why HTML render

| Old way (deprecated) | New way (Skill v3.4) |
|---|---|
| Generate slide images via `POSTZEE_GENERATE_IMAGE` and hope the AI model renders text correctly | Author HTML + CSS for each slide; Postzee renders pixel-perfect PNGs via headless Chrome |
| Each slide a separate Media → manual ordering, easy to lose | One MediaGroup with `orderInGroup` baked in by Postzee — order is **structural, not temporal** |
| Inconsistent fonts/colors across slides | Same CSS = same look, every slide |
| Up to ~30s per AI image × 10 slides | Typical 10-slide render: 5-30s total, parallel rendering |
| Cost = N image generations | Cost = compute, not generation (much cheaper for text-heavy slides) |

**Use `POSTZEE_GENERATE_IMAGE` only for** photo-realistic background images (Nano Banana). Composite them into HTML as `background-image: url(...)`.

---

## A. Script template — the Phase 2 deliverable

Phase 2 produces a structured plan the user reviews. Keep it tight; don't over-explain. Adapt the labels to the user's language but keep the structure.

```
🎯 Strategic angle (1-2 sentences)
   Why this carousel beats alternatives. If there's a competitor reference,
   name the gap you're attacking.

🧠 Framework — <name>
   1-line justification (which framework from §3 and why it fits this topic).

📜 Roadmap (10 slides)

   SLIDE 1 — Hook
   Copy:    "<the actual on-slide text>"
   Visual:  "<typography size, layout, color block, any image needed>"

   SLIDE 2 — <label, e.g. "Acknowledge the news">
   Copy:    "<…>"
   Visual:  "<…>"

   ... slides 3-9 ...

   SLIDE 10 — CTA
   Copy:    "<verb-first command + brand handle>"
   Visual:  "<…>"

🪝 Hook variants for slide 1 (pick one to lock)
   1. <variant>
   2. <variant>
   3. <variant>

✍️ Caption variants for the post body (pick one to lock)

   Variant A — Contrarian (sharper, more aggressive opening)
   <120-180 word caption with hook in first 125 chars>

   Variant B — Story-driven (lighter, narrative)
   <120-180 word caption>

   Variant C — Direct (punchy, no fluff)
   <60-100 word caption>

   Hashtags (3-5, niche-relevant, never spam):
   #example #example #example

🎨 Visual decisions to lock
   1. Hook variant (1, 2 or 3)?
   2. Caption variant (A, B, C)?
   3. Brand color confirmed? Logo URL? <or — if no kit — propose 2-3 palettes>

✅ Once you confirm those 3, I render the 10 slides.
```

This is the artifact, not a checklist. Fill it for real, then send to the user. If the user is silent or signs off briefly, advance to Phase 4. If they push back, edit the SCRIPT — never the renders.

---

## B. Competitor analysis (when user pasted a reference)

When the user pastes a competitor post or article, Phase 1 expands. Don't just copy their angle. Position differentiated.

Template:

```
📰 What the reference does well
   - <specificity numérica? framing? narrative?>
   - <…>
   - <…>

🕳 The gap (where they fall short)
   <The single sentence that defines our angle. The narrower, the better.>

🎯 Our position
   <How we frame Postzee differently. NOT "we also do X." Always "the next
   move that they didn't make.">

🔥 The angle for the carousel
   <One sentence the carousel will earn over 10 slides.>
```

Real example (the post about Higgsfield connecting 30 models to Claude):

```
📰 What it does well
   - Specificity (30 models, 4K, named: Sora 2, Kling, Flux, Veo)
   - "Structural change" framing — emotional weight
   - Before/after narrative

🕳 The gap
   It only solves *generation*. The real creative flow is: brief → script →
   generate → adapt → caption → schedule → publish to N networks.
   Generation is one step.

🎯 Our position
   Generation is becoming commodity. The next move is the *whole flow*
   collapsed into a single conversation — including publishing.

🔥 The angle
   "Generation in Claude went mainstream this week.
   The bigger move — distribution inside Claude — nobody's covering."
```

The angle becomes the slide-1 hook. The reveal slide names Postzee. The closer is the meta-proof (§D).

---

## C. Caption variants — write all three, every time

Don't ask the user "what tone?". Write three real variants and let them pick. The exercise sharpens the copy.

| Variant | Voice | When to recommend |
|---|---|---|
| **A — Contrarian** | Disagree with the prevailing take. Hard hook in first sentence. Builds tension before the reveal. | Topic is debate-able / has a popular but flawed framing. Best for LinkedIn / X. |
| **B — Story-driven** | "Last week I…", "I was about to…". Personal, narrative, lower-stakes. | Lifestyle / process content. Reels-friendly. Best for IG. |
| **C — Direct** | Short, punchy, almost zero adjectives. 60-100 words max. | Crowded feeds. When the carousel image already carries 80% of the punch. |

Length:
- **IG**: 120-180 words. Hook in the first 125 chars (the visible part before "...mais").
- **LinkedIn**: 200-350 words. Generous line breaks (3-line paragraphs).
- **TikTok / X**: 60-150 words. Punch first, no warm-up.

Hashtags: **3-5**, niche-relevant. More than 5 is a 2026 spam signal on LinkedIn and IG.

Every caption ends with one of these:
- A save CTA ("Salva esse post.")
- A comment-trigger CTA ("Comenta WORD que mando o link.")
- An arrow indicator ("Arrasta ⤵") for Phase 1 of the post

---

## D. Meta-proof — the recursive sales pitch

When the carousel is *about* AI / no-code / creative tools, slide 8 or 9 can be the meta-proof:

> "This carousel — script, illustrations, copy, caption, hashtags, scheduling — was made inside a single Claude conversation using Postzee. You're seeing the proof happen."

It only works when:
- The topic is creative / AI / marketing tooling
- The carousel actually *was* made with Postzee end-to-end (it will be, if you're doing your job)
- The user's audience cares about HOW the work was made

Don't force it on every carousel. When it fits, it's the strongest single slide.

---

## E. Iteration playbook — APPEND, REPLACE, REBUILD

Skill v3.4.2+ ships THREE carousel tools. Knowing which one to use is the difference between a clean carousel and a polluted gallery.

```
                          ┌─────────────────────────────────┐
User wants slide-by-slide │ Phase 4-B (iterative path):     │
preview while building?   │  RENDER once with [slide1]      │
─────────────────────►    │  then APPEND for each next      │
                          └─────────────────────────────────┘

                          ┌─────────────────────────────────┐
User wants to change      │ POSTZEE_REPLACE_CAROUSEL_SLIDE  │
an existing slide?        │  same orderInGroup, new content │
─────────────────────►    └─────────────────────────────────┘

                          ┌─────────────────────────────────┐
User wants to add a       │ POSTZEE_APPEND_CAROUSEL_SLIDE   │
slide AT THE END?         │  next orderInGroup, atomic       │
─────────────────────►    └─────────────────────────────────┘

                          ┌─────────────────────────────────┐
User wants to insert in   │ Rebuild via POSTZEE_RENDER_     │
the middle, reorder, or   │ CAROUSEL with the new sequence  │
delete a slide?           │ (no insert/reorder primitive)   │
─────────────────────►    └─────────────────────────────────┘
```

### REPLACE — change existing slide

**Trigger phrases:**
- "Change slide 4."
- "The hook is too soft, make it sharper."
- "Swap slide 7's background for the green one we generated earlier."
- "The CTA slide should mention our handle."

```ts
POSTZEE_REPLACE_CAROUSEL_SLIDE({
  mediaGroupId: "<from your scrollback — the ID from POSTZEE_RENDER_CAROUSEL>",
  orderInGroup: 3,                  // zero-based — slide 4 → 3
  slide: { html: "<!doctype html>...new slide HTML...", width: 1080, height: 1350 }
})
```

**Workflow:**
1. **Recall** the existing HTML for that slide from your scrollback. You authored it; you have it.
2. **Apply** the user's instruction to that one slide. Don't rewrite the others.
3. **Call** the tool. It returns the full updated `mediaUrls` array.
4. **Confirm** in one line ("Slide 4 atualizado. Os outros 9 estão intactos.").

### APPEND — add a slide at the end

**Trigger phrases:**
- "agora faça o slide N+1"
- "ok, próximo"
- "vamos para o slide 7"
- (general iterative authoring after the first RENDER)

```ts
POSTZEE_APPEND_CAROUSEL_SLIDE({
  mediaGroupId: "<from the first POSTZEE_RENDER_CAROUSEL response>",
  slide: { html: "<!doctype html>...", width: 1080, height: 1350 }
})
```

The next `orderInGroup` is computed server-side from the current live-media count. Caps at MAX_SLIDES (15) — refuses if already at the limit.

### REBUILD — structural change

**Trigger phrases:**
- "insere um slide entre o 4 e o 5"
- "troca o slide 3 com o 7"
- "remove o slide 5"

There's no insert/reorder/delete primitive in v1.

1. Confirm with the user that this requires a full rebuild.
2. Update the script in your scrollback with the structural change.
3. Call `POSTZEE_RENDER_CAROUSEL` with the new sequence. The old MediaGroup remains in history (user can soft-delete via gallery if they want).

### Edge cases

| Scenario | Response |
|---|---|
| User wants to change >3 slides | Rebuild is faster than 3+ REPLACE calls. Suggest rebuild. |
| User attached carousel to a draft post, then wants REPLACE/APPEND | Tool works, but draft still references the previous `mediaUrls`. Tell them to refresh the attachments — or you do it for them by re-issuing `POSTZEE_CREATE_POST`. |
| User keeps adding slides past 15 | APPEND returns error `Carousel is already at the 15-slide limit`. Politely refuse, explain Instagram allows up to 20 but Postzee caps at 15 for render reliability. Suggest split into a "Part 2" carousel. |
| First slide was rendered with RENDER, but user now says "ok, faça os outros 9 todos juntos" | Use APPEND **per slide** (9 calls). Do NOT call RENDER again — that creates a second carousel. |

### Why this matters

Every carousel that gets fragmented into multiple MediaGroups is gallery clutter the user has to clean up. The tools are there to keep ONE carousel = ONE MediaGroup, regardless of how many iterations the user wants.

---

## 1. The single tool

```ts
POSTZEE_RENDER_CAROUSEL({
  slides: [
    { html: "<!doctype html>...", width: 1080, height: 1350 },
    { html: "<!doctype html>...", width: 1080, height: 1350 },
    // ...
  ],
  aspectRatio: "4:5",
  name: "10 erros que matam um pitch"
})
```

**Hard limits:**
- 1-15 slides per call
- 256-2160 px per dimension
- 250 KB max HTML per slide
- 45 s timeout per slide
- All-or-nothing: any failure rolls back the whole carousel

**Returned:**
```json
{ "success": true, "mediaGroupId": "uuid", "totalSlides": 10,
  "mediaUrls": ["https://cdn.../slide-0.png", ..., "https://cdn.../slide-9.png"] }
```

`mediaUrls` is already in display order — feed it directly into `POSTZEE_CREATE_POST`.

---

## 2. Brief — 4 questions you ALWAYS ask first

Don't generate without these answers. Skip = generic, off-brand carousel.

1. **Topic in one sentence.** Forces clarity. ("10 mistakes new founders make in fundraising.")
2. **Audience.** Who reads this? B2B SaaS founders? Beauty creators? Determines tone, references, vocabulary.
3. **Platform.** Instagram (4:5 1080×1350), Stories/Reels (9:16 1080×1920), LinkedIn (1:1 1080×1080), TikTok photo mode (9:16). Different specs, different reading patterns.
4. **Brand colors + logo.** Always ask — never assume. Acceptable answers:
   - "Primary `#6C5CE7`, secondary `#E84393`, logo at https://..."
   - "I have no brand kit — pick something for me." (Then you propose 2-3 palettes and let user choose.)

If user has no logo: skip the logo step. If user has one: see §6 (Logo enhancement).

---

## 3. Frameworks (pick one before composing)

| User content | Framework | Sweet spot |
|---|---|---|
| Educational / list | Listicle | 7-10 slides |
| Tutorial | Step-by-step | 5-8 slides |
| Transformation | Before/After (BAB) | 5-7 slides |
| Disruptive | Mythbusting | 6-9 slides |
| Personal narrative | Story arc | 7-10 slides |
| Buying decision | Comparison | 5-8 slides |
| Cautionary | Mistakes | 7-12 slides |
| Quick wins | Hacks/Tips | 7-10 slides |
| Inspirational | Quote + commentary | 4-6 slides |
| Authenticity | Behind-the-scenes | 5-8 slides |

---

## 4. Anatomy of a high-performing carousel

```
┌────────────────────────────────────────────────────────────────┐
│ SLIDE 1 — HOOK (50% of success)                                │
│ Massive text (60-100pt), bold claim/number/question, high      │
│ contrast. Reader must understand the value in <1 second.       │
├────────────────────────────────────────────────────────────────┤
│ SLIDES 2…N-1 — VALUE                                           │
│ One idea per slide. Big number/word + supporting line.         │
│ Same palette/typography/grid throughout.                       │
├────────────────────────────────────────────────────────────────┤
│ SLIDE N-1 (optional) — TL;DR / RECAP                           │
│ List or summary card. Increases save rate.                     │
├────────────────────────────────────────────────────────────────┤
│ SLIDE N — CTA                                                  │
│ Specific action verb + brand handle. "Save this." "Comment X." │
└────────────────────────────────────────────────────────────────┘
```

---

## 5. Design system — defaults that just work

These are the defaults to use unless the user asks otherwise. Variations welcome — the HTML is yours — but start here.

### 5.1 Canvas

| Aspect ratio | Width × Height | Use for |
|---|---|---|
| 4:5  | 1080×1350 | Instagram feed (best engagement zone) |
| 1:1  | 1080×1080 | LinkedIn, generic |
| 9:16 | 1080×1920 | Stories, Reels, TikTok photo mode |

### 5.2 Type scale (for 1080×1350)

| Role | Size | Weight | Color (light bg) | Color (dark bg) |
|---|---|---|---|---|
| Slide-1 hook | 80-110 px | 900 | `#0F172A` | `#FFFFFF` |
| Card title | 56-72 px | 800 | `#0F172A` | `#FFFFFF` |
| Body / explanation | 28-36 px | 500 | `#475569` | `rgba(255,255,255,0.85)` |
| Caption / label | 18-22 px | 600 | brand-primary | brand-primary |
| Footer / handle | 16-20 px | 500 | `#94A3B8` | `rgba(255,255,255,0.65)` |

Letter-spacing: `-0.02em` for hooks/titles, `0` for body, `0.04em` uppercase for labels.

### 5.3 Spacing

Outer padding: **80-100px**. Generous whitespace beats decoration.

Vertical rhythm: 24px small, 40px medium, 80px section break.

### 5.4 Fonts (Google Fonts CDN — load only what you use)

**Sans (default):** Inter (300, 500, 700, 800, 900) — neutral, premium.
**Display alternatives:** Plus Jakarta Sans, Sora, Manrope (modern), Playfair Display (editorial), Bebas Neue (bold display).
**Serif (warmth/luxury):** Lora, Crimson Text, EB Garamond.
**Mono (code/dev content):** JetBrains Mono, Fira Code.

**Pairing rule:** one display + one body (or just one). Never 3 fonts in a carousel.

### 5.5 Color palettes (when user has no preference)

| Vibe | Primary | Secondary | Bg | Text |
|---|---|---|---|---|
| Modern SaaS | `#6366F1` | `#A855F7` | `#0F172A` | `#FFFFFF` |
| Soft pastel | `#F472B6` | `#FCD34D` | `#FEF3C7` | `#1F2937` |
| Premium dark | `#FBBF24` | `#F59E0B` | `#0A0A0A` | `#FFFFFF` |
| Editorial print | `#1F2937` | `#DC2626` | `#FAFAF9` | `#1F2937` |
| Bold gradient | `#FF006E` | `#8338EC` | gradient | `#FFFFFF` |
| Earthy / wellness | `#84CC16` | `#22D3EE` | `#FFFBEB` | `#1F2937` |

Always confirm with user before using.

---

## 6. Logo enhancement — circle, ring, drop-shadow

Most user logos are **square PNGs with transparent or unkind backgrounds**. Drop them raw and the carousel looks amateur. Apply this default treatment everywhere a logo appears (corner badge, header, sign-off):

```html
<div style="
  width: 96px; height: 96px;
  border-radius: 50%;
  overflow: hidden;
  background: #ffffff;
  border: 4px solid #ffffff;
  box-shadow:
    0 8px 24px rgba(0,0,0,0.18),
    0 0 0 1px rgba(0,0,0,0.04);
  display: flex; align-items: center; justify-content: center;
">
  <img src="USER_LOGO_URL"
       alt="Brand logo"
       crossorigin="anonymous"
       style="width: 100%; height: 100%; object-fit: cover;">
</div>
```

Why each line:
- **`border-radius: 50%`** — circular crop, like an Instagram profile pic. Hides square edges, instantly looks designed.
- **`overflow: hidden`** + **`object-fit: cover`** — no white gaps inside the circle, even if the logo isn't square.
- **`background: #ffffff`** behind the image — when the logo has transparent background, the circle stays a clean white disk on dark slides.
- **`border: 4px solid #fff`** + **`box-shadow`** — separates the badge from any background, keeps it readable on busy hero images.
- **`crossorigin="anonymous"`** — required so Puppeteer can load it without CORS errors when the user logo lives on a different CDN.

**Variations** (pick by context):
- **On dark hero**: keep white background. Strong separation.
- **On light card**: drop the white border, keep just the shadow. Soft and tactile.
- **As a corner sign-off**: 64-72px instead of 96. Position bottom-right, 32px from edges.
- **As big hero brand mark**: 200-260px, no border, light shadow only.

If the user's logo is wordmark-style (long, not square): drop the circle and use the wordmark inline at sensible height (40-56px), letting the wordmark's own shape be the brand.

---

## 7. Slide HTML — the spine

Every slide is a complete `<!doctype html>` document. JavaScript is **disabled at render** — anything dynamic must be CSS. Here's the spine:

```html
<!doctype html>
<html>
<head>
  <meta charset="UTF-8">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@500;700;800;900&display=swap" rel="stylesheet">
  <style>
    :root {
      --brand-primary: #6366F1;
      --brand-secondary: #A855F7;
      --brand-text: #FFFFFF;
      --brand-bg: #0F172A;
    }
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 1080px; height: 1350px; overflow: hidden; }
    body { font-family: 'Inter', sans-serif; color: var(--brand-text); background: var(--brand-bg); }
  </style>
</head>
<body>
  <!-- slide content -->
</body>
</html>
```

**Tailwind CDN note**: it can work, but Tailwind runs at *runtime via JS* and JS is disabled in the renderer. Use **inline `style`** attributes or a `<style>` block with regular CSS. Do not rely on Tailwind utility classes for production-grade slides.

---

## 8. Layout patterns — copy & adapt

### 8.1 Hook slide (slide 1)

```html
<div style="
  width:1080px;height:1350px;
  display:flex;flex-direction:column;justify-content:flex-end;
  padding:100px;
  background:linear-gradient(180deg,#0F172A 0%,#312E81 100%);
">
  <div style="font-size:24px;letter-spacing:0.12em;text-transform:uppercase;
              color:var(--brand-primary);font-weight:700;margin-bottom:32px;">
    GUIA RÁPIDO · INSTAGRAM 2026
  </div>
  <div style="font-size:96px;font-weight:900;line-height:1.05;
              letter-spacing:-0.025em;color:#fff;">
    10 erros<br>que matam<br>seu engajamento
  </div>
  <div style="font-size:28px;color:rgba(255,255,255,0.7);
              margin-top:40px;font-weight:500;line-height:1.4;max-width:80%;">
    O #4 é o mais sutil — e o que mais aparece em contas que estagnam.
  </div>
</div>
```

### 8.2 Numbered card (slides 2-N)

```html
<div style="
  width:1080px;height:1350px;
  display:flex;flex-direction:column;justify-content:center;
  padding:120px;
  background:#FAFAF9;color:#0F172A;
">
  <div style="font-size:240px;font-weight:900;line-height:1;
              color:var(--brand-primary);letter-spacing:-0.04em;">
    04
  </div>
  <div style="font-size:64px;font-weight:800;line-height:1.1;
              margin-top:24px;letter-spacing:-0.02em;">
    Postar sem<br>variar formato
  </div>
  <div style="font-size:28px;color:#475569;margin-top:32px;
              line-height:1.5;font-weight:500;max-width:85%;">
    O algoritmo recompensa diversidade. Alterne carrossel, reel e foto na mesma semana — não escolha uma só.
  </div>
</div>
```

### 8.3 Quote slide

```html
<div style="
  width:1080px;height:1350px;
  display:flex;flex-direction:column;justify-content:center;align-items:center;
  padding:120px 100px;text-align:center;
  background:linear-gradient(135deg,#F472B6,#FCD34D);color:#1F2937;
">
  <div style="font-family:'Playfair Display',serif;font-size:140px;
              line-height:0.5;opacity:0.4;margin-bottom:40px;">
    "
  </div>
  <div style="font-family:'Playfair Display',serif;font-size:52px;
              line-height:1.3;font-weight:600;font-style:italic;max-width:85%;">
    A consistência derrota o talento quando o talento não é consistente.
  </div>
  <div style="font-size:20px;letter-spacing:0.16em;text-transform:uppercase;
              margin-top:48px;font-weight:700;">
    @yourbrand
  </div>
</div>
```

### 8.4 CTA slide (last)

```html
<div style="
  width:1080px;height:1350px;
  display:flex;flex-direction:column;justify-content:space-between;
  padding:100px;
  background:#0F172A;color:#fff;
">
  <div>
    <div style="font-size:32px;letter-spacing:0.1em;text-transform:uppercase;
                color:var(--brand-primary);font-weight:700;">
      Próximo passo
    </div>
    <div style="font-size:88px;font-weight:900;line-height:1.05;
                margin-top:32px;letter-spacing:-0.025em;">
      Salva este post<br>antes do próximo<br>algoritmo<br>te trair.
    </div>
  </div>
  <div style="display:flex;align-items:center;gap:24px;">
    <!-- ↓↓ Logo treatment from §6 ↓↓ -->
    <div style="width:88px;height:88px;border-radius:50%;overflow:hidden;
                background:#fff;border:4px solid #fff;
                box-shadow:0 8px 24px rgba(0,0,0,0.3);
                display:flex;align-items:center;justify-content:center;">
      <img src="USER_LOGO_URL" crossorigin="anonymous"
           style="width:100%;height:100%;object-fit:cover;" alt="">
    </div>
    <div>
      <div style="font-size:28px;font-weight:800;">@yourbrand</div>
      <div style="font-size:18px;color:rgba(255,255,255,0.6);
                  font-weight:500;margin-top:4px;">
        yourbrand.com
      </div>
    </div>
  </div>
</div>
```

### 8.5 Background image + overlay (composed slide)

When you generated a Nano Banana background and want text over it:

```html
<div style="
  width:1080px;height:1350px;position:relative;overflow:hidden;
  font-family:'Inter',sans-serif;
">
  <img src="https://cdn.../nano-banana-bg.jpg" crossorigin="anonymous"
       style="position:absolute;inset:0;width:100%;height:100%;
              object-fit:cover;z-index:0;" alt="">
  <!-- legibility overlay -->
  <div style="position:absolute;inset:0;
              background:linear-gradient(180deg,rgba(0,0,0,0.1) 0%,rgba(0,0,0,0.7) 80%);
              z-index:1;"></div>
  <!-- content -->
  <div style="position:absolute;inset:0;display:flex;flex-direction:column;
              justify-content:flex-end;padding:100px;color:#fff;z-index:2;">
    <div style="font-size:80px;font-weight:900;line-height:1.1;
                letter-spacing:-0.02em;">
      Onde a história começa.
    </div>
    <div style="font-size:24px;color:rgba(255,255,255,0.8);
                margin-top:24px;font-weight:500;">
      Coffee Roasters · since 2019
    </div>
  </div>
</div>
```

**Always include `crossorigin="anonymous"`** on `<img>` tags — without it Puppeteer cannot capture the canvas if the image is on a different origin.

---

## 9. Order — never lost

When you call `POSTZEE_RENDER_CAROUSEL`, the array index = `orderInGroup` for each rendered slide. Postzee assigns `orderInGroup: 0…N-1` BEFORE any worker starts; your slides land in the gallery in submission order, not finish order.

What this means for you:
- **Always submit slides in display order.** Slide 1 → first array entry. Slide N → last.
- **Never** try to re-order after the fact. There's no API for it.
- The returned `mediaUrls` is already ordered. Pass it through unchanged to `POSTZEE_CREATE_POST`.

---

## 10. Quality checklist (run before posting)

- [ ] Slide 1 hook visible without zoom (≥ 60pt)
- [ ] All slides share the same palette + typography
- [ ] Numbers/labels consistent (slide 4 always says "04", not "4" then "Slide 4")
- [ ] CTA slide has a verb-first command + brand handle
- [ ] Aspect ratio matches platform spec (`POSTZEE_GET_CONTEXT.platformSpecs`)
- [ ] Logo, when present, has been visually upgraded (not raw)
- [ ] Caption hook in first 125 chars (IG) or 3 lines (LinkedIn)
- [ ] No `<script>` tags (would be ignored anyway, but signals you understand)
- [ ] No external HTTP fetches that could hit private/internal hosts (Postzee blocks them, but cleaner HTML = faster render)

---

## 11. Common mistakes — avoid

| Mistake | Fix |
|---|---|
| Tiny text on slide 1 | Bump to 80-110px. Reader is scrolling — they need 1 second of clarity |
| Different font per slide | Pick one display + one body across all slides |
| Raw square logo on every slide | Apply §6 treatment |
| Generating slides via `POSTZEE_GENERATE_IMAGE` because "the model has good text rendering" | No. AI image models still butcher text under load. Use `POSTZEE_RENDER_CAROUSEL` |
| Calling `POSTZEE_RENDER_CAROUSEL` once per slide and trying to assemble manually | The point of the tool is one call = one MediaGroup. Submit all slides at once |
| `<script>` inside the HTML | Inert. Use CSS instead |
| External URL pointing to a private/internal host | Blocked by Postzee SSRF guard. Use `POSTZEE_GENERATE_IMAGE` for backgrounds, then reference the returned R2 URL |

---

## 12. Captions

The carousel image is 60-70% of conversion. The caption is the rest.

- **Instagram**: hook in first 125 chars (the visible part before "...mais"). Use BAB or PAS framework. End with a save CTA.
- **LinkedIn**: long form welcome. AIDA structure, 3-line paragraphs, generous line breaks.
- **TikTok photo mode**: short, punchy, complement the image text — never duplicate.

See `reference/captions-frameworks.md` for templates.

---

## 13. Sample full call

```ts
const slides = [
  // Slide 1: hook
  {
    width: 1080, height: 1350,
    html: `<!doctype html><html><head>...</head>
      <body><div style="...hook layout...">10 erros...</div></body></html>`,
  },
  // Slide 2: card #1
  {
    width: 1080, height: 1350,
    html: `<!doctype html>...numbered card layout...`,
  },
  // ... slides 3-9 ...
  // Slide 10: CTA
  {
    width: 1080, height: 1350,
    html: `<!doctype html>...cta layout with logo treatment...`,
  },
];

const result = await POSTZEE_RENDER_CAROUSEL({
  slides,
  aspectRatio: "4:5",
  name: "10 erros que matam o engajamento — IG 2026",
});

if (!result.success) {
  // Surface the error to the user, suggest retry / simplification
  return;
}

await POSTZEE_CREATE_POST({
  type: "schedule",
  date: "2026-05-08T14:00:00Z",
  channelId: "<from POSTZEE_LIST_CHANNELS>",
  text: "<caption with hook in first 125 chars>",
  mediaUrls: result.mediaUrls, // already in order
});
```
