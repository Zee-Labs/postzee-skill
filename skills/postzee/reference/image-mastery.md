# Image Mastery — Single-Image Posts via HTML

This file is the methodology for **single-image posts** (vs. carousels). Same architectural insight as carousels: AI image models are bad at text → the agent composes HTML with editorial typography + photo overlay → Postzee renders to PNG → user posts.

Why a separate methodology: a single image is a **moment**, not a narrative arc. A carousel earns the swipe with promise → setup → tension → payoff across 9 slides. A single image has ONE shot to hook + deliver value. Different copywriting, different design discipline.

The result, when this methodology is followed: posts like the references in image #18 — editorial portrait + magazine typography + branded composition. Posts that look like a designer made them.

---

## 1. When to use single image vs carousel

| Single image | Carousel |
|---|---|
| One promise, one moment | Argument across multiple slides |
| Hook + small payoff | Hook + setup + tension + payoff |
| 3-15s of attention | 30-90s of attention |
| Save-rate target: <2% (most won't save a single image) | Save-rate target: 4-8% |
| Hero photo OR hero typography | Mix of slide types |
| 1 CTA, 1 instruction | Final CTA slide |
| Time to create: 3-5 min | Time to create: 8-15 min |
| Tools: POSTZEE_RENDER_IMAGE | Tools: POSTZEE_RENDER_CAROUSEL + APPEND/REPLACE |

**Default decision tree**:
- User says "post", "imagem", "anúncio", "campanha avulsa" → single image
- User says "carrossel", "9 slides", "argumento longo", "passo a passo" → carousel
- Ambiguous: ask one question — *"Você quer um post avulso (1 imagem com hook forte) ou um carrossel (8-10 slides desenvolvendo uma tese)?"*

---

## 2. The 6-stage single-image workflow

Mandatory stages, never skip. Same editorial-discipline rigor as the carousel workflow (carousel-mastery.md §2), but compressed to 6 stages since single image is one moment.

```
┌─────────────────────────────────────────────────────────────────┐
│ STAGE 1 — BRIEFING (3 questions max, smart defaults)            │
│   Brand identity + tema/mensagem + visual movement              │
│   (Editorial / Bold / Minimal / Photo-led / Magazine / Brutalist)│
├─────────────────────────────────────────────────────────────────┤
│ STAGE 2 — HOOK + TREATMENT PROPOSAL (winner-first)              │
│   Surface 1 hook (one of the 12 patterns in copywriting-        │
│   mastery.md §3) + 1 visual treatment proposal.                 │
│   Commands: "boa, vai" / "outras" / "outro estilo".             │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 3 — PHOTO + COPY DETAIL                                   │
│   If hero photo: generate via POSTZEE_GENERATE_IMAGE OR use     │
│   user-provided. Color-grade per editorial-design.md §8.        │
│   Write the full hook + supporting body + CTA copy.             │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 4 — VISUAL COMPOSITION (HTML artifact preview)            │
│   Compose single HTML following editorial-design.md §1-§9.      │
│   Inline images as base64 (carousel-mastery.md §10.1.5).        │
│   Output as artifact for user to iterate.                       │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 5 — ITERATION LOOP                                        │
│   User: "muda cor de fundo", "headline maior", "outra foto",    │
│         "italic na palavra X", "tipografia mais editorial"      │
│   Agent edits master HTML, re-outputs artifact. Zero render.    │
│   ⛔ NEVER call POSTZEE_RENDER_IMAGE in this stage.              │
├─────────────────────────────────────────────────────────────────┤
│ STAGE 6 — RENDER & SHIP                                         │
│   Triggered by `renderiza` / `pode publicar` / `tá pronto` /    │
│   `aprovado` / `vai`.                                           │
│   POSTZEE_GET_CONTEXT (credits) → POSTZEE_RENDER_IMAGE with     │
│   the approved HTML → returns mediaUrl.                         │
│   Optional: POSTZEE_CREATE_POST with the resulting mediaUrl.    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Stage 1 — Briefing (3 questions max, smart defaults)

Single images don't need the 7-question carousel briefing. The agent infers everything possible from the user's first message and asks at most 3 questions.

### 3.1 What the agent INFERS (doesn't ask)

| Field | Inferred from |
|---|---|
| **Brand + handle** | Session memory (set once per session in the first brief) OR omitted if the user hasn't established a brand yet |
| **Color palette** | The chosen visual movement (§1 of editorial-design.md), the photo's dominant colors (§4 of editorial-design.md), or the user's brand color if cached |
| **Visual style** (movement) | Inferred from tone: corporate B2B → Editorial; viral creator → Bold; premium product → Minimal; personal brand → Photo-led; deep dive → Magazine; subculture/builder → Brutalist |
| **Format/dimensions** | Default 1080×1350 (4:5, IG-feed optimized). Override only if user explicitly says "story" (1080×1920) or "square" (1080×1080) |
| **Awareness level** | Inferred from the topic — `copywriting-mastery.md` §2 |
| **CTA pattern** | Default `comment-keyword` unless user mentions a link |

### 3.2 What the agent ASKS (3 questions max)

When the brief gives you everything: 0 questions. Just propose at Stage 2.

When the brief leaves gaps, ask ONLY for what blocks you:

1. **Tema/mensagem precisa** — IF the user's brief is too vague ("faça um post bom") to infer. Phrasing: *"Qual a UMA mensagem que esse post precisa entregar? Pode ser uma frase ou um link com o tema."*

2. **Visual movement** — IF the inferred movement might not match brand voice. Phrasing: *"Pelo tema chutei estilo {X}. Quer assim ou prefere algo mais {Y}?"*. Always propose, never open-ask.

3. **Hero photo source** — IF photo is needed. Phrasing: *"Você tem uma foto pra usar de fundo, ou gero uma com IA?"* — and if "gero com IA", propose a description before generating.

If 3 questions aren't enough → user gave you nothing. Push back ONCE: *"Pra ficar afiado, preciso de pelo menos: o tema/mensagem central. Manda 1 linha."* Don't generate generic content.

### 3.3 The "propose-don't-ask" stance

The agent SURFACES the inferences as a one-line commit, not a checklist:

```
Entendi — vou fazer um post avulso 1080×1350, estilo Editorial 
(serif + alta tipografia), tema "novas regras de IA do CNPq", 
ângulo authority + urgency, foto de pesquisador em estúdio com 
luz quente.

👉 "boa, vai"      — começo agora
   "troca X"      — ajusta antes
   "passo a passo"— me guie por cada decisão
```

This collapses 6-7 micro-decisions into ONE user response. The autonomous mode is what makes single images fast.

---

## 4. Stage 2 — Hook + Treatment Proposal

Same winner-first surface as the carousel headline engine — but adapted for single images.

### 4.1 What the agent generates internally

Before surfacing, the agent runs the headline engine `carousel-headline-engine.md` §6 procedure (compressed for single image):

1. Triagem (4-layer, internal — never shown)
2. Generate **5 hooks** internally (vs 10 for carousels — single image has tighter slot, fewer angles needed)
3. Each hook follows the 4-component anatomy from `copywriting-mastery.md` §4
4. Run the rejection checklist `carousel-headline-engine.md` §7 on each
5. Pick the WINNER

### 4.2 What the user sees

```
✨ Post avulso pro tema "novas regras de IA do CNPq":

   "URGENTE. O CNPq publicou novas regras de IA. Agora é 
   obrigatório declarar uso em qualquer publicação científica."

   Pattern: Authority + Urgency (§3.10 copywriting-mastery.md) · 
   joga com a fricção atual de pesquisadores BR · ancora em 
   instituição real + consequência concreta · 3 elementos do hook 
   anatomy presentes.

   Treatment proposto:
   • Movement: Editorial (serif display + body sans)
   • Hero photo: pesquisador em estúdio, luz tungsten quente, 
     desaturado -15%, eyes na linha do terço superior
   • Type: Playfair Display 800 pra "URGENTE" + headline em 
     Inter 700 96pt branco com gradient overlay no terço inferior
   • Brand bar top-left: handle + página 01/01

   👉 "boa, vai"     — começo a foto + composição
      "outras"      — te mostro 2 alternativas de hook
      "outro estilo"— troca pra Bold ou Photo-led
      "manual"      — pra cada decisão você confirma
```

### 4.3 Expansion paths

| Command | Reveals |
|---|---|
| `outras` | 3 alternative hooks (same topic, different patterns from §3 of copywriting-mastery.md) |
| `outro estilo` | The same hook re-cast for a different visual movement |
| `mistura` | Combine elements of two options |
| `refazer` | Fresh batch of 5 hooks (different angle entirely) |

---

## 5. Stage 3 — Photo + Copy Detail

### 5.1 Photo decision tree

```
1. User provided a photo URL?
   → Yes: use as-is. Pass through editorial-design.md §8 grading 
     in the prompt for AI-generated overlays (e.g. logo).

2. POSTZEE_GENERATE_IMAGE is needed?
   → Yes: compose the prompt following editorial-design.md §8.1 
     (explicit grade instructions in the prompt itself).
   
   Standard prompt template for editorial portrait:
   "Editorial portrait of a {subject description}, 
    {lighting} from a {direction}, slightly desaturated -15%, 
    medium contrast, subject's eyes on upper third, 3/4 angle, 
    negative space on the {left/right} for text overlay, 
    shot on Hasselblad H6D-50c, 80mm lens, f/2.8"

   Wait for POSTZEE_CHECK_JOB → success → use resultUrl.

3. Photo not needed (typography-only)?
   → Skip. Move to copy detail.
```

### 5.2 Copy detail

Write the FULL copy structure for the post:

**For the image itself**:
- Slot 1: Pattern interrupt (one word, ALL CAPS, with period) — if used
- Slot 2: Authority signal (institution name, percentage, etc.)
- Slot 3: Specific number/name (concrete detail)
- Slot 4: Promise/question (the payoff hook)

**For the caption** (what the user pastes when posting via `POSTZEE_CREATE_POST`):
- Pick the right framework from `copywriting-mastery.md` §5 (AIDA / PAS / BAB / Hook→Promise→Payoff→CTA)
- 80-200 words for IG/Threads/LinkedIn (LinkedIn allows up to 3000 — but 200 hits the sweet spot for reach)
- ONE explicit CTA (comment keyword, link, save)
- 3-5 hashtags max (use SPECIFIC tags from the niche, not generic #marketing)

### 5.3 Hand the package to stage 4

Output to the user:
```
Pacote pronto. Vou compor o visual:

Headline na imagem: "URGENTE. O CNPq publicou novas regras de IA. 
                    Agora é obrigatório declarar uso em qualquer 
                    publicação científica."

Caption pro post:   "[180-word PAS body]"

Foto: gerada via IA — pronto e validei (1080×1350, lighting checked).

Comando: "boa, vai" pra eu montar o HTML.
```

---

## 6. Stage 4 — Visual Composition (HTML artifact)

The agent composes the HTML using:
- **Slide skeleton** from `carousel-mastery.md` §10.2 (the render shape is one independent HTML doc — same as a single-slide carousel; if using artifact preview, wrap in the aggregated single-doc structure from `carousel-visual-preview.md` §2 with N=1 and apply the §5.1 preview→render conversion at hand-off)
- **Movement-specific typography + composition** from `editorial-design.md` §1
- **Image inlining as base64** per `carousel-mastery.md` §10.1.5

### 6.1 The HTML scaffold for single image

```html
<!doctype html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <style>
    /* PREVIEW shape: base64 @font-face + font-display: swap (artifact CSP).
       RENDER shape: prefer Google Fonts <link> (smaller HTML, no token-budget
       burn) — base64 only when the font isn't on Google Fonts or as fallback.
       See carousel-mastery.md §11 + §11.3 + §11.4 for the full rationale
       and visual-preview.md §5.1 step 3 for the preview→render swap. */

    /* This example shows the PREVIEW-shape inline base64 block. At render
       conversion, the agent replaces it with:
       <link rel="stylesheet"
         href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@800&family=Inter:wght@500&display=block"> */
    @font-face { 
      font-family: 'Playfair Display'; 
      font-weight: 800; 
      src: url(data:font/woff2;base64,...) format('woff2');
      font-display: swap; /* preview: swap; render: block — see §11.3 */
    }
    @font-face { 
      font-family: 'Inter'; 
      font-weight: 500; 
      src: url(data:font/woff2;base64,...) format('woff2');
      font-display: swap;
    }
    
    /* CSS variables from briefing + movement */
    :root {
      --P:  #7C5BB8;   /* primary brand (accent) */
      --LB: #FAFAF9;   /* light background (if no full-bleed) */
      --DT: #1A1A1A;   /* dark text */
      --F-HEAD: 'Playfair Display', serif;
      --F-BODY: 'Inter', sans-serif;
    }
    
    * { margin: 0; padding: 0; box-sizing: border-box; }
    html, body { width: 1080px; height: 1350px; overflow: hidden; }
    body {
      font-family: var(--F-BODY);
      position: relative;
      background: var(--LB);
      color: var(--DT);
    }
    
    /* Movement-specific styles — Editorial example */
    .hero-photo {
      position: absolute;
      inset: 0;
      width: 100%;
      height: 100%;
      object-fit: cover;
      z-index: 1;
    }
    .overlay-gradient {
      position: absolute;
      bottom: 0; left: 0; right: 0;
      height: 55%;
      background: linear-gradient(180deg,
        transparent 0%,
        rgba(0, 0, 0, 0.55) 45%,
        rgba(0, 0, 0, 0.88) 100%);
      z-index: 2;
    }
    .brand-bar {
      position: absolute;
      top: 32px; left: 48px;
      z-index: 4;
      color: #FFFFFF;
      font-size: 14px;
      font-weight: 600;
      letter-spacing: 0.04em;
      text-transform: uppercase;
    }
    .page-indicator {
      position: absolute;
      top: 32px; right: 48px;
      z-index: 4;
      color: rgba(255, 255, 255, 0.7);
      font-size: 13px;
      font-weight: 500;
      letter-spacing: 0.04em;
    }
    .content {
      position: absolute;
      left: 64px; right: 64px; bottom: 80px;
      z-index: 3;
      color: #FFFFFF;
    }
    .interrupt {
      font-family: var(--F-HEAD);
      font-size: 36px;
      font-weight: 900;
      letter-spacing: -0.01em;
      line-height: 1;
      color: #F97316;
      margin-bottom: 24px;
    }
    .headline {
      font-family: var(--F-HEAD);
      font-size: 84px;
      font-weight: 800;
      letter-spacing: -0.02em;
      line-height: 0.95;
      color: #FFFFFF;
      margin-bottom: 28px;
    }
    .body {
      font-size: 22px;
      font-weight: 500;
      line-height: 1.4;
      color: rgba(255, 255, 255, 0.92);
      max-width: 80%;
    }
    .cta-badge {
      position: absolute;
      bottom: 40px; right: 56px;
      z-index: 4;
      background: rgba(255, 255, 255, 0.95);
      color: #1A1A1A;
      padding: 14px 24px;
      border-radius: 32px;
      font-size: 18px;
      font-weight: 700;
      letter-spacing: -0.005em;
      display: inline-flex;
      align-items: center;
      gap: 8px;
    }
  </style>
</head>
<body>
  <img class="hero-photo" src="data:image/jpeg;base64,/9j/4AAQ..." alt="">
  <div class="overlay-gradient"></div>
  
  <div class="brand-bar">@gpt_academico</div>
  <div class="page-indicator">01 / 01</div>
  
  <div class="content">
    <div class="interrupt">URGENTE.</div>
    <h1 class="headline">O CNPq publicou novas regras de IA.</h1>
    <p class="body">Agora é obrigatório declarar uso em qualquer publicação científica. Entra em vigor em 60 dias.</p>
  </div>
  
  <div class="cta-badge">Veja como adequar →</div>
</body>
</html>
```

### 6.2 Output as artifact

Wrap in the artifact preview container per `carousel-visual-preview.md` §2 — same structure as carousels, just with N=1 slide. The user sees the rendered preview, can iterate.

If the surface doesn't support artifact rendering: fall back to the textual variant per `carousel-visual-preview.md` §6 (fenced HTML block + summary).

---

## 7. Stage 5 — Iteration Loop

The user iterates on the artifact via natural language. The agent edits the master HTML and re-outputs the artifact. Zero Postzee call.

**Vocabulary specific to single images** (carousels have more — iteration is per-slide; single image is just per-element):

| User command | Agent action |
|---|---|
| "muda a cor de fundo" / "fundo mais escuro" | Adjust the background or gradient overlay |
| "headline maior" / "fonte mais editorial" | Adjust font-size or swap typeface from the movement's options |
| "outra foto" / "essa foto não tá boa" | If AI-generated: re-generate with adjusted prompt. If user-provided: ask for new URL. |
| "italic em X" / "destaque a palavra Y" | Apply italic, highlight block, or color emphasis to specific word |
| "move o texto pra esquerda" | Adjust .content positioning (left/right/center) |
| "tira o gradient" / "deixa a foto inteira" | Remove the overlay-gradient element (test legibility first) |
| "muda o CTA" / "tira o badge" | Adjust or remove the CTA element |
| "mais minimalista" / "menos elementos" | Strip non-essential elements; reduce to headline + photo only |
| "vira pra Story" | Change dimensions to 1080×1920, re-position elements for the new aspect |

**Smart defaults during iteration**: if the user makes a change that breaks legibility (e.g., removes the gradient on a busy photo), the agent should WARN before applying: *"Vou tirar o gradient, mas o texto branco vai ficar difícil de ler nas áreas claras da foto. Continuo mesmo assim ou aumentar a opacidade?"*

---

## 8. Stage 6 — Render & Ship

Triggered by explicit visual approval phrase:
- PT: `renderiza` / `pode publicar` / `tá pronto` / `aprovado` / `vai` / `manda ver`
- EN: `render` / `ship it` / `let's go` / `approved` / `looks good`

### 8.1 Render path selection

The agent reads `smart-rendering.md` and chooses Path A (`POSTZEE_RENDER_IMAGE`) or Path B (local Playwright + `POSTZEE_UPLOAD_RENDERED_IMAGE`) based on surface capability.

For Path A:
```
POSTZEE_RENDER_IMAGE({
  html: "<the approved HTML>",
  width: 1080,
  height: 1350,
  name: "URGENTE - CNPq regras IA"  // optional human-friendly
})
→ Returns { mediaId, mediaUrl, width, height }
```

For Path B (when capability is detected):
```
1. Write HTML to /tmp/postzee-image.html
2. Run playwright script — viewport 1080×1350 — screenshot to PNG
3. Base64 the PNG bytes
4. POSTZEE_UPLOAD_RENDERED_IMAGE({ imageBase64, mimeType: "image/png", width, height, name })
→ Returns { mediaId, mediaUrl, width, height }
```

Either way: same return shape. Agent surfaces success to user:

```
🎨 Pronto. Imagem renderizada (1080×1350).

📎 mediaUrl: https://cdn.postzee.app/...

Quer publicar agora?
- Instagram feed (post normal)
- Instagram story
- Outra rede
- Salva pro Postzee gallery, posto depois
```

### 8.2 Auto-publish flow

If the user wants to publish immediately, the agent calls `POSTZEE_CREATE_POST` with:
- The mediaUrl from rendering
- The platform-specific settings from `platform-settings.md`
- The caption written in stage 3
- The user's chosen channel(s)

Example for Instagram story (NOT feed — Lucas's bug fix from v3.7):
```
POSTZEE_CREATE_POST({
  type: 'now',
  channelId: '<instagram-channel-id>',
  text: '<caption from stage 3>',
  mediaUrls: ['<mediaUrl from render>'],
  settings: {
    post_type: 'story'  // ← this is the v3.7 fix — without it, posts to feed
  }
})
```

Agent reads platform-settings.md before composing this call so it KNOWS to set `post_type` when the user mentioned "story".

---

## 9. Edge cases

### 9.1 User provides multiple photos

Single image can only use 1 hero photo. If user provides 3, ask: *"Você quer todas no mesmo post (single image suporta 1 foto principal — outras viram acessórios menores), ou vira carrossel?"*. Don't compose a chaotic single image with 3 hero photos competing.

### 9.2 User wants vertical (Story / Reel cover)

Switch dimensions to 1080×1920. Re-layout the content: brand bar moves to top, headline gets MORE vertical space (since the aspect is taller), CTA badge moves to bottom-center. The 4-zone framework still applies, just stretched vertically.

### 9.3 User wants square

1080×1080. Compress vertical content; either remove the body (headline-only on cover-style) or fit a tighter 3-line headline. Mostly used for older-platform feeds (LinkedIn personal) and TikTok photo posts.

### 9.4 No suitable photo + AI generation refused (NSFW, etc.)

Switch to typography-only Bold or Minimal movement. Headline dominates the slide, no photo. Often LANDS HARDER than a mediocre photo would — see `@gpt_academico` typography-only top posts.

### 9.5 The user wants the image in 4 languages

Render 4 separate images (one per language) by calling `POSTZEE_RENDER_IMAGE` 4 times with different `text` content but same composition. Agent surfaces all 4 mediaUrls and lets user pick which to publish where.

### 9.6 Realtime events — Path A vs Path B asymmetry

Single-image renders emit DIFFERENT realtime event types depending on the path:

| Path | Event emitted | Why |
|---|---|---|
| Path A (`POSTZEE_RENDER_IMAGE`) | `group.ready` | Internally creates a 1-slide MediaGroup, inherits the carousel emit path |
| Path B (`POSTZEE_UPLOAD_RENDERED_IMAGE`) | `media.ready` | Bypasses the MediaGroup — produces a standalone Media directly |

This is **intentional**, not a bug — the events reflect the underlying data model. The frontend `RealtimeProvider` handles both: `group.ready` triggers gallery SWR invalidation; `media.ready` does the same plus toast notification routing. From the user's perspective the behaviour is identical (gallery updates, no manual refresh).

If you're writing a new consumer of single-image events (e.g. a third-party webhook listener), subscribe to BOTH event types and treat them as semantically equivalent for the "a single image is ready" intent.

---

## 10. Cross-references

- `copywriting-mastery.md` — the 10 laws, 12 hook patterns, 4 caption frameworks, BR voice (REQUIRED reading for any image post)
- `editorial-design.md` — the 6 movements, type contrast law, photo treatment, brand bar system (REQUIRED reading for composition)
- `carousel-mastery.md` §10-§11 — slide skeleton + font embedding (shared infra)
- `carousel-mastery.md` §10.1.5 — image inlining rule (applies identically here)
- `carousel-visual-preview.md` — artifact preview protocol (single-image artifact is the same with N=1)
- `smart-rendering.md` — Path A vs Path B render decision
- `platform-settings.md` — per-network publish settings (CRITICAL — without this the user's "story" goes to feed)

The image-mastery workflow is shorter than the carousel workflow because single images don't need a narrative arc. But the editorial-design + copywriting + autonomous rigor is the same. A single image done right outperforms a carousel done lazy — every time.
