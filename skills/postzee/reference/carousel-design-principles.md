# Carousel Design Principles — Visual Discipline

This file governs the **visual language** of every carousel: how text and elements are arranged on each 1080×1350 slide, how dark and light slides alternate to create rhythm, and which patterns the agent must avoid because they read as amateur.

It works alongside `carousel-mastery.md` (which contains the actual CSS / HTML templates) and `carousel-quality-manual.md` (which governs the *content* density). Together they produce carousels that feel produced — not generated.

---

## 1. The three-tier hierarchy

Every slide has exactly **three levels of information**, and only three. Mixing levels collapses the hierarchy and creates noise.

### Tier 1 — Anchor

The single dominant element. The reader's eye lands here first.

- On the cover: the headline (88-108px)
- On internal slides: the slide title (64-80px) **OR** a big stat (160-240px) **OR** a quote
- On the CTA: the action verb

**Rule:** One anchor per slide. Two competing big elements = no hierarchy = reader skips.

### Tier 2 — Context

Two to three medium-weight elements that support the anchor.

- Body paragraphs (36-40px)
- Sub-headings (28-32px)
- Side captions
- The data table behind a stat

### Tier 3 — Metadata

Small functional elements: tag/label, slide number, brand bar, progress bar, source line.

- Tags / labels (13px 700)
- Page indicator (3 / 9)
- Source attribution (16-20px)
- Brand bar at the bottom

**Rule:** Tier 3 is *always present, never noticed*. If your eye lingers on a tag, it's too big.

---

## 2. The dark / light rhythm

Carousels feel produced when their slides **alternate** between dark and light backgrounds. Same-tone runs of 3+ slides create monotony — the reader senses the carousel "not progressing".

### 2.1 The canonical 9-slide rhythm

| Slide | Tone | Function |
|---|---|---|
| 1 | Dark (capa) | Headline anchored on full-bleed image OR dark gradient |
| 2 | Dark | Tension setup |
| 3 | Light | Data + reading |
| 4 | Dark | Friction + reframe |
| 5 | Light | Big stat + implication |
| 6 | Dark | Case + mechanism |
| 7 | Light | Counterpoint + resolution |
| 8 | Gradient | Future direction + trade-off |
| 9 | Dark (CTA) | Frase-ponte + CTA |

Reads as a sequence of waves. The gradient slide breaks pattern intentionally — it signals direction (the carousel is pointing forward).

### 2.2 Why this specific cadence

**Dark slides carry tension.** The reader interprets dark backgrounds as "intensity" / "stakes" / "concentration". Use dark for friction, conflict, the contrarian moment.

- Max body density on dark: **80 words**
- Max heading length on dark: **8 words**
- Body color: `rgba(255,255,255,0.85)` — never pure white (too bright on dark = reader fatigue)

**Light slides carry data.** The reader interprets light as "information / clarity / breath". Use light for evidence, statistics, comparisons, lists.

- Max body density on light: **100 words**
- Max heading length on light: **10 words**
- Body color: `#475569` (slate-600) — never pure black (too high contrast = harshness)

**Gradient slides carry direction.** Use sparingly — slide 8 of a 9-carousel, slide 6 of a 7-carousel. Gradient signals movement; the reader feels the carousel pivoting forward.

### 2.3 Cadence violations to detect

- ❌ 3+ dark slides in a row → reader feels the wall, scrolls past
- ❌ All-light carousel → no tension, reads as passive
- ❌ Random alternation (D-L-D-D-L-L-D…) → no pattern = no rhythm
- ❌ Gradient on every slide → loses meaning

---

## 3. The lower-third rule (vertical composition)

Within each slide's content area, **the body content sits in the lower third**. Use `display: flex; flex-direction: column; justify-content: flex-end;` on the slide container with `padding: 100px;` (or 120px when dense).

Why:
- Reader's thumb covers the lower-right of the screen on Instagram. Content low = readable while scrolling.
- The accent bar at top and the brand/progress bar at bottom create natural framing — content concentrated at lower-third uses the visual weight of those framing elements.
- The headline at top of cover slides is the exception (it dominates) — but on internal slides, top is brand identifiers, bottom is body.

### 3.1 Specific layout patterns

**Internal dark slide:**
```
┌──────────────────────────────────┐
│ ▓▓▓▓ ACCENT BAR (7px gradient) ▓▓│
│                                  │
│                                  │
│                                  │
│                                  │
│  TAG  →  CASE                    │
│                                  │
│  HEADING (72-80px)               │
│  Two lines max                   │
│                                  │
│  Body paragraph (36px). One      │
│  paragraph. ~22 words.           │
│                                  │
│ ▓▓▓ progress 6/9 ▓▓▓             │
│ @handle | YYYY                   │
└──────────────────────────────────┘
```

**Internal light slide:**
```
┌──────────────────────────────────┐
│ ▓▓▓▓ ACCENT BAR ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓│
│                                  │
│                                  │
│                                  │
│  TAG  →  DADO                    │
│                                  │
│  HEADING                          │
│ ▔▔▔ (border-left 7px primary)    │
│  Body paragraph (36px). Up to    │
│  two paragraphs separated by     │
│  generous spacing.               │
│                                  │
│  Source: NomeDaFonte 2025        │
│                                  │
│ ▓▓▓ progress 5/9 ▓▓▓             │
│ @handle | YYYY                   │
└──────────────────────────────────┘
```

The card-with-border-left pattern is the **light-slide signature** — primary color border on the left edge of the heading block, 7px wide, body content flowing below.

---

## 4. Type scale — non-negotiable

Use these exact ranges. Don't improvise outside them.

| Element | Min | Max | Weight | Letter-spacing |
|---|---|---|---|---|
| Cover headline (slide 1) | 88px | 108px | 900 | -0.025em |
| Cover sub-headline | 24px | 32px | 700 | 0.12em uppercase |
| Dark internal heading | 72px | 80px | 800 | -0.02em |
| Light internal heading | 64px | 72px | 800 | -0.02em |
| Big stat (when present) | 160px | 240px | 900 | -0.04em |
| Body | 36px | 40px | 500 | 0 |
| Tag / label | 13px | 13px | 700 | 0.24em uppercase |
| Source / footer | 16px | 20px | 500 | 0 |
| Brand bar | 14px | 16px | 500 | 0.04em |

### 4.1 The "headline cabe ou não cabe" rule

The chosen headline goes on the cover **whole**. The agent does not summarize it.

Decision tree:

1. Render at 108px. Fits in 5 lines? → **use 108px.**
2. Doesn't fit at 108px? → render at 96px. Fits in 5 lines? → **use 96px.**
3. Still doesn't fit? → render at 88px. Fits in 5 lines? → **use 88px.**
4. Still doesn't fit at 88px? → **stop and ask the user**: "Essa headline não cabe na capa nem em 88px (5 linhas). Posso encurtar para [versão mais curta], ou você prefere escolher uma das outras 9?"

**Never go below 88px.** Below that, the headline becomes unreadable on a phone screen.

---

## 5. Color application discipline

### 5.1 The accent rule

The brand primary (accent color) appears on **at most 3 words per slide** — and on only one place per slide.

✅ One word in the heading + the tag + the border-left → 1 visual zone, 3 words
❌ One word in the heading + a word in the body + the border + a number → too many anchor points

### 5.2 The 60-30-10 rule

On every slide, color usage roughly follows:
- **60%** dominant background (light bg or dark bg)
- **30%** secondary text/element color
- **10%** accent (primary brand color)

If accent climbs above 10% the slide reads garish. If below 5% the brand identity disappears.

### 5.3 The cover gradient overlay (when there's a hero photo)

When the cover uses a full-bleed photo:

```css
background: linear-gradient(
  180deg,
  rgba(0,0,0,0.10) 0%,
  rgba(0,0,0,0.55) 40%,
  rgba(0,0,0,0.85) 100%
), url(...) center/cover;
```

The gradient ramp protects readability of the headline at the bottom regardless of photo content.

### 5.4 The 70%+ overlay rule (dark internal with photo)

If a dark internal slide uses a photo as background, the dark overlay must reach at least **70% opacity at the body text region** — otherwise body text fights the photo for attention and both lose.

---

## 6. The 9-item visual checklist (run before render)

Before calling `POSTZEE_RENDER_CAROUSEL`, mentally walk every slide through this checklist. **Any failure blocks render.**

1. ☐ Single anchor per slide (one Tier-1 element only)
2. ☐ Body content sits in the lower-third (flex-end positioning)
3. ☐ Dark/light rhythm matches the canonical pattern (§2.1)
4. ☐ Accent color used in ≤ 3 words per slide
5. ☐ No nested cards (card inside a card → flatten)
6. ☐ Heading typography within range (§4)
7. ☐ Body paragraphs within word count for slide tone (§2)
8. ☐ Progress bar shows correct N/total
9. ☐ Brand bar present and identical across all slides

---

## 7. Anti-patterns — kill on sight

| Anti-pattern | Why it fails | Fix |
|---|---|---|
| **Centered body text on internal slides** | Reads as decorative, not informative. Body should flow left-aligned (or right in RTL contexts). | Left-align. Reserve center for cover headline + CTA verb only. |
| **Two paragraphs of equal weight** | No progression. Reader doesn't know what to take away. | One dominant block + one supporting block. Different sizes, different typographic weight. |
| **Accent on > 3 words per slide** | Visual noise. Reader's eye doesn't know where to go. | One accent zone. Highlight the contrarian word, not the whole sentence. |
| **Card inside a card** (nested boxes) | Web-app aesthetic. Carousel slides are flat compositions. | Flatten to a single composition. |
| **Drop shadows on text** | Cheap presentation aesthetic. | Use only for the logo treatment (§Logo in carousel-mastery.md). |
| **Too many fonts (>2)** | Inconsistent identity. | One display font + one body font. Maximum 2. |
| **Justified text** | Awkward word spacing on mobile, especially on Portuguese. | Always left-align body text. |
| **Pure black `#000` text on pure white `#FFF`** | Harsh contrast, eye fatigue. | Use slate-700 / slate-900 on light bg; rgba(255,255,255,0.85) on dark. |
| **Pure white `#FFF` body text on dark** | Too bright for paragraph reading. | rgba(255,255,255,0.85) for body, white for headings only. |
| **Numbered lists as primary structure** ("1. ... 2. ... 3. ...") | Tutorial register, not editorial. | Continuous prose with embedded structure. |
| **Bullet points spreading the slide** | Reads as a checklist, not analysis. | One paragraph or one mini-table. |
| **Emojis as decoration** | Influencer aesthetic. | Cut. Reserve for tags ("→") or arrows in lists when functional. |
| **Stock-photo-style icons (lightbulb, rocket, gear)** | Generic. | If iconography is needed, use a single typographic mark (✕, →, †). |
| **Gradients that don't match brand palette** | Visual mismatch. | Gradient must use brand primary + secondary, never random. |
| **Headlines wrapped to a fixed character width** (`max-width: 20ch`) at the wrong size | Awkward orphan words. | Test the actual line break at the actual size. |
| **Inconsistent number formats** | Slide 4 says "4", slide 7 says "07" → reader notices. | Pick one (typically `04` zero-padded for index, raw `Nº` for stats). |
| **Brand bar inconsistent across slides** | Looks like 9 separate posts, not one carousel. | Identical brand bar, exact same position, identical typography. |
| **Progress bar moving in unexpected direction** | Reader confused. | Always left-to-right fill. |

---

## 8. The cover slide — a separate craft

The cover is **50% of the carousel's success**. It either earns the swipe or it doesn't. Treat it differently than internal slides.

### 8.1 Cover layout principles

- **Headline at lower-third** (not centered, not at top) — gives the eye somewhere to rest before the swipe
- **Brand handle on top** — small badge with the user's profile picture (circular, white ring) + handle
- **Headline ABOVE everything**, even if it's a photo cover — the photo is backdrop, not subject
- **Accent bar at very top** (7px gradient)
- **Optional sub-headline** (3-line description) below the headline — only if the headline benefits from a single line of context

### 8.2 Cover composition variants

**A. Typographic cover** (no photo)
- Solid dark background OR brand-color gradient
- Massive headline at lower-third
- Accent line above the headline
- Brand handle top-right

**B. Photo + headline cover** (most common)
- Full-bleed vertical photo (4:5 ratio matches slide)
- Gradient overlay (§5.3)
- Headline at lower-third in white
- Brand handle top-right

**C. Tag-driven cover** (when tag carries weight)
- Big tag at top center ("INVESTIGAÇÃO 03 / 12")
- Headline below
- Photo or solid bg

The cover decision happens during Phase 2 (script approval) — confirm with the user which variant before composing HTML.

---

## 9. Image-component rules

### 9.1 The `.img-box` (360px tall, 1080px wide)

For internal slides where text is < 60% of the slide's normal density, fill the visual gap with an `.img-box`:

```html
<!-- The url() value MUST be a base64 data URI in v3.6+ (e.g.
     url('data:image/jpeg;base64,/9j/4AAQSk...')). External CDN URLs
     are blocked by the Claude artifact CSP — the preview won't render.
     See carousel-mastery.md §10.1.5 for the inlining workflow. -->
<div class="img-box" style="
  width: 100%;
  height: 360px;
  background: url('data:image/jpeg;base64,...') center/cover;
  border-radius: 12px;
  margin: 40px 0;
"></div>
```

**Use when:**
- The block has a single short data point + reading
- The slide would otherwise feel sparse
- The user provided enough images that distributing them across slides 3, 5, 6 makes sense

**Don't use when:**
- The slide is already dense (full word target)
- The image is decorative rather than informative

### 9.2 Full-bleed dark slide with photo overlay

For a dark slide where the photo is the *atmosphere* (not the data):

```html
<!-- The <img> src MUST be a base64 data URI in v3.6+. External URLs
     break the artifact preview (Claude CSP blocks remote fetches).
     See carousel-mastery.md §10.1.5. -->
<div style="
  width:1080px;height:1350px;position:relative;overflow:hidden;
">
  <img src="data:image/jpeg;base64,..." style="
    position:absolute;inset:0;width:100%;height:100%;
    object-fit:cover;
  ">
  <div style="
    position:absolute;inset:0;
    background:linear-gradient(180deg,
      rgba(0,0,0,0.55) 0%,
      rgba(0,0,0,0.85) 100%);
  "></div>
  <div style="position:relative;z-index:2;...content...">
    <!-- heading + body in lower-third -->
  </div>
</div>
```

### 9.3 Image distribution across the carousel

If the user provides N images, distribute them according to:

| N | Distribution |
|---|---|
| 1 image | Cover only (variant B) |
| 2 images | Cover + slide 6 (case) full-bleed dark |
| 3 images | Cover + slide 4 (friction dark, full-bleed) + slide 6 (case dark, full-bleed) |
| 4-5 images | Cover + dark slides (2, 4, 6) + one .img-box on a light slide |
| 6+ images | Distribute one per non-CTA, non-cover slide; .img-box on light slides, full-bleed on dark |

If user provides zero images — don't fabricate. Typography-only carousels work — the brand identity carries through font + color + accent + brand bar.

---

## 10. The progress bar — small detail, big signal

Every slide except the cover and CTA has a **3px-tall progress bar** at the bottom edge of the content area (above the brand bar). It shows N/total filled in primary color.

```html
<div style="
  display: flex;
  width: 100%;
  height: 3px;
  background: rgba(255,255,255,0.15); /* or rgba(0,0,0,0.08) on light */
  border-radius: 2px;
  overflow: hidden;
  margin-top: auto;
  margin-bottom: 16px;
">
  <div style="
    width: calc(100% * (N / TOTAL));
    height: 100%;
    background: var(--brand-primary);
  "></div>
</div>
```

- N = current slide number (1-based)
- TOTAL = total slide count

The progress bar is the **single most under-used signal** in 2026 carousels — it tells the reader "you're 60% in, swipe to finish" subliminally. Always include it.

---

## 11. The brand bar (footer)

```
@handle | YYYY
```

That's it. **No "Powered by"**, no platform attribution, no third-party mention. Just the user's handle and the year, in a quiet 14-16px line at the bottom of every slide.

```html
<div style="
  margin-top: 8px;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 0.04em;
  opacity: 0.5;
  color: inherit;
">
  @USER_HANDLE | 2026
</div>
```

The brand bar is identical on every slide — same typography, same opacity, same position. Inconsistency here makes the carousel read as 9 separate posts rather than one piece.

---

## 12. The accent bar (top of every slide)

```html
<div style="
  position: absolute;
  top: 0; left: 0;
  width: 100%; height: 7px;
  background: linear-gradient(
    90deg,
    var(--brand-primary) 0%,
    var(--brand-secondary) 100%
  );
"></div>
```

7px tall, full width, brand gradient. **On every slide, including the cover and CTA.** It is the single visual element that unifies the carousel into one piece.

---

## 13. The four visual styles

The user picks one of four visual styles in the brief (`carousel-mastery.md` §Briefing Criativo). Each style sets default font pairings and accent treatments — they are starting points, not prisons.

### 13.1 Clássico

- Headline font: `Playfair Display` (serif, 700/800/900)
- Body font: `Inter` (sans, 500/600/700)
- Accent treatment: subtle, refined — no neon
- Use when: editorial / longform / brands with heritage

### 13.2 Moderno

- Headline font: `Bricolage Grotesque` (geometric sans, 700/800/900)
- Body font: `Inter` (500/600/700)
- Accent: bold, saturated
- Use when: tech, SaaS, fintech, contemporary brands

### 13.3 Minimalista

- Headline font: `Inter` (humanist sans, 700/800/900)
- Body font: `Inter` (500)
- Accent: monochrome with one thin color stripe
- Lots of whitespace
- Use when: minimalist brands, design studios, premium services

### 13.4 Bold

- Headline font: `Anton` (display extra-bold, 900)
- Body font: `Inter` (500/700)
- Accent: maximum contrast — black/white or color-block
- Compressed letter-spacing on headlines
- Use when: fitness, sports, energetic brands, urgency content

### 13.5 Outro (user-described)

The user can describe a custom style ("quero algo que pareça newsletter do NYT — serif, espaço branco, poucos elementos"). The agent translates it to:
- A font pair (one display + one body)
- A color discipline (mono / monochrome accent)
- A density level (low / medium / high)

---

## 14. Niche-specific palettes

When the user has no brand colors and isn't sure, propose a palette based on their niche. These have been calibrated against in-platform performance.

| Niche | Primary | Accent | Light bg | Dark bg | Style default |
|---|---|---|---|---|---|
| Marketing Digital | `#6366F1` | `#A855F7` | `#FAFAF9` | `#0F172A` | Moderno |
| Imobiliário | `#1E3A5F` | `#C9A961` | `#F8F5F0` | `#0A1A2A` | Clássico |
| Fitness | `#FF3B30` | `#FFCC00` | `#FAFAF9` | `#0A0A0A` | Bold |
| Gastronomia | `#8B4513` | `#E8A33D` | `#FFF8E7` | `#1F0F0A` | Clássico |
| Moda / Beleza | `#FF6B9D` | `#FFC9D9` | `#FFF5F7` | `#1F0A14` | Minimalista |
| Educação | `#0EA5E9` | `#22C55E` | `#F0F9FF` | `#0C1E2C` | Moderno |
| Tech / SaaS | `#7C3AED` | `#06B6D4` | `#FAFAFA` | `#0F0A1F` | Moderno |
| Advocacia | `#1F2937` | `#B59B6A` | `#F5F3EE` | `#0F1419` | Clássico |
| Contabilidade | `#0F4C81` | `#3DB39E` | `#F0F4F8` | `#0A1A2E` | Minimalista |
| E-commerce | `#FF6B35` | `#0F4C81` | `#FFFAF5` | `#0A1A2E` | Moderno |
| Pet / Veterinária | `#34B3A0` | `#F4A261` | `#F5FAF8` | `#0A1F1A` | Moderno |

The user can override at any time. The palette is a starting point.

---

## 15. The visual identity propagation rule

Once the user picks (or is auto-assigned) a visual style + palette, **every slide** in the carousel carries:

- Same primary color
- Same accent color
- Same fonts
- Same bg tones (alternating dark/light per §2)
- Same brand bar
- Same accent bar
- Same progress bar style

Visual variety comes from **layout** (full-bleed photo vs typographic vs big-stat), **NOT from changing colors / fonts / accents mid-carousel**. A user changing fonts between slides 4 and 7 is the surest signal of an amateur carousel.

---

## 16. Iteration discipline

When the user asks for a visual change to one slide ("muda o slide 5 pra dark"):

1. **Don't change the carousel-wide palette** — only the requested slide.
2. **Recompute the dark/light rhythm** — if changing slide 5 to dark creates 3 dark slides in a row, surface that to the user before applying.
3. **Use `POSTZEE_REPLACE_CAROUSEL_SLIDE`** — surgical replacement, not full re-render.

When the user asks for a carousel-wide change ("o accent ficou muito tímido, deixa mais forte"):

1. **Update the CSS variables** in every slide.
2. **Re-render via `POSTZEE_RENDER_CAROUSEL`** with the new sequence — the old MediaGroup remains in history; user can soft-delete from gallery.

---

## 17. The final visual gate

Before submitting HTML to render, the agent runs the 9-item checklist (§6). If all pass — render. If any fail — fix first.

**A carousel that ships visually wrong is harder to recover than one that ships textually wrong.** Text can be `REPLACE`d slide by slide. Visual identity drift requires full re-render.

So: spend the time at this gate.
