# Multi-Scene Video Workflow — Consistency Mastery

When the user's idea needs **2+ scenes that connect** — storytelling, narrative, before/after, day-in-the-life — single-shot generation isn't enough. This is the workflow that separates amateur AI video from professional production.

---

## ⚠️ Feature gating (read first)

Before proposing ANY strategy below, check `features.*` from `POSTZEE_GET_CONTEXT`:

```
features.veoR2V          → if false, do NOT propose Strategy A (Veo R2V)
features.soraStoryboard  → if false, do NOT propose Strategy B (Sora Storyboard)
features.firstLastFrame  → if false, do NOT propose Strategy C (FLF chain)
```

The MCP is the source of truth for what's currently available. If a strategy is not enabled, fall back to **Strategy D (Reference image)** which works with any I2V-capable model.

When asking the user to choose a strategy, only present the ones currently enabled.

---

## The fundamental problem

**Without consistency strategy:** each AI video generation is independent. Generate "barista pouring coffee" twice → you get two different baristas, two different cafés, two different cups.

**With consistency strategy:** character looks the same, scene environment matches, motion flows naturally between cuts. Result feels like a real production.

---

## The 4 strategies

### Strategy A — Veo 3.1 Reference-to-Video (CHARACTER LOCK) ⭐

**Available when** `features.veoR2V === true`.

The R2V mode accepts reference images and locks the character/object/scene look across multiple separately-generated videos.

#### When to use
- Same character must appear in 3+ separate scenes
- Need 1080p or 4K
- Each scene needs full quality
- Cinematic look + audio + lip-sync

#### Workflow

```
STEP 1: Generate or upload character portrait
─────────────────────────────────────────────────────────
POSTZEE_GENERATE_IMAGE({
  model: "<image-model-from-LIST_MODELS_DETAILED>",
  prompt: "Mid-30s woman, dark curly hair, wearing blue blazer,
           gold earrings, professional headshot, neutral background,
           natural lighting",
  aspectRatio: "1:1"
})
→ portrait_url

STEP 2: Generate each scene with R2V
─────────────────────────────────────────────────────────
POSTZEE_GENERATE_VIDEO({
  model: "<veo3.1-r2v-model-id>", // confirm exact id from LIST_MODELS_DETAILED
  prompt: "[Character] sitting at desk, looking at laptop,
           thoughtful expression. Camera dolly in slowly.",
  imageUrl: portrait_url, // (or imageUrls if multi-ref supported by future schema)
  aspectRatio: "9:16",
  duration: <pick from durations array of the model>
})
→ scene1.mp4

[Repeat for scenes 2, 3, ...N — each call uses same reference]

STEP 3: Compose final video (if shell-capable, see ffmpeg-cookbook)
─────────────────────────────────────────────────────────
ffmpeg concat with crossfade transitions → final.mp4
```

#### Pros / Cons
✅ Best character consistency · ✅ Premium quality · ✅ Audio + lip-sync
❌ Requires ffmpeg for compose · ❌ Each scene = separate generation (more credits)

---

### Strategy B — Sora 2 Storyboard (NATIVE multi-shot)

**Available when** `features.soraStoryboard === true`.

Sora 2 has built-in multi-scene mode. Single API call, multiple scenes, internal continuity.

#### When to use
- Total duration ≤ 25s (Sora storyboard caps at 25s)
- 2-6 distinct scenes
- 720p is enough
- Audio + lip-sync needed
- Want fastest path to multi-scene

#### Workflow
**Confirm exact model id and supported `shots` schema via `POSTZEE_LIST_MODELS_DETAILED`** when this feature is enabled. Never assume the model id from this doc — the MCP is authoritative.

#### Pros / Cons
✅ Native consistency · ✅ Single API call · ✅ Handles audio across scenes
❌ Max 25s · ❌ 720p only · ❌ Less control per scene

---

### Strategy C — Frame Chain (Wan FLF2V)

**Available when** `features.firstLastFrame === true` AND you have shell access (ffmpeg).

Smoothest motion continuation. Each scene starts where the last ended.

#### When to use
- Need natural motion flow between scenes
- Have shell access (ffmpeg required)
- Continuous action / single environment with motion progression
- Budget-conscious (Wan FLF2V is in the very-low cost tier)

#### Workflow

```
STEP 1: Generate Scene 1 with any video model
─────────────────────────────────────────────────────────
POSTZEE_GENERATE_VIDEO({
  model: "<from-LIST_MODELS_DETAILED>",
  prompt: "Scene 1 description",
  duration: <valid from model.durations>,
  aspectRatio: "9:16"
})
→ scene1.mp4

STEP 2: Extract last frame
─────────────────────────────────────────────────────────
$ ffmpeg -sseof -0.1 -i scene1.mp4 -frames:v 1 -q:v 2 last_frame_1.jpg

STEP 3: Upload last_frame_1.jpg to a public URL
─────────────────────────────────────────────────────────
Use Postzee's media upload, R2/S3, or any public host
→ last_frame_1_url

STEP 4: Generate Scene 2 with FLF
─────────────────────────────────────────────────────────
POSTZEE_GENERATE_VIDEO({
  model: "wan-flf2v",  // confirm via LIST_MODELS_DETAILED
  imageUrl: last_frame_1_url,    // start frame
  endImageUrl: <optional end frame for the next scene>,
  prompt: "Scene 2 continues from this frame: [description]",
  duration: <valid from model>,
  aspectRatio: "9:16"
})
→ scene2.mp4

STEP 5: Repeat for N scenes (extract last → use for next)

STEP 6: Concatenate
─────────────────────────────────────────────────────────
$ cat > list.txt << EOF
file 'scene1.mp4'
file 'scene2.mp4'
file 'scene3.mp4'
EOF
$ ffmpeg -f concat -safe 0 -i list.txt -c copy final.mp4

# Or with crossfade:
$ ffmpeg -i scene1.mp4 -i scene2.mp4 -filter_complex \
    "[0:v][1:v]xfade=transition=fade:duration=0.5:offset=<dur1-0.5>[v]" \
    -map "[v]" combined.mp4
```

#### Pros / Cons
✅ Smooth motion · ✅ Cheap · ✅ Each scene at full quality
❌ Requires ffmpeg · ❌ Wan FLF2V has no audio · ❌ Need public storage

---

### Strategy D — Reference Image (always available, simplest)

For any client without shell access, OR when no other strategy is enabled.

#### When to use
- No shell access (can't run ffmpeg)
- Quick multi-scene where motion continuity isn't critical
- Each scene is a "moment" rather than continuous flow

#### Workflow

```
STEP 1: Generate character portrait
─────────────────────────────────────────────────────────
POSTZEE_GENERATE_IMAGE({
  model: "<image-model>",
  prompt: "[character description]"
})
→ portrait_url

STEP 2: Generate each scene with I2V using portrait
─────────────────────────────────────────────────────────
POSTZEE_GENERATE_VIDEO({
  model: "<i2v-model>",  // any model with supportsImg2Vid: true
  imageUrl: portrait_url,
  prompt: "[scene description with character]",
  duration: <valid from model.durations>
})
→ scene1.mp4

[Repeat — same imageUrl, different prompts]

STEP 3: User downloads videos and edits manually,
or posts as carousel of multiple videos
```

#### Pros / Cons
✅ Works in any client · ✅ Simple · ✅ Cheap
❌ Motion doesn't chain · ❌ Each scene starts from the static portrait

---

## Decision matrix

```
SHELL ACCESS (OpenClaw / Hermes / Claude Code with shell)?
├── YES
│   ├── features.veoR2V       → STRATEGY A (premium character lock)
│   ├── features.firstLastFrame → STRATEGY C (motion continuity)
│   └── features.soraStoryboard → STRATEGY B (≤25s native)
│
└── NO (Claude.ai web, etc.)
    ├── features.soraStoryboard → STRATEGY B
    ├── features.veoR2V         → STRATEGY A (post as multi-video, no compose)
    └── always                   → STRATEGY D (reference image)
```

---

## Storyboard algorithm (use every time)

Before generating, always:

```
1. Estimate total duration
   - Speech: 25 words ≈ 10s; 50 words ≈ 20s
   - Visual moment: 3-5s (static), 5-8s (with motion)
   - Multi-scene story: typically 15-30s for social media

2. Break into N scenes
   - Each scene: durations valid for the chosen model
   - 3-shot rule: setup → action → resolution

3. Build CHARACTER BIBLE (reuse VERBATIM in every prompt)
   "Mid-30s woman, dark curly hair, wearing blue blazer,
    gold earrings, professional headshot style"

4. Build SCENE BIBLE (locked environment)
   "Modern minimalist office, large windows, warm afternoon light"

5. Prompt template per scene
   "[CHARACTER BIBLE] [scene action] [SCENE BIBLE].
    Camera: [movement]. Mood: [tone]."

6. Choose strategy A/B/C/D based on context.features

7. Validate: POSTZEE_VALIDATE_GENERATION per scene
   (confirms duration is valid for the chosen model)

8. Generate
```

---

## When NOT to multi-scene

Sometimes a single-scene video is genuinely better:

- **Hero product shot** — one beautiful single shot is more impactful
- **Quote / typography video** — text-on-video as single shot
- **Logo animation** — 3-5s single scene
- **Fast-paced TikTok** — native cuts can be done in editing, not generation
- **Budget-tight** — single-scene is 1 generation vs 3-6 for multi-scene

When in doubt, ask:
> "Quer um único vídeo dinâmico de [duração] ou uma sequência de cenas conectadas (mais elaborado)?"

---

## Common mistakes

- ❌ Proposing strategies when `features.*` says they're unavailable
- ❌ Using same prompt for each scene without character bible (drift)
- ❌ Trying frame chain without shell access
- ❌ Using a duration not in the model's `durations` array (will throw)
- ❌ Not budgeting credits — multi-scene with premium models can multiply costs
- ❌ Forgetting `imageUrl` for I2V/FLF models (will fail)

Always run `POSTZEE_VALIDATE_GENERATION` before each scene to catch param errors before burning credits.

---

## Cost guidance

Never quote prices in dollars to the user. Always:

1. Run `POSTZEE_ESTIMATE_GENERATION_COST` for ONE scene
2. Multiply by number of scenes
3. Show total in **credits** to the user
4. Run `POSTZEE_VALIDATE_GENERATION({slideCount: N})` for batched cost confirmation

Example: "Pro storyboard de 3 cenas, vai dar ~{credits} créditos no total. Tens {available} disponíveis. Sigo?"
