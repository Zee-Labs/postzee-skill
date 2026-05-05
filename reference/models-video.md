# Video Models — Capability Matrix

Complete reference for choosing the right Postzee video model. All capability data verified from fal.ai/kie.ai docs (May 2026). The audio capability column is the most important — get this wrong and the user's intent fails.

---

## Audio capability glossary

- **None** — model produces silent video. Need to add audio in post (ffmpeg + music).
- **Ambient** — model generates contextual audio (music, SFX, environment) but no spoken dialogue.
- **Speech + lip-sync** — model generates a person speaking the prompt's dialogue with lip-sync. Game-changer for talking-head content.
- **Voice control** — model accepts voice IDs / characteristics for dialogue control.

---

## Quick decision: what audio do you need?

```
USER WANTS A PERSON SPEAKING SPECIFIC TEXT (interview, course, explainer)?
├── Static talking head, full control → HEYGEN (separate § — uses HeyGen credits)
├── Cinematic scene with dialogue → SORA 2 PRO (10s/15s) or VEO 3.1
└── Multilingual dialogue → VEO 3.1 STANDARD

USER WANTS AMBIENT AUDIO (music, SFX, scene sounds)?
├── Premium → VEO 3.1 STANDARD (any res)
├── Pro budget → KLING 3.0 PRO, SEEDANCE 2.0
└── Cheaper → KLING 2.5 TURBO PRO, KLING 2.6 PRO, PIXVERSE V4.5

USER WANTS SILENT VIDEO (mute, will add audio later)?
└── Any model — pick by motion quality / consistency / duration needs
```

---

## Master capability matrix — Video

| Model ID | Audio | Lip-sync | Max duration | Resolutions | Modes | Multi-shot | Cost tier | Best for |
|----------|-------|---------|--------------|-------------|-------|------------|-----------|----------|
| **`veo3.1`** | ✅ Native | ✅ Multilingual | 8s | 720p / 1080p / 4K | T2V, I2V (auto) | No | High | Premium dialogue + cinematic |
| **`veo3.1/fast`** | ✅ Native | ✅ Multilingual | 8s | 720p / 1080p / 4K | T2V, I2V (auto) | No | Mid | Fast premium |
| **`veo3.1/image-to-video`** | ✅ Native | ✅ | 8s | 720p / 1080p / 4K | I2V only | No | High | Animate photo with audio |
| **`veo3.1/fast/image-to-video`** | ✅ Native | ✅ | 8s | 720p / 1080p / 4K | I2V only | No | Mid | Fast animate photo |
| **`veo3.1/first-last-frame-to-video`** | ✅ Native | ✅ | 8s | 720p / 1080p / 4K | FLF2V | No | High | Bridge two frames |
| **`veo3.1/fast/first-last-frame-to-video`** | ✅ Native | ✅ | 8s | 720p / 1080p / 4K | FLF2V | No | Mid | Fast bridge |
| **`veo3.1/reference-to-video`** ⭐ | ✅ Native | ✅ | 8s | 720p / 1080p / 4K | R2V (multi-ref) | No | High | **Character consistency across scenes** |
| **`sora-2-t2v-10s`** | ✅ Native | ✅ | 10s | 720p | T2V | No | Low | Cheap premium dialogue |
| **`sora-2-t2v-15s`** | ✅ Native | ✅ | 15s | 720p | T2V | No | Low | Longer Sora 2 |
| **`sora-2-i2v-10s`** | ✅ Native | ✅ | 10s | 720p | I2V | No | Low | Animate photo with Sora |
| **`sora-2-i2v-15s`** | ✅ Native | ✅ | 15s | 720p | I2V | No | Low | Longer animate |
| **`sora-2-t2v-pro-720p-10s`** | ✅ Native | ✅ | 10s | 720p HD | T2V | No | Mid | Sora Pro 720p |
| **`sora-2-t2v-pro-720p-15s`** | ✅ Native | ✅ | 15s | 720p HD | T2V | No | Mid | Longer Pro |
| **`sora-2-t2v-pro-1080p-10s`** | ✅ Native | ✅ | 10s | 1080p Full HD | T2V | No | High | Premium Sora |
| **`sora-2-t2v-pro-1080p-15s`** | ✅ Native | ✅ | 15s | 1080p Full HD | T2V | No | High | Premium long |
| **`sora-2-i2v-pro-720p-10s`** | ✅ Native | ✅ | 10s | 720p HD | I2V | No | Mid | Pro animate |
| **`sora-2-i2v-pro-720p-15s`** | ✅ Native | ✅ | 15s | 720p HD | I2V | No | Mid | Longer pro animate |
| **`sora-2-i2v-pro-1080p-10s`** | ✅ Native | ✅ | 10s | 1080p Full HD | I2V | No | High | Premium animate |
| **`sora-2-i2v-pro-1080p-15s`** | ✅ Native | ✅ | 15s | 1080p Full HD | I2V | No | High | Premium long animate |
| **`sora-2-storyboard-10s`** ⭐ | ✅ Native | ✅ | 10s | 720p | T2V + I2V via shots[] | **YES** | Mid | Native multi-scene |
| **`sora-2-storyboard-15s`** ⭐ | ✅ Native | ✅ | 15s | 720p | T2V + I2V via shots[] | **YES** | Mid | Native multi-scene |
| **`sora-2-storyboard-25s`** ⭐ | ✅ Native | ✅ | 25s | 720p | T2V + I2V via shots[] | **YES** | Mid | **Longest native multi-scene** |
| **`kling-2.1-master`** | ❌ None | ❌ | 5s, 10s | 720p | T2V, I2V | No | Mid | Cinematic motion premium |
| **`kling-2.5-turbo-pro`** | ✅ Ambient | ❌ | 5s, 10s | 720p | T2V, I2V | No | Low | Fast cheap with audio |
| **`kling-2.6-pro`** | ✅ Ambient + voice | Partial | 5s, 10s | 720p | T2V, I2V | No | Low | Voice control |
| **`kling-3.0-pro`** ⭐ | ✅ Ambient + voice | ✅ Hint | 3-15s | 720p | T2V, I2V, start_end | Hint | Low | **Cinematic + audio + multi-shot hint** |
| **`kling-o3-standard`** | ✅ Ambient | ❌ | 3-15s | 720p | T2V, I2V, start_end | Hint | Low | Multi-shot variant |
| **`luma-ray-2`** | ❌ None | ❌ | 5s, 9s | 540p / 720p (2x) / 1080p (4x) | T2V, I2V, start_end, loop | No | Mid | Natural motion |
| **`luma-ray-2-flash`** | ❌ None | ❌ | 5s, 9s | 540p / 720p / 1080p | T2V, I2V, start_end, loop | No | Low | **Cheap fast Luma** |
| **`pixverse-v4.5`** | ✅ Ambient | ❌ | 5s, 8s | 360p / 540p / 720p / 1080p | T2V, I2V | No | Low | **Cheap 1080p with audio** |
| **`seedance-1.0-lite`** | ❌ None | ❌ | 2-12s | 720p | T2V, I2V | No | Very Low | Cheapest reliable |
| **`seedance-1.0-pro`** | ❌ None | ❌ | 2-12s | 1080p | T2V, I2V | No | Mid | 1080p budget |
| **`seedance-2.0`** ⭐ | ✅ Ambient | ✅ | 4-15s | 480p / 720p | T2V, I2V, start_end, reference | Yes | Mid | **Multi-shot + lip-sync + 15s** |
| **`vidu-q1`** | ❌ None | ❌ | 5s | 1080p | T2V, I2V, start_end, reference | No | Mid | Reference-to-video |
| **`wan-2.1`** | ❌ None | ❌ | 5s | 480p / 720p | T2V, I2V | No | Very Low | Cheapest 720p |
| **`wan-2.1-pro`** | ❌ None | ❌ | 5-15s | 1080p | T2V, I2V | No | Mid | 1080p reliable |
| **`wan-2.5`** | ✅ Ambient | ❌ | 5s, 10s | 480p / 720p / 1080p | T2V, I2V | No | Low | Audio + tiered res |
| **`wan-flf2v`** ⭐ | ❌ None | ❌ | 5-15s | 480p / 720p | I2V (FLF only) | No | Very Low | **Frame-to-frame chain** |
| **`minimax-video-01`** | ❌ None | ❌ | 5, 10, 15s | 720p | T2V, I2V | No | Low | Reliable simple |
| **`minimax-video-01-live`** | ❌ None | ❌ | 5s | 720p | T2V, I2V | No | Low | Live variant |
| **`hunyuan-video`** | ❌ None | ❌ | 5s | 720p | T2V, I2V | No | Low | Tencent open-source |

⭐ = recommended for specific high-value scenarios

---

## kie.ai vs fal.ai providers

- **kie.ai**: Sora 2 family (all 15 variants + watermark remover)
- **fal.ai**: everything else

Both providers integrate seamlessly via Postzee MCP. User doesn't need to choose — pick the model and Postzee routes correctly.

---

## Pricing tiers (relative)

- **Very Low** — Wan 2.1, Seedance 1.0 Lite, Wan FLF2V, Hunyuan
- **Low** — Sora 2 Standard, Pixverse V4.5, Kling Turbo, Kling 3.0 Pro, Luma Flash, MiniMax
- **Mid** — Sora 2 Pro 720p, Veo 3.1 Fast, Kling 2.1 Master, Seedance 1.0 Pro, Seedance 2.0, Wan 2.1 Pro, Wan 2.5
- **High** — Sora 2 Pro 1080p, Veo 3.1 Standard

Always check current credit cost via `POSTZEE_LIST_VIDEO_MODELS` before committing — pricing may have changed.

---

## Special capabilities to know

### Sora 2 Storyboard (multi-shot, native)

`sora-2-storyboard-{10s,15s,25s}` accepts a `shots` array. Each shot has its own prompt and reference image. The model generates **all scenes connected** in a single API call with internal continuity.

**When to use:**
- 2-6 scenes in one piece
- Storytelling with progression
- Up to 25s total

**Use case example:**
```
shots: [
  { prompt: "barista grinding coffee beans, close-up", duration: 8 },
  { prompt: "espresso pouring into white cup, slow motion", duration: 8 },
  { prompt: "barista handing cup to smiling customer", duration: 9 }
]
```

### Veo 3.1 Reference-to-Video (multi-image consistency)

`fal-ai/veo3.1/reference-to-video` accepts multiple reference images. Locks character / object / scene across the generation.

**When to use:**
- Character must look identical across multiple separately-generated videos
- Brand product appears in multiple scenes
- Lock a specific outfit / styling

**Workflow:**
```
1. Generate or upload character portrait
2. For each scene:
   POSTZEE_GENERATE_VIDEO(
     model='fal-ai/veo3.1/reference-to-video',
     prompt='[scene description]',
     imageUrls=[character_portrait, product_shot] // up to ~3 refs
   )
```

### Wan FLF2V (frame chain — needs ffmpeg)

`wan-flf2v` interpolates between two specific frames. Combined with ffmpeg last-frame extraction, builds a perfect motion chain.

**Workflow (shell-capable client only):**
```
1. Generate Scene 1 with any model → scene1.mp4
2. ffmpeg -sseof -0.1 -i scene1.mp4 -frames:v 1 last_frame_1.jpg
3. POSTZEE_GENERATE_VIDEO(
     model='wan-flf2v',
     imageUrl=last_frame_1.jpg,
     prompt='[scene 2 description]'
   )
4. Repeat for N scenes
5. ffmpeg concat all scenes
```

### Veo 3.1 First-Last-Frame (similar idea, premium quality)

`fal-ai/veo3.1/first-last-frame-to-video` — same concept but Veo quality + audio.

---

## Provider-specific notes

### Sora 2 (kie.ai)
- All variants generate **native audio with lip-sync** automatically when prompt describes speech
- No `generate_audio` flag — always on
- Duration is **embedded in modelId** (`-10s`, `-15s`, `-25s`)
- Storyboard variants accept `shots[]` for multi-scene
- 720p Standard / 720p Pro / 1080p Pro tiers

### Veo 3.1 (fal.ai, Google DeepMind)
- **`generate_audio: true` by default** — pricing is higher with audio (be aware)
- Multilingual lip-sync (PT, EN, ES, FR, DE, JP, etc.)
- 4 modes: T2V, I2V, FLF2V, R2V (R2V is a hidden gem for character consistency)
- `duration` accepts `4s`, `6s`, `8s` (enum)
- 720p / 1080p / 4K (4K costs notably more)

### Kling family (Kuaishou)
- **2.1 Master**: cinematic motion, no audio
- **2.5 Turbo Pro**: cheaper, fast — audio supported via `generate_audio` (default true on fal.ai)
- **2.6 Pro**: native audio + voice control via `voice_ids`
- **3.0 Pro**: native audio + voice control + multilingual + multi-shot hint
- **O3 Standard**: multi-shot variant of Kling line
- All accept 5s and 10s duration; some support 3-15s range
- 720p resolution

### Luma Ray 2 (Luma AI)
- No audio — silent video only
- Resolution multipliers: 540p (1x base), 720p (2x), 1080p (4x)
- Duration multiplier: 9s = 2x cost of 5s (pricing non-linear)
- Modes: T2V, I2V, start-end (FLF), loop
- **Ray 2 Flash**: 5x cheaper than Ray 2, similar quality at 540p

### Seedance (ByteDance)
- **Seedance 1.0 Lite**: cheapest reliable, 720p, no audio
- **Seedance 1.0 Pro**: 1080p, no audio
- **Seedance 2.0**: native audio + lip-sync + multi-shot + reference + start-end. Token-based pricing internally.

### Pixverse v4.5
- Audio via `generate_audio_switch` (different from Veo/Kling param name)
- 4 resolutions, duration 5s or 8s (8s costs 2x — pricing non-linear)
- 1080p limited to 5s

### Vidu Q1
- Reference-to-video (R2V) — accepts multiple reference images for character
- 5s only, 1080p, no audio
- Cheaper R2V alternative to Veo 3.1 R2V

### Wan family (Alibaba)
- **Wan 2.1 / 2.1 Pro**: per-video flat pricing, no audio
- **Wan 2.5**: audio support, tiered resolution (480p/720p/1080p), per-second pricing
- **Wan FLF2V**: first-last-frame interpolation, cheap, perfect for chaining

### MiniMax / Hunyuan
- Simple per-video pricing, no audio (in production)
- Use as backup or for variety

---

## Choosing strategy by use case

### "Vídeo de pessoa falando" (talking head)

```
1 take, full lip-sync control, voice you can pick → HEYGEN
Cinematic narrative with dialogue → SORA 2 PRO 1080p (10/15s)
Multilingual + 4K + premium → VEO 3.1 STANDARD
Multi-scene story with dialogue → SORA 2 STORYBOARD 25s
```

### "Vídeo curto pra TikTok / Reels" (10-15s vertical)

```
With ambient audio + cheap → KLING 2.5 TURBO PRO or PIXVERSE V4.5 (9:16)
With dialogue + cheap → SORA 2 STANDARD (10s, 720p)
Premium quality → SORA 2 PRO 720p (15s)
```

### "Animar uma foto" (image-to-video)

```
Premium with audio → VEO 3.1 i2v
Premium with dialogue + audio → SORA 2 i2v PRO
Quick + cheap → KLING 2.5 TURBO PRO i2v
Bridge to specific end frame → VEO 3.1 FLF or WAN FLF2V
```

### "Vídeo cinematográfico longo" (15-25s)

```
Native multi-shot with audio → SORA 2 STORYBOARD 25s
Multi-scene with character lock → VEO 3.1 R2V (chain externally with ffmpeg)
Multi-shot Seedance → SEEDANCE 2.0 (15s)
```

### "Múltiplas cenas com mesmo personagem"

```
Best consistency → VEO 3.1 R2V with character portrait reference
Quick storyboard → SORA 2 STORYBOARD with shots[]
Frame-perfect motion → WAN FLF2V chain (needs ffmpeg)
```

---

## Validation checklist before generating

Before calling `POSTZEE_GENERATE_VIDEO`, verify:

- [ ] **Duration** within model's supported range
- [ ] **Resolution** supported by model (no `1080p` for Sora Standard, no `4K` for Sora at all)
- [ ] **Aspect ratio** supported (most are `16:9` / `9:16`; some auto)
- [ ] **Audio** capability matches user's need (don't pick Luma if they want sound)
- [ ] **Lip-sync** if dialogue is required (Sora 2, Veo 3.1, HeyGen only)
- [ ] **Cost** fits user's credit balance (`POSTZEE_GET_CREDITS` first)
- [ ] **Mode** matches input (T2V if no image, I2V if image provided)

If any check fails, explain and offer alternative.

---

## Common mistakes to avoid

- ❌ Picking Luma for "vídeo com música" — Luma has no audio. Use Veo 3.1, Kling, Pixverse, Seedance 2.0, or Wan 2.5
- ❌ Picking Kling 3.0 Pro for "pessoa falando texto X" — partial lip-sync only. Use Sora 2 Pro or Veo 3.1
- ❌ Picking Sora 2 Standard for 4K — only 720p. Use Sora 2 Pro 1080p or Veo 3.1 4K
- ❌ Asking for 12s on Veo 3.1 — max is 8s. Use Sora 2 Storyboard for longer
- ❌ Asking for 25s on a single-shot model — break into multi-scene with Sora Storyboard or Veo 3.1 R2V chain
- ❌ Forgetting `imageUrl` for I2V variants — required parameter
