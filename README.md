# Postzee Skill v3

The most complete AI agent skill for social media production. Turns your agent into a **world-class creative director, copywriter, video producer, and social media manager** — generating images, videos, carousels, captions, and posting to 30+ networks.

All operations go through the **Postzee MCP HTTP** server — never the REST API directly.

## What's new in v3.5 — Editorial Carousel Methodology

Carousels are now produced through a **7-stage editorial workflow** that delivers content indistinguishable from what a top human editorial team would publish:

- **Briefing Criativo** — 7 questions (brand, niche, color, visual style, narrative arc, CTA, slide count)
- **Triagem** — 4-layer analysis (Transformação / Fricção / Ângulo / Evidências) before any draft
- **Headline Engine** — exactly 10 numbered headlines (5 Investigative Cultural + 5 Magnetic Narrative) with empirical lift data, 5 patterns, 6 emotional triggers, rejection checklist
- **18-block / 9-slide structure** — every block has a target word count and a defined function
- **4 narrative arcs** — Tendência Interpretada / Tese Contraintuitiva / Case-Benchmark / Previsão-Futuro — each with its own block adaptation
- **Editorial Validation Gate** — 7 quality parameters scored ≥ 8/10, plus 5 final tests (Folha / Substitution / Promise / Article / Binary), plus 9-item visual checklist before render
- **Anti-AI-slop ruleset** — 32+ banned constructions, Portuguese grammar rules, AI-tone test
- **Mandatory frase-ponte** on the CTA slide — the bridge between content and action
- **Design system** — 4 visual styles, 11-niche palette table, dark/light rhythm, base64 `@font-face` font embedding
- **Invisible scaffolding** — agent never narrates the methodology; user only sees output

Five new reference files: `carousel-headline-engine.md`, `carousel-editorial-filter.md`, `carousel-quality-manual.md`, `carousel-design-principles.md`, `carousel-references.md` (with two complete worked examples). Plus a fully rewritten `carousel-mastery.md` orchestrator.

## What's new in v3

- **Plan-aware & credit-aware** — agent reads the user's subscription tier, credit balance, and channel state via `POSTZEE_GET_CONTEXT` before any work, then makes intelligent CTAs (FREE → upgrade, low credits → matched pack, posts cap → TEAM, etc.)
- **Single source of truth** — model catalog, capabilities, durations, resolutions, platform specs, and best-times all come live from the MCP. Skill no longer hardcodes any of these.
- **Costs in credits, never USD** — `POSTZEE_ESTIMATE_GENERATION_COST` is the only place pricing is shown to the user
- **Skill version self-check** — every session, agent compares its installed version against the published version returned by the MCP and warns the user if outdated
- **No invented features** — agent only proposes features the MCP currently exposes (`features.veoR2V`, `features.soraStoryboard`, etc.)
- **Pre-flight validation** — `POSTZEE_VALIDATE_GENERATION` catches param errors before burning credits
- **8 new MCP tools + 5 extended** — see [Architecture](#architecture)

## Capabilities

### Image
- 15+ AI image models (GPT Image 2, Recraft V4, Nano Banana 2/Pro, Ideogram V3, FLUX 2 Pro, etc.) — list lives in MCP, not skill
- Per-platform aspect ratio
- Reference image / character consistency
- Vector output (SVG via Recraft)

### Video
- 20+ AI video models (Veo 3.1, Sora 2/Pro, Kling, Luma Ray, Seedance, Pixverse, Wan, Vidu)
- Native lip-sync (HeyGen, Sora 2, Veo 3.1)
- 1080p Pro for Sora via `quality: "high"`
- Multi-language audio control
- First-Last-Frame (Wan FLF2V)

### Subtitles
- Whisper.cpp / faster-whisper / WhisperX / OpenAI Whisper API
- Word-level timestamps for trending styles
- Burn-in via ffmpeg with ASS / SRT styling

### Posting
- 30+ social networks (Instagram, Facebook, LinkedIn, X, TikTok, YouTube, Pinterest, Threads, BlueSky, Reddit, Mastodon, Telegram, Discord, etc.)
- Carousel posting in correct order (`mediaUrls` array)
- Per-platform caption optimization
- Schedule (with timezone-aware best times) or post immediately
- **Subscription-gated** — FREE plan blocked at MCP level (no surprise paywalls)

## Architecture

```
postzee-skill/
├── SKILL.md                          # Orchestrator v3.0.0
├── README.md                         # This file
└── reference/
    ├── plans-and-pricing.md          # NEW v3 — 5 plans, 5 credit packs, when to recommend which
    ├── credit-aware-flow.md          # NEW v3 — state matrix and CTA copy templates
    ├── carousel-mastery.md           # 10 frameworks
    ├── captions-frameworks.md        # AIDA/PAS/BAB/FAB/4Ps templates
    ├── hooks-library.md              # 80+ proven hook templates
    ├── multi-scene-workflow.md       # Multi-scene strategies (gated by features.*)
    ├── heygen-vs-aivideo.md          # Talking-head decision matrix
    ├── ffmpeg-cookbook.md            # Professional video composition recipes
    ├── subtitle-workflows.md         # Whisper + trending caption styles
    └── trends-2026.md                # Macro shifts and format trends
```

The agent loads `SKILL.md` first, then references the appropriate file based on user intent. Three former files (`models-image.md`, `models-video.md`, `platform-specs.md`) were **removed in v3** — that information now comes live from MCP tools.

### MCP tools used by the skill

The skill talks to the Postzee backend exclusively via these MCP tools:

| Tool | Purpose |
|------|---------|
| `POSTZEE_GET_CONTEXT` | Plan, credits, storage, channels, features, skill version (call first every session) |
| `POSTZEE_LIST_PLANS` | The 5 subscription tiers with prices and limits |
| `POSTZEE_LIST_CREDIT_PACKAGES` | The 5 one-time credit packs (eternal) |
| `POSTZEE_LIST_MODELS_DETAILED` | Capability matrix (audio, lip-sync, durations, resolutions, params) — no absolute price |
| `POSTZEE_LIST_PLATFORM_SPECS` | Per-platform aspect ratios, max slides, captions limits |
| `POSTZEE_GET_BEST_POSTING_TIMES` | Best windows per channel in the org's timezone |
| `POSTZEE_ESTIMATE_GENERATION_COST` | Cost in credits — single source of truth |
| `POSTZEE_VALIDATE_GENERATION` | Pre-flight: params valid? credits enough? plan permits? |
| `POSTZEE_LIST_CHANNELS` | Connected social accounts |
| `POSTZEE_GET_CREDITS` | Credit balance only (subset of GET_CONTEXT) |
| `POSTZEE_ENHANCE_PROMPT` | Optimize a prompt |
| `POSTZEE_GENERATE_IMAGE` | Generate an AI image |
| `POSTZEE_GENERATE_VIDEO` | Generate an AI video |
| `POSTZEE_GENERATE_HEYGEN_VIDEO` | Avatar video with HeyGen (uses HeyGen credits) |
| `POSTZEE_LIST_HEYGEN_AVATARS` / `_VOICES` | HeyGen catalog |
| `POSTZEE_CHECK_JOB` | Poll generation status |
| `POSTZEE_CREATE_POST` | Publish or schedule (subscription-gated server-side) |

## Installation

### Claude Code

```bash
gh skill install Zee-Labs/postzee-skill
```

This auto-discovers `skills/postzee/SKILL.md` in this repository.

Or manually:

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/Zee-Labs/postzee-skill /tmp/postzee-skill
cp -r /tmp/postzee-skill/skills/postzee ~/.claude/skills/postzee
```

### OpenClaw

```bash
clawhub install postzee
```

### Hermes Agent

```bash
hermes skills install https://github.com/Zee-Labs/postzee-skill --path skills/postzee
```

(or download `skills/postzee/SKILL.md` plus the `skills/postzee/reference/` directory directly into your Hermes skills folder).

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

## Updating the skill

The agent self-checks the skill version on every new session and warns you if there's a newer release. To update:

```bash
gh skill update postzee
# or, if installed manually:
cd ~/.claude/skills/postzee && git pull
```

## Usage Examples

### Image generation
```
"Generate a professional product photo for Instagram"
"Create a coffee shop scene, lifestyle aesthetic, 4:5 ratio"
```

### Video generation
```
"Create a 15-second cinematic dialogue scene for TikTok"
"Make a multi-scene story about a transformation journey"
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

### Posting
```
"Post this carousel to my Instagram and LinkedIn channels, schedule for tomorrow at the best time"
```

### Captions and copy
```
"Write the caption using PAS framework, in punchy-confident tone, with 5 niche hashtags"
"Generate 3 hook variations for this carousel"
```

## Plan & Credit awareness

The skill knows Postzee's plan structure (FREE / STANDARD / TEAM / PRO / ULTIMATE) and one-time credit packs (Starter / Basic / Standard / Pro / Enterprise). When you're low on credits or your plan doesn't cover what you're trying to do, the agent surfaces a contextual upgrade CTA — never a surprise paywall mid-generation.

**Cost is always shown in credits.** ($1 USD = 1,000 credits internally; the agent only ever talks credits to you.)

## Requirements

- A [Postzee](https://postzee.app) account
- AI credits to generate (any subscription tier with monthly credits, or one-time credit packs from any plan including FREE)
- A paid plan (STANDARD or higher) to publish via Postzee. FREE accounts can generate but not post — you can still download files and post manually.
- For ffmpeg composition: shell access in your agent environment + `ffmpeg` installed
- For local subtitles: `whisper.cpp` or `whisperx` installed

## Links

- [Postzee App](https://dashboard.postzee.app)
- [Documentation](https://docs.postzee.app)
- [Buy Credits](https://dashboard.postzee.app/credits)
- [Manage Plan](https://dashboard.postzee.app/billing)
- [Connect Channels](https://dashboard.postzee.app/channels)
- [API Public Settings](https://dashboard.postzee.app/settings)

## License

MIT — Zee Labs LLC

## Credits

Built by Zee Labs for the Postzee community.
