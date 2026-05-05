# Image Models — Capability Matrix

Complete reference for choosing the right Postzee image model. All data verified from fal.ai/openai docs (May 2026).

---

## Quick decision tree

```
TEXT IN IMAGE (posters, logos with text, infographics)?
└── Ideogram V3 Quality (best text rendering) or GPT Image 2 High

VECTOR / EDITABLE LOGO / ICON?
└── Recraft V4 Vector or Recraft V4 Pro Vector

PHOTOREALISTIC PHOTO (people, scenes, products)?
├── Premium → GPT Image 2 High or Nano Banana Pro
├── Balanced → Nano Banana 2 (popular)
└── Budget → Nano Banana

ARTISTIC / ILLUSTRATIVE / STYLIZED?
├── Premium → GPT Image 2 High, Recraft V4 Pro
├── Balanced → Recraft V4
└── Budget → Recraft V3, Ideogram V3 Turbo

PORTRAIT / VERTICAL aspect ratio?
└── Use the "-portrait" variant of the model (cheaper or specifically tuned)

REFERENCE IMAGE NEEDED (img-to-img)?
└── Most models support imageUrls — Ideogram V3 Quality, Recraft, GPT Image 2

BATCH / VOLUME / TESTING?
└── Nano Banana, GPT Image 1 Mini, Ideogram V3 Turbo (cheapest reliable)
```

---

## Full capability matrix

### OpenAI / fal.ai providers

| Model ID | Provider | Cost (credits) | Best for | Resolution | Special |
|----------|----------|----------------|----------|------------|---------|
| `nano-banana` | fal.ai | 78 | Budget photoreal | Variable | Cheapest |
| `nano-banana-2` | fal.ai | 160 | **Photoreal** ⭐ | Variable | Best quality/price |
| `nano-banana-pro` | fal.ai | 300 | Premium photoreal | Variable | Top tier |
| `ideogram-v2` | fal.ai | 160 | Text in images | Variable | Legacy |
| `ideogram-v3-turbo` | fal.ai | 60 | **Quick text-in-image** ⭐ | Variable | Fastest |
| `ideogram-v3-balanced` | fal.ai | 120 | Balanced text rendering | Variable | — |
| `ideogram-v3-quality` | fal.ai | 180 | **Best text in image** ⭐ | Variable | Posters, infographics |
| `flux-2-pro` | fal.ai | 60 | **Pro photoreal** ⭐ | Up to 1MP | Versatile |
| `flux-2-pro-portrait` | fal.ai | 90 | Portrait/vertical | 9:16 / 16:9 (2MP) | — |
| `flux-1.1-pro` | fal.ai | 80 | Reliable pro | 1MP | Legacy pro |
| `flux-1.1-pro-portrait` | fal.ai | 160 | Portrait | 9:16 / 16:9 (2MP) | — |
| `flux-1.1-ultra` | fal.ai | 120 | High-res photoreal | Up to 4MP | 2K resolution |
| `recraft-v3` | fal.ai | 80 | Versatile illustration | Variable | 70+ styles |
| `recraft-v3-vector` | fal.ai | 160 | Vector illustration | Variable | SVG output |
| `recraft-v4` | fal.ai | 80 | **Modern illustration** | Variable | Updated quality |
| `recraft-v4-vector` | fal.ai | 160 | Vector illustration | Variable | SVG output |
| `recraft-v4-pro` | fal.ai | 500 | Premium design | Variable | Brand systems |
| `recraft-v4-pro-vector` | fal.ai | 600 | Premium vector | Variable | SVG output |
| `recraft-vectorize` | fal.ai | 20 | Raster → SVG | — | Conversion utility |
| `gpt-image-2-low` | fal.ai | 20 | Cheap GPT Image | 1024x1024 | — |
| `gpt-image-2-medium` | fal.ai | 120 | Mid GPT Image | 1024x1024 | — |
| `gpt-image-2-high` | fal.ai | 440 | **Premium GPT Image** ⭐ | 1024x1024 | Versatile, popular |
| `gpt-image-2-low-portrait` | fal.ai | 20 | Cheap portrait | 1024x1536 | — |
| `gpt-image-2-medium-portrait` | fal.ai | 100 | Mid portrait | 1024x1536 | — |
| `gpt-image-2-high-portrait` | fal.ai | 340 | Premium portrait | 1024x1536 | — |
| `gpt-image-1.5` | openai | 68 | OpenAI direct | 1024x1024 | State-of-the-art |
| `gpt-image-1.5-portrait` | openai | 100 | OpenAI portrait | 1024x1536 | — |
| `gpt-image-1` | openai | 84 | OpenAI direct | 1024x1024 | Pro |
| `gpt-image-1-portrait` | openai | 126 | OpenAI portrait | 1024x1536 | — |
| `gpt-image-1-mini` | openai | 22 | **Cheap reliable** ⭐ | 1024x1024 | Budget pick |
| `gpt-image-1-mini-portrait` | openai | 32 | Cheap portrait | 1024x1536 | — |

⭐ = recommended for most use cases

---

## Model-specific notes

### Nano Banana family
- **Nano Banana**: Google Gemini 3.1, character consistency, prompt adherence
- **Nano Banana 2**: Google Gemini Flash — legible text in images, fast high-res
- **Nano Banana Pro**: Google Gemini Pro — advanced semantic understanding for complex compositions
- All accept `imageUrls` for img-to-img / character reference

### Ideogram V3
- Param: `rendering_speed` — `turbo` (cheap) / `balanced` / `quality` (best)
- **Best-in-class text rendering** — use for any image with readable text
- Quality tier supports 50+ artistic styles + reference images

### FLUX
- **flux-2-pro**: zero-config professional, consistent results
- **flux-1.1-pro**: 6x faster than FLUX.1, top Elo on benchmarks
- **flux-1.1-ultra**: 2K (4MP) — print-ready
- All support reference images via @ syntax in prompt

### Recraft
- **V3**: #1 on Hugging Face benchmark for text + vectors
- **V4**: refined lighting, realistic materials
- **V4 Pro**: AI auto-selects style, brand-system ready
- `style` param: `realistic_image`, `digital_illustration`, `vector_illustration`
- Vector variants output SVG — editable in design tools
- `recraft-vectorize`: convert any raster image to SVG

### GPT Image (fal.ai routing)
- **GPT Image 2** (low/medium/high): quality affects price massively (20 → 120 → 440 credits)
- For high-fidelity photoreal use `gpt-image-2-high`
- Portrait variants when aspect ratio ≠ 1:1

### GPT Image (OpenAI direct)
- **gpt-image-1.5**: state-of-the-art, multilingual text, integrated reasoning
- **gpt-image-1**: maximum quality with multimodal understanding
- **gpt-image-1-mini**: cheapest reliable option (22 credits) — great for batch

---

## Choosing strategy by use case

### Carousel slides (10 slides, mixed text + visual)

```
Slide 1 (HOOK with big text)         → ideogram-v3-quality (180) ⭐
Slides 2-9 (text + visual mixed)     → gpt-image-2-high (440) — consistency
Slide 10 (CTA, mostly visual)        → recraft-v4 (80) or gpt-image-2-high
```

**Total: ~3,540 credits ($3.54) for 10 slides** (with markup 2.0x)

To save credits, use `ideogram-v3-balanced` (120) for middle slides → ~2,500 credits.

### Single hero image for IG feed (4:5)

```
Photoreal product / lifestyle → flux-2-pro-portrait (90) or nano-banana-2 (160)
With text overlay (offer, quote) → ideogram-v3-quality (180)
Illustration / brand asset → recraft-v4 (80)
```

### Logo / brand mark

```
Vector (editable, scalable) → recraft-v4-vector (160) or recraft-v4-pro-vector (600)
Raster (one-off) → recraft-v4 (80) + recraft-vectorize (20) to convert later
```

### Profile pictures / portraits

```
Photoreal portrait → nano-banana-2 (160) or gpt-image-2-high-portrait (340)
Stylized illustration → recraft-v4 (80) or gpt-image-2-high (440)
```

### Posters / event flyers

```
With heavy text → ideogram-v3-quality (180) — only model that nails text
Visual-first → gpt-image-2-high (440)
```

---

## Aspect ratios

Most models accept these via `aspectRatio` parameter:
- `1:1` — square (Instagram feed default, X/Twitter)
- `4:5` — portrait (Instagram feed best engagement)
- `9:16` — vertical (Reels, TikTok, Shorts, Stories)
- `16:9` — landscape (YouTube, X header, LinkedIn banner)
- `4:3` — old TV (rare on social)
- `3:2` — DSLR / web hero
- `2:3` — Pinterest

Some models have **dedicated portrait variants** (e.g., `flux-2-pro-portrait`) — these are tuned for vertical and may produce better results than the standard model in `9:16`.

---

## Cost optimization tips

1. **Default to mid-tier** (gpt-image-2-medium, ideogram-v3-balanced) for testing — go premium only on final
2. **Use `gpt-image-1-mini`** (22 credits) for thumbnails and low-stakes images
3. **For carousels**: mix premium (slide 1 hook + slide N CTA) with cheaper middle slides
4. **For variations**: same prompt + different seed = much cheaper than re-prompting
5. **Recraft Vectorize** (20 credits) is ridiculously cheap — convert any image to vector

---

## Common mistakes to avoid

- ❌ Using `gpt-image-2-high` for every slide of a 20-slide carousel (~8,800 credits = $8.80) — use `medium` for middle slides
- ❌ Using non-portrait variants for 9:16 — quality is lower; use `*-portrait` versions
- ❌ Using `nano-banana` for text-in-image — text comes out garbled; use Ideogram V3 Quality
- ❌ Generating raster when client needs editable — use Recraft Vector or `recraft-vectorize`
- ❌ Re-prompting from scratch for variations — use seed + same prompt

---

## When to enhance prompt

**Always** call `POSTZEE_ENHANCE_PROMPT` before generation — it converts simple descriptions into model-optimized prompts. Skip only if:
- User explicitly says "use this exact prompt"
- Prompt is already model-specific and detailed
- Generating a variation of an already-enhanced prompt
