# Multi-Scene Video Workflow — Consistency Mastery

When the user's idea needs **2+ scenes that connect** — storytelling, narrative, before/after, day-in-the-life — single-shot generation isn't enough. This is the workflow that separates amateur AI video from professional production.

---

## The fundamental problem

**Without consistency strategy:** each AI video generation is independent. Generate "barista pouring coffee" twice → you get two different baristas, two different cafés, two different cups. The video chain looks like a collage of strangers.

**With consistency strategy:** character looks the same, scene environment matches, motion flows naturally between cuts. The result feels like a real production.

---

## The 4 strategies (pick one per project)

### Strategy A — Sora 2 Storyboard (NATIVE multi-shot)

**The simplest path** — Sora 2 has built-in multi-scene mode. Single API call, multiple scenes, internal continuity.

#### When to use
- Total duration ≤ 25s
- 2-6 distinct scenes
- 720p is enough (Sora 2 Storyboard is 720p only)
- Audio + lip-sync needed
- Want fastest path to multi-scene

#### Models
- `sora-2-storyboard-10s` — 2-3 scenes
- `sora-2-storyboard-15s` — 3-4 scenes
- `sora-2-storyboard-25s` — 4-6 scenes

#### How it works

```
POSTZEE_GENERATE_VIDEO({
  model: "sora-2-storyboard-25s",
  prompt: "[overall narrative]",  // optional outer prompt
  shots: [
    {
      prompt: "scene 1 detailed description",
      duration: 8,
      imageUrl: "optional ref image"
    },
    {
      prompt: "scene 2 detailed description",
      duration: 8,
      imageUrl: "optional ref"
    },
    {
      prompt: "scene 3 detailed description",
      duration: 9
    }
  ],
  aspectRatio: "9:16"
})
```

#### Pros
- ✅ Native consistency between shots
- ✅ Single API call
- ✅ Handles audio across scenes
- ✅ No external composition needed

#### Cons
- ❌ Max 25s
- ❌ 720p only
- ❌ Less control over individual scene quality

---

### Strategy B — Veo 3.1 Reference-to-Video ⭐ (CHARACTER LOCK)

**Best for character consistency** across multiple separately-generated videos. The R2V mode accepts multiple reference images and locks the character/object/scene look.

#### When to use
- Same character must appear in 3+ separate scenes
- Need 1080p or 4K (Sora Storyboard caps at 720p)
- Each scene needs full 8s with high quality
- Cinematic look + audio + lip-sync

#### Workflow

```
STEP 1: Generate or upload character portrait (reference image)
─────────────────────────────────────────────────────────────
POSTZEE_GENERATE_IMAGE({
  model: "nano-banana-2",  // or gpt-image-2-high
  prompt: "Mid-30s woman, dark curly hair, wearing blue blazer, 
           gold earrings, professional headshot, neutral background, 
           natural lighting",
  aspectRatio: "1:1"
})
→ portrait_url

STEP 2: Optionally generate scene/environment reference
─────────────────────────────────────────────────────────────
POSTZEE_GENERATE_IMAGE({
  model: "nano-banana-2",
  prompt: "Modern minimalist office, large windows, warm afternoon 
           light, plants on desk, soft beige walls"
})
→ scene_url

STEP 3: Generate each video scene with R2V
─────────────────────────────────────────────────────────────
POSTZEE_GENERATE_VIDEO({
  model: "fal-ai/veo3.1/reference-to-video",
  prompt: "[Character] sitting at desk, looking at laptop, 
           thoughtful expression. Camera dolly in slowly.",
  imageUrls: [portrait_url, scene_url],  // up to 3 refs
  aspectRatio: "9:16"
})
→ scene1.mp4

[Repeat for scenes 2, 3, ...N — each call uses same imageUrls]

STEP 4: Compose final video (if shell-capable, see ffmpeg-cookbook)
─────────────────────────────────────────────────────────────
ffmpeg concat with crossfade transitions → final.mp4
```

#### Pros
- ✅ Best character consistency across separate generations
- ✅ Can scale to 4+ scenes (no Sora 25s limit)
- ✅ 4K available
- ✅ Audio + multilingual lip-sync
- ✅ Each scene has full 8s of premium quality

#### Cons
- ❌ Requires external composition (ffmpeg) for final video
- ❌ More expensive per scene than Sora Storyboard
- ❌ Each scene is a separate API call

---

### Strategy C — Frame Chain (Wan FLF2V or Veo 3.1 FLF)

**Smoothest motion continuation.** Each scene starts where the last one ended — perfect for fluid action sequences.

#### When to use
- Need natural motion flow between scenes
- Have shell access (ffmpeg required)
- Continuous action / single environment with motion progression
- Budget-conscious (Wan FLF2V is very cheap)

#### Models
- **`wan-flf2v`** — first-last-frame interpolation, no audio, very cheap
- **`fal-ai/veo3.1/first-last-frame-to-video`** — premium with audio
- **`fal-ai/veo3.1/fast/first-last-frame-to-video`** — Veo Fast variant

#### Workflow (shell-capable required)

```
STEP 1: Generate Scene 1 with any video model
─────────────────────────────────────────────────────────────
POSTZEE_GENERATE_VIDEO({
  model: "veo3.1",  // or sora-2-t2v-10s, kling-3.0-pro, etc.
  prompt: "Scene 1 description",
  duration: 8,
  aspectRatio: "9:16"
})
→ scene1.mp4

STEP 2: Extract last frame
─────────────────────────────────────────────────────────────
$ ffmpeg -sseof -0.1 -i scene1.mp4 -frames:v 1 -q:v 2 last_frame_1.jpg

STEP 3: Upload last_frame_1.jpg to public storage
─────────────────────────────────────────────────────────────
Use: Cloudflare R2, S3, imgur, or any public host
→ last_frame_1_url

STEP 4: Generate Scene 2 with FLF
─────────────────────────────────────────────────────────────
POSTZEE_GENERATE_VIDEO({
  model: "wan-flf2v",  // or veo3.1/first-last-frame-to-video
  imageUrl: last_frame_1_url,  // start frame
  prompt: "Scene 2 continues from this frame: [description]",
  duration: 8,
  aspectRatio: "9:16"
})
→ scene2.mp4

STEP 5: Repeat for N scenes
─────────────────────────────────────────────────────────────
Extract last frame of scene2 → use for scene3 → ...

STEP 6: Concatenate all scenes
─────────────────────────────────────────────────────────────
$ cat > list.txt << EOF
file 'scene1.mp4'
file 'scene2.mp4'
file 'scene3.mp4'
EOF
$ ffmpeg -f concat -safe 0 -i list.txt -c copy final.mp4

# Or with crossfade:
$ ffmpeg -i scene1.mp4 -i scene2.mp4 -filter_complex \
    "[0:v][1:v]xfade=transition=fade:duration=0.5:offset=7.5[v]" \
    -map "[v]" combined.mp4
```

#### Pros
- ✅ Smooth motion continuity
- ✅ Wan FLF2V is the cheapest video model
- ✅ Each scene at full quality

#### Cons
- ❌ Requires ffmpeg (shell-capable client only)
- ❌ Wan FLF2V has no audio
- ❌ More steps and orchestration
- ❌ Need public storage to host extracted frames

---

### Strategy D — Reference Image (simplest, less consistency)

**For Claude.ai / web clients without shell access.** Generate a character portrait, then pass it as `imageUrl` in each I2V generation. Character is preserved, but motion may not chain perfectly.

#### When to use
- No shell access (can't run ffmpeg)
- Quick multi-scene where motion continuity isn't critical
- Each scene is a "moment" rather than a continuous flow

#### Workflow

```
STEP 1: Generate character portrait
─────────────────────────────────────────────────────────────
POSTZEE_GENERATE_IMAGE({
  model: "nano-banana-2",
  prompt: "[character description]"
})
→ portrait_url

STEP 2: Generate each scene with I2V using portrait
─────────────────────────────────────────────────────────────
POSTZEE_GENERATE_VIDEO({
  model: "kling-3.0-pro",  // or any I2V-capable model
  imageUrl: portrait_url,
  prompt: "[scene description with character]",
  duration: 5
})
→ scene1.mp4

[Repeat — same imageUrl, different prompts]

STEP 3: User downloads videos and edits manually
or posts as carousel of multiple videos
```

#### Pros
- ✅ Works in any client (no shell needed)
- ✅ Simple to orchestrate
- ✅ Cheap

#### Cons
- ❌ Motion doesn't chain between scenes
- ❌ User has to compose externally if they want a single combined video
- ❌ Each scene starts from the static portrait

---

## Decision matrix

```
SHELL ACCESS (OpenClaw / Hermes / Claude Code with shell)?
├── YES
│   ├── Need premium quality + character lock → STRATEGY B (Veo R2V) + ffmpeg compose
│   ├── Need motion continuity (action sequence) → STRATEGY C (FLF chain) + ffmpeg compose
│   └── Quick native multi-shot ≤ 25s → STRATEGY A (Sora Storyboard)
│
└── NO (Claude.ai web, etc.)
    ├── Native multi-shot ≤ 25s → STRATEGY A (Sora Storyboard)
    ├── Premium with character lock → STRATEGY B (Veo R2V), post as multi-video carousel
    └── Quick multi-scene with character → STRATEGY D (Reference image)
```

---

## Storyboard algorithm (use this every time)

Before generating, always:

```
1. Estimate total duration
   - Speech: 25 words ≈ 10s; 50 words ≈ 20s
   - Visual moment: 3-5s (static), 5-8s (with motion)
   - Multi-scene story: typically 15-30s for social media

2. Break into N scenes
   - Each scene: 5-15s
   - 3-shot rule: setup → action → resolution
   - Transition points: where the scene naturally cuts

3. Build CHARACTER BIBLE
   "Mid-30s woman, dark curly hair, wearing blue blazer, 
    gold earrings, professional headshot style"
   
   Lock this description and reuse VERBATIM in every prompt.

4. Build SCENE BIBLE
   "Modern minimalist office, large windows, warm afternoon 
    light, plants on desk, soft beige walls"
   
   Lock this and reuse.

5. Prompt template per scene
   "[CHARACTER BIBLE] [scene action] [SCENE BIBLE]. 
    Camera: [movement]. Mood: [tone]."

6. Choose strategy (A/B/C/D)

7. Generate
```

### Example storyboard

**User asks:** "Vídeo de uma jornada de transformação, mulher empreendedora começando do zero até o sucesso, pra Reels"

**Storyboard:**

```
Total: 25s, vertical 9:16, with audio
Strategy: SORA 2 STORYBOARD 25s (single API, native consistency)

CHARACTER BIBLE:
"Brazilian woman, mid-30s, dark curly hair, expressive eyes, 
warm smile, casual chic style"

SCENE BIBLE:
Each scene, distinct location showing progression

Shot 1 (8s) — Setup
"[CHARACTER] sitting at small kitchen table, late at night, 
laptop screen glowing, surrounded by sketches and coffee cups, 
determined expression. Camera slowly pushes in. Soft jazz ambience."

Shot 2 (8s) — Growth  
"[CHARACTER] standing in small office, presenting product to 
3 people, confident gesture, natural daylight, energetic atmosphere. 
Camera dolly around. Upbeat music."

Shot 3 (9s) — Achievement
"[CHARACTER] on stage at conference, applause, confident smile, 
spotlight, large 'SUCCESS' banner. Camera wide shot. Triumphant music."
```

---

## When NOT to multi-scene

Sometimes a single-scene video is genuinely better:

- **Hero product shot** — one beautiful 8s shot of the product is more impactful
- **Quote / typography video** — text-on-video works as single shot
- **Logo animation** — 3-5s single scene
- **Fast-paced trending format** — TikTok native cuts can be done in editing, not generation
- **Budget-tight** — single-scene is 1 generation vs 3-6 for multi-scene

When in doubt, ask the user:
> "Quer um único vídeo dinâmico de [duração] ou uma sequência de cenas conectadas (mais elaborado)?"

---

## Common mistakes

- ❌ Using same prompt for each scene without character bible — drift
- ❌ Mixing strategies mid-project (start with Storyboard, switch to FLF chain mid-way)
- ❌ Forgetting to verify the model supports the chosen mode (e.g., trying R2V on a non-R2V model)
- ❌ Trying frame chain without shell access — won't work
- ❌ Using Sora Storyboard for >25s — break into 2 separate Storyboard calls + concat
- ❌ Not budgeting credits — multi-scene with Veo R2V + 4K can hit thousands of credits per minute of final video

---

## Cost reality check

For a 25s final video:

| Strategy | Generations | Est. cost (relative) |
|----------|-------------|----------------------|
| Sora 2 Storyboard 25s (native) | 1 | $$ |
| Veo 3.1 R2V (3 scenes × 8s, 720p) | 3 | $$$$ |
| Veo 3.1 R2V 1080p audio (3 scenes) | 3 | $$$$$$ |
| Wan FLF2V chain (5 scenes × 5s) | 5 | $ |
| Reference image (3 scenes × Kling) | 3 + 1 image | $$ |

Always tell the user the estimated cost before generating multi-scene.
