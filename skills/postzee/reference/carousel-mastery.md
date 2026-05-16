# Carousel Mastery — The Editorial Carousel System

This is the **central reference** for the carousel pipeline. Skill v3.7 extends the v3.6 editorial methodology with new disciplines for single-image posts, design depth, and copywriting:

**Disciplines this file orchestrates** (carousel-specific):
- `carousel-headline-engine.md` — 10-headline discipline with winner-first surface
- `carousel-visual-preview.md` — stage 7a HTML artifact preview protocol
- `carousel-editorial-filter.md` — anti-IA-slop language rules
- `carousel-quality-manual.md` — 18-block / 9-slide structure with word counts
- `carousel-design-principles.md` — legacy carousel visual rules (most material migrated to `editorial-design.md` in v3.7)
- `carousel-references.md` — two complete worked examples

**v3.7 disciplines (apply to BOTH carousels and single images)**:
- `copywriting-mastery.md` — 10 inviolable laws, 12 hook patterns, 4 caption frameworks, BR voice
- `editorial-design.md` — 6 design movements, type contrast law, photo treatment, brand bar system
- `smart-rendering.md` — Path A (Postzee renders) vs Path B (agent renders locally)
- `platform-settings.md` — per-network publish settings (REQUIRED before any `POSTZEE_CREATE_POST`)

**v3.7 parallel methodology**:
- `image-mastery.md` — single-image methodology (6-stage workflow); read for any post that's NOT a carousel

This file (carousel-mastery.md) is the orchestrator for carousels: it defines the workflow that runs the carousel disciplines together, the design-system CSS + HTML scaffolding for each slide type, the image and font inlining rules, the iteration playbook, and the control commands the user can issue. Pair it with `image-mastery.md` for single-image work — same disciplines, different methodology.

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
- **7 MB max HTML per slide** (enough headroom for base64-inlined images alongside fonts — required by the visual-preview workflow, see `carousel-visual-preview.md`)
- 50 MB max **total payload** per RENDER call (sum of all slides combined)
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

## 2. The 8-stage workflow

Every carousel goes through these 8 stages. Skipping any stage produces a worse carousel. **Never skip the editorial validation gate (stage 5).**

```
┌─────────────────────────────────────────────────────────────────┐
│ STAGE 1 — BRIEFING CRIATIVO (7 questions)                       │
│   Brand, niche, color, style, type, CTA, slide count            │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 2 — TRIAGEM (4-layer analysis)                            │
│   Transformação, Fricção, Ângulo, Evidências                    │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 3 — HEADLINE: WINNER-FIRST SURFACE                        │
│   Internally generate 10 (5 IC + 5 NM), apply rejection check + │
│   coverage rule. Surface ONE winner + 1-line reasoning + the    │
│   three expansion commands: "boa, vai" / "outras" / "todas".    │
│   Indexed iteration commands activate after expansion.          │
│   See carousel-headline-engine.md §1 and §11                    │
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
│   Do NOT generate slide HTML until this happens.                │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 7a — VISUAL PREVIEW (HTML artifact, no Postzee call)      │
│   Compose slides with base64-inlined images, output as ONE      │
│   aggregated HTML doc (single document, scaled <section>s, NO   │
│   iframes — see preview rationale §2). Iterate freely: "muda    │
│   fundo do slide 3", "troca slide 4 e 5", etc. → edit master    │
│   HTML, re-output. No call to POSTZEE_RENDER_CAROUSEL.          │
│   See carousel-visual-preview.md                                │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 7b — RENDER & SHIP (user approves visual)                 │
│   Triggered by "renderiza" / "pode publicar" / "tá pronto" /    │
│   "aprovado" / "vai" (PT) or "render" / "ship it" / "let's go"  │
│   / "approved" (EN). POSTZEE_RENDER_CAROUSEL with the SAME HTML │
│   that was in the artifact. One call, no retry on failure.      │
│   REPLACE / APPEND are escape hatches for POST-render tweaks    │
│   only, not the main iteration loop (which lives in 7a).        │
└─────────────────────────────────────────────────────────────────┘
```

SKILL.md §8.0 references the same 8 stages — single shared terminology, no translation table needed.

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

## 5. Stage 3 — Headline: Winner-First Surface

Run the headline engine. **Internally**: always 10. Always 5 IC + 5 NM. Always rejection-checked. Always coverage-validated. **Externally**: surface ONE winner with a one-line defense — top of the funnel of decision-making, not a menu of 10.

**Full discipline:** `carousel-headline-engine.md` (read §1 and §11 for the surface protocol; §2-§10 for the internal generation rules).

Default surface (what the user sees first):

```
✨ Headline mais forte pro carrossel:

   "<the winning variation, full text>"

   <one-line reasoning: lift pattern + why this beat the other 9.
    ~15-25 words. Copywriter voice, not tool voice.>

   👉 "boa, vai"  — sigo com essa
      "outras"   — te mostro o top-3
      "todas"    — te mostro as 10 numeradas
```

**The user can:**
- Approve the winner (`boa, vai`, `tá bom`, silence followed by next message about something else) → advance to stage 4 with the winner.
- Ask for `outras` → top-3 numbered revealed; indexed commands (§8 of headline-engine) activate.
- Ask for `todas` → full 10 numbered revealed; same indexed commands cover 1-10.
- Issue an indexed command without first expanding (`ajusta a 3`, `mistura a 2 com a 7`) → auto-expand to `todas`, then apply the command. Don't refuse, don't ask for clarification — see headline-engine.md §1 auto-expand rule.
- Type `refazer headlines` → fresh batch of 10 generated internally, default surface re-emitted.

**Once a headline lands (winner or any expanded choice)**, the agent moves to stage 4. The chosen variation will be used whole on slide 1 (cover headline rule — see headline-engine.md §10).

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

## 9. Stage 7a / 7b — Visual preview → Render & ship

### 9.0 The shape of stage 7

Stage 7 splits into **7a (visual preview)** and **7b (render & ship)**.

**Stage 7a has 3 steps**, in order:

1. **Step 0 — Image Strategy** (NEW in v3.8.0, §9.1 below): proactively propose background images for slides that lose editorial force without one. User accepts / partial / skips. Zero Postzee calls beyond `POSTZEE_GENERATE_IMAGE` for accepted slides.
2. **Step 1 — Compose the preview HTML artifact**: typography + images (the ones generated in Step 0, if any) into the aggregated single-doc artifact. See `carousel-visual-preview.md`.
3. **Step 2 — Iterate freely** on the artifact (§9.4 below). All edits are local, no Postzee calls.

**Stage 7b** (§9.2 below) happens once: a single commit to `POSTZEE_RENDER_CAROUSEL` after explicit visual approval. By that point the HTML is final and the mediaGroupId comes back, ready to publish.

See `carousel-visual-preview.md` for the artifact protocol, image inlining rules, and surface fallbacks.

### 9.1 Stage 7a Step 0 — Image Strategy (NEW in v3.8.0)

Before composing the preview HTML, the agent runs a strategic analysis: **which slides (if any) would gain real editorial impact from a background image?** This is an editorial decision, not an upsell.

The default mental model: a typography-only carousel is the **baseline**. Images are added only when the slide LOSES force without them. Carousels that need images and ship typography-only underperform; carousels that don't need images and ship with them visually saturate. The agent must know the difference.

#### 9.1.0 First: account for any user-provided photos

Before running the strategy, the agent checks whether the user already supplied photos in the brief or session context.

**If the user provided photos**:
1. Distribute them per `§18` (Image distribution — when the user provides photos). That table assigns specific slides based on photo count.
2. The slides covered by user-provided photos are **out of scope** for §9.1 proposal — don't propose to generate an image for a slide that already has one.
3. For the **remaining** slides (those NOT covered by user photos), run §9.1.1 + §9.1.2 normally.

**Example**: user provides 1 photo for the cover. Agent assigns it to slide 1 per §18. Then §9.1 evaluates slides 2-N for the rigorous filter. If slide 3 qualifies, the agent proposes generating that one — never proposes regenerating the cover (user already chose).

**If the user provided NO photos**: proceed directly to §9.1.1 (cover candidate) and §9.1.2 (filter for internals). This is the common case.

This step is silent — the agent doesn't surface anything to the user. It's a pre-filter on what's considered for the proposal.

**Note on user-uploaded role assets** (avatar, brand logo, single reference photo for one slide): when the user attaches an image specifically for a role (not as a full-bleed slide background), the routine is **§9.1.6.2 + `media-memory.md` §8.2** — upload to Postzee CDN first, register in IMAGE_REGISTRY, then compose. This is a different code path from "user provided a full-bleed photo for a whole slide" handled in §18 + the table above. Both routines coexist; the agent picks based on the user's intent.

#### 9.1.1 The cover slide — almost always a candidate

Slide 1 (capa) is proposed as an image candidate by default, **except** when:
- The design movement chosen at brief is explicitly typography-led (Brutalist / Minimal / Magazine with typography-only direction stated by the user)
- The headline IS the visual statement (e.g. a giant single-word cover where typography carries the entire visual; verified against the chosen movement)

For all other carousels, propose an image for the cover. The cover is the scroll-stopper — without strong visual on slide 1, even brilliant text loses the feed.

#### 9.1.2 Internal slides — the rigorous filter

For ANY internal slide (2 through N), apply the filter. The slide qualifies ONLY when ALL four criteria are simultaneously true:

| # | Criterion | What it means |
|---|---|---|
| 1 | **Loses editorial force without image** | Not "would look nicer" — fundamentally weakens without one. If the slide reads strong as pure typography, skip. |
| 2 | **Has a concrete visual subject** | Person, object, place, specific scene a prompt can clearly render. Abstract concepts (*liberdade*, *verdade*, *futuro*) fail this. |
| 3 | **Body text under ~40 words** | Text-heavy slides compete with the image. Both lose. |
| 4 | **Doesn't saturate the rhythm** | If slide N-1 or N+1 is already proposed, slide N must be exceptionally strong to also pass. Alternance > clustering. |

Slides that systematically FAIL the filter:
- Argumentative / opinion slides (no concrete subject, prose carries the weight)
- Data-heavy slides (the number is the protagonist)
- Bridge / transition slides
- Text-driven CTAs (verb-first action + keyword box — typography wins)

**Worked example — 9-slide carousel "A morte do gosto pessoal":**

| # | Slide content | Decision | Why |
|---|---|---|---|
| 1 | Capa: "A morte do gosto pessoal" | ✅ Propose | Cover default; strong metaphor with visual subject |
| 2 | Tese: "O algoritmo decide o que você consome" | ❌ Skip | Argumentative, no concrete subject |
| 3 | Case: "Spotify, 2019: 30M de usuários receberam a mesma playlist gerada por IA" | ✅ Propose | Concrete subject (Spotify), specific year, <40 words |
| 4 | Dados: "70% das playlists de 2024 foram algorítmicas" | ❌ Skip | Number is the protagonist |
| 5 | Contexto histórico (3 frases) | ❌ Skip | Text-heavy |
| 6 | Pivô: "E aí, isso é ruim?" | ❌ Skip | Bridge slide |
| 7 | Virada: "O custo é a curiosidade" | ❌ Skip | Abstract — no visual subject |
| 8 | Frase-ponte | ❌ Skip | Transition |
| 9 | CTA: "Recomece. Escolha uma música hoje sem algoritmo." | ❌ Skip | Text-driven CTA |

**Result**: 2 images proposed (slides 1 and 3). Carousel feels complete, focus maintained.

**Counter-example — 6-slide tutorial "Como otimizar custos com IA":**

| # | Slide | Decision |
|---|---|---|
| 1 | Capa: "Como cortar 60% do seu gasto com IA" | ✅ Propose (cover default) |
| 2-5 | 4 steps with action items | ❌ All skip (tutorial = action-driven, text leads) |
| 6 | CTA: "Comece pelo passo 1 ainda hoje" | ❌ Skip |

**Result**: 1 image proposed (capa only). Most tutorial carousels land here.

**Expected distribution across carousel types**:
- Tutorial / how-to: **1 image** (capa)
- Educational / explanatory: **1-2 images** (capa + maybe 1 case)
- Tese / opinion: **1-2 images** (capa + maybe 1 metaphor or case)
- Storytelling / case study: **2-3 images** (capa + 1-2 concrete scenes)
- Aspirational / lifestyle: **2-3 images** (capa + 1-2 emotional)

If the agent identified 4+ qualifying slides, the filter wasn't strict enough — re-evaluate with criterion #1 (loses force without image) as the hard gate. The default is **fewer images, more disciplined**.

#### 9.1.3 Choosing the model

Don't hardcode. Call `POSTZEE_LIST_IMAGE_MODELS` once at the start of Step 0 (cache for session), then categorize:

| Image type | Tier preference | Use case |
|---|---|---|
| Editorial photoreal — humans, objects, real scenes | balanced (FLUX 1.1 Pro, Imagen 3, etc.) | Cover with person, case real, brand object |
| Conceptual / metaphoric — abstract, surreal compositions | balanced or premium | Metaphorical cover, conceptual slide |
| Cinematic / atmospheric backgrounds — moody scenery, environmental shots | `nano-banana` or equivalent (see SKILL.md §8 background-art notes) | Full-bleed slide backgrounds where the image is mostly atmosphere behind text |
| Minimalist design — clean geometric / illustrative | recraft (design mode) when available | Slides with limited visual weight, brand-friendly |

Default tier: **balanced** (predictable cost, high quality). Reach for premium only if the user explicitly asks for max quality.

**Aspect ratio**: match the carousel canvas decided at briefing — it varies by destination platform:

| Destination | Aspect | Pixels |
|---|---|---|
| Instagram / Facebook / LinkedIn carousel (default) | 4:5 | 1080×1350 |
| Pinterest carousel | 2:3 | 1080×1620 |
| X (Twitter) carousel | 16:9 or 1:1 | 1920×1080 or 1080×1080 |
| TikTok carousel | 9:16 or 4:5 | 1080×1920 or 1080×1350 |

If the brief didn't specify a destination, default to 4:5 (the most common). If multiple destinations were stated, default to the most restrictive aspect (4:5 fits everywhere acceptably).

Use `POSTZEE_ESTIMATE_GENERATION_COST` to get the exact credit cost before showing the proposal. **Never guess** the cost — pricing changes; the live tool returns the right number.

#### 9.1.4 Composing the image prompt

One prompt per qualifying slide. Structure:

```
[Concrete subject doing concrete action], [composition: rule of thirds /
centered / negative space / off-center], [lighting: cinematic /
editorial / documentary / golden hour], [mood: tense / hopeful /
nostalgic / dystopian], [style: editorial photography / fine art /
minimalist design / documentary], [color hint from brand palette], 4:5
```

Tie the style to the design movement chosen at brief:

| Movement | Prompt voice |
|---|---|
| Editorial | "Editorial photography, magazine spread quality, shallow depth of field, [subject], [lighting]" |
| Bold | "High-contrast photography, dramatic single-source lighting, bold composition, [subject]" |
| Minimal | "Minimalist composition, generous negative space, [subject] as single focal element, soft natural light" |
| Photo-led | "Cinematic photography, full bleed frame, [subject], golden or blue hour, depth and atmosphere" |
| Magazine | "Vintage editorial, slight film grain, [subject], composition leaving room for typography overlay" |
| Brutalist | "Stark documentary photography, raw composition, hard lighting, [subject]" |

**Anti-slop discipline** (image-brief variant of `copywriting-mastery.md`):
- ❌ "vibrant colors, ultra detailed, masterpiece, 4K, photorealistic" — empty filler that bloats the prompt without specifying anything
- ❌ "professional, beautiful, stunning" — non-specific quality adjectives
- ❌ "in the style of [famous artist] but better" — vague aspirational refs
- ✅ Specific scene, specific lighting, specific composition direction
- ✅ Real visual references when applicable ("Henri Cartier-Bresson decisive moment", "Annie Leibovitz portrait gravity", "Wes Anderson centered symmetry")

The prompt should read as a sentence and produce the same image consistently. If the agent itself can't picture the result from the prompt, the prompt is too vague.

#### 9.1.5 The user-facing proposal — copy template

Compact, justification-driven, cost-transparent, 4-5 commands. Example for the "morte do gosto pessoal" carousel:

```
🎨 Antes do preview — 2 slides que ganhariam imagem de fundo:

   📍 Slide 1 (capa) — "A morte do gosto pessoal"
      Imagem: estátua clássica de mármore quebrada sobre piso escuro
      reflexivo, dramatic side lighting, deep shadows, editorial
      photography monocromática com sutis tons quentes
      FLUX 1.1 Pro · 4:5 · 70 créditos

   📍 Slide 3 — "Spotify, 2019: 30M receberam a mesma playlist"
      Imagem: silhueta humana de costas frente a uma tela mostrando
      interface do Spotify em loop, neon cool blue, dystopian
      editorial photography
      FLUX 1.1 Pro · 4:5 · 70 créditos

   Total: ~140 créditos  ·  Saldo atual: 4.500
   Alternativa: carrossel typography-only — 0 créditos extras.

   👉 "gera as 2"      — sigo com todas
      "só capa"        — só o slide 1
      "só 3"           — só o slide 3
      "pula"           — render sem imagens
      "outros prompts" — refaço as descrições
```

**Required elements**:
- Slide number + headline / block summary (user knows which slide)
- Prompt translated into the user's language (transparency about what's being generated)
- Model + aspect + per-image credit cost
- TOTAL credits + CURRENT balance (no surprises)
- The typography-only alternative spelled out (it's a choice, not a requirement)
- 4-5 commands covering: all / one / partial subset / skip / iterate-prompts

**Voice**: editorial, neutral, no salesy adjectives. NOT "boost your carousel with stunning images!" — just: here's what I'd add, here's why, here's the cost.

#### 9.1.6 Handling user response

| Response | Action |
|---|---|
| `gera as N` / `todas` / `ok` / `vai` | **Generate in parallel**: issue `POSTZEE_GENERATE_IMAGE` for ALL accepted slides simultaneously (don't await one before firing the next). Each returns a `jobId`. **Then poll**: call `POSTZEE_CHECK_JOB(jobId)` for each every ~5s until `status: success` (typical: 10-60s per image). Collect the `mediaUrl` from each job's success payload. See §9.1.6.1 for the parallel polling pattern. |
| `só capa` / `só 1` | Same flow — one GENERATE_IMAGE + one CHECK_JOB poll. |
| `só 3` / `só 1 e 3` / numerical subset | Same parallel pattern for the listed indices. |
| `pula` / `não` / `vai sem` / `typography` | Skip step entirely. **ZERO** charge, NO retry, NO guilt-trip. Continue straight to Step 1 (compose preview, all slides typography-only). |
| `outros prompts` / `refaz` | Re-write prompts for the SAME qualifying slides (the editorial decision of WHICH slides was correct — only prompt-text changes). Present again. Do not re-analyze qualification. **Cap: 2 cycles.** After 2 rewrites, if the user still asks for `outros prompts`, surface: *"Essas foram as 2 melhores versões que tenho pros prompts. Escolhe uma das opções (`gera`, `só capa`, etc.) ou `pula` pra seguir typography-only."* |
| Ambiguous / unclear | Ask ONE clarifying question, or default to "pula" if intent unreadable. Never re-propose if the user clearly declined. |

##### 9.1.6.1 Parallel generation + polling pattern

For N accepted slides:

```
1. Fire N POSTZEE_GENERATE_IMAGE calls in parallel (single message,
   multiple tool calls). Each returns { jobId, status: 'processing' }.
2. Hold the N jobIds.
3. Poll: every ~5s, issue POSTZEE_CHECK_JOB for each still-processing
   jobId in parallel. Continue until ALL jobs are 'success' or 'failed'.
4. Cap polling at 90s total wall-clock per job (typical: 10-60s; if
   it stretches past 90s, treat as 'failed' for that slide and apply
   §9.1.8 handling).
5. Collect (mediaUrl, mediaId, slideIndex) tuples from successful jobs.
6. **REGISTER each tuple in IMAGE_REGISTRY** (`media-memory.md` §8) immediately:
     IMAGE_REGISTRY[`slide_${slideIndex}_${role}`] = {
       mediaId, mediaUrl, role, source: 'generated'
     }
7. Surface a single combined message to the user:
     "✅ Gerado: slide 1 + slide 3. Compondo o preview agora."
8. Proceed to Step 1.
```

**Why parallel**: 3 images sequential ≈ 30-90s of wall-clock; 3 images in parallel ≈ 10-30s. The backend's worker pool handles concurrent generation comfortably.

**Why register in IMAGE_REGISTRY explicitly**: at hand-off to Stage 7b, the `§5.1` conversion (`carousel-visual-preview.md`) reads IMAGE_REGISTRY to know which slide gets which CDN URL in the render shape. Without persistence, the agent has to re-improvise the mapping — which is the exact pattern that caused the "fabricated `lucas_avatar.jpg` path" incident on 2026-05-15. The registry is the single source of truth for asset placement; populate it as soon as the asset exists.

After generation completes, the agent has N `(mediaUrl, mediaId)` pairs in IMAGE_REGISTRY. These feed Step 1:

- **Preview shape**: WebFetch each `mediaUrl` once, base64-encode, embed in the corresponding slide's HTML. Cache the bytes for the session (don't re-fetch).
- **Render shape**: `carousel-visual-preview.md` §5.1 step 5 swaps base64 → URL using the registry. Zero re-work, zero re-decision.

### 9.1.6.2 User-uploaded assets (avatar, logo, brand photo)

When the user **uploads an image in the chat** (file attachment, paste, or URL) intended for use in the carousel — typical roles: avatar on cover/CTA, brand logo on the brand bar, reference photo on a case slide:

⚠️ **Mandatory: run `media-memory.md` §8.2 routine BEFORE composing any HTML that references that asset.**

Briefly:

1. Call `POSTZEE_UPLOAD_MEDIA` with the source (URL or temporary client URL) → receive `mediaUrl` on Postzee CDN
2. Register in IMAGE_REGISTRY: `IMAGE_REGISTRY[role_key] = { mediaId, mediaUrl, role, source: 'user-uploaded' }`
3. Confirm to user in one line: *"Subi sua foto pro Postzee — vou usar como avatar nos slides 1 e 9."*
4. Then proceed to compose HTML referencing `IMAGE_REGISTRY[role_key].mediaUrl`

⛔ **NEVER fabricate a path** like `<img src="lucas_avatar.jpg">` or `<img src="cdn1.postzee.app/user_photo.jpg">`. If you're about to write a `src=` or `url(...)` and the asset isn't in IMAGE_REGISTRY: **STOP**, upload first (§8.2), then come back. The 2026-05-15 incident — avatar-empty on slides 1 and 9 of a rendered carousel — was exactly this anti-pattern. Two REPLACE calls + ~30s of extra work to recover. Prevent it by uploading-first, always.

**Scope of this routine — not limited to Step 0**: §9.1.6.2 sits inside the Step 0 subsection because that's where most carousel images get generated, but the **routine applies any time** the user uploads an image during the carousel workflow:

- **Step 0 declined** (user said `pula`): user can still upload an avatar later — run §8.2.
- **During Step 2 iteration** (`§9.4`): user says *"coloca essa foto como avatar no slide 1"* — run §8.2 before editing the master HTML.
- **Post-render in stage 7b** (escape hatches `§9.5`): user says *"troca o avatar pelo essa nova foto"* before issuing `POSTZEE_REPLACE_CAROUSEL_SLIDE` — run §8.2 first, then REPLACE.

The principle is invariant: **assets in HTML always come from IMAGE_REGISTRY**; user-uploaded sources always reach the registry via §8.2.

#### 9.1.7 Insufficient credit balance

If `POSTZEE_GET_CREDITS` shows balance insufficient for the proposed total:

1. Compute the largest affordable subset. Typically "só capa" fits when "todas" doesn't.
2. Surface the gap and the partial paths explicitly:

```
Saldo atual: 50 créditos.
Proposta total: 140 créditos.

Opções:
- "só capa" (70 créditos) — também não cabe.
- Comprar 1.000 créditos avulsos (~$1 USD) → cobre as 2.
- "pula" — render sem imagens, 0 créditos.
```

The agent NEVER auto-purchases. User chooses.

For **Free plan** users with 0 generation balance: same flow. Free supports AI generation via credit packs (avulso); surface the cheapest pack option contextually, not as a paywall.

#### 9.1.8 Generation failure handling

Failures can surface at two points in the flow:

**A. `POSTZEE_GENERATE_IMAGE` rejects synchronously** (rate limit, validation error, model unavailable, content-policy block at submission)
- The call returns an error instead of a `jobId`
- Skip that slide's image; the rest of the parallel batch continues normally

**B. `POSTZEE_CHECK_JOB` reports `status: failed`** (model crashed mid-generation, post-generation content-policy block, timeout)
- The job's success payload never arrives
- Skip that slide's image; treat as if (A) happened
- If polling exceeds 90s without `success` or `failed` (very rare), treat as a B failure and stop polling

**In both cases**:
- Continue with the slides that succeeded (don't await failures to block the batch)
- Surface to the user, briefly: *"Slide N não gerou (motivo: X). Sigo com as outras N-1 imagens; o slide N vai typography-only no preview."*
- DO NOT auto-retry. User decides whether to request `outros prompts` for that slide or proceed.

If ALL proposed images fail: skip the step entirely, surface a single combined message, proceed to typography-only Step 1. Don't loop on retries.

#### 9.1.9 What Step 0 is NOT

- ❌ **NOT an upsell mechanism.** The agent proposes ONLY when editorial necessity is real. If the carousel doesn't need internal images, propose "só capa" or skip the step entirely.
- ❌ **NOT a place to re-decide visual direction** (movement, brand palette, headlines). Those were decided at brief. Images here REINFORCE, not REFRAME.
- ❌ **NOT for slide reordering or structural changes.** The script is approved. Images plug into the existing structure.
- ❌ **NOT replayed during Step 2 (iteration) or later.** If the user said "pula" or "só capa", that decision sticks for this carousel. User can still manually add images during Step 2 iteration (*"troca a imagem do slide 5 por essa: <url>"*), but the agent never re-proposes the strategy.
- ❌ **NOT cap-driven.** Don't force ≥1 image just because the cover is a default candidate. If the design movement is typography-led, skip the cover proposal too.

#### 9.1.10 Why this step exists — the user-value frame

In carousel analysis, ~30% of carousels are weakened by shipping typography-only when an editorial image would have anchored the message. Step 0's role is to recognize those cases and surface a clear, actionable proposal — not to push images on every carousel.

The right success rate for adoption isn't 100%. It's *"the agent proposed when it mattered, the user agreed or chose typography for the right reasons, and the carousel that shipped was the strongest version of itself."*

### 9.2 Stage 7b — render path A: atomic (only path going forward)

After the user approves the visual in stage 7a, render the whole carousel atomically. Apply the preview→render conversion from `carousel-visual-preview.md` §5.1 — same content + design system, render shape (per-slide independent HTML docs at full 1080×1350, `font-display: block` for the Puppeteer wait window):

```ts
POSTZEE_RENDER_CAROUSEL({
  slides: [
    { html: "<!doctype html>...slide 1 with base64-inlined cover image...", width: 1080, height: 1350 },
    { html: "<!doctype html>...slide 2 dark...", width: 1080, height: 1350 },
    // ... 9 total
  ],
  aspectRatio: "4:5",
  name: "Por que o tema que você mais domina é o que menos viraliza"
})
```

The 7MB-per-slide and 50MB-total payload limits comfortably fit base64-embedded images alongside fonts. Save the returned `mediaGroupId` — you need it for any post-render tweaks.

### 9.3 Legacy iterative path (still supported, rarely the right choice)

The old "render slide 1, then APPEND slide 2, 3, 4…" pattern still works, and the tool contract for `POSTZEE_APPEND_CAROUSEL_SLIDE` is unchanged. But with stage 7a doing the visual iteration upfront, slide-by-slide render mostly stops being useful: the user has already approved all slides as a unit before any render call.

Reserve this pattern for the rare case where a user explicitly says "renderiza só o slide 1, quero ver pixel-perfeito antes dos outros" — then `POSTZEE_RENDER_CAROUSEL([slide1])` followed by sequential awaited `APPEND` calls.

⛔ **Never parallelise APPEND on the same `mediaGroupId`.** Two concurrent appends race on `MAX(orderInGroup) + 1`; the loser's render is discarded server-side and surfaces as an invariant-violation error to the agent — which then panics and retries, compounding the problem. Always await the previous append before issuing the next. Mutations on different groups parallelise fine.

⛔ Never call RENDER more than once for the same carousel. Postzee deduplicates identical RENDER payloads via a 1-hour idempotency cache, but the right answer is: don't re-issue RENDER at all — iterate in 7a before committing, then use REPLACE / APPEND for post-render tweaks. See SKILL.md §8.5.D.

### 9.4 Iteration during stage 7a Step 2 (PRIMARY path — no Postzee call)

While the user is still in the artifact preview, all iteration is local. Edit the master HTML, re-output the artifact, no tool call:

| User asks | Action |
|---|---|
| "muda cor de fundo do slide 3 pra preto" | Edit slide 3 CSS in master HTML → re-output artifact |
| "headline do slide 1 maior" | Adjust font-size → re-output |
| "troca slide 4 e 5 de posição" | Reorder array → re-output |
| "remove slide 7" | Filter out → re-output |
| "insere slide entre 2 e 3 sobre X" | Splice new HTML → re-output |
| "troca a imagem do slide 6 por essa: <url>" | Apply `media-memory.md` §8.2 (POSTZEE_UPLOAD_MEDIA → register in IMAGE_REGISTRY) → fetch the new mediaUrl → base64 → embed → re-output |
| "coloca minha foto como avatar" (user attached an image) | §9.1.6.2 + §8.2: upload → IMAGE_REGISTRY → re-embed in master HTML → re-output. **Never** fabricate a path. |

⛔ NEVER call `POSTZEE_RENDER_CAROUSEL` / `REPLACE` / `APPEND` during 7a. The whole point is to spend zero credits while the user shapes the visual.

### 9.5 Iteration tools — ESCAPE HATCHES after render (post-7b)

Once the carousel is rendered, the artifact preview is gone — the user is now looking at the real PNGs in the gallery. If they want a tweak at that point, surgical primitives are the path:

| User asks (post-render) | Tool |
|---|---|
| "muda o slide 4" | `POSTZEE_REPLACE_CAROUSEL_SLIDE({ mediaGroupId, orderInGroup: 3, slide })` |
| "agora faça o slide N+1" | `POSTZEE_APPEND_CAROUSEL_SLIDE({ mediaGroupId, slide })` |
| "insere um slide entre 4 e 5" | No primitive — back to stage 7a (rebuild the artifact, render fresh) |
| "remove o slide 5" | No primitive — same as above |
| "troca a ordem dos slides" | No primitive — same as above |

These are **escape hatches**, not the iteration loop. The right pattern is: iterate in 7a, render once, publish. REPLACE/APPEND exist for the case where the user wanted to publish, got the carousel, then noticed something the artifact preview missed.

### 9.6 Failure handling

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

### 10.1.5 Image source rule (paralela à de fontes em §11)

Two delivery modes, used in different contexts:

| Mode | Used in | When |
|---|---|---|
| **base64 `data:image/...` URI** | preview shape | Default for preview. Artifact CSP blocks external image fetches, so the data: URI is the only thing that renders. |
| **CDN URL** | render shape (PREFERRED when available) | Default for render when the image has a known CDN URL (POSTZEE_GENERATE_IMAGE output, POSTZEE_UPLOAD_MEDIA result, or any postzee CDN reference). Puppeteer fetches server-side — no CSP. |

```html
<!-- Preview shape: base64 ONLY — artifact CSP blocks external -->
<img src="data:image/jpeg;base64,/9j/4AAQSk...">

<!-- Render shape: CDN URL when available -->
<img src="https://cdn.postzee.app/r2/abc.jpg">

<!-- Render shape: base64 when no CDN URL (e.g. user pasted data: URI directly) -->
<img src="data:image/jpeg;base64,/9j/4AAQSk...">
```

The swap from base64 → CDN URL happens at the preview→render conversion (`carousel-visual-preview.md` §5.1 step 5). Don't second-guess it: same image bytes either way; render output is byte-identical.

**Why this matters:**
- The Claude artifact CSP blocks fetches to external CDN URLs. A slide with `<img src="https://...">` renders with a missing image in the artifact preview — breaks the visual fidelity of stage 7a.
- The render shape has no CSP (Puppeteer fetches freely), and CDN URL refs are ~50 chars vs ~120 KB of base64 — same image, ~99% smaller. This is one half of the token-budget fix (see `carousel-mastery.md` §11.4 for the other half: fonts).
- The 7 MB per-slide ceiling has enough headroom: a 1080×1350 JPEG at quality 85 is ~250-800 KB raw → ~330 KB-1 MB base64. Comfortably fits with fonts (~200 KB) and HTML/CSS. The ceiling isn't the binding constraint — the model's output token budget is, which is why we prefer URLs over base64 for render.

**How the agent gets images:**

| Source | How to inline |
|---|---|
| User pasted a CDN URL | Fetch via WebFetch (or available HTTP tool) → base64 encode → embed |
| `POSTZEE_GENERATE_IMAGE` returned URL | Same — fetch the result URL, base64, embed |
| User pasted a `data:image/...` URI directly | Use as-is |
| Image is >5MB raw | Resize/recompress before embed (target 2160px max dimension, JPEG quality 80-85). If still too large after compression, use the CDN URL and warn the user that **the preview slide will show a placeholder** but the server-side render will still work. |
| Fetch fails (401, 404, timeout, CORS) | Fall back to CDN URL with the same placeholder warning. Surface the failure to the user — don't silently degrade the preview. |

**Background-image variant** (CSS, used by `.img-box` and full-bleed dark slides):

```html
<!-- ❌ DON'T -->
<div style="background: url('https://cdn.postzee.app/...') center/cover;"></div>

<!-- ✅ DO -->
<div style="background: url('data:image/jpeg;base64,/9j/...') center/cover;"></div>
```

See `carousel-visual-preview.md` for the full image-inlining workflow and the aggregated single-document preview shape.

### 10.2 The slide skeleton (every slide is built from this)

```html
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <style>
    /* Embedded fonts via @font-face base64 — see §11 */
    /* CSS variables — see §10.1 */
    /* Images: base64 data: URIs in the preview shape (CSP requires it);
       swapped to CDN URL at render-shape conversion when available — see §10.1.5 */
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
      <!-- Preview shape: src is a base64 data URI (artifact CSP requires it).
           At render-shape conversion (visual-preview §5.1 step 5), the agent
           swaps base64 → CDN URL when the image has a known CDN URL.
           Example preview src: "data:image/jpeg;base64,/9j/4AAQSk..." -->
      <img src="USER_LOGO_BASE64_DATA_URI"
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
      <!-- Preview shape: src is a base64 data URI (artifact CSP requires it).
           At render-shape conversion (visual-preview §5.1 step 5), the agent
           swaps base64 → CDN URL when the image has a known CDN URL.
           Example preview src: "data:image/jpeg;base64,/9j/4AAQSk..." -->
      <img src="USER_LOGO_BASE64_DATA_URI"
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

## 11. Font delivery rule

Two delivery modes, used in different contexts:

| Delivery mode | Used in | When |
|---|---|---|
| **Google Fonts `<link>`** | render shape (PREFERRED) | Default for render. Puppeteer waits for `document.fonts.ready` before screenshotting — fonts always arrive. Works for any font in the pre-approved set (§11.5). |
| **base64 `@font-face`** | preview shape | Default for preview (artifact CSP blocks external font fetches). Also a render fallback when the font isn't on Google Fonts. |

### 11.1 Render shape — prefer Google Fonts `<link>`

In the render shape (HTML sent to `POSTZEE_RENDER_CAROUSEL` / `POSTZEE_RENDER_IMAGE`), use Google Fonts:

```html
<head>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="stylesheet"
    href="https://fonts.googleapis.com/css2?family=Anton&family=Inter:wght@500;700&display=block">
</head>
```

**Why this works in render but not in preview**: the backend Puppeteer (`canvas/src/services/html-render.service.ts:239-255`) calls `await page.evaluate(() => document.fonts.ready)` AFTER `networkidle0` — fonts are guaranteed loaded before the screenshot. The artifact preview has no equivalent guarantee (and CSP often blocks the fetch entirely), which is why the preview shape uses base64.

This rule was previously inverted in the skill (legacy: an earlier worker didn't wait for fonts and Google Fonts arrived too late). The worker was made font-aware; the skill rule lagged. Fixed in v3.7.2 — Google Fonts `<link>` in render is now correct and PREFERRED.

### 11.2 Render shape — base64 `@font-face` as fallback

Acceptable when:
- The font isn't on Google Fonts (brand-custom face the agent has bytes for)
- The agent already has the base64 in hand AND the carousel total HTML is comfortably small (uncommon — image swap and font `<link>` together already keep slides ~10 KB)

When using base64 in the render shape, the block looks like the preview-shape block but with `font-display: block`:

```html
<style>
@font-face {
  font-family: 'BrandCustom';
  font-weight: 700;
  src: url(data:font/woff2;base64,d09GMgABAA...) format('woff2');
  font-display: block; /* Render: Puppeteer waits. Preview uses swap. See §11.3. */
}
</style>
```

### 11.3 `font-display` by context — DO NOT GET THIS WRONG

The same `@font-face` block needs **different `font-display` values** depending on which surface will consume the HTML:

| Surface | `font-display` | Why |
|---|---|---|
| Render HTML (sent to `POSTZEE_RENDER_CAROUSEL`) | `block` | Puppeteer waits up to 3s for the font before capturing the PNG — we WANT the correct typography, not a fallback. Puppeteer is not subject to artifact CSP, so data: URI fonts always load. |
| Preview HTML (Stage 7a artifact) | `swap` | The artifact CSP can block `data:` URI font loads. With `block`, text stays invisible forever when the font is blocked. With `swap`, text renders immediately using the fallback chain (`Inter, system-ui, sans-serif`) — degraded typography is fine; invisible text is not. |

Always pair `font-display: swap` (in the preview) with an **explicit system fallback chain** on every `font-family` declaration, otherwise the swap target has nothing to swap to. Example:

```css
/* ✅ Preview-safe */
.headline { font-family: 'Anton', Impact, "Arial Black", sans-serif; }

/* ❌ Will be invisible if Anton fails */
.headline { font-family: 'Anton'; }
```

The mechanical preview→render conversion (see `carousel-visual-preview.md` §5.1) is the moment to flip `swap` → `block`. Get this wrong in either direction:
- `block` in preview → invisible text in the artifact, user thinks the carousel is broken
- `swap` in render → Puppeteer may capture before the font loads → PNG ships with fallback typography

### 11.4 The token-budget reason for moving font delivery off base64

Path A's user-visible bottleneck is NOT the backend's 7 MB/slide + 50 MB total payload limit. It's the model's **output token budget** — every byte of base64 in the tool-call argument costs ~0.25 tokens to emit, and Claude has only ~8K–32K output tokens per turn.

Worked example, 9-slide carousel:

| Strategy | Per slide | 9 slides total | Output tokens |
|---|---|---|---|
| Naive (4 weights base64 fonts + base64 cover) | ~270 KB | ~2.4 MB | ~600 K (impossible) |
| After image swap (cover → CDN URL) | ~150 KB | ~1.4 MB | ~340 K (impossible) |
| After font swap (Google Fonts `<link>`) | ~5 KB | ~45 KB | ~12 K (comfortable) |
| Combined (image + font swap) | ~10 KB | ~90 KB | ~22 K (comfortable) |

Without these swaps, the agent on Path A burns minutes doing "shrink gymnastics" (removing covers from slides 2–N, recompressing, switching font weights) and often still can't fit the response. With the swaps, the same carousel goes through in one shot.

The optimizations move bytes from `model output → server-side fetches`. The render PNG is byte-identical. The bottleneck disappears.

### 11.5 Pre-approved font set

To keep slide HTML compact and rendering fast, restrict to these fonts (each weight is ~30-50KB base64):

| Style | Display | Body |
|---|---|---|
| Clássico | Playfair Display 700/800/900 | Inter 500/700 |
| Moderno | Bricolage Grotesque 700/800 | Inter 500/700 |
| Minimalista | Inter 700/800/900 | Inter 500 |
| Bold | Anton 400 (visually bold by design — single weight on Google Fonts) | Inter 500/700 |

Maximum weights per slide: **5**. The 7MB per-slide ceiling can technically fit more (with base64 images plus fonts), but disciplined typography produces better carousels — 5 weights is more than enough to express the four design styles.

### 11.6 Font fallback chain

If the preferred Google Fonts `<link>` fetch fails (rare — backend allowlist permits it and Puppeteer waits) OR the requested font isn't on Google Fonts:

1. **Render shape**: try base64 `@font-face` (only if the agent actually has the base64 bytes — don't fabricate). Use `font-display: block`.
2. **Both shapes**: fall back to system stack `font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;`. The slide still renders, brand fidelity drops. Surface to the user: "I rendered with system fonts because I couldn't embed [Font]. If you have the file, I can embed it for the next render."

For the pre-approved set (§11.5 — Anton, Inter, Playfair Display, Bricolage Grotesque), Google Fonts `<link>` always works. The fallback chain is real but rarely exercised.

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

- One winning headline + 3 expansion commands (or, on request, the top-3 / all-10 numbered list — see `carousel-headline-engine.md` §1)
- The script (or its output: the visual preview artifact, then the rendered slides)
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

This section handles the case where the user supplies photos. For the complementary case where the **agent proactively proposes AI-generated images** before render, see §9.1 (Stage 7a Step 0 — Image Strategy).

| Photos provided | Where they go |
|---|---|
| 0 | Run §9.1 image strategy (agent proposes generated images if editorially needed); otherwise typography-only |
| 1 | Cover only (full-bleed photo + gradient + headline) |
| 2 | Cover + slide 6 (case slide, full-bleed dark) |
| 3 | Cover + slide 4 (friction, dark full-bleed) + slide 6 (case, dark full-bleed) |
| 4-5 | Cover + dark slides + one .img-box on a light slide |
| 6+ | Distribute one per non-CTA, non-cover slide |

If a photo doesn't fit the slide context — drop it. Forced photo placement looks worse than typographic clarity.

When the user provides photos AND additional slides would still benefit from images (e.g. user provided 1 photo for the cover but slide 3 also qualifies), the agent can run §9.1 for the remaining qualifying slides — the two paths combine cleanly.

---

## 19. Quality checklist before publishing

- [ ] Stage 5 (editorial validation gate) passed
- [ ] Stage 6 (text approval) explicitly given by user
- [ ] Stage 7a Step 0 (image strategy, §9.1) considered before preview — either proposal presented (user accepted/partial/`pula`) OR agent decided to skip (movement typography-led; user-provided photos cover all qualifying slides; zero qualifying slides after the filter)
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
- [ ] Render shape uses Google Fonts `<link>` (preferred) or base64 @font-face fallback for non-Google fonts — see §11.0
- [ ] Render shape images use CDN URL when available, base64 only when no URL exists — see §10.1.5 + visual-preview §5.1
- [ ] Preview shape uses base64 for both images and fonts (CSP requirement)
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
- ❌ Skip Stage 7a Step 0 (image strategy proposal) — even on text-only-friendly carousels, propose at least the cover (unless the design movement is explicitly typography-led)
- ❌ Force ≥1 image just because the cover is a default candidate — if the design movement is typography-led (Brutalist / Minimal / Magazine typography-only), skip the proposal entirely; the agent decides whether to propose at all
- ❌ Propose 4+ images in any carousel — if the agent identified that many qualifying slides, the §9.1.2 filter wasn't applied strictly enough; re-evaluate with criterion #1 (loses force without image) as the hard gate
- ❌ Frame the image strategy proposal as a sale (*"deixe seu carrossel mais bonito! gere imagens!"*) — frame it editorially (*"slide N ganha força com imagem por essa razão"*)
- ❌ Re-propose images during Stage 7a Step 2 (iteration) — if user said `pula` or accepted a subset, the decision sticks
- ❌ Re-render to "fix" — use REPLACE per slide
- ❌ Use Google Fonts `<link>` in the PREVIEW shape — artifact CSP blocks the fetch → use base64 in preview, `<link>` in render (see §11.1)
- ❌ Inline base64 for the render shape when the image has a known CDN URL — blows the model's output token budget for no benefit (see §11.4)
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

The discipline is the difference. Run all 8 stages. Don't skip the gate. Iterate on the visual preview before committing to a render. Use REPLACE/APPEND only as a post-render escape hatch. Embed fonts AND images as base64. Show only the result, never the scaffolding.

That's the bar. Ship at the bar.
