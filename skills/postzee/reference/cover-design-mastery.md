# Cover Design Mastery

A carousel cover is **advertising**, not editorial. Its only job is to earn the next swipe. The slides inside are editorial — calm, structured, generous with negative space. The cover is louder, sharper, more committed.

This doc teaches the agent to design covers like an ad creative: read the image, pick a pattern, write copy that synergizes, never default to "headline in the middle".

> Sibling doc: `cover-copywriting-mastery.md` — what the cover *says*. Read both before designing any cover.

---

## 1. The 8 composition patterns

Every great cover collapses to one of 8 patterns. Memorize them. Pick by zone read (§2), never by habit.

### 1.1 Lower-third

Headline in the bottom third, subject occupies the upper two-thirds. Used when the subject's face/body is high in the frame and the photographer left clean ground/floor below.

```
┌─────────────────────────┐
│                         │
│      [SUBJECT]          │
│                         │
│                         │
│  ───────────────────    │
│  HEADLINE GOES HERE     │  ← lower third, left-aligned
│  small subline          │
└─────────────────────────┘
```

**When**: face/eyes are in upper half, lower half is calm (floor, table, blur, gradient).
**Type**: bold serif or strong sans, 72–96pt. Subline 18–24pt.
**Color**: text color picks from a complementary tone in the subject zone (echo the photo, don't fight it).

### 1.2 Upper-third

Headline at the top, subject sits low. Mirror of 1.1. Used for editorial-style covers (newspaper masthead vibe).

**When**: subject is bottom-anchored (sitting, lying, low horizon).
**Type**: editorial serif (Playfair, Tiempos, Canela), 64–96pt. Larger leading than lower-third — top headlines read slower. Subline 16–22pt.
**Color**: text picks from the luminance of the upper zone (dark zone → light text, bright zone → dark text). Avoid accent colors at the top — they read as ad banners, not editorial.

### 1.3 Left-third

Headline runs down the left third, vertical column. Subject occupies right two-thirds.

```
┌─────────────────────────┐
│ A      │                │
│ M      │                │
│ O      │   [SUBJECT]    │
│ R      │                │
│ T      │                │
│ E      │                │
└─────────────────────────┘
```

**When**: subject faces right or is right-anchored; left edge has a calm gradient/wall.
**Type**: tall sans-serif (Anton, Bebas, Druk Wide). Stacked one-word-per-line works; multi-word lines need extra-tight tracking.
**Bonus**: feels like a magazine spine, premium.

### 1.4 Right-third

Mirror of 1.3. Used when subject faces left.

**When**: subject faces left or is left-anchored; right edge has a calm gradient/wall/dark band.
**Type**: same as 1.3 — tall sans-serif (Anton, Bebas, Druk Wide), stacked one-word-per-line, tight tracking. If the right zone is dark, warm off-white text reads better than pure white (see Example A §5.1).
**Bonus**: same magazine-spine premium feel as 1.3, mirrored.

### 1.5 Full-bleed text (image as backdrop, text dominates)

Headline takes 60–80% of the cover. Image is almost a texture beneath it.

```
┌─────────────────────────┐
│                         │
│  A MORTE                │
│  DO GOSTO               │  ← headline dominates
│  PESSOAL                │
│                         │
│  [muted/blurred image]  │
└─────────────────────────┘
```

**When**: image is generic/stock-feeling and the *idea* is the hero. If the zone read returns no calm region, the **first** move is to regenerate the image with a calm-zone clause (see §2.3 and `image-mastery.md` §5.1) — pattern 1.5 is the second move, only when regeneration isn't an option (user-provided photo, brief locks a specific image).
**Type**: display-weight, 120–180pt. Editorial serif preferred (Tiempos Headline, GT Sectra, Canela Deck) — the magazine-poster register.
**Color**: high contrast. Black text on muted color image, or white on dark image.

### 1.6 Text-on-color-block

Solid color block (1/3, 1/4, or diagonal strip) sits over the image and holds the headline.

```
┌─────────────────────────┐
│      [SUBJECT]          │
│                         │
│┌───────────────────────┐│
││ ████████████████████ ││  ← solid color block
││ HEADLINE IN BLOCK    ││
││ ████████████████████ ││
│└───────────────────────┘│
└─────────────────────────┘
```

**When**: image has zero calm zones. Block becomes part of the design, not a band-aid.
**Color**: block in brand accent color (yellow, magenta, electric blue) — turns the cover into an ad poster.
**Type**: sans-serif inside the block. Tight padding.

### 1.7 Diagonal

Headline tilted 8–18°. High-energy, attention-grabbing.

**When**: subject in motion, energetic content (sport, music, conflict). **Never** for serious/editorial.
**Type**: condensed sans (Druk Condensed, Steelfish). Capitals.
**Risk**: overuse looks amateur. Use once per carousel set, never twice in a row.

### 1.8 Centered-on-negative-space

Headline centered in a real negative space the photographer left (sky, blank wall, ocean, snow).

```
┌─────────────────────────┐
│                         │
│   HEADLINE HERE         │  ← centered in negative space
│                         │
│        [SUBJECT below]  │
└─────────────────────────┘
```

**When**: image was shot for text (rare with AI gen, common with stock). Or when the AI prompt explicitly asked for a calm zone.
**Type**: serif preferred — centered serifs read as elegant; centered sans reads as PowerPoint.

---

## 2. Image-zone analysis protocol (mandatory)

🔒 Hard rule (SKILL.md §2.5): every cover gets a written zone read **before** any CSS. Three lines, no exceptions.

### 2.1 The three reads

**Subject zone** — where the eye is forced to go. Face > eyes > body > primary object. If there's a human or animal looking somewhere, that gaze is part of the subject zone (text in the gaze line = collision).

**Calm zones** — regions with low detail variance: gradients, walls, sky, blur, monochrome floor, out-of-focus background. Calm means you can drop type on it without fighting texture. Quantify: thirds (upper-left third, lower band, right column).

**Luminance map** — divide the cover into rough zones and tag each as *dark*, *mid*, or *bright*. Type color picks from the opposite end of the zone it sits in: dark zone → bright text; bright zone → dark text; mid zone → either with strong weight.

### 2.2 The declaration format

```
🔍 Zone read:
   • Subject zone:  upper-right third (woman's face, gaze drifting left)
   • Calm zones:    lower-left third (soft floor gradient), upper-left third (out-of-focus wall)
   • Luminance:     upper half mid-bright, lower half dark warm tones
```

### 2.3 Pattern picker from the zone read

| Subject zone | Calm zone | → Pattern |
|---|---|---|
| Upper half | Lower third | 1.1 Lower-third |
| Lower half | Upper third | 1.2 Upper-third |
| Right two-thirds | Left third (vertical) | 1.3 Left-third |
| Left two-thirds | Right third (vertical) | 1.4 Right-third |
| Anywhere | None / image is busy | 1.6 Text-on-color-block |
| Centered, image is generic | (image becomes texture) | 1.5 Full-bleed text |
| Motion / dynamic | Anywhere | 1.7 Diagonal (sparingly) |
| Off-center subject | Real negative space (sky/wall) | 1.8 Centered-on-negative-space |

If the read returns "no calm zones, image is busy everywhere": regenerate the image with an explicit calm-zone instruction in the prompt — don't fight the photo. (See `image-mastery.md` §5.1 for the prompt clause, and `carousel-mastery.md` §9.1.4 for the carousel equivalent.)

---

## 3. The anti-mask rule

🔒 **Do not mask the photo to make text win.** A dark overlay >30% of the cover is a sign the wrong zone was picked. Re-read the image first.

### 3.1 What's forbidden

- Dark gradient overlay covering >30% of the cover ("vignette to force readability")
- Blur filter on the image to make text legible
- Black box behind text (different from 1.6 text-on-color-block — see distinction below)
- Drop shadow stronger than `text-shadow: 0 1px 2px rgba(0,0,0,.35)` used as a cover-up

### 3.2 The distinction: cover-up vs. design choice

| | Cover-up (forbidden) | Design choice (allowed) |
|---|---|---|
| Intent | "make text readable on bad zone" | "block is part of the composition" |
| Coverage | random | aligned to a third, edge, or diagonal |
| Color | always black/40% | brand color, intentional contrast |
| Edge | feathered/soft | hard edge or designed |
| Test | "would I remove it if text was elsewhere?" | "this is part of the visual identity" |

### 3.3 Allowed escapes

- **Solid color block** (pattern 1.6) — designed, on-grid, in brand color
- **Full-bleed text** (pattern 1.5) — image becomes texture by intent
- **Single-line text-shadow** `text-shadow: 0 1px 2px rgba(0,0,0,.35)` — only as polish on already-readable text, never as the readability mechanism

---

## 4. Typography for covers

Covers are louder than slide bodies. Four type styles cover ~95% of cases.

### 4.1 Editorial serif (Playfair, Tiempos, Canela, GT Sectra)

**Voice**: considered, premium, magazine.
**Sizes**: 72–120pt for short headlines, 56–80pt for 5+ words.
**Use with**: patterns 1.1, 1.2, 1.5, 1.8.
**Avoid**: tight tracking. Editorial serifs need air — letter-spacing 0 to 0.5%.

### 4.2 Display sans (Druk, Anton, Bebas, Steelfish)

**Voice**: confrontational, ad-poster, urgent.
**Sizes**: 96–180pt. Capitals only.
**Use with**: patterns 1.3, 1.4, 1.5, 1.6, 1.7.
**Tracking**: tight (-1 to -3% on display sans), loose on stacked one-word-per-line (5–10%).

### 4.3 Modern geometric sans (Inter, Söhne, Founders Grotesk)

**Voice**: tech, neutral, designer-friendly.
**Sizes**: 64–88pt headlines, 18–22pt sublines.
**Use with**: patterns 1.1, 1.6.
**Risk**: bland on its own — pair with a strong color block or a striking image to give it presence.

### 4.4 Hand/script (use rarely)

**Voice**: personal, confessional, intimate.
**Sizes**: variable; works smaller than display sans (48–72pt).
**Use with**: pattern 1.8 over real negative space. Almost never works with diagonal or full-bleed text.
**Risk**: gets cheesy fast. One script per carousel set; never on serious content.

### 4.5 What never to do

- ❌ Mix two display fonts in one cover
- ❌ Use Comic Sans, Papyrus, or anything that ships with Office (Inter/Söhne/Roboto are free and better)
- ❌ Center-align a non-serif headline (centered sans = PowerPoint vibe; pattern 1.8 wants serif)
- ❌ Stretch type vertically or horizontally to "fit" — re-size or re-pattern instead

---

## 5. Three worked examples

### 5.1 Example A — "A morte do gosto pessoal"

**Brief**: carrossel sobre conformidade estética na era do algoritmo. 9 slides.
**Image generated**: cinematic portrait, young woman, side lighting from upper-left, looking off-frame to the right, blurred warm background.

```
🔍 Zone read:
   • Subject zone:  centered-left third (face + eyes drifting right)
   • Calm zones:    upper-right third (blurred warm wall), lower band 25% (soft floor)
   • Luminance:     left half mid-bright (light on face), right half dark warm
```

**Pattern picked**: 1.4 right-third. Headline runs vertical in the dark warm right band; subject's gaze flows into the text.
**Type**: Druk Condensed Bold, 124pt, stacked one-word-per-line, tracking -1%.
**Color**: warm off-white (#F4ECDD) for the first four words — echoes the warm tones in the image, doesn't go full white (would feel cold against the warm photo). Final word `PESSOAL.` in muted brand magenta (#C04A78) to land the punch and break the column visually.
**Subline**: none. The four words carry it.

```html
<!-- right-third pattern -->
<div class="cover">
  <img src="..." class="bg" />
  <div class="text-column">
    <h1>A</h1><h1>MORTE</h1><h1>DO</h1><h1>GOSTO</h1>
    <h1 class="accent">PESSOAL.</h1>  <!-- accent color: #C04A78 -->
  </div>
</div>
```

### 5.2 Example B — "Eu chorei na consulta."

**Brief**: carrossel pessoal-confessional sobre saúde mental dos fundadores. 7 slides.
**Image generated**: hands holding a coffee mug, soft window light, intentionally generic — *the idea is the hero, not the photo*.

```
🔍 Zone read:
   • Subject zone:  lower-right third (hands and mug)
   • Calm zones:    upper two-thirds (window light, blurred indoor space)
   • Luminance:     upper half bright (window), lower half mid
```

**Pattern picked**: 1.5 full-bleed text. The image is generic enough to be texture; the confession is the punch.
**Type**: Tiempos Headline Bold, 96pt, three lines.
**Color**: deep ink black (#0F0F0F) on the bright upper half.
**Subline**: small italic, 18pt, "— um fundador, em fevereiro."

### 5.3 Example C — "47% dos meus posts não chegaram a ninguém."

**Brief**: carrossel sobre algorithm reach. 11 slides.
**Image generated**: abstract data viz, dark navy background with bright cyan data lines, lots of negative space in upper-left.

```
🔍 Zone read:
   • Subject zone:  lower-right third (cluster of bright data lines)
   • Calm zones:    upper-left two-thirds (dark navy, no detail)
   • Luminance:     upper half dark, lower-right bright cyan
```

**Pattern picked**: 1.8 centered-on-negative-space, anchored upper-left (not true center — image isn't symmetric).
**Type**: Inter Bold, 72pt, two lines. The number "47%" set in Druk Bold 144pt above the rest.
**Color**: bright cyan (#00E5FF) echoing the data lines; rest in off-white.

```html
<div class="cover" style="background: url('...') center/cover;">
  <div class="text-block upper-left">
    <h1 class="number">47%</h1>
    <h2>dos meus posts<br/>não chegaram a ninguém.</h2>
  </div>
</div>
```

---

## 6. Cover checklist before render

Before calling `POSTZEE_RENDER_CAROUSEL`, walk this list. If any answer is "no", iterate before rendering.

- [ ] Zone read declared in writing (subject, calm, luminance)?
- [ ] Pattern picked deliberately, not by default?
- [ ] Headline lives in a calm zone or on a designed block (not over the subject)?
- [ ] Text color picked from the luminance map (high contrast against its zone)?
- [ ] No dark overlay >30% acting as a cover-up?
- [ ] No blur filter on the image?
- [ ] Typography matches the voice (editorial serif for considered; display sans for confrontational)?
- [ ] If diagonal: only one diagonal in the carousel set?
- [ ] Cover reads from 2m (Instagram feed thumbnail) and from 30cm (open carousel)?

If the cover passes the checklist but still feels weak: the *copy* is the bottleneck, not the design. Go to `cover-copywriting-mastery.md`.
