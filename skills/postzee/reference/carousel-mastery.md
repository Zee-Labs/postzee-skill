# Carousel Mastery — The Editorial Carousel System

This is the **central reference** for the carousel pipeline. It orchestrates the editorial disciplines into a single end-to-end workflow:

**Disciplines this file orchestrates** (carousel-specific):
- `carousel-headline-engine.md` — 10-headline discipline with winner-first surface
- `carousel-editorial-filter.md` — anti-AI-slop language rules
- `carousel-quality-manual.md` — 18-block / 9-slide structure with word counts
- `carousel-design-principles.md` — visual rules specific to carousel slide flow
- `carousel-references.md` — two complete worked examples

**Shared disciplines (apply to both carousels and single images)**:
- `copywriting-mastery.md` — 10 inviolable laws, 12 hook patterns, 4 caption frameworks, BR voice
- `editorial-design.md` — 6 design movements, type contrast law, photo treatment, brand bar system
- `platform-settings.md` — per-network publish settings (REQUIRED before any `POSTZEE_CREATE_POST`)

**Parallel methodology**:
- `image-mastery.md` — single-image methodology (6-stage workflow); read for any post that's NOT a carousel

This file is the orchestrator for carousels: it defines the workflow that runs the carousel disciplines together, the design-system scaffolding for each slide type, the image and font discipline, the iteration playbook, and the control commands the user can issue. Pair it with `image-mastery.md` for single-image work — same disciplines, different methodology.

> **Hard rule:** before generating any carousel for a user, read this file end-to-end. Then dive into the discipline files only as needed during generation.

---

## 0. Why this exists

Carousels are the highest-leverage format on Instagram and LinkedIn (2026): 3-5x the engagement of single images, 2-3x the save rate. But they only work when the **content is editorial-grade**. AI-generated carousels with template hooks, slop language, and missing structure die on impact — the audience scrolls past in 1 second.

The system in this file produces carousels that **pass an editor's red pen**: specific, opinionated, evidence-led, designed with rhythm, written in a register that doesn't read as machine-translated.

The promise: every carousel that comes out of Postzee is *indistinguishable from* — not in the style of — what a top-tier human editorial team would ship.

> **Read first** — hard rules from `SKILL.md` that govern every carousel with imagery:
> - **§2.3 Image generation gate** — never call `POSTZEE_GENERATE_IMAGE` without explicit user approval (prompt + model + cost in writing)
> - **§2.4 Text in images** — never ask the AI image model to render text; words go through HTML overlay → render
> - **§2.5 Image-zone analysis** — write the 3-line zone read before any CSS over an image-backed slide
>
> Cover discipline lives in dedicated docs — read before designing any cover slide:
> - **`cover-design-mastery.md`** — 8 composition patterns, zone analysis protocol, anti-mask rule, typography
> - **`cover-copywriting-mastery.md`** — 6 hook patterns, specificity rule, anti-platitudes, copy+visual synergy
>
> A carousel cover is **advertising** (loud, committed); the slides inside are **editorial** (calm, structured). Do not let the cover bleed editorial; do not let the slides bleed ad. Both reinforce each other only when they stay in their lane.

---

## 1. The pipeline (split: agent vs Postzee)

> **You design. Postzee delivers.**
>
> *You* (the agent) compose a complete slide document for each slide — pixel-perfect text, exact typography, controlled hierarchy. *Postzee* returns the rendered slides, atomically grouped as one MediaGroup ready to publish.

The 3 carousel tools (see SKILL.md §8.1):
- `POSTZEE_RENDER_CAROUSEL` — atomic render of N slides as one MediaGroup
- `POSTZEE_APPEND_CAROUSEL_SLIDE` — append one slide to existing MediaGroup
- `POSTZEE_REPLACE_CAROUSEL_SLIDE` — surgical replacement of one slide

**Hard limits (render pipeline):**
- 1-15 slides per carousel total
- 256-2160 px per dimension
- **7 MB max payload per slide** (room enough for rich compositions with inlined imagery)
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

Every carousel goes through these stages. Skipping any stage produces a worse carousel. **Never skip the editorial validation gate (stage 5).**

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
│   Do NOT render until this happens.                             │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 7 — IMAGE STRATEGY (optional, per slide)                  │
│   Decide which slides gain real impact from a background image. │
│   Cover almost always; internal slides pass the 4-criterion     │
│   filter (§9.1). For user-provided images, call                 │
│   POSTZEE_UPLOAD_MEDIA per SKILL.md §5 rule. For AI-generated   │
│   images, propose with cost (POSTZEE_ESTIMATE_GENERATION_COST), │
│   await approval, generate in parallel, poll.                   │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 8 — RENDER & DISPLAY                                      │
│   POSTZEE_RENDER_CAROUSEL once with all composed slides. The    │
│   response is synchronous — mediaUrls arrive populated. Display │
│   inline to the user via markdown image syntax (one per slide). │
│   No retry on failure — surface error to user.                  │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 9 — ITERATION (primary path)                              │
│   After the user sees the rendered slides, iterate via:         │
│     "muda fundo do slide 3"  → POSTZEE_REPLACE_CAROUSEL_SLIDE   │
│     "adiciona slide no fim"   → POSTZEE_APPEND_CAROUSEL_SLIDE   │
│   After each, display the FULL updated carousel inline again    │
│   (Display Contract — SKILL.md §8.6.D).                         │
└─────────────────────────────────────────────────────────────────┘
```

SKILL.md §8.0 references the same stages — single shared terminology, no translation table needed.

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

**Why this matters:** RENDER creates a MediaGroup that lives in the gallery. A premature render = the user has to clean up + re-do. Slow down here and save effort downstream. (RENDER itself is credit-free — see SKILL.md §2.1 — but rendering the wrong script wastes the user's time.)

---

## 9. Stages 7-9 — Image strategy → Render → Iteration

### 9.0 The shape of post-approval

After the user types `aprovado` in Stage 6, three sequential stages take the carousel from script to published-ready slides:

- **Stage 7 — Image Strategy** (§9.1 below): proactively decide which slides gain real impact from a background image. User accepts / partial / skips. Costs land only on `POSTZEE_GENERATE_IMAGE` for accepted slides.
- **Stage 8 — Render & display** (§9.2 below): one synchronous `POSTZEE_RENDER_CAROUSEL` call. Postzee returns the final rendered slides as one MediaGroup. Display them inline to the user via markdown image syntax.
- **Stage 9 — Iteration** (§9.4 below): the user reacts to the rendered slides. Tweaks land via `POSTZEE_REPLACE_CAROUSEL_SLIDE` (per slide) or `POSTZEE_APPEND_CAROUSEL_SLIDE` (new slide). After each, display the full updated carousel inline again.

### 9.1 Stage 7 — Image Strategy

Before composing the slides, the agent runs a strategic analysis: **which slides (if any) would gain real editorial impact from a background image?** This is an editorial decision, not an upsell.

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

**Cover ≠ slide.** A cover is an ad — louder, sharper, more committed. Before composing the cover HTML:

1. **Pick the hook pattern** from `cover-copywriting-mastery.md` §1 (anti-claim / pair+outcome / pessoal-confessional / proof-by-number / slow-burn / direct provocation). The headline engine generates 10 internally and surfaces 1 — but the winner must clearly belong to one of these 6 patterns, defended in one line.
2. **Pick the composition pattern** from `cover-design-mastery.md` §1 (lower-third, upper-third, left-third, right-third, full-bleed-text, text-on-color-block, diagonal, centered-on-negative-space). Pick by zone read (§2 of that doc), not by habit.
3. **Synergize** copy voice with design pattern via `cover-copywriting-mastery.md` §4.1 voice→pattern map. A confessional headline in display sans on a diagonal background is wrong — match the volume.

When proposing the cover image to the user, the prompt instruction must end with an explicit **"leave [zone] calm and uniform"** clause (e.g. *"leave the upper-left third calm and uniform — gradient or out-of-focus background"*). This gives the subsequent zone read a real calm region to land type on. Without it, you'll fight the photo or be forced into pattern 1.6 text-on-color-block as a rescue.

🔒 **Before composing the cover HTML**, output the 3-line zone read (SKILL.md §2.5; `cover-design-mastery.md` §2.2):

```
🔍 Zone read:
   • Subject zone:  <where the focal element sits>
   • Calm zones:    <regions with low detail variance>
   • Luminance:     <dark/mid/bright map>
```

Then declare the pattern picked + why before any CSS. This is non-negotiable for covers.

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

🔒 **Zone read applies to every image-backed slide, not only covers.** When an internal slide passes the filter and gets an image, the agent declares the 3-line zone read (SKILL.md §2.5) before composing the slide's HTML. Internal slides typically use a quieter pattern (1.1 lower-third or 1.6 text-on-color-block) — covers are advertising, slides are editorial.

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
minimalist design / documentary], [color hint from brand palette],
leave [zone] calm and uniform (gradient or out-of-focus background)
for type overlay, 4:5
```

🔒 **Two hard rules apply to every image prompt** (SKILL.md §2.4 + §2.5):

1. **No text in the prompt.** Never ask the model to render a headline, a number, a logo, a word. Diffusion models hallucinate letters; text on the image goes through HTML overlay → render.
2. **Always include a calm-zone clause.** "Leave [upper-left third / lower band / right column] calm and uniform" — pick the zone that matches the composition pattern you'll use in the cover/slide design (`cover-design-mastery.md` §1). Without this clause the model fills every pixel with detail and the zone read returns "no calm zones".

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
     "✅ Gerado: slide 1 + slide 3. Vou montar o carrossel agora."
8. Proceed to Stage 8 (Render).
```

**Why parallel**: 3 images sequential ≈ 30-90s of wall-clock; 3 images in parallel ≈ 10-30s. The backend's worker pool handles concurrent generation comfortably.

**Why register in IMAGE_REGISTRY explicitly**: when the agent composes each slide for Stage 8, it reads IMAGE_REGISTRY to know which CDN URL to reference per slide. Without persistence, the agent has to re-improvise the mapping — which is the exact pattern that caused the "fabricated `lucas_avatar.jpg` path" incident (2026-05-15: avatar empty on slides 1 and 9 of a rendered carousel; recovery cost ~30s + 2 REPLACE calls). The registry is the single source of truth for asset placement; populate it as soon as the asset exists.

After generation completes, the agent has N `(mediaUrl, mediaId)` pairs in IMAGE_REGISTRY. The compose step in Stage 8 references those URLs directly.

### 9.1.6.2 User-uploaded assets (avatar, logo, brand photo)

When the user **uploads an image in the chat** (file attachment, paste, or URL) intended for use in the carousel — typical roles: avatar on cover/CTA, brand logo on the brand bar, reference photo on a case slide:

⚠️ **Mandatory: run `media-memory.md` §8.2 routine BEFORE composing any HTML that references that asset.**

Briefly:

1. Call `POSTZEE_UPLOAD_MEDIA` with the source (URL or temporary client URL) → receive `mediaUrl` on Postzee CDN
2. Register in IMAGE_REGISTRY: `IMAGE_REGISTRY[role_key] = { mediaId, mediaUrl, role, source: 'user-uploaded' }`
3. Confirm to user in one line: *"Subi sua foto pro Postzee — vou usar como avatar nos slides 1 e 9."*
4. Then proceed to compose HTML referencing `IMAGE_REGISTRY[role_key].mediaUrl`

⛔ **NEVER fabricate a path** like `<img src="lucas_avatar.jpg">` or `<img src="cdn1.postzee.app/user_photo.jpg">`. If you're about to write a `src=` or `url(...)` and the asset isn't in IMAGE_REGISTRY: **STOP**, upload first (§8.2), then come back. The 2026-05-15 incident — avatar-empty on slides 1 and 9 of a rendered carousel — was exactly this anti-pattern. Two REPLACE calls + ~30s of extra work to recover. Prevent it by uploading-first, always.

**Scope of this routine — not limited to Stage 7**: §9.1.6.2 sits inside the Image Strategy subsection because that's where most carousel images get added, but the **routine applies any time** the user uploads an image during the carousel workflow:

- **Stage 7 declined** (user said `pula`): user can still upload an avatar later — run §8.2.
- **Stage 9 iteration** (`§9.4`): user says *"coloca essa foto como avatar no slide 1"* — run §8.2 first, then `POSTZEE_REPLACE_CAROUSEL_SLIDE`.

The principle is invariant: **assets referenced in slides always come from IMAGE_REGISTRY**; user-uploaded sources always reach the registry via §8.2.

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

#### 9.1.9 What Stage 7 is NOT

- ❌ **NOT an upsell mechanism.** The agent proposes ONLY when editorial necessity is real. If the carousel doesn't need internal images, propose "só capa" or skip the stage entirely.
- ❌ **NOT a place to re-decide visual direction** (movement, brand palette, headlines). Those were decided at brief. Images here REINFORCE, not REFRAME.
- ❌ **NOT for slide reordering or structural changes.** The script is approved. Images plug into the existing structure.
- ❌ **NOT replayed during Stage 9 iteration.** If the user said "pula" or "só capa", that decision sticks for this carousel. User can still add images later by uploading one (`POSTZEE_UPLOAD_MEDIA` per SKILL.md §5) and asking for a REPLACE, but the agent never re-proposes the strategy.
- ❌ **NOT cap-driven.** Don't force ≥1 image just because the cover is a default candidate. If the design movement is typography-led, skip the cover proposal too.

#### 9.1.10 Why this stage exists — the user-value frame

In carousel analysis, ~30% of carousels are weakened by shipping typography-only when an editorial image would have anchored the message. Stage 7's role is to recognize those cases and surface a clear, actionable proposal — not to push images on every carousel.

The right success rate for adoption isn't 100%. It's *"the agent proposed when it mattered, the user agreed or chose typography for the right reasons, and the carousel that shipped was the strongest version of itself."*

### 9.2 Stage 8 — Render & display

After Stage 7 completes (image generation done or user said `pula`), compose each slide and call `POSTZEE_RENDER_CAROUSEL` once with the full slide array:

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

The response is **synchronous** — `mediaUrls[]` is populated when the promise resolves. Save the returned `mediaGroupId` (needed for Stage 9 iteration). The 7MB-per-slide and 50MB-total payload limits give comfortable headroom for rich compositions.

**Display the result inline.** Per SKILL.md §8.6.D, show ALL slides as markdown images in your reply so the user sees the rendered carousel in the conversation:

```
Pronto! Aqui está seu carrossel:

![Slide 1 — Capa](https://cdn.../slide-0.png)
![Slide 2 — Hook](https://cdn.../slide-1.png)
...
![Slide 9 — CTA](https://cdn.../slide-8.png)

Posso ajustar algum ou já publicamos?
```

⛔ Never call RENDER more than once for the same carousel. Postzee deduplicates identical payloads via a 1-hour idempotency cache, but the right answer is: don't re-issue RENDER at all — use Stage 9 primitives (REPLACE / APPEND) for any tweak. See SKILL.md §8.5.D.

### 9.3 Iterative authoring path (slide-by-slide previews)

For users who explicitly want to see slides one at a time ("renderiza só o slide 1, quero ver antes dos outros") — `POSTZEE_RENDER_CAROUSEL([slide1])` followed by sequential awaited `POSTZEE_APPEND_CAROUSEL_SLIDE` calls for slides 2…N. Same MediaGroup grows; same `mediaGroupId` is used throughout.

⛔ **Never parallelise APPEND on the same `mediaGroupId`.** Two concurrent appends race on `MAX(orderInGroup) + 1`; the loser's render is discarded server-side and surfaces as an invariant-violation error. Always await the previous append before issuing the next. Mutations on different groups parallelise fine.

### 9.4 Stage 9 — Iteration (PRIMARY path)

After the user sees the rendered slides inline, iteration is the main loop. REPLACE and APPEND are the **workhorses**, not escape hatches:

| User asks | Tool |
|---|---|
| "muda o fundo do slide 4 pra preto" | `POSTZEE_REPLACE_CAROUSEL_SLIDE({ mediaGroupId, orderInGroup: 3, slide })` |
| "headline do slide 1 maior" | `POSTZEE_REPLACE_CAROUSEL_SLIDE` on slide 1 |
| "troca a imagem do slide 6 por essa" + new image | Apply `media-memory.md` §8.2 (`POSTZEE_UPLOAD_MEDIA` → register in IMAGE_REGISTRY) → `POSTZEE_REPLACE_CAROUSEL_SLIDE` on slide 6 |
| "coloca minha foto como avatar" (user attached photo) | §9.1.6.2 + §8.2 routine: upload → IMAGE_REGISTRY → REPLACE the affected slide(s). **Never** fabricate a path. |
| "adiciona um slide no final sobre X" | `POSTZEE_APPEND_CAROUSEL_SLIDE({ mediaGroupId, slide })` |
| "insere um slide entre 4 e 5" | No primitive — offer rebuild ("posso refazer o carrossel inteiro com a nova ordem") |
| "remove o slide 5" | No primitive — offer rebuild |
| "troca a ordem dos slides" | No primitive — offer rebuild |

**After every REPLACE or APPEND**, display the FULL updated carousel inline again (markdown images of all N slides). Never show only the modified one — the user needs to confirm the whole composition stayed intact. See SKILL.md §8.6.D.

### 9.5 Cost transparency during iteration

REPLACE and APPEND are **credit-free** (only AI image generation in Stage 7 costs credits, per SKILL.md §2.1). Tell the user this proactively if they hesitate:

> *"Pode pedir as alterações que quiser — refazer slide é livre. Só geração de imagens nova consome créditos."*

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

### 10.1.5 Image source rule

Images in slides are referenced by **their Postzee CDN URL**. There is one delivery mode and one rule.

```html
<!-- Always reference images by their Postzee CDN URL -->
<img src="https://cdn1.postzee.app/abc123.jpg">
```

```html
<!-- Background-image variant — same rule -->
<div style="background: url('https://cdn1.postzee.app/abc123.jpg') center/cover;"></div>
```

**Where the URLs come from**:

| Source | Path to a Postzee CDN URL |
|---|---|
| AI-generated for a slide | `POSTZEE_GENERATE_IMAGE` → CHECK_JOB returns `mediaUrl` (already a Postzee URL) |
| User-provided image (attachment, paste, external URL) | `POSTZEE_UPLOAD_MEDIA` returns `mediaUrl` (a Postzee URL) — see SKILL.md §5 |
| Asset already in the user's library | `POSTZEE_LIST_MEDIA` → use the `path` from the matching item |

⛔ **Never reference an external URL directly** in a slide (Drive, Imgur, S3, Telegram). Always upload first; reference the returned Postzee URL.

⛔ **Never fabricate a CDN path**. If you're about to write `src="cdn1.postzee.app/something.jpg"` and that URL didn't come from a real tool response, STOP. Upload the asset first (per SKILL.md §5), then use the URL the tool actually returned. The 2026-05-15 incident — avatar empty on slides 1 and 9 of a rendered carousel — was caused by fabrication.

For routing user-provided images to specific slides, see §18 (Image distribution — when the user provides photos).

### 10.2 The slide skeleton (every slide is built from this)

```html
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <style>
    /* Fonts — design system stack (see §11) */
    /* CSS variables — see §10.1 */
    /* Images: referenced by Postzee CDN URL (see §10.1.5) */
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
      <!-- Reference images by Postzee CDN URL — see §10.1.5.
           Example: src="https://cdn1.postzee.app/abc123.jpg" -->
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
      <!-- Reference images by Postzee CDN URL — see §10.1.5.
           Example: src="https://cdn1.postzee.app/abc123.jpg" -->
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

## 11. Font discipline

Slides use **fonts from the design system stack** — Google Fonts loaded via standard `<link>`:

```html
<head>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link rel="stylesheet"
    href="https://fonts.googleapis.com/css2?family=Anton&family=Inter:wght@500;700&display=block">
</head>
```

Pair every primary face with a system fallback chain — if the primary fails to load for any reason, the slide still renders with degraded typography rather than invisible text:

```css
/* ✅ Safe */
.headline { font-family: 'Anton', Impact, "Arial Black", sans-serif; }
.body     { font-family: 'Inter', system-ui, sans-serif; }

/* ❌ Will be invisible if 'Anton' fails to load */
.headline { font-family: 'Anton'; }
```

### 11.1 Pre-approved font set

To keep slides compact and consistent, restrict to these fonts:

| Style | Display | Body |
|---|---|---|
| Clássico | Playfair Display 700/800/900 | Inter 500/700 |
| Moderno | Bricolage Grotesque 700/800 | Inter 500/700 |
| Minimalista | Inter 700/800/900 | Inter 500 |
| Bold | Anton 400 (visually bold by design — single weight on Google Fonts) | Inter 500/700 |

Maximum weights per slide: **5**. Disciplined typography produces better carousels — 5 weights is more than enough to express any of the design styles.

### 11.2 Fonts outside the pre-approved set

If the user explicitly requests a brand-custom face that isn't on Google Fonts (rare):
1. Surface the constraint clearly: *"essa fonte específica eu não tenho — quer que eu use [Playfair Display / Inter / Anton / Bricolage Grotesque] como aproximação visual?"*
2. If the user provides the font file itself, escalate — that's a brand asset request beyond the standard carousel flow.

For routine carousels, the pre-approved set covers every editorial direction.

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
| `gera só o slide 1 pra ver` | Iterative authoring (§9.3): RENDER with [slide1] only, then APPEND subsequent slides |
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

This section handles the case where the user supplies photos. For the complementary case where the **agent proactively proposes AI-generated images** before render, see §9.1 (Stage 7 — Image Strategy).

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
- [ ] Stage 7 (image strategy, §9.1) considered before render — either proposal presented (user accepted/partial/`pula`) OR agent decided to skip (movement typography-led; user-provided photos cover all qualifying slides; zero qualifying slides after the filter)
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
- [ ] Fonts from the pre-approved set (§11.1) with system fallback chain
- [ ] Images referenced by Postzee CDN URL (§10.1.5) — no external URLs, no fabricated paths
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
- ❌ Skip Stage 7 (image strategy) — even on text-only-friendly carousels, propose at least the cover (unless the design movement is explicitly typography-led)
- ❌ Force ≥1 image just because the cover is a default candidate — if the design movement is typography-led (Brutalist / Minimal / Magazine typography-only), skip the proposal entirely
- ❌ Propose 4+ images in any carousel — if the agent identified that many qualifying slides, the §9.1.2 filter wasn't applied strictly enough; re-evaluate with criterion #1 (loses force without image) as the hard gate
- ❌ Frame the image strategy proposal as a sale (*"deixe seu carrossel mais bonito! gere imagens!"*) — frame it editorially (*"slide N ganha força com imagem por essa razão"*)
- ❌ Re-propose images during Stage 9 iteration — if user said `pula` or accepted a subset in Stage 7, the decision sticks
- ❌ Re-render the whole carousel to "fix" one slide — use `POSTZEE_REPLACE_CAROUSEL_SLIDE` per slide
- ❌ Reference images by external URL or fabricated path — always upload first via `POSTZEE_UPLOAD_MEDIA` and use the returned Postzee URL (§10.1.5)
- ❌ Use fonts outside the pre-approved set (§11.1) without surfacing the constraint to the user
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

The discipline is the difference. Run every stage. Don't skip the gate. Render once, then iterate via REPLACE/APPEND with the user looking at the real slides. Use the pre-approved typography. Reference images by their Postzee URLs only. Show only the result, never the scaffolding.

That's the bar. Ship at the bar.
