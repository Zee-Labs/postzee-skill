# Postzee Skill

The most complete AI agent skill for social media production. Turns your agent into a **world-class creative director, copywriter, editorial designer, video producer, and social media manager** — generating images, videos, carousels, captions, and posting to 30+ networks.

All work goes through the **Postzee MCP HTTP** server. The skill never calls the REST API directly.

**Current version:** `4.0.0` · **Compatible with:** Claude Code, Claude Desktop, Claude Web, OpenClaw, Hermes Agent.

---

## What's new in v4.0.0 — Render-direct workflow + cost / capability / voice hard rules

v4.0.0 simplifies the carousel workflow and tightens the agent's discipline around cost, capability, user assets, and voice.

### Render-direct workflow

Carousels go from approved script straight to a real Postzee render and the slides are shown inline in the conversation. Iteration runs on the actual rendered slides — no intermediate preview to maintain. The agent calls `POSTZEE_RENDER_CAROUSEL` once, displays the result via markdown image syntax (one per slide), and uses `POSTZEE_REPLACE_CAROUSEL_SLIDE` / `POSTZEE_APPEND_CAROUSEL_SLIDE` for any subsequent tweak.

The stages are now:

1. Briefing criativo (7 questions)
2. Triagem (4-layer, internal)
3. Headline — winner-first surface
4. Script (18 blocks)
5. Editorial validation gate (hard stop, internal)
6. Text approval (hard stop, user types `aprovado`)
7. Image strategy (optional — propose which slides gain a background image)
8. Render & display (one `POSTZEE_RENDER_CAROUSEL` call, slides shown inline)
9. Iteration (REPLACE/APPEND on the real slides)

Single-image posts follow a parallel 5-stage workflow with the same render-direct philosophy.

### Cost transparency hard rule (`SKILL.md` §2.1)

The agent **never quotes a credit cost without calling a pricing tool in the same turn**. Only three tools consume credits — `POSTZEE_GENERATE_IMAGE`, `POSTZEE_GENERATE_VIDEO`, `POSTZEE_GENERATE_HEYGEN_VIDEO` — and the number must come from `POSTZEE_ESTIMATE_GENERATION_COST` in the live response, never from memory. Rendering, uploading, posting, and enhancing prompts are credit-free; the agent no longer implies otherwise.

### Plan capability hard rule (`SKILL.md` §2.2)

Before promising features that depend on the plan, the agent reads `ctx.plan.canPost` / `ctx.plan.canUseAi` from `POSTZEE_GET_CONTEXT` and surfaces capability limits proactively — no surprise paywall at publish time. Plan names are quoted live from `POSTZEE_LIST_PLANS`, never hardcoded.

### User-provided images hard rule (`SKILL.md` §5)

Whenever the user provides an image (attachment, external URL, paste), the agent calls `POSTZEE_UPLOAD_MEDIA` immediately and uses the returned Postzee URL. The agent never asks the user to host the image elsewhere first.

### Voice — speak product, not implementation (`SKILL.md` §0)

The agent describes failures in product terms ("I had trouble loading that image — can you resend it?") instead of mechanism terms. Internal helper output (intermediate compositions, debug payloads) doesn't reach the conversation unless the user is explicitly debugging.

### Headline winner-first surface (preserved from v3.6)

The agent generates 10 candidates internally (5 Investigative Cultural + 5 Magnetic Narrative, with rejection checklist + coverage rule) but surfaces ONE winner with a one-line defense. Commands `boa, vai` / `outras` / `todas` expand on demand. Decision time drops from 30–180s to 5–15s.

### Editorial Carousel Methodology (preserved)

Carousels go through the full editorial discipline:

- **Briefing Criativo** — 7 questions (brand, niche, color, visual style, narrative arc, CTA, slide count)
- **Triagem** — 4-layer analysis (Transformação / Fricção / Ângulo / Evidências) before any draft
- **Headline Engine** — 10 candidates internally with empirical lift data, 5 patterns, 6 emotional triggers, rejection checklist
- **18-block / 9-slide structure** — every block has a target word count and a defined function
- **4 narrative arcs** — Tendência Interpretada / Tese Contraintuitiva / Case-Benchmark / Previsão-Futuro
- **Editorial Validation Gate** — 7 quality parameters scored ≥ 8/10, plus 5 final tests (Folha / Substitution / Promise / Article / Binary), plus 9-item visual checklist before render
- **Anti-AI-slop ruleset** — 32+ banned constructions, Portuguese grammar rules, AI-tone test
- **Mandatory frase-ponte** on the CTA slide — the bridge between content and action
- **Design system** — 6 design movements, 11-niche palette table, dark/light rhythm
- **Invisible scaffolding** — agent never narrates the methodology; user only sees output

---

## What's new in v3 (foundation)

- **Plan-aware & credit-aware** — agent reads the user's subscription tier, credit balance, and channel state via `POSTZEE_GET_CONTEXT` before any work, then makes intelligent CTAs (FREE → upgrade, low credits → matched pack, posts cap → TEAM, etc.)
- **Single source of truth** — model catalog, capabilities, durations, resolutions, platform specs, and best-times all come live from MCP tools. Skill no longer hardcodes any of these.
- **Costs in credits, never USD** — `POSTZEE_ESTIMATE_GENERATION_COST` is the only place pricing is shown to the user
- **Skill version self-check** — every session, agent compares its installed version against the published version returned by the MCP and warns the user if outdated, with a mid-session staleness fallback for clients that don't hot-reload
- **No invented features** — agent only proposes features the MCP currently exposes
- **Pre-flight validation** — `POSTZEE_VALIDATE_GENERATION` catches param errors before burning credits

---

## Capabilities

### Image

- 15+ AI image models (FLUX 2 Pro, Nano Banana Pro, Recraft V4, GPT Image 2, Imagen 3, Ideogram V3, etc.) — list lives in MCP, never hardcoded in skill
- Per-platform aspect ratios (4:5, 1:1, 9:16, 16:9, 2:3)
- Reference image / character consistency
- Vector output (SVG via Recraft)

### Video

- 20+ AI video models (Veo 3.1, Sora 2/Pro, Kling, Luma Ray, Seedance, Pixverse, Wan, Vidu)
- Native lip-sync (HeyGen, Sora 2, Veo 3.1)
- 1080p Pro for Sora via `quality: "high"`
- Multi-language audio control
- First-Last-Frame (Wan FLF2V)

### Editorial composition (carousels + single-image posts)

- **Carousels**: 1–15 slides composed as editorial documents, rendered server-side and returned as a single ordered MediaGroup
- **Single-image posts**: same architecture, N=1
- **Iteration**: the user sees the rendered slides inline in the conversation and asks for tweaks; the agent applies them via `POSTZEE_REPLACE_CAROUSEL_SLIDE` or `POSTZEE_APPEND_CAROUSEL_SLIDE` (both credit-free)

### Subtitles

- Whisper.cpp / faster-whisper / WhisperX / OpenAI Whisper API
- Word-level timestamps for trending styles
- Burn-in via ffmpeg with ASS / SRT styling

### Posting

- 30+ social networks (Instagram, Facebook, LinkedIn, X, TikTok, YouTube, Pinterest, Threads, BlueSky, Reddit, Mastodon, Telegram, Discord, Slack, etc.)
- Carousel posting in correct order (`mediaUrls` array, MediaGroup-backed)
- Per-platform caption optimization (length, hashtag conventions, hooks)
- Per-platform settings (Instagram story vs feed, TikTok privacy, YouTube visibility, etc.) via `POSTZEE_CREATE_POST` `settings` field
- Schedule (with timezone-aware best times) or post immediately
- **Subscription-gated** — FREE plan blocked at MCP level (no surprise paywalls)

---

## Architecture

```
postzee-skill/
├── SKILL.md                              # Orchestrator (~1140 lines)
├── README.md                             # This file
├── release.sh                            # Release pipeline (bumps version, packages skill, drafts GitHub Release)
└── skills/
    └── postzee/
        ├── SKILL.md                      # Same orchestrator (skill load entrypoint)
        └── reference/
            ├── carousel-mastery.md           # Carousel editorial workflow orchestrator (§9.1 Image Strategy)
            ├── carousel-headline-engine.md   # 10-headline discipline, winner-first surface, lift patterns
            ├── carousel-editorial-filter.md  # 32+ banned constructions, AI-tone test, 7 quality parameters
            ├── carousel-quality-manual.md    # 18-block structure, 4 narrative arcs, 5 final tests
            ├── carousel-design-principles.md # Slide types, dark/light rhythm, .img-box rules
            ├── carousel-references.md        # Two complete worked examples
            ├── image-mastery.md              # Single-image post workflow (5 stages)
            ├── editorial-design.md           # 6 design movements, typography pairings, brand bar, highlight system
            ├── copywriting-mastery.md        # 10 laws, 5 awareness levels, 12 hook patterns, 4 caption frameworks
            ├── smart-routing.md              # Image model routing (text-heavy vs photoreal vs illustration)
            ├── platform-settings.md          # 80+ per-platform publish settings
            ├── plans-and-pricing.md          # 5 subscription tiers, 5 credit packs
            ├── credit-aware-flow.md          # State matrix, CTA copy templates
            ├── media-memory.md               # (mediaUrl, mediaId) session tracking for asset reuse
            ├── multi-scene-workflow.md       # Character/scene consistency strategies (Sora Storyboard, Veo R2V, Wan FLF2V)
            ├── heygen-vs-aivideo.md          # Talking-head decision matrix
            ├── ffmpeg-cookbook.md            # Professional composition recipes (concat, ducking, LUFS, picture-in-picture)
            ├── subtitle-workflows.md         # Whisper + 5 trending caption styles
            ├── hooks-library.md              # 80+ proven hook templates in 10 categories
            ├── captions-frameworks.md        # AIDA / PAS / BAB / FAB / 4Ps templates
            └── trends-2026.md                # Macro shifts and format trends
```

The agent loads `SKILL.md` first, then references the appropriate file based on user intent. Three former files (`models-image.md`, `models-video.md`, `platform-specs.md`) were **removed in v3** — that information now comes live from MCP tools.

### MCP tools used by the skill

The skill talks to the Postzee backend exclusively through these MCP tools:

| Tool | Purpose |
|------|---------|
| `POSTZEE_GET_CONTEXT` | Plan, credits, storage, channels, features, skill version — **call first every session** |
| `POSTZEE_LIST_PLANS` | 5 subscription tiers with prices and limits |
| `POSTZEE_LIST_CREDIT_PACKAGES` | 5 one-time credit packs (eternal) |
| `POSTZEE_LIST_MODELS_DETAILED` | Capability matrix (audio, lip-sync, durations, resolutions, params) |
| `POSTZEE_LIST_IMAGE_MODELS` | Image-model catalog (used by §9.1 Image Strategy and `smart-routing.md`) |
| `POSTZEE_LIST_VIDEO_MODELS` | Video-model catalog |
| `POSTZEE_LIST_PLATFORM_SPECS` | Per-platform aspect ratios, max slides, captions limits |
| `POSTZEE_LIST_HEYGEN_AVATARS` / `_VOICES` | HeyGen catalog |
| `POSTZEE_GET_BEST_POSTING_TIMES` | Best windows per channel in the org's timezone |
| `POSTZEE_ESTIMATE_GENERATION_COST` | Cost in credits — single source of truth |
| `POSTZEE_VALIDATE_GENERATION` | Pre-flight: params valid? credits enough? plan permits? |
| `POSTZEE_LIST_CHANNELS` | Connected social accounts |
| `POSTZEE_GET_CREDITS` | Credit balance only (subset of GET_CONTEXT) |
| `POSTZEE_ENHANCE_PROMPT` | Optimize a prompt |
| `POSTZEE_GENERATE_IMAGE` | Generate an AI image (async → returns `jobId`) |
| `POSTZEE_GENERATE_VIDEO` | Generate an AI video (async → returns `jobId`) |
| `POSTZEE_GENERATE_HEYGEN_VIDEO` | Avatar video with HeyGen (uses HeyGen credits) |
| `POSTZEE_CHECK_JOB` | Poll generation status (returns `mediaUrl` on success) |
| `POSTZEE_RENDER_IMAGE` | Composed single-image post → rendered PNG Media |
| `POSTZEE_RENDER_CAROUSEL` | N composed slides → atomic carousel MediaGroup |
| `POSTZEE_REPLACE_CAROUSEL_SLIDE` | Replace a slide in an existing carousel (credit-free) |
| `POSTZEE_APPEND_CAROUSEL_SLIDE` | Append a slide to an existing carousel (credit-free) |
| `POSTZEE_LIST_MEDIA` | List the org's media library |
| `POSTZEE_UPLOAD_MEDIA` | Import an external URL into Postzee's CDN |
| `POSTZEE_CREATE_POST` | Publish or schedule (subscription-gated server-side) |

---

## Installation

### Claude Code

```bash
gh skill install Zee-Labs/postzee-skill
```

This auto-discovers `skills/postzee/SKILL.md` in the repository.

Or manually:

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/Zee-Labs/postzee-skill /tmp/postzee-skill
cp -r /tmp/postzee-skill/skills/postzee ~/.claude/skills/postzee
```

### Claude Desktop / Claude Web

1. Download the latest skill ZIP from [github.com/Zee-Labs/postzee-skill/releases/latest](https://github.com/Zee-Labs/postzee-skill/releases/latest) (or from the in-app dashboard at [dashboard.postzee.app/settings/account/api/](https://dashboard.postzee.app/settings/account/api/)).
2. Open Claude → Settings → Skills → Add.
3. Upload the ZIP.
4. Configure your Postzee MCP URL once — see [Setup](#setup).

> ⚠️ **Mid-session staleness**: Claude Desktop loads the skill filesystem at the **start of a conversation** and does **not** hot-reload when you update the skill in settings. If you update mid-flow, start a **new conversation** to pick up the new version. The skill detects this drift and surfaces it honestly when it happens.

### OpenClaw

```bash
clawhub install postzee
```

### Hermes Agent

```bash
hermes skills install https://github.com/Zee-Labs/postzee-skill --path skills/postzee
```

Then add to `~/.hermes/config.yaml`:

```yaml
mcp_servers:
  postzee:
    url: "https://api.postzee.app/mcp/YOUR_API_KEY/http"
    timeout: 120
```

All four clients (Claude Code, Claude Desktop, OpenClaw, Hermes) support the multi-file structure with relative markdown links.

---

## Setup

After installation, tell your agent:

> "Configure Postzee with my MCP URL"

Get your MCP URL at [dashboard.postzee.app/settings](https://dashboard.postzee.app/settings) → **API Pública** tab.

---

## Updating the skill

The agent self-checks the skill version on every new session and warns you if there's a newer release.

```bash
# Claude Code
gh skill update postzee

# OpenClaw
clawhub update postzee

# Hermes
hermes skills update postzee

# Manual (any client)
cd ~/.claude/skills/postzee && git pull
```

**Claude Desktop / Web**: download the latest ZIP and re-import (Settings → Skills). **Start a new conversation** to pick up the new version — the filesystem doesn't hot-reload mid-conversation.

---

## Usage Examples

### Carousel (the flagship flow)

```
"Create a 9-slide LinkedIn carousel about why most AI demos fail in production"
```

The agent runs the editorial workflow end to end:

1. **Briefing** — 7 questions (or 3 if user requests autonomous mode)
2. **Triagem** — silent 4-layer analysis
3. **Headline** — winner-first surface (1 headline + 3 expansion commands)
4. **Script** — 18-block / 9-slide structure with mandatory frase-ponte
5. **Validation gate** — silent (7 parameters × ≥ 8/10 + 5 final tests + visual checklist)
6. **Text approval** — hard stop, user types `aprovado`
7. **Image strategy** — agent proposes which slides gain editorial impact from a background image (user picks `gera todas` / partial / `pula`)
8. **Render & display** — one `POSTZEE_RENDER_CAROUSEL` call, slides shown inline in the conversation
9. **Iteration** — `POSTZEE_REPLACE_CAROUSEL_SLIDE` / `POSTZEE_APPEND_CAROUSEL_SLIDE` for any tweaks (credit-free)
10. **Publish** — `POSTZEE_CREATE_POST` with platform-specific settings

### Single-image post (text-heavy editorial)

```
"Make a single-image post for Instagram: 'O dev que lidera 2027 parou de esperar o próximo Opus.'"
```

Runs the 5-stage image workflow with editorial typography + photo overlay + brand bar, rendered via `POSTZEE_RENDER_IMAGE`.

### Image generation (AI image, not HTML-rendered)

```
"Generate a cinematic product photo for Instagram, 4:5"
"Create a coffee shop scene, lifestyle aesthetic"
```

### Video generation

```
"Create a 15-second cinematic dialogue scene for TikTok"
"Make a multi-scene story about a transformation journey, 4 scenes, character consistency"
```

### Talking-head video

```
"HeyGen explainer, 1 minute, my standard avatar, calm voice"
```

### Posting

```
"Post this carousel to my Instagram and LinkedIn channels, schedule for tomorrow at the best time"
"Post on Instagram as story, not feed"
"Upload to TikTok with comments disabled, no duet, no stitch"
```

### Captions and copy

```
"Write the caption using PAS framework, in punchy-confident tone, with 5 niche hashtags"
"Generate 3 hook variations using pattern-interrupt"
```

---

## Plan & Credit awareness

The skill knows Postzee's plan structure (FREE / STANDARD / TEAM / PRO / ULTIMATE) and one-time credit packs (Starter / Basic / Standard / Pro / Enterprise). When you're low on credits or your plan doesn't cover what you're trying to do, the agent surfaces a contextual upgrade CTA — never a surprise paywall mid-generation.

**Cost is always shown in credits.** ($1 USD = 1,000 credits internally; the agent only ever talks credits to the user.)

---

## Requirements

- A [Postzee](https://postzee.app) account
- AI credits to generate — any subscription tier with monthly credits, or one-time credit packs from any plan including FREE
- A paid plan (STANDARD or higher) to publish via Postzee. FREE accounts can generate but not post — files can still be downloaded and posted manually
- For ffmpeg composition: shell access + `ffmpeg` installed
- For local subtitles: `whisper.cpp` or `whisperx` installed

---

## Links

- [Postzee App](https://dashboard.postzee.app)
- [Documentation](https://docs.postzee.app)
- [Buy Credits](https://dashboard.postzee.app/credits)
- [Manage Plan](https://dashboard.postzee.app/billing)
- [Connect Channels](https://dashboard.postzee.app/channels)
- [API Pública Settings (MCP URL + Skill download)](https://dashboard.postzee.app/settings/account/api/)
- [Releases](https://github.com/Zee-Labs/postzee-skill/releases)

---

## License

MIT — Zee Labs LLC

## Credits

Built by Zee Labs for the Postzee community.
