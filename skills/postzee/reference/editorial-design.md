# Editorial Design — The Visual System

This file is the agent's design brain. It exists because **the same headline lands differently depending on the typography, the composition, the color rhythm, and the photo treatment**. A great hook in a generic layout looks like Canva. The same hook in editorial composition looks like a magazine cover.

The agent reads this file before composing any HTML for `POSTZEE_RENDER_IMAGE`, `POSTZEE_RENDER_CAROUSEL`, or the artifact preview that precedes them.

What this codifies (synthesized from professional magazine design, top-performing social accounts at >1M followers, and the 6 design movements that dominate the 2026 editorial-social landscape):
- The 6 canonical design movements with full typography + composition + color specs
- Type contrast law (the single biggest factor in "looks designed vs. looks generic")
- Photographic treatment rules — how to make stock/AI-generated photos look intentional
- Color extracted from photo — algorithm for harmonized palettes
- Brand bar system — 8 canonical positions and when each works
- Highlight block system — the orange/red/underline emphasis treatments that drive viral content
- The 9-item visual polish checklist that runs before every render

---

## 1. The 6 Design Movements

Every social media post lives in one of these 6 movements. The agent picks the one matching the brand's `Visual style` answer from briefing stage 1, then composes within its rules.

### 1.1 Editorial — magazine-class authority

**When to use**: news / analysis / B2B thought leadership / journalism-grade content. Audiences that read New Yorker, Folha de S.Paulo, Linha Aberta. The default for `@gpt_academico`-tier content.

**Typography**:
- **Display**: Playfair Display 800/900, OR Bricolage Grotesque 800, OR GT Sectra Display 700/900 (when budget permits paid fonts)
- **Body**: Inter 500/700, OR Söhne 400/600, OR Neue Haas Grotesk Text Pro 55/75
- **Italic accent**: Playfair Display Italic 600, used for emotional emphasis (the "*jeito*" italic pattern in image #18 example)

**Typography rules**:
- Display size: 88-128pt (slide cover) / 64-88pt (internal slides)
- Body size: 18-22pt
- Caption size: 12-14pt
- Letter-spacing: -0.02em on display, -0.005em on body, +0.04em on caption (small caps)
- Line-height: 0.95 on display, 1.4 on body, 1.6 on caption

**Color system**:
- Off-white background: `#FAFAF9` or `#F7F5F0`
- Text dark: `#1A1A1A` (not pure black — too harsh on display)
- Accent: a single deep color from the brand palette, used for *one* italic word per slide and the brand bar underline
- Generous use of light → dark rhythm (alternate slides)

**Composition**:
- Top brand bar: handle + page indicator (e.g., `@gpt_academico` left, `01/09` right)
- Wide gutters (~80px) left and right
- Display headline starts at vertical center, breaks across 2-4 lines
- Body 60% of available horizontal space, ragged-right
- Bottom: optional CTA or attribution line

**Reference accounts**: `@gpt_academico`, `@Stripe`, `@Linear`, `@Atlassian` brand carousels

---

### 1.2 Bold — viral attention engineering

**When to use**: creator/influencer accounts, marketing, growth content, social media tips, hot takes. Audiences scrolling fast in feed.

**Typography**:
- **Display**: Anton 700 (free), OR Inter 900/Black, OR Druk Wide 800 (paid)
- **Body**: Inter 600/700
- **Highlight emphasis**: same display, but in highlight block (see §6)

**Typography rules**:
- Display size: 96-144pt (slide cover, MAX impact)
- Body size: 22-28pt
- ALL-CAPS allowed for display only — body always Title Case or sentence case
- Letter-spacing: -0.03em on display (tight, dense)
- Line-height: 0.85 on display (almost touching), 1.3 on body

**Color system**:
- Background: solid color (black `#0A0A0A`, white `#FFFFFF`, brand-primary saturated)
- Text contrast: maximum (black-on-white, white-on-black, or white-on-brand)
- Highlight block: orange `#F97316` or red `#DC2626` or yellow `#FACC15` for hook word(s)

**Composition**:
- No-gutter or very tight gutters (~30px)
- Headline DOMINATES the slide — often 60-70% of vertical space
- Body shrinks to support role
- Highlight block treats one or two key words within the headline
- Bold arrow/icon at bottom-right for "swipe" or "click"

**Reference accounts**: `@gpt_academico` (mixes Editorial and Bold; the high-engagement posts skew Bold), `@hormozi`, top creator BR feeds

---

### 1.3 Minimal — confident silence

**When to use**: premium product, design-conscious brands, B2B SaaS, agency portfolio. Audiences for whom less = more sophisticated.

**Typography**:
- **Display**: Inter 800/900 (NOT serif — Minimal stays sans), OR Söhne Halbfett, OR Suisse Int'l Black
- **Body**: Inter 400/500, OR Söhne Buch 400
- Single typeface system; weight contrast carries hierarchy

**Typography rules**:
- Display size: 56-80pt (intentionally smaller than Editorial — minimal owns its space differently)
- Body size: 16-20pt
- Letter-spacing: -0.01em display, 0 body
- Line-height: 1.1 display, 1.5 body

**Color system**:
- Background: pure white `#FFFFFF` or warm off-white `#FAFAF9`
- Text: medium-gray `#525252` for body, near-black `#171717` for display
- Accent: single brand color used VERY sparingly — one element per slide max

**Composition**:
- WIDE margins (~120-160px)
- Massive negative space (50%+ of slide is empty)
- Headline never touches edge — always floats in the upper third
- Body small and centered or left-aligned
- Brand bar minimal: just a small wordmark or asterisk-style mark
- NO icons, NO arrows, NO highlight blocks

**Reference accounts**: `@Notion`, `@Linear`, `@Vercel`, `@stripe`

---

### 1.4 Photo-led — emotional anchor

**When to use**: personal brand (creator with a face), lifestyle content, product photography, narrative storytelling. Audiences that connect with a person, not a logo.

**Typography**:
- **Display**: serif italic (Playfair Italic 800) for emotional headline, OR clean sans heavy (Inter 900)
- **Body**: Inter 500
- Display sized to NOT compete with the photo — type is the punctuation, photo is the sentence

**Typography rules**:
- Display size: 56-88pt
- Body size: 18-22pt
- Display always has high contrast against photo (white over dark, dark over light)
- Type lives in lower-third or vertical edge — never centered over a face

**Color system**:
- Background: the photo itself, full-bleed (1080×1350 or 1080×1920)
- Type color extracted from photo's complementary palette (see §4)
- Optional gradient overlay (`rgba(0,0,0,0.55)` to `rgba(0,0,0,0.85)`) on the lower third to make type legible
- Accent: one of the photo's existing colors, used for a single underline or icon

**Composition**:
- Hero photo: rule of thirds, subject's eyes on upper third line, never centered
- Subject not pure-frontal — slight 3/4 angle reads more emotional
- Brand bar top-corner: small, semi-transparent (white with low opacity on dark photos)
- Headline lower-third or right-vertical edge
- Bottom CTA badge with rounded corners and shadow

**Reference accounts**: examples in image #18 (creator portraits), `@dieter` (Verge), `@cnnbrasil` photo-essay format

---

### 1.5 Magazine — long-form editorial

**When to use**: deep dive, case study, narrative analysis. When the content itself is the value (not just the hook). Audiences willing to read.

**Typography**:
- **Display**: GT Sectra Display 700, OR Editorial New 700, OR Tiempos Headline 700/800
- **Body**: GT Sectra Text 400, OR Tiempos Text 400/500 — serif body, classical magazine register
- Italic for byline, subheads
- Drop cap on first paragraph (Adobe Caslon-style)

**Typography rules**:
- Display size: 64-96pt — restrained compared to Editorial; the dignity comes from the words
- Body size: 18-20pt (serif body is read longer; can be smaller than sans)
- Letter-spacing: classical typesetting (-0.005em display, 0 body)
- Line-height: 1.1 display, 1.55 body
- Justified body with hyphenation OK
- Wide first-line indent (1em) on paragraphs after the first

**Color system**:
- Cream background: `#FAF6F0` or `#F6F0E6`
- Body text: `#2A2620` (warm dark)
- Accent: deep burgundy / forest / navy / brand color, used for subheads and pull-quotes
- Rule lines: 1px hairlines in `#C8BFB1` (warm gray) between sections

**Composition**:
- Strict grid: 6 or 12 columns with consistent gutters
- Headline + standfirst at top, body underneath in 2-column or 1-column layout
- Pull quotes in italic, larger, indented
- Page indicator and date in masthead style (top corners)
- Section breaks marked with center-aligned ornament (asterism `* * *` or small filigree)

**Reference accounts**: `@nytimes` carousel format, `@theatlantic`, `@piaui_magazine` (BR)

---

### 1.6 Brutalist — anti-design design

**When to use**: subculture, edgy creator, tech/dev/builder community, anything intentionally NOT polished. Audiences that distrust corporate polish.

**Typography**:
- **Display**: Helvetica Bold / Inter Black / system-ui at extreme sizes (no fancy display fonts)
- **Body**: Inter / Helvetica Regular
- Monospace permitted for technical content (JetBrains Mono, IBM Plex Mono)

**Typography rules**:
- Display size: 80-160pt — comically large
- Body size: 14-18pt — small to contrast the display
- Letter-spacing: 0 (default — no fine kerning)
- Line-height: 0.9 display, 1.4 body
- Mixed weights ALLOWED within a single headline ("bold WORD regular word")

**Color system**:
- Background: stark — pure black, pure white, or saturated single color (yellow, red, blue, green)
- Text: pure white or pure black
- NO gradients, NO drop shadows, NO rounded corners
- Accent via background blocks of saturated color (rectangular, no border-radius)

**Composition**:
- Asymmetric, intentionally "wrong" — headline overflows, breaks margins
- Grid is violated intentionally
- Photos cropped harshly, often at unexpected angles
- Brand bar in unusual position (rotated 90deg, or HUGE in bottom corner)
- Visible structural elements: black bars, color blocks, raw rectangles

**Reference accounts**: `@figma` (some carousels), `@craft_dot_do`, builder/dev tech accounts; underground BR design accounts

---

## 2. The Type Contrast Law

Single biggest factor separating "looks designed" from "looks generic". The agent enforces it on every slide.

**Rule**: the ratio of display font-size to body font-size must be at least **4:1**, ideally **5-7:1**.

Examples:
- Display 96px / Body 22px = 4.4:1 ✓
- Display 128px / Body 22px = 5.8:1 ✓ (better — more editorial impact)
- Display 64px / Body 22px = 2.9:1 ✗ (looks like a default slide deck)
- Display 32px / Body 16px = 2:1 ✗ (looks like a blog post)

When a slide has ONLY display (no body) — even more important the display is sized for impact: minimum 96pt cover, 80pt internal.

When a slide has THREE type levels (display + subhead + body), maintain the contrast:
- Display 128px / Subhead 36px / Body 22px = 3.6:1 + 1.6:1 (still passes)
- Display 96px / Subhead 56px / Body 28px = 1.7:1 + 2:1 (fails — too compressed)

**Why this matters**: Eye trajectory. The display catches the scroll → eye reads it → eye drops to body for context → eye finishes on CTA. Without high contrast, the eye doesn't have a clear path. It bounces.

---

## 3. Bold Caps — the 3 permitted use cases

Bold + all-caps is loud. Most slides shouldn't have it. The 3 exceptions:

1. **One-word interrupt** at the top of a slide: `URGENTE.` `FINALMENTE.` `ATENÇÃO:` — 4-8 chars max, period at end
2. **Brand bar** (small, ~12-14pt, with letter-spacing +0.08em — makes it elegant, not loud)
3. **Highlight block emphasis** within a sentence (see §6) — and even there, prefer italic over bold caps unless the brand voice is Bold movement (§1.2)

Outside these 3 cases: **DON'T**. The reasons:
- Bold caps over-uses an attention asset (the visual SHOUT)
- It reads as marketing/desperation in any context except interrupt
- Italic (when typeface supports it) carries emotional emphasis with more sophistication

The image #18 right example: "comunicar de um *jeito* mais seu" — italic on the emotional word. Bold caps would have killed the intimacy.

---

## 4. Color Extracted from the Photo

For Photo-led layouts (§1.4) and any slide with a full-bleed image, the color palette MUST be derived from the photo itself — not chosen arbitrarily.

**Algorithm the agent runs**:

1. **Extract 3 dominant colors** from the hero photo (use perceptual clustering — k-means in LAB color space if implementing programmatically; for the agent, eyeball it from the photo)
2. **Assign roles**:
   - **Background** — the most muted of the 3 (often a wall, sky, or out-of-focus area)
   - **Type-on-photo** — the color with HIGHEST contrast to where the type sits (typically pure white on dark photo, dark text on light photo)
   - **Accent** — one of the photo's vibrant colors, used for the brand bar underline / one italic word / a small CTA button
3. **Validate contrast**: type/background must pass WCAG AA (4.5:1 for body text, 3:1 for display 24pt+)
4. **Resist color clichés**: don't add colors that AREN'T in the photo. The harmony comes from staying inside the photo's palette.

Worked example (image #18 center — multigenerational family in lavender):

```
Dominant colors:
  1. Lavender (~#C9B6E2)
  2. Cream skin tone (~#E8D4C7)
  3. Warm brown hair (~#634A3D)

Assignments:
  Background — lavender (#C9B6E2)
  Type — warm brown (#634A3D) — high contrast against lavender, harmonized
  Accent — deep purple variant for the brand badge top-left (#7C5BB8)

Result: a palette that LIVES in the photo, not over it.
```

When the photo is grayscale or color-graded: use shades of the dominant temperature (warm vs cool) for type + accent. Black-on-warm-gray reads richer than black-on-pure-white when the photo is warm-toned.

---

## 5. The Brand Bar System

The brand bar is the persistent identity element (account handle, logo, page indicator) that runs across every slide. 8 canonical positions:

| Position | Layout | When to use |
|---|---|---|
| **A. Top-left** | `@handle` small (12-14pt), regular weight | Most carousels. Universal default. |
| **B. Top-right** | Page indicator (`01/09`) small | Pair with A for editorial layouts |
| **C. Top-center** | Wordmark or symbol centered | Magazine movement (§1.5) — masthead style |
| **D. Bottom-left** | `@handle` + small horizontal rule | Photo-led layouts; preserves clean top for headline |
| **E. Bottom-right** | Small icon/CTA badge | When CTA dominates the bottom |
| **F. Vertical-left (rotated)** | `@handle` rotated 90deg | Brutalist (§1.6) — confident weirdness |
| **G. Floating brand badge** | Small rounded badge with logo + icons (bookmark, heart, share — see image #18 center) | Photo-led personal brand |
| **H. Inline with content** | Brand handle as part of the headline ("by @handle") | Quote slides, attributions, op-eds |

**Consistency rule**: pick ONE position and use it on EVERY slide of a carousel. Switching brand-bar position mid-carousel = visual whiplash.

**Page indicator format**:
- Editorial: `01/09` or `01 of 09`
- Bold: `1/9` or just `→` arrow on last slide
- Magazine: `Page 1 — May 15, 2026` (masthead style)
- Photo-led: `01 02 03 04 05` (line of numbers, current one bolded — see image #18 left)
- Minimal: nothing, OR a tiny `1·9` dot-separated

---

## 6. The Highlight Block System

Color-coded text emphasis that drives engagement in the Bold and Editorial movements. 3 canonical styles:

### 6.1 The Orange Bar (warm urgency)

```html
<span style="
  background: #F97316;
  color: #1A1A1A;
  padding: 4px 12px 6px;
  border-radius: 4px;
  font-weight: 800;
  line-height: 1.2;
  display: inline-block;
">FINALMENTE</span>
```

Use for: pattern-interrupt openings, positive surprises ("FINALMENTE", "AGORA SIM"). Black text on orange = max readability + warmth.

### 6.2 The Red Box Caps (alert/urgency)

```html
<span style="
  background: #DC2626;
  color: #FFFFFF;
  padding: 6px 14px 8px;
  font-weight: 900;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  display: inline-block;
">URGENTE</span>
```

Use for: time-bound calls, deadlines, "URGENTE", "AGORA OBRIGATÓRIO". White on red — high alert. Sparingly — overuse kills the alert.

### 6.3 The Underline Accent (subtle emphasis)

```html
<span style="
  background: linear-gradient(180deg, transparent 65%, #FACC15 65%, #FACC15 95%, transparent 95%);
  padding: 0 2px;
">o que realmente importa</span>
```

Use for: highlighting key phrases within a body sentence without breaking flow. Highlighter-marker style — feels handwritten, not loud. Yellow `#FACC15`, soft orange `#FCD34D`, or pale pink `#FBCFE8`.

**Rule**: at most ONE highlight block per slide. Two blocks on one slide = competing emphasis = no emphasis. The whole point of a highlight is it's the ONE thing that stops the eye.

---

## 7. Composition Anatomy — the 4-zone slide

Every slide (cover or internal) divides into 4 zones with predictable purpose:

```
┌─────────────────────────────────────────────┐
│ ZONE 1 — Brand bar (top 8% — 108px)         │
│   @handle · 01/09                           │
├─────────────────────────────────────────────┤
│ ZONE 2 — Display headline (next 40-50%)     │
│   The hook. Largest type. Most negative     │
│   space around it.                          │
├─────────────────────────────────────────────┤
│ ZONE 3 — Supporting content (next 30-40%)   │
│   Body, photo, chart, quote, or            │
│   sub-headline. Smaller type.              │
├─────────────────────────────────────────────┤
│ ZONE 4 — CTA / page indicator (bottom 10%)  │
│   Arrow, badge, "swipe →", or attribution. │
└─────────────────────────────────────────────┘
```

Proportions vary by slide type (cover vs. data slide vs. CTA slide), but the 4-zone framework is constant.

**Cover slide variant**: Zone 2 can grow to 60% (headline-dominant); Zone 3 shrinks to 20% (just a kicker).

**CTA slide variant**: Zone 4 grows to 30% (the CTA IS the slide); Zone 2 shrinks.

**Quote/case slide variant**: Zone 3 grows to 50% (the body or quote IS the content); Zone 2 shrinks to a 2-3 word label.

---

## 8. Photographic Treatment

Stock photos look stock. AI-generated images look uncanny. Both can look INTENTIONAL with the right treatment:

### 8.1 Color grade for cohesion

Within a carousel, every photo must feel like it was shot for the SAME story. Achieve this with:

- **Match temperature**: pick warm OR cool for the whole set. Mix → looks like a moodboard, not a publication.
- **Match saturation**: -10 to -20% from default usually reads more editorial. Punchy saturation reads "social media tips bro".
- **Match contrast**: high contrast for Bold; medium for Editorial; soft for Photo-led.

The agent generates the photo via `POSTZEE_GENERATE_IMAGE` with explicit grade instructions in the prompt:

```
"Editorial portrait of a researcher in a study,
warm tungsten lighting from a desk lamp, 
slightly desaturated -15%, medium contrast,
shot on Hasselblad H6D-50c, 80mm lens"
```

### 8.2 Subject placement

- **Rule of thirds**: subject's eyes on the upper third line. Center-eyes = portrait-photo cliché.
- **3/4 angle**: subject's body angled 30-45° from camera reads more dynamic than pure frontal.
- **Negative space**: at least 30% of the photo should be empty (for text overlay).
- **Eye direction**: subject looks INTO the slide (toward the headline), not OUT of it.

### 8.3 Subject blocking for type legibility

When text overlays photo, the area behind the text must be predictably dark or predictably light:

```html
<!-- Dark overlay gradient on lower third for type legibility -->
<div style="
  position: absolute;
  bottom: 0; left: 0; right: 0;
  height: 50%;
  background: linear-gradient(180deg,
    transparent 0%,
    rgba(0, 0, 0, 0.45) 40%,
    rgba(0, 0, 0, 0.85) 100%);
"></div>
```

The gradient holds the text without flattening the photo (the upper-half stays visible). Always test legibility at 24px on mobile — if the text isn't crisp, the gradient isn't dark enough.

---

## 9. The 9-Item Visual Polish Checklist

Run before every render. Every "yes". One "no" = fix before shipping.

1. **Type contrast ratio**: display:body ≥ 4:1 ?
2. **Brand bar consistency**: same position + same elements on every slide ?
3. **Color palette discipline**: max 4 colors total (background, text, accent, optional highlight) ?
4. **Negative space**: each slide has at least 25% empty visual area ?
5. **Single focal point**: each slide has ONE element the eye lands on first ?
6. **Photo treatment**: cohesive grade across all photos in the carousel ?
7. **Highlight discipline**: max 1 highlight block per slide ?
8. **CTA singularity**: max 1 CTA per slide (and only on the CTA slide or cover) ?
9. **Mobile legibility**: at 50% scale, body text still readable ?

---

## 10. The Anti-Generic Checklist

Three things that mark a carousel/image as "made by an amateur with a template" (kill on sight):

1. **Centered everything**. Center-aligned headline + center body + center brand bar = no hierarchy. Pick ONE thing to center; everything else aligns differently.
2. **Default fonts only** (Arial/Times/Calibri). Use the specified pairings from §1. Even with system fonts, prefer Inter > Arial.
3. **Three or more colors competing**. If your slide has more than 3 colors fighting for attention, simplify until only 1 wins.

---

## 11. Cross-references

- `carousel-mastery.md` §10 — slide skeleton + CSS variables (base layer this doc layers on top of)
- `carousel-mastery.md` §11 — font discipline (you reference these specs, this doc tells you WHICH fonts pair editorially)
- `carousel-design-principles.md` — visual rules specific to carousel slide flow; this doc extends them with the 6 movements
- `copywriting-mastery.md` — the WORDS that go inside this design system
- `image-mastery.md` — single-image specific application of these rules

The 6 movements + 9-item checklist are the difference between "generic AI carousel" and "this looks like the publication's design team made it". Every render passes through both before commit.
