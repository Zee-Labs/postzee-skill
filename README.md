# Postzee Skill v2

The most complete AI agent skill for social media production. Turns your agent into a **world-class creative director, copywriter, video producer, and social media manager** — generating images, videos, carousels, captions, and posting to 30+ networks.

## What's new in v2

- **Conversational creative briefs** — the agent builds a full creative direction with you before generating anything
- **Carousel mastery** — 10 proven frameworks (listicle, BAB, mythbusting, story arc, comparison, mistakes, hacks, quote+commentary, BTS, step-by-step) with per-platform specs
- **Multi-scene video consistency** — character lock via Veo 3.1 R2V, Sora 2 Storyboard 25s, Wan FLF2V chain, or reference image
- **Professional ffmpeg composition** — concat with crossfades, audio ducking, loudness normalization, aspect ratio conversion, Ken Burns, picture-in-picture, chromakey
- **Whisper subtitle workflows** — standard, highlighted-word (viral TikTok style), single-word, karaoke, type-on
- **Copywriting frameworks** — AIDA, PAS, BAB, FAB, 4 Ps with per-platform templates
- **80+ proven hooks library** organized by category (Number+Benefit, Pain+Relief, Bold Claim, Curiosity Gap, Question, Time-bound, Story, Mistake, BTS, Comparison)
- **Trends 2026 snapshot** with macro shifts, format trends, visual aesthetics, algorithm signals
- **Smart model selection** — picks the right image/video model based on use case + cost
- **Multi-language native** — respects user's language (any), adapts captions and CTAs culturally

## Capabilities

### Image
- 25+ AI image models (GPT Image 2, Recraft V4, Nano Banana 2/Pro, Ideogram V3 Quality, FLUX 2 Pro, etc.)
- Per-platform aspect ratio (1:1, 4:5, 9:16, 16:9, 2:3)
- Reference image / character consistency
- Vector output (Recraft V4 Vector / SVG)

### Video
- 20+ AI video models (Veo 3.1, Sora 2/Pro, Kling, Luma Ray, Seedance, Pixverse, Wan, Vidu)
- Native lip-sync (HeyGen, Sora 2, Veo 3.1)
- Reference-to-Video character lock (Veo 3.1 R2V)
- Multi-scene storyboards (Sora 2 Storyboard 25s)
- Frame-chain consistency (Wan FLF2V)
- ffmpeg composition (concat, transitions, audio mix, normalization)

### Subtitles
- Whisper.cpp / faster-whisper / WhisperX / OpenAI Whisper API
- Word-level timestamps for trending styles
- Burn-in via ffmpeg with ASS / SRT styling

### Posting
- 30+ social networks
- Carousel posting in correct order (mediaUrls array)
- Per-platform caption optimization
- Schedule or post immediately

## Architecture

```
postzee-skill/
├── SKILL.md                          # Orchestrator
├── README.md                         # This file
└── reference/
    ├── models-image.md               # Image model capability matrix
    ├── models-video.md               # Video model capability matrix
    ├── multi-scene-workflow.md       # 4 strategies for character/scene consistency
    ├── heygen-vs-aivideo.md          # Talking-head decision matrix
    ├── carousel-mastery.md           # 10 frameworks + per-platform specs
    ├── captions-frameworks.md        # AIDA/PAS/BAB/FAB/4Ps templates
    ├── hooks-library.md              # 80+ proven hook templates
    ├── platform-specs.md             # 2026 specs for all platforms
    ├── ffmpeg-cookbook.md            # Professional video composition recipes
    ├── subtitle-workflows.md         # Whisper + trending caption styles
    └── trends-2026.md                # Macro shifts and format trends
```

The agent loads `SKILL.md` first, then references the appropriate file based on user intent.

## Installation

### Claude Code

```bash
gh skill install Zee-Labs/postzee-skill
```

Or manually:

```bash
git clone https://github.com/Zee-Labs/postzee-skill ~/.claude/skills/postzee
```

### OpenClaw

```bash
clawhub install postzee
```

### Hermes Agent

```bash
hermes skills install https://github.com/Zee-Labs/postzee-skill
```

Then add to `~/.hermes/config.yaml`:

```yaml
mcp_servers:
  postzee:
    url: "https://api.postzee.app/mcp/YOUR_API_KEY/http"
    timeout: 120
```

All three (Claude Code, OpenClaw, Hermes) support the multi-file structure with relative markdown links.

## Setup

After installation, tell your agent:

> "Configure Postzee with my MCP URL"

Get your MCP URL at [dashboard.postzee.app/settings](https://dashboard.postzee.app/settings) → **API Pública** tab.

## Usage Examples

### Image generation
```
"Generate a professional product photo for Instagram"
"Create a coffee shop scene, lifestyle aesthetic, 4:5 ratio"
```

### Video generation
```
"Create a 15-second cinematic dialogue scene for TikTok"
"Make a multi-scene story about a transformation journey, 25s, character locked"
```

### Carousel
```
"Create a 10-slide LinkedIn carousel: '7 mistakes founders make in their first year'"
"Generate an Instagram carousel using the BAB framework about productivity"
```

### Talking head
```
"Create a HeyGen explainer video, 1 minute, my standard avatar, calm voice"
```

### Multi-scene with consistency
```
"Make a 30s video with the same character across 4 scenes — morning routine to evening reflection"
```

### Composition (with shell access)
```
"Combine these 3 clips with crossfade transitions, add bg music with ducking, normalize to -14 LUFS"
```

### Captions and copy
```
"Write the caption using PAS framework, in punchy-confident tone, with 5 niche hashtags"
"Generate 3 hook variations for this carousel"
```

### Posting
```
"Post this carousel to my Instagram and LinkedIn channels, schedule for tomorrow 7pm"
```

## Requirements

- A [Postzee](https://postzee.app) account (free or paid)
- AI credits for media generation (starting at $2 for 2,000 credits)
- At least one connected social channel (for posting)
- For ffmpeg composition: shell access in your agent environment + `ffmpeg` installed
- For local subtitles: `whisper.cpp` or `whisperx` installed

## Cost philosophy

The skill is **cost-aware** — it estimates credits before generating and proposes mid-tier models for testing, premium for finals. Carousels mix premium (slide 1 + CTA) with cheaper middle slides for 4x cost reduction without quality loss.

## Links

- [Postzee App](https://dashboard.postzee.app)
- [Documentation](https://docs.postzee.app)
- [Buy Credits](https://dashboard.postzee.app/credits)
- [Connect Channels](https://dashboard.postzee.app/channels)
- [API Public Settings](https://dashboard.postzee.app/settings)

## License

MIT — Zee Labs LLC

## Credits

Built by [Zee Labs](https://zeelabs.com.br) for the Postzee community.
