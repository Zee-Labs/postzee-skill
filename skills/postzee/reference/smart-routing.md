# Smart Routing — Picking model, aspect, and quality automatically

When the user says **"create a carousel about productivity for LinkedIn"**, you must NOT ask "which model? which aspect? which quality?" — figure it out yourself.

When the user says **"create using Nano Banana"**, you must NOT override their explicit choice. Trust them.

This file is the decision engine. Memorize the tree. Reference it when in doubt.

---

## Hierarchy of priority (non-negotiable, top wins)

```
1. EXPLICIT OVERRIDE        — user named the model
       ↓ (if absent)
2. EXPLICIT QUALITY SIGNAL  — user said "premium", "draft", "best", etc.
       ↓ (if absent)
3. SMART DEFAULT            — content type + plan-aware tier
       ↓ (always layered on)
4. ASPECT RATIO             — derived from platform automatically
```

Always log the four decisions mentally before calling `POSTZEE_GENERATE_*`. If you can't articulate which step picked the model, you're guessing.

---

## 1. Override — user named the model

**Pattern A — explicit name**
- "using Nano Banana", "use FLUX Ultra", "with Sora 2 Pro"
- "no modelo Recraft", "with Kling 3.0", "avec Veo 3.1"

**Pattern B — tier explicit**
- "Ideogram V3 Quality", "GPT Image low", "Sora 2 Pro 1080p"

**Resolution algorithm:**

1. Lowercase + strip punctuation from the user's phrase.
2. Get the full registry from `POSTZEE_LIST_MODELS_DETAILED`.
3. Try **exact match** (modelId or displayName, case-insensitive).
4. If no exact, try **substring match** against modelId + displayName + family.
5. If a single candidate → use it.
6. If multiple candidates → **ASK THE USER** with up to 3 options. Never guess.
7. If no candidate → tell the user the model isn't available + show the 3 closest from suggestions.

**Honor the override even when subóptimo.** If the user picks `nano-banana` for a text-heavy carousel, you may briefly note "Nano Banana isn't optimized for text-in-image — want me to use Ideogram V3 Turbo instead, or stick with Nano Banana?" — but **respect their final answer**.

---

## 2. Quality signal — multilingual mapping

Default tier when the user gives no signal: **`fast`** (turbo / mini / low / fast variants).

When the user gives a signal, escalate or descend one tier within the same family:

| Signal | Mapped tier | Examples per language |
|--------|-------------|------------------------|
| **Preview / draft** | cheapest in family | EN: `draft`, `preview`, `quick test`, `cheap`, `rough` · PT: `rascunho`, `prévia`, `teste rápido` · ES: `borrador`, `prueba rápida`, `barato` · FR: `brouillon`, `aperçu`, `test rapide` · DE: `Entwurf`, `Vorschau`, `schneller Test`, `billig` |
| **Default (none)** | `fast` tier | (no quality word — common case) |
| **Mid / publish quality** | `balanced` tier | EN: `quality`, `good`, `nice`, `publish`, `publication` · PT: `qualidade`, `bom`, `bonito`, `publicação` · ES: `calidad`, `bueno`, `bonito`, `publicación` · FR: `qualité`, `bon`, `beau`, `publication` · DE: `Qualität`, `gut`, `schön`, `Veröffentlichung` |
| **Premium / final** | `premium` tier | EN: `premium`, `best quality`, `max quality`, `final`, `for print` · PT: `máxima qualidade`, `premium`, `perfeito`, `para impressão` · ES: `máxima calidad`, `premium`, `perfecto`, `para impresión` · FR: `qualité maximale`, `premium`, `parfait`, `pour impression` · DE: `höchste Qualität`, `premium`, `perfekt`, `Druckqualität` |
| **Agency-grade** | `premium` + Pro models when available | EN: `agency-grade`, `broadcast`, `professional final` · PT: `qualidade de agência`, `profissional final` · ES: `nivel agencia`, `profesional final` · FR: `qualité agence`, `professionnel final` · DE: `Agenturqualität`, `professionell final` |

**If the user's language isn't in the table** (Russian, Japanese, Chinese, etc.) and you don't recognize a signal, **default to `fast` tier**. Don't err on the side of expensive — they will tell you if they want premium.

---

## 3. Smart default per content type

When override and quality signal are both absent, pick the family by what they're producing:

| User intent | Family default | Why |
|-------------|----------------|-----|
| Carousel slide / poster / infographic (text-heavy) | `ideogram-v3` | Best in-image text rendering |
| Photoreal photo / lifestyle / product shot | `nano-banana` | Sweet spot quality/price for photoreal |
| Illustration / digital art | `recraft-v4` | Modern illustration champion |
| Logo / icon / vector / SVG | `recraft-v4` (vector tier) | Only modern path to vector output |
| Mixed text + complex visual | `gpt-image-2` | Versatile for hybrid content |
| Quick test / preview anything | cheapest in matching family | Don't waste credits on test runs |
| Cinematic dialogue video | `sora-2` (or `sora-2-pro` for premium) | Native lip-sync |
| Multilingual lip-sync video | `veo3.1/fast` | Multilingual + economy |
| Animate a photo (silent) | `kling-2.5-turbo-pro` or `luma-ray-2-flash` | Budget photo motion |
| Animate a photo with audio | `pixverse-v4.5` | Budget 1080p with audio |
| First-last-frame chain | `wan-flf2v` | Only path; cheap; silent |

Then pick the **tier within the family** based on plan:

```
plan.tier === "FREE"     → entry tagged `agenticDefaultFree: true`  (cheapest)
plan.tier !== "FREE"     → entry tagged `agenticDefault: true`      (fast tier)
quality signal present?  → escalate / descend per §2 within the SAME family
```

The `agenticDefault` and `agenticDefaultFree` flags come from `POSTZEE_LIST_MODELS_DETAILED`. Trust them. Don't override based on intuition.

---

## 4. Aspect ratio — derived, not asked

Never ask "which aspect ratio?" — derive it from platform + format.

```
platform == instagram, format == feed       → 4:5
platform == instagram, format == carousel   → 4:5
platform == instagram, format == reels      → 9:16
platform == instagram, format == stories    → 9:16
platform == linkedin,  format == feed       → 1:1
platform == linkedin,  format == carousel   → 4:5
platform == facebook,  format == feed       → 1:1
platform == facebook,  format == reels      → 9:16
platform == x,         format == feed       → 16:9
platform == tiktok                          → 9:16
platform == youtube,   format == feed       → 16:9
platform == youtube,   format == shorts     → 9:16
platform == pinterest                       → 2:3
platform == threads                         → 1:1
platform == bluesky                         → 1:1
```

**Verify support** in the chosen model's `aspectRatios` (from `POSTZEE_LIST_MODELS_DETAILED`). If the ideal aspect isn't supported, fall back to `1:1` (always supported) and note it briefly to the user.

`POSTZEE_LIST_PLATFORM_SPECS` is the live source of truth — call it when stakes are high.

---

## 5. Anti-patterns (do NOT do these)

- ❌ **Default to `premium` tier "to be safe"** — burns user credits unnecessarily. Default = `fast`. Escalate ONLY on signal.
- ❌ **Mix tiers within the same carousel** — visual inconsistency. Pick a tier once for the whole batch.
- ❌ **Ignore explicit user override** — even if the model is "wrong" for the use case, the user's named choice wins.
- ❌ **Switch family mid-flow when a generation stalls** — try the same family at a lower tier first (e.g. `ideogram-v3-quality` slow → try `ideogram-v3-balanced`).
- ❌ **Hardcode the registry** — always read from `POSTZEE_LIST_MODELS_DETAILED`. The list evolves.
- ❌ **Generate 10 carousel slides in parallel without checking balance** — call `POSTZEE_ESTIMATE_GENERATION_COST({slideCount: 10})` first; if balance < estimate, propose a tier downgrade or a credit pack BEFORE generating anything.
- ❌ **Ask the user a question you could grep** — "what aspect ratio?" is forbidden when you know the platform.

---

## 6. Worked examples

### A) Default automation — no signal

> "Crie um carrossel pro LinkedIn sobre produtividade"

- Override? No
- Quality signal? No
- Content type? Carousel (text-heavy) → family `ideogram-v3`
- Plan? STANDARD (assume) → tier `agenticDefault` → `ideogram-v3-turbo`
- Platform? LinkedIn carousel → 4:5
- **Decision:** `model: 'ideogram-v3-turbo'`, `aspectRatio: '4:5'`, ~600 credits for 10 slides

### B) Premium request

> "Quero o melhor carrossel possível pro LinkedIn"

- "melhor possível" = `premium` signal
- Family `ideogram-v3` (carousel text-heavy)
- Tier `premium` → `ideogram-v3-quality`
- **Decision:** `model: 'ideogram-v3-quality'`, `aspectRatio: '4:5'`, ~1.800 credits for 10 slides

### C) Explicit override

> "Crie um carrossel usando nano banana"

- Override? Yes — `nano-banana` family
- Disambiguation: 3 entries (`nano-banana`, `nano-banana-2`, `nano-banana-pro`). Default to `popular: true` → `nano-banana-2`
- Note: "Heads up — Nano Banana is photoreal-tuned, not optimized for in-image text. Want me to use Ideogram V3 Turbo for the text-heavy slides instead?"
- **If user confirms nano-banana** → proceed with `nano-banana-2`, `aspectRatio: '4:5'`

### D) FREE plan + photoreal

> "Foto realista da minha cafeteria pro Instagram" (plan = FREE, balance = 800 cr)

- Override? No
- Quality signal? "realista" hints photoreal but no premium signal
- Content type → photoreal → family `nano-banana`
- Plan FREE → `agenticDefaultFree: true` → `nano-banana` (the cheapest of the family)
- Platform IG feed → 4:5
- Estimate 1 image: ~80 cr — fits in 800 balance
- **Decision:** `model: 'nano-banana'`, `aspectRatio: '4:5'`

### E) Mixed signal

> "Carrossel premium pro LinkedIn com fotos realistas dos produtos"

- Override? No
- Quality signal? "premium" → escalate
- Content type? Photoreal (not text-heavy — "fotos realistas")
- Family `nano-banana`, premium tier → `nano-banana-pro`
- Platform LinkedIn carousel → 4:5
- **Decision:** `model: 'nano-banana-pro'`, `aspectRatio: '4:5'`

### F) Vector logo

> "Logo da minha marca" / "Quero um SVG"

- Override? No
- Content type? Vector → family `recraft-v4`, vector variant
- **Decision:** `model: 'recraft-v4-vector'`, `aspectRatio: '1:1'` (logos are square by default)

### G) Cinematic video, default

> "Vídeo cinematográfico de 10 segundos sobre minha cafeteria"

- Override? No
- Quality signal? No
- Content type → cinematic dialogue video → family `sora-2` OR `veo3.1`
- Default to `agenticDefault: true` → `veo3.1/fast` (multilingual lip-sync + economy)
- Platform unstated → assume IG Reels or TikTok → 9:16
- Duration 10s
- **Decision:** `model: 'veo3.1/fast'`, `aspectRatio: '9:16'`, `duration: 10`

If the user later says "for IG feed" → switch to `4:5` if model supports it (Veo 3.1 supports 16:9 / 9:16 only — fall back to 9:16 with a note).

---

## 7. Pre-flight ritual (every batch)

Before any `POSTZEE_GENERATE_*`:

1. `POSTZEE_GET_CONTEXT` (cached — refresh if stale).
2. Run the decision tree above, **mentally articulate all 4 decisions**.
3. `POSTZEE_ESTIMATE_GENERATION_COST` for the **whole batch** (multiply by slideCount).
4. If `balance < estimate` → CTA the right credit pack OR propose a lower tier OR reduce count. Do not generate before resolving.
5. `POSTZEE_VALIDATE_GENERATION` for the chosen model + params.
6. Generate.

For carousels: **never parallelize** generations within the same batch. Sequential generation keeps balance accounting correct and lets you abort cleanly if a slide fails.

---

## 8. When `LIST_MODELS_DETAILED` doesn't return what you expect

If the list doesn't include the family you'd pick (e.g. `ideogram-v3` is empty for some reason), it means the registry was filtered server-side. Don't fall back to a hardcoded id — **ask the user** which available family they want to use, or pick the next closest from the response.

The registry is the source of truth at request time. Your assumptions about it are not.
