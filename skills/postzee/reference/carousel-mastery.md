# Carousel Mastery — The Editorial Carousel System

This is the **central reference** for the carousel pipeline. Skill v3.5 ships an editorial-grade carousel methodology built on five disciplines, each with its own deep-dive file:

- `carousel-headline-engine.md` — the 10-headline generation discipline
- `carousel-editorial-filter.md` — anti-IA-slop language rules
- `carousel-quality-manual.md` — 18-block / 9-slide structure with word counts
- `carousel-design-principles.md` — visual hierarchy, dark/light rhythm, anti-patterns
- `carousel-references.md` — two complete worked examples

This file (carousel-mastery.md) is the orchestrator: it defines the workflow that runs all five together, the design-system CSS + HTML scaffolding for each slide type, the iteration playbook, and the control commands the user can issue.

> **Hard rule:** before generating any carousel for a user, read this file end-to-end. Then dive into the discipline files only as needed during generation.

---

## 0. Why this exists

Carousels are the highest-leverage format on Instagram and LinkedIn (2026): 3-5x the engagement of single images, 2-3x the save rate. But they only work when the **content is editorial-grade**. AI-generated carousels with template hooks, slop language, and missing structure die on impact — the audience scrolls past in 1 second.

The system in this file produces carousels that **pass an editor's red pen**: specific, opinionated, evidence-led, designed with rhythm, written in a register that doesn't read as machine-translated.

The promise: every carousel that comes out of Postzee is *indistinguishable from* — not in the style of — what a top-tier human editorial team would ship.

---

## 1. The pipeline (split: agent vs Postzee)

> **You design. Postzee renders.**
>
> *You* (the agent) write a complete HTML/CSS document for each slide — pixel-perfect text, exact typography, controlled hierarchy. *Postzee* runs Puppeteer and gives you back PNGs, atomically grouped as one MediaGroup.

The 3 carousel tools (see SKILL.md §8.1):
- `POSTZEE_RENDER_CAROUSEL` — atomic render of N slides as one MediaGroup
- `POSTZEE_APPEND_CAROUSEL_SLIDE` — append one slide to existing MediaGroup
- `POSTZEE_REPLACE_CAROUSEL_SLIDE` — surgical replacement of one slide

**Hard limits (render pipeline):**
- 1-15 slides per carousel total
- 256-2160 px per dimension
- 250 KB max HTML per slide
- 45s render timeout per slide
- All-or-nothing: any slide failure rolls back the whole RENDER call

**Platform limits (where the carousel will be published):**

Postzee renders up to 15 slides, but each social network has its own ceiling. Always pick a slide count that fits **all** target platforms — or split the publication.

| Network | Min | Max | Notes |
|---|---|---|---|
| Instagram (all variants) | 2 | **10** | Hardest constraint — design around this |
| Facebook Page | 2 | 10 | Same as IG |
| LinkedIn (Personal + Page) | 2 | 20 | More room for long-form |
| TikTok | 2 | 35 | Photo carousel mode |
| Threads | 2 | 20 | — |
| X (Twitter) | 1 | **4** | Multi-media tweet — not a true carousel UX |
| Pinterest | 2 | 5 | Carousel pin |
| Bluesky / Mastodon | 1 | 4 | Multi-attachment post |
| Reddit | 2 | 20 | Gallery post |
| Telegram / VK | 2 | 10 | Media group |
| Discord | 1 | 10 | Attachments per message |
| Warpcast | 1 | 2 | Frame embeds |

**Rules:**
- If the user picks Instagram + LinkedIn → cap at **10** (the IG limit). Don't propose 12 just because LinkedIn allows it.
- If the user wants 13 slides on LinkedIn only → 13 is fine.
- If the user wants 13 slides on Instagram → push back: *"Instagram supports max 10 slides per carousel. Want me to merge two slides, or shall I render 13 and publish to LinkedIn only?"*
- Postzee enforces these limits server-side and will reject the post **before** calling the social API, with a translated error message — but catching it at brief time saves the user a failed publish.

---

## 2. The 7-stage workflow

Every carousel goes through these 7 stages. Skipping any stage produces a worse carousel. **Never skip the editorial validation gate (stage 5).**

```
┌─────────────────────────────────────────────────────────────────┐
│ STAGE 1 — BRIEFING CRIATIVO (7 questions)                       │
│   Brand, niche, color, style, type, CTA, slide count            │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 2 — TRIAGEM (4-layer analysis)                            │
│   Transformação, Fricção, Ângulo, Evidências                    │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 3 — HEADLINE BATCH (10 variations)                        │
│   5 IC + 5 NM, numbered, rejection-checklist passed             │
│   See carousel-headline-engine.md                               │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 4 — SCRIPT (18 blocks across 9 slides)                    │
│   Per-block copy, density per word-count targets                │
│   See carousel-quality-manual.md                                │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 5 — EDITORIAL VALIDATION GATE (hard stop)                 │
│   7 parameters ≥ 8/10 each + 5 final tests + visual checklist   │
│   See carousel-editorial-filter.md §5 + carousel-quality-       │
│   manual.md §7-§8 + carousel-design-principles.md §6            │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 6 — TEXT APPROVAL (hard stop, user types `aprovado`)      │
│   Do NOT call POSTZEE_RENDER_CAROUSEL until this happens.       │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 7 — RENDER + ITERATE                                      │
│   POSTZEE_RENDER_CAROUSEL → review → REPLACE / APPEND on demand │
└─────────────────────────────────────────────────────────────────┘
```

SKILL.md §8.0 references the same 7 stages — single shared terminology, no translation table needed.

---

## 3. Stage 1 — Briefing Criativo (7 questions)

Before the agent does anything else — **including any analysis or headline draft** — collect these 7 answers.

| # | Question | Why |
|---|---|---|
| 1 | **Brand + handle** (e.g. `RunLab @runlab.br`) | Drives brand bar and identity |
| 2 | **Niche / sector** (single sentence) | Drives palette default + jargon register |
| 3 | **Primary color** (hex preferred) — or "não sei" | Drives CSS variables. If "não sei" → suggest from niche palette table (`carousel-design-principles.md` §14) |
| 4 | **Visual style** — Clássico / Moderno / Minimalista / Bold / Outro+descrição | Drives font pairing and accent treatment |
| 5 | **Carousel type** — Tendência Interpretada / Tese Contraintuitiva / Case-Benchmark / Previsão-Futuro | Drives the narrative arc (`carousel-quality-manual.md` §4) |
| 6 | **CTA pattern** — comment-keyword, link, offer | Drives slide 9 |
| 7 | **Slide count + image count** — `9 slides, 3 com imagem` | Drives layout adaptation (`carousel-quality-manual.md` §6). **Must fit the destination platform** (see §1 Platform limits) — if the user says "12 slides" but is targeting Instagram, cap at 10 and explain why. |

The user can answer all 7 in a single line:
```
RunLab @runlab.br, corrida e saúde mental, #1A1A2E, Bold,
Tendência Interpretada, Comenta CORRIDA, 9 slides 3 com imagem
```

If the user answers partially, ask only what's missing — never re-ask what they already said.

If the user says "do whatever you think is best for everything" — push back once: at minimum, you need brand + handle, niche, and CTA. Without those three, you're not making *their* carousel — you're making a generic one.

---

## 4. Stage 2 — Triagem (4-layer analysis)

Before generating headlines, do this analysis. Never skip — it's what separates editorial from generic.

### Layer 1 — Transformação

**Question:** What changes in the reader's head after they finish this carousel? (Single sentence.)

If the answer is "they learn 5 tips" — the carousel will be generic. The transformation should be specific: a belief flipped, a frame replaced, a name added to their vocabulary.

### Layer 2 — Fricção central

**Question:** What pain, contradiction, or absurdity justifies this carousel existing right now? (Single sentence.)

Without this, the carousel has no urgency. The friction is the reason the reader can't keep scrolling.

### Layer 3 — Ângulo narrativo

**Question:** What is the unique point-of-view this carousel defends? (Single sentence — usually contrarian or angled.)

The angle is the slide-1 hook in seed form.

### Layer 4 — Evidências

**Question:** What 2-3 facts (with named sources) and 1 specific case anchor the thesis?

Every carousel must hit the fact-density floor (`carousel-quality-manual.md` §11). If the user can't supply evidence, either ask for it, search the web (if available), or document the placeholder.

The triagem produces a 4-line memo. The agent uses it internally to drive stages 3-4. **Don't show it to the user.** The user sees the *output* (headlines + script), not the analysis.

---

## 5. Stage 3 — Headline Batch (10 variations)

Run the headline engine. Always 10. Always numbered. Always 5 IC + 5 NM.

**Full discipline:** `carousel-headline-engine.md`.

Output format the user sees:

```
Aqui estão 10 ideias para essa headline:

INVESTIGATIVE CULTURAL (1-5)
VARIAÇÃO 1 — [headline]
VARIAÇÃO 2 — [headline]
VARIAÇÃO 3 — [headline]
VARIAÇÃO 4 — [headline]
VARIAÇÃO 5 — [headline]

MAGNETIC NARRATIVE (6-10)
VARIAÇÃO 6 — [headline]
VARIAÇÃO 7 — [headline]
VARIAÇÃO 8 — [headline]
VARIAÇÃO 9 — [headline]
VARIAÇÃO 10 — [headline]

Qual te chama mais? Pode dizer "a 3", "mistura a 2 com a 7",
"refazer headlines", ou "a 5 com ângulo brasileiro".
```

**Wait for the user to pick** before moving on.

---

## 6. Stage 4 — Script (18 blocks)

Once the user picks a headline, generate the 18-block script following:

- The 4 narrative arcs (`carousel-quality-manual.md` §4 — pick the arc matching the brief's carousel type)
- Block-by-block word count targets (`carousel-quality-manual.md` §2)
- Tone/register rules (`carousel-editorial-filter.md`)

Output format:

```
🧠 ESPINHA DORSAL — [headline chosen]

SLIDE 1 — Capa
   [the headline, used whole]

SLIDE 2 — Dark — Setup + Tension
   Setup:    [block 2 copy, ~14 words]
   Tension:  [block 3 copy, ~18 words]

SLIDE 3 — Light — Data + Reading
   Data:     [block 4, ~12 words]
   Reading:  [block 5, ~22 words]

... (continue for slides 4-8) ...

SLIDE 9 — CTA
   Frase-ponte:  [block 16, ~18 words]
   CTA:          [block 17, ~14 words]
   Keyword:      [block 18, ~6 words]

📝 LEGENDA — [3-paragraph caption draft]

#hashtag1 #hashtag2 #hashtag3
```

The script is shown to the user. Wait for feedback.

---

## 7. Stage 5 — Editorial Validation Gate

**Before offering the script for approval, the agent runs the gate internally.** All checks must pass.

### 7.1 The 7 parameters (each must score ≥ 8/10)

See `carousel-editorial-filter.md` §5 for full definitions:

1. Gramática
2. Fluidez
3. AI Slop (banned constructions absent)
4. Fatos verificados
5. Estrutura
6. Densidade
7. Tom editorial

### 7.2 The 5 final tests

See `carousel-quality-manual.md` §8 for full definitions:

1. Folha test
2. Substitution test
3. Promise test
4. Article test
5. Binary test

### 7.3 The 9-item visual checklist

See `carousel-design-principles.md` §6.

### 7.4 If anything fails

Surface to the user:
> "Detectei [N] pontos a ajustar antes de gerar:
> - Slide [X]: [what failed, in one sentence]
> - Slide [Y]: [what failed]
> Quer que eu ajuste agora?"

Only when all checks pass — offer the script for approval.

---

## 8. Stage 6 — Text Approval (hard stop)

**The agent will not call `POSTZEE_RENDER_CAROUSEL` until the user explicitly types one of:**

| Language | Approval phrases |
|---|---|
| PT | aprovado / pode mandar / pode renderizar / fechado / vamos / segue |
| EN | approved / go / render it / let's go / ship it / good to go |
| ES | aprobado / puedes ir / dale / adelante |
| FR | approuvé / vas-y / on lance |

If the user gives a *partial* approval ("o slide 4 ainda tá fraco, ajusta") — that's a revision request, not an approval. Iterate the script in place. Don't render.

If the user gives a *non-committal* response ("hmm tá bom") — ask once: "Posso renderizar?" Don't infer approval.

**Why this matters:** RENDER costs credits and creates a MediaGroup that lives in the gallery. A premature render = the user has to clean up + re-do. Slow down here and save effort downstream.

---

## 9. Stage 7 — Render + Iterate

### 9.1 Render path A — Atomic (preferred)

User approved the full script → one call:

```ts
POSTZEE_RENDER_CAROUSEL({
  slides: [
    { html: "<!doctype html>...slide 1 capa...", width: 1080, height: 1350 },
    { html: "<!doctype html>...slide 2 dark...", width: 1080, height: 1350 },
    // ... 9 total
  ],
  aspectRatio: "4:5",
  name: "Por que o tema que você mais domina é o que menos viraliza"
})
```

Save the returned `mediaGroupId` — you need it for any subsequent iteration call.

### 9.2 Render path B — Iterative (slide-by-slide)

User wants to see each slide before moving on:

```ts
// Slide 1 only
POSTZEE_RENDER_CAROUSEL({ slides: [slide1], ... })
  → returns mediaGroupId, save it.

// Slide 2 onwards — ONE AT A TIME, always awaited.
await POSTZEE_APPEND_CAROUSEL_SLIDE({ mediaGroupId, slide: slide2 })
await POSTZEE_APPEND_CAROUSEL_SLIDE({ mediaGroupId, slide: slide3 })
...
```

⛔ **Never parallelise APPEND on the same `mediaGroupId`.** Two concurrent appends race on `MAX(orderInGroup) + 1`; the loser's render is discarded server-side and surfaces as an invariant-violation error to the agent — which then panics and retries, compounding the problem. Always await the previous append before issuing the next. Mutations on different groups parallelise fine.

⛔ Never call RENDER more than once for the same carousel. Postzee deduplicates identical RENDER payloads via a 1-hour idempotency cache, but the right answer is: don't re-issue RENDER at all — use REPLACE / APPEND for changes. See SKILL.md §8.5.D.

### 9.3 Iteration tools

| User asks | Tool |
|---|---|
| "muda o slide 4" | `POSTZEE_REPLACE_CAROUSEL_SLIDE({ mediaGroupId, orderInGroup: 3, slide })` |
| "agora faça o slide N+1" | `POSTZEE_APPEND_CAROUSEL_SLIDE({ mediaGroupId, slide })` |
| "insere um slide entre 4 e 5" | No primitive — full rebuild via `POSTZEE_RENDER_CAROUSEL` |
| "remove o slide 5" | No primitive — full rebuild |
| "troca a ordem dos slides" | No primitive — full rebuild |

### 9.4 Failure handling

See SKILL.md §8.5.C — never silently retry, surface raw response, ask user.

---

## 10. The design system

### 10.1 CSS variables (always include in every slide)

```css
:root {
  --P:        #7C3AED;      /* primary brand color */
  --PL:       #A78BFA;      /* primary light variant */
  --PD:       #5B21B6;      /* primary dark variant */
  --LB:       #FAFAF9;      /* light background */
  --LR:       #1F2937;      /* light-mode body text */
  --DB:       #0F172A;      /* dark background */
  --G:        linear-gradient(135deg, var(--P), #06B6D4);
  --F-HEAD:   'Inter', sans-serif;
  --F-BODY:   'Inter', sans-serif;
}
```

The agent fills `--P`, `--LB`, `--DB`, `--F-HEAD`, `--F-BODY` based on the briefing answers. The other variables derive.

### 10.2 The slide skeleton (every slide is built from this)

```html
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <style>
    /* Embedded fonts via @font-face base64 — see §11 */
    /* CSS variables — see §10.1 */
    /* Slide-type-specific styles */

    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body {
      width: 1080px;
      height: 1350px;
      overflow: hidden;
    }
    body {
      font-family: var(--F-BODY);
      position: relative;
      /* bg set per slide type */
    }

    /* Accent bar — top of every slide */
    .accent-bar {
      position: absolute;
      top: 0; left: 0;
      width: 100%; height: 7px;
      background: var(--G);
      z-index: 10;
    }

    /* Brand bar — bottom of every slide */
    .brand-bar {
      position: absolute;
      bottom: 36px; left: 0; right: 0;
      text-align: center;
      font-size: 14px;
      font-weight: 500;
      letter-spacing: 0.04em;
      opacity: 0.5;
    }
  </style>
</head>
<body>
  <div class="accent-bar"></div>
  <!-- slide content -->
  <div class="brand-bar">@USER_HANDLE | YYYY</div>
</body>
</html>
```

### 10.3 Slide types — CSS + HTML

#### A. Capa (slide 1)

```html
<body style="
  background: linear-gradient(180deg,
    rgba(0,0,0,0.10) 0%,
    rgba(0,0,0,0.55) 40%,
    rgba(0,0,0,0.85) 100%
  ), url('PHOTO_URL') center/cover, var(--DB);
  color: #fff;
">
  <div class="accent-bar"></div>

  <!-- Brand handle top-right -->
  <div style="
    position: absolute; top: 56px; right: 56px;
    display: flex; align-items: center; gap: 16px; z-index: 5;
  ">
    <div style="
      width: 72px; height: 72px; border-radius: 50%; overflow: hidden;
      background: #fff; border: 3px solid #fff;
      box-shadow: 0 6px 18px rgba(0,0,0,0.3);
    ">
      <img src="USER_LOGO_URL" crossorigin="anonymous"
           style="width:100%;height:100%;object-fit:cover;" alt="">
    </div>
    <div style="font-size: 22px; font-weight: 700; letter-spacing: 0.02em;">
      @USER_HANDLE
    </div>
  </div>

  <!-- Headline at lower-third -->
  <div style="
    position: absolute;
    bottom: 140px; left: 80px; right: 80px;
    z-index: 3;
  ">
    <div style="
      font-family: var(--F-HEAD);
      font-size: 96px;
      font-weight: 900;
      line-height: 1.05;
      letter-spacing: -0.025em;
      color: #fff;
    ">
      [HEADLINE — full, untruncated]
    </div>
  </div>

  <div class="brand-bar" style="color: rgba(255,255,255,0.6);">
    @USER_HANDLE | 2026
  </div>
</body>
```

#### B. Dark internal slide

```html
<body style="background: var(--DB); color: rgba(255,255,255,0.85);">
  <div class="accent-bar"></div>

  <!-- Tag/label at top of content area -->
  <div style="
    position: absolute; top: 100px; left: 100px;
    display: flex; align-items: center; gap: 12px;
  ">
    <span style="
      font-size: 13px; font-weight: 700;
      letter-spacing: 0.24em; text-transform: uppercase;
      color: var(--P);
    ">CASE</span>
    <span style="opacity: 0.4;">→</span>
    <span style="
      font-size: 13px; font-weight: 600;
      opacity: 0.7;
    ">SLIDE 06 / 09</span>
  </div>

  <!-- Content lower-third -->
  <div style="
    position: absolute;
    left: 100px; right: 100px;
    bottom: 140px;
    display: flex; flex-direction: column; gap: 32px;
  ">
    <h2 style="
      font-family: var(--F-HEAD);
      font-size: 76px;
      font-weight: 800;
      line-height: 1.08;
      letter-spacing: -0.02em;
      color: #fff;
    ">
      [HEADING — block A from quality-manual table]
    </h2>
    <p style="
      font-size: 38px;
      font-weight: 500;
      line-height: 1.45;
      max-width: 90%;
    ">
      [BODY — block B]
    </p>
  </div>

  <!-- Progress bar -->
  <div style="
    position: absolute; bottom: 80px; left: 100px; right: 100px;
    height: 3px;
    background: rgba(255,255,255,0.12);
    border-radius: 2px;
    overflow: hidden;
  ">
    <div style="
      width: calc(100% * (6 / 9));
      height: 100%;
      background: var(--P);
    "></div>
  </div>

  <div class="brand-bar" style="color: rgba(255,255,255,0.5);">
    @USER_HANDLE | 2026
  </div>
</body>
```

#### C. Light internal slide (with border-left card)

```html
<body style="background: var(--LB); color: var(--LR);">
  <div class="accent-bar"></div>

  <div style="
    position: absolute; top: 100px; left: 100px;
    display: flex; align-items: center; gap: 12px;
  ">
    <span style="
      font-size: 13px; font-weight: 700;
      letter-spacing: 0.24em; text-transform: uppercase;
      color: var(--P);
    ">DADO</span>
    <span style="opacity: 0.4;">→</span>
    <span style="
      font-size: 13px; font-weight: 600;
      opacity: 0.7;
    ">SLIDE 03 / 09</span>
  </div>

  <div style="
    position: absolute;
    left: 100px; right: 100px;
    bottom: 140px;
    display: flex; flex-direction: column; gap: 32px;
  ">
    <!-- Card with border-left primary -->
    <div style="
      border-left: 7px solid var(--P);
      padding-left: 32px;
    ">
      <h2 style="
        font-family: var(--F-HEAD);
        font-size: 68px;
        font-weight: 800;
        line-height: 1.08;
        letter-spacing: -0.02em;
        color: var(--LR);
      ">
        [HEADING]
      </h2>
    </div>
    <p style="
      font-size: 38px;
      font-weight: 500;
      line-height: 1.5;
      color: #475569;
      max-width: 90%;
    ">
      [BODY]
    </p>
    <p style="
      font-size: 18px;
      font-weight: 600;
      color: #94A3B8;
      letter-spacing: 0.04em;
    ">
      Fonte: [SOURCE NAME, YEAR]
    </p>
  </div>

  <div style="
    position: absolute; bottom: 80px; left: 100px; right: 100px;
    height: 3px;
    background: rgba(0,0,0,0.08);
    border-radius: 2px;
    overflow: hidden;
  ">
    <div style="
      width: calc(100% * (3 / 9));
      height: 100%;
      background: var(--P);
    "></div>
  </div>

  <div class="brand-bar" style="color: rgba(15,23,42,0.5);">
    @USER_HANDLE | 2026
  </div>
</body>
```

#### D. Big-stat light slide

```html
<body style="background: var(--LB); color: var(--LR);">
  <div class="accent-bar"></div>

  <div style="
    position: absolute; top: 100px; left: 100px;
    font-size: 13px; font-weight: 700;
    letter-spacing: 0.24em; text-transform: uppercase;
    color: var(--P);
  ">
    NÚMERO
  </div>

  <div style="
    position: absolute;
    left: 100px; right: 100px;
    top: 50%; transform: translateY(-50%);
    text-align: left;
  ">
    <div style="
      font-family: var(--F-HEAD);
      font-size: 220px;
      font-weight: 900;
      line-height: 0.95;
      letter-spacing: -0.04em;
      color: var(--P);
    ">
      +187%
    </div>
    <div style="
      font-size: 36px;
      font-weight: 600;
      line-height: 1.3;
      margin-top: 24px;
      max-width: 80%;
      color: var(--LR);
    ">
      [Implication paragraph from block 9]
    </div>
  </div>

  <!-- progress bar + brand bar same as type C -->
</body>
```

#### E. Gradient slide (slide 8)

```html
<body style="
  background: linear-gradient(135deg, var(--P) 0%, #06B6D4 100%);
  color: #fff;
">
  <div class="accent-bar" style="background: rgba(255,255,255,0.5);"></div>

  <div style="
    position: absolute; top: 100px; left: 100px;
    font-size: 13px; font-weight: 700;
    letter-spacing: 0.24em; text-transform: uppercase;
    color: rgba(255,255,255,0.85);
  ">
    DIREÇÃO
  </div>

  <div style="
    position: absolute;
    left: 100px; right: 100px;
    bottom: 140px;
    display: flex; flex-direction: column; gap: 36px;
  ">
    <h2 style="
      font-family: var(--F-HEAD);
      font-size: 78px;
      font-weight: 800;
      line-height: 1.08;
      letter-spacing: -0.02em;
    ">
      [Block 14 — future direction]
    </h2>
    <p style="
      font-size: 36px;
      font-weight: 500;
      line-height: 1.4;
      color: rgba(255,255,255,0.9);
      max-width: 90%;
    ">
      [Block 15 — trade-off]
    </p>
  </div>

  <!-- progress + brand bar -->
</body>
```

#### F. CTA slide (slide 9)

```html
<body style="background: var(--DB); color: #fff;">
  <div class="accent-bar"></div>

  <!-- Logo top-left -->
  <div style="
    position: absolute; top: 80px; left: 80px;
    display: flex; align-items: center; gap: 16px;
  ">
    <div style="
      width: 64px; height: 64px; border-radius: 50%; overflow: hidden;
      background: #fff; border: 3px solid #fff;
      box-shadow: 0 4px 12px rgba(0,0,0,0.25);
    ">
      <img src="USER_LOGO_URL" crossorigin="anonymous"
           style="width:100%;height:100%;object-fit:cover;" alt="">
    </div>
    <div style="font-size: 22px; font-weight: 700;">
      @USER_HANDLE
    </div>
  </div>

  <!-- Frase-ponte (block 16) at upper-mid -->
  <div style="
    position: absolute;
    top: 280px;
    left: 80px; right: 80px;
  ">
    <p class="cta-bridge" style="
      font-size: 38px;
      font-weight: 500;
      line-height: 1.4;
      color: rgba(255,255,255,0.85);
      max-width: 92%;
    ">
      [Block 16 — frase-ponte]
    </p>
  </div>

  <!-- CTA action (block 17) -->
  <div style="
    position: absolute;
    left: 80px; right: 80px;
    bottom: 220px;
    display: flex; flex-direction: column; gap: 28px;
  ">
    <h2 class="cta-action" style="
      font-family: var(--F-HEAD);
      font-size: 64px;
      font-weight: 800;
      line-height: 1.1;
      letter-spacing: -0.02em;
    ">
      [Block 17 — verb-first CTA]
    </h2>

    <!-- Keyword box (block 18) -->
    <div class="cta-kbox" style="
      display: inline-block;
      align-self: flex-start;
      background: var(--P);
      color: #fff;
      padding: 24px 40px;
      border-radius: 12px;
      font-size: 36px;
      font-weight: 800;
      letter-spacing: 0.06em;
    ">
      [BLOCK 18 — KEYWORD]
    </div>
  </div>

  <div class="brand-bar" style="color: rgba(255,255,255,0.5);">
    @USER_HANDLE | 2026
  </div>
</body>
```

---

## 11. Font embedding rule (critical for Puppeteer)

**Never use `<link rel="stylesheet" href="https://fonts.googleapis.com/...">`** in slide HTML. The headless browser may render the slide before the font has loaded — leading to fallback typography in the PNG.

Instead, **embed fonts as base64 `@font-face`** inside the `<style>` block:

```html
<style>
@font-face {
  font-family: 'Inter';
  font-weight: 700;
  font-style: normal;
  src: url(data:font/woff2;base64,d09GMgABAA...) format('woff2');
  font-display: block;
}
@font-face {
  font-family: 'Inter';
  font-weight: 800;
  ...
}
</style>
```

### 11.1 Pre-approved font set

To keep HTML size under 250KB after embedding, restrict to these fonts (each weight is ~30-50KB base64):

| Style | Display | Body |
|---|---|---|
| Clássico | Playfair Display 700/800/900 | Inter 500/700 |
| Moderno | Bricolage Grotesque 700/800 | Inter 500/700 |
| Minimalista | Inter 700/800/900 | Inter 500 |
| Bold | Anton 700 | Inter 500/700 |

Maximum weights per slide: **5**. Beyond that, embedded payload pushes near the 250KB limit.

### 11.2 If fonts fail to embed

If the agent doesn't have access to base64 font payloads (and can't generate them), fall back to a system-stack fallback: `font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;`. The slide will still render — it just loses brand fidelity. Surface this to the user: "I rendered with system fonts because I couldn't embed [Font]. If you have the file, I can embed it for the next render."

---

## 12. Control commands

The user can issue these at any stage. Map their phrases to actions.

### 12.1 Briefing stage

| User phrase | Action |
|---|---|
| `pula o briefing, usa o que sabe` | Refuse politely. At minimum need brand + handle, niche, CTA. |
| `usa minha cor padrão` | If the user has past carousels in the session, reuse. Otherwise ask. |

### 12.2 Headline stage

| User phrase | Action |
|---|---|
| `refazer headlines` | Generate fresh batch of 10 |
| `ajusta a [N]` | Rewrite only variation N, keep other 9 |
| `mistura a [N] com a [M]` | Synthesize N's hook + M's payoff (or strongest blend) |
| `a [N] mais provocativa` | Stronger tension lever, same format slot |
| `a [N] com ângulo brasileiro` | Add regional anchor (lift +155%) |
| `a [N] mais curta` | Trim within format limits |
| `usa a [N] na capa` | Lock that variation as the headline |

### 12.3 Script stage

| User phrase | Action |
|---|---|
| `ajusta o slide [N]` | Revise slide N's blocks, keep others |
| `os títulos internos estão genéricos` | Re-run quality-manual §10 across all slide titles |
| `troca a tabela do slide [N] por [data]` | Replace block 8's stat with provided data |
| `mais denso no slide [N]` | Push that block toward upper word-count tolerance |
| `mais leve no slide [N]` | Push toward lower word-count tolerance |

### 12.4 Approval / render stage

| User phrase | Action |
|---|---|
| `aprovado` | Advance to render |
| `pode mandar` / `vamos` | Same |
| `o slide [N] ainda tá fraco` | Revision request, NOT approval — iterate slide N |
| `gera só o slide 1 pra ver` | Iterative path B (RENDER with [slide1] only) |
| `próximo` after slide 1 was rendered | APPEND slide 2 |

### 12.5 Post-render iteration

| User phrase | Action |
|---|---|
| `troca o slide [N]` | `POSTZEE_REPLACE_CAROUSEL_SLIDE` |
| `troca a imagem da capa` | REPLACE slide 1 with new background image |
| `adiciona um slide` | `POSTZEE_APPEND_CAROUSEL_SLIDE` |
| `inverte a ordem` / `move o slide 4 pro 7` | No primitive — confirm and full rebuild |
| `reiniciar` / `começa de novo` | Clear session script, re-do briefing |
| `exporta` / `salva` | The slides are already in the user's gallery — point them to the dashboard |

---

## 13. The invisible scaffolding rule

The user never sees:

- The triagem analysis (Layer 1-4)
- The 7-parameter scoring
- The 5 final tests
- The visual checklist
- "I generated using the Two-Colon formula"
- "I optimized for the +155% lift pattern"
- "I verified that the dark/light rhythm follows the canonical pattern"

The work is invisible. The user sees:

- The 10 numbered headlines
- The script (or its output: the rendered slides)
- The caption + hashtags
- Surgical iteration responses

If the user asks why something was chosen — *then* explain, briefly, in their language. Never volunteer.

---

## 14. The 4 narrative arcs — quick reference

Full block-by-block adaptation is in `carousel-quality-manual.md` §4.

| Arc | When to use | Cover hook angle |
|---|---|---|
| **Tendência Interpretada** | News-cycle / cultural shift / fresh data point | Investigation pattern, regional anchor |
| **Tese Contraintuitiva** | Challenging consensus / breaking a default belief | Contrarian declaration, Brand-reveal |
| **Case / Benchmark** | Specific success / failure with data | Named entity + counterintuitive result |
| **Previsão / Futuro** | Forward-looking projection (12-36 months) | Future-tense headline, trend convergence |

Pick one in stage 1 (briefing). Don't switch mid-script — if the user wants a different arc, restart from stage 2 (triagem).

---

## 15. The frase-ponte rule (CTA slide block 16)

**Mandatory.** The CTA slide cannot land cold. Block 16 bridges the carousel's content to the action being requested.

Examples:

| Context | Example frase-ponte |
|---|---|
| Carousel about creator economy | "A próxima virada do mercado vai ser invisível pra quem não está prestando atenção." |
| Tese contraintuitiva on productivity | "Quem ainda mede produtividade em horas vai assistir o jogo terminar de fora." |
| Case-study carousel | "A diferença entre quem replica e quem só admira é uma decisão por semana." |

If you can't write a frase-ponte that connects the carousel's thesis to the CTA — the carousel doesn't have a thesis yet. Re-do stage 2 (triagem).

---

## 16. The competitor-analysis playbook

If the user pastes a competitor's post or article in the brief, expand stage 2 with strategic positioning:

```
📰 What the reference does well
   - <one specific strength>
   - <another>

🕳 The gap
   <The single sentence defining where they fall short>

🎯 Our position
   <How this carousel positions differently — never "we also do X",
    always "the next move they didn't make">

🔥 The angle for the carousel
   <One sentence the carousel will earn over 9 slides>
```

Then run stage 3 with the angle locked.

---

## 17. The competitor-naming rule

Naming a competitor explicitly in the carousel is allowed only if:
1. The user has the data to back the claim against them
2. There's no defamation risk
3. The naming is genuinely instructive, not merely combative

When in doubt, refer obliquely ("a maior fintech brasileira") rather than naming. Editorial quality survives without naming; the audience often respects restraint.

---

## 18. Image distribution — when the user provides photos

| Photos provided | Where they go |
|---|---|
| 0 | Typography-only carousel. Type carries identity. |
| 1 | Cover only (full-bleed photo + gradient + headline) |
| 2 | Cover + slide 6 (case slide, full-bleed dark) |
| 3 | Cover + slide 4 (friction, dark full-bleed) + slide 6 (case, dark full-bleed) |
| 4-5 | Cover + dark slides + one .img-box on a light slide |
| 6+ | Distribute one per non-CTA, non-cover slide |

If a photo doesn't fit the slide context — drop it. Forced photo placement looks worse than typographic clarity.

---

## 19. Quality checklist before publishing

- [ ] Stage 5 (editorial validation gate) passed
- [ ] Stage 6 (text approval) explicitly given by user
- [ ] Slide 1 headline visible at min 88px, fits in 5 lines
- [ ] Same palette + typography across all 9 slides
- [ ] Tags/labels present and consistent on internal slides
- [ ] Dark/light rhythm matches canonical pattern (D-D-L-D-L-D-L-G-D)
- [ ] Brand bar identical on every slide
- [ ] Accent bar present on every slide (7px gradient top)
- [ ] Progress bar shows correct N/9 on internal slides
- [ ] CTA slide contains: frase-ponte (block 16) + verb-first action (17) + keyword box (18)
- [ ] Caption draft has hook in first 125 chars (IG) or first 3 lines (LinkedIn)
- [ ] Hashtags 3-5, niche-relevant, not spam
- [ ] Fonts embedded base64 (not `<link>` to Google Fonts)
- [ ] mediaUrls passed to POSTZEE_CREATE_POST in original order

---

## 20. What NOT to do

- ❌ Skip the briefing — generic carousel is the result
- ❌ Skip the triagem — flat carousel
- ❌ Generate fewer than 10 headlines (or more) — discipline break
- ❌ Mix headline formats inside a single number slot (variation 1-5 must be IC; 6-10 must be NM)
- ❌ Use a single-colon Investigative Cultural — must be 0 or 2 colons
- ❌ Generate a Magnetic Narrative with 2 or 4 sentences — must be exactly 3
- ❌ Use the "Powered by Postzee" / any platform attribution in the brand bar — only `@handle | YYYY`
- ❌ Use any banned construction from `carousel-editorial-filter.md` §2
- ❌ Skip the editorial validation gate — text quality is the differentiator
- ❌ Skip the frase-ponte (block 16) on slide 9 — CTA reads cold
- ❌ Render before stage 6 (explicit approval) — wastes credits + clutters gallery
- ❌ Re-render to "fix" — use REPLACE per slide
- ❌ Use `<link>` to Google Fonts in slide HTML — fonts may not load in time → use base64 @font-face
- ❌ Place body text centered on internal slides — only cover and CTA verb are centered
- ❌ Apply accent color to more than 3 words per slide
- ❌ Show the user the triagem, the 7-parameter scoring, or the visual checklist — invisible scaffolding rule

---

## 21. Sample full RENDER call

```ts
const slides = [
  {
    width: 1080,
    height: 1350,
    html: `<!doctype html>...slide 1 capa with full-bleed photo + gradient + headline at lower-third...`,
  },
  {
    width: 1080,
    height: 1350,
    html: `<!doctype html>...slide 2 dark with setup + tension blocks at lower-third...`,
  },
  // ... 9 total
];

const result = await POSTZEE_RENDER_CAROUSEL({
  slides,
  aspectRatio: "4:5",
  name: "Por que o tema que você mais domina é o que menos viraliza",
});

if (!result.success || result.totalSlides !== 9) {
  // Surface raw response to user, ask, do not retry silently
  return;
}

// Save mediaGroupId for any subsequent iteration
const mediaGroupId = result.mediaGroupId;

// Then publish:
await POSTZEE_CREATE_POST({
  type: "schedule",
  date: "2026-05-12T13:00:00Z",
  channelId: "<from POSTZEE_LIST_CHANNELS>",
  text: "[caption with hook in first 125 chars + 3-5 hashtags]",
  mediaUrls: result.mediaUrls,
});
```

---

## 22. The bar

Every carousel that ships from this system should be **indistinguishable from** what a top human editorial team would publish — not "in the style of", but "actually equivalent". If a slide reads as AI-generated, the system failed. If a headline reads as templated, the system failed. If the visual rhythm feels random, the system failed.

The discipline is the difference. Run all 7 stages. Don't skip the gate. Wait for explicit approval. Use REPLACE for fixes, not RENDER. Embed fonts. Show only the result, never the scaffolding.

That's the bar. Ship at the bar.
