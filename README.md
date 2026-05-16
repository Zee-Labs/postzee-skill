# Postzee Skill

The most complete AI agent skill for social media production. Turns your agent into a **world-class creative director, copywriter, editorial designer, video producer, and social media manager** — generating images, videos, carousels, captions, and posting to 30+ networks.

All work goes through the **Postzee MCP HTTP** server. The skill never calls the REST API directly.

**Current version:** `3.8.1` · **Compatible with:** Claude Code, Claude Desktop, Claude Web, OpenClaw, Hermes Agent.

---

## What's new in v3.8

### v3.8.1 — Path B engine discipline + stale-version UX (2026-05-15, patch)

Two corrections that close real production incidents:

- **Path B is Playwright + Chromium. No substitutes.** The skill now explicitly rejects `wkhtmltoimage`, `weasyprint`, `pdfkit`, `html2canvas`, `phantomjs`, and any non-Chromium-modern engine for Path B rendering — even when they're conveniently installed on the host. The carousel design system uses modern CSS (flexbox `gap`, `clip-path`, `filter: drop-shadow`, large `data:` URI assets, pill backgrounds) that legacy engines silently break. Detection (§2.1 of `smart-rendering.md`) is now Playwright-strict; if Playwright + Chromium isn't available, the skill falls back to Path A. The "95% similar" alternative engine is not Path B — it's a quiet broken-promise to the user.

- **Mid-session staleness honesty** — in Claude Desktop and similar clients, the skill filesystem is loaded at session start and does not hot-reload when the user updates the skill in app settings. The skill now detects this drift (§1.1 of `SKILL.md`) and surfaces an honest message: "this conversation loaded v[X], the current published version is v[Y], the client doesn't reload mid-conversation, please start a new conversation — I'll hand you a context bundle to resume from where we paused." No silent degradation.

### v3.8.0 — Image Strategy Step 0 (2026-05-15, minor)

The carousel workflow gains a new beat **between text approval and visual preview**: the agent proactively analyzes which slides would gain real editorial impact from a background image and proposes generating them — before composing the artifact, before any render call.

- **Cover slide is almost always proposed** as an image candidate (except typography-led design movements where the headline IS the visual).
- **Internal slides pass a rigorous 4-criterion AND filter**: (1) loses editorial force without image, (2) has a concrete visual subject (abstract concepts fail), (3) body text < ~40 words, (4) doesn't saturate the rhythm.
- **Typical results**: tutorials get 1 image (cover only), educational/tese get 1-2, storytelling/case-study get 2-3. If the filter qualifies 4+ slides, the discipline broke — re-evaluate with criterion #1 as the hard gate.
- **User-facing proposal** lists each candidate slide with prompt (translated to the user's language) + model + cost in credits + current balance + the typography-only alternative. Five commands: `gera todas` / `só capa` / numerical subset / `pula` / `outros prompts`.
- **NOT an upsell**. The agent proposes only when editorial necessity is real. Carousels that don't need images get a "só capa" proposal or no proposal at all.

Stage 7a is now **three steps**: Step 0 (image strategy, `carousel-mastery.md` §9.1), Step 1 (compose preview), Step 2 (iterate). Workflow detail in `carousel-mastery.md` §9.0–§9.1.

---

## What's new in v3.7

### v3.7.2 — Path A token-budget breakthrough + capability-first Path B (2026-05-15, patch)

The bottleneck that made some carousels stall in render wasn't Postzee's payload limit — it was the **model's output token budget** writing tool-call arguments. Each byte of base64 in the call costs ~0.25 tokens; 9 slides × ~270 KB (fonts + cover in base64) = ~600K output tokens. Impossible.

Three swaps applied at the preview→render conversion (`carousel-visual-preview.md` §5.1):

1. **Image source swap**: preview keeps base64 (artifact CSP blocks externals); render uses CDN URLs when known (Postzee `POSTZEE_GENERATE_IMAGE` output, `POSTZEE_UPLOAD_MEDIA` result, or any public URL the agent reached via WebFetch). Backend's Puppeteer allowlist is permissive — any public URL passes.
2. **Font delivery swap**: preview keeps base64 `@font-face`; render uses Google Fonts `<link>` (Postzee Puppeteer waits for `document.fonts.ready` before screenshotting). Base64 stays as a fallback for non-Google brand fonts.
3. **`font-display` swap**: preview uses `swap` (CSP-safe); render uses `block` (Puppeteer waits, no fallback typography in the PNG).

Result: ~270 KB / slide → ~10 KB / slide. ~600K output tokens → ~22K. Renders that previously took minutes of "shrink gymnastics" now go through in one shot.

Path B was also refactored from surface-name-driven to **capability-first**: any surface that exposes Bash + Node + Playwright runs detection (`smart-rendering.md` §2.1) and gets Path B if it passes — Claude Desktop with shell MCP, hermes, openclaw included. No external MCP server required.

### v3.7.1 — Cleanup of legacy refs after preview shape switch (2026-05-15, patch)

After the v3.6 preview shape change (iframe → single doc), ~13 references across other skill docs still mentioned the old iframe / "single HTML for both surfaces" model. Cleanup commit. Zero functional change.

### v3.7.0 — Single-image posts + Editorial design system + Smart rendering + Per-platform settings (2026-05-14, minor)

Four pillars on top of v3.6:

- **Single-image posts via HTML** — the same architecture that powers carousels (skill composes editorial HTML, Postzee renders to PNG) extended to standalone text-heavy posts. The agent generates editorial typography + photo overlay + brand bar in a single composition; the user posts the resulting PNG to any feed. New tools: `POSTZEE_RENDER_IMAGE`. New methodology: `reference/image-mastery.md` (6-stage workflow with autonomous-mode briefing — 3 questions max instead of 7).

- **Editorial design system** — `reference/editorial-design.md` codifies the 6 design movements (Editorial / Bold / Minimal / Photo-led / Magazine / Brutalist) with typography pairings, composition rules, color systems. The type contrast law (display:body ≥ 4:1), the photo treatment rules (grade, subject placement, blocking), the brand bar system (8 canonical positions), the highlight block system (orange/red/underline emphasis), the 9-item visual polish checklist.

- **Copywriter brain** — `reference/copywriting-mastery.md` codifies 10 inviolable laws (specificity, one-promise, conversation join, pattern interrupt, slippery slope, show-don't-tell, etc.) synthesized from Schwartz / Sugarman / Kennedy / Halbert / Hopkins / Ogilvy / Shleyner / Harry Dry. The 5 awareness levels, the 12 hook patterns atlas, the 4 caption frameworks (AIDA / PAS / BAB / Hook→Promise→Payoff→CTA), the Brazilian voice register with anti-anglicism guidelines.

- **Smart rendering — Path A vs Path B** — when the agent has local rendering capability (Bash + Playwright + Chromium), `reference/smart-rendering.md` teaches it to render locally and upload bytes (Path B) instead of sending HTML to Postzee's Puppeteer pool (Path A). Saves 5-30s per render on capable surfaces; falls back transparently otherwise. New tools: `POSTZEE_UPLOAD_RENDERED_IMAGE`, `POSTZEE_UPLOAD_RENDERED_CAROUSEL`.

- **Per-platform publish settings** — `reference/platform-settings.md` documents 80+ network-specific settings across the top-8 platforms (Instagram story vs feed, TikTok privacy/duet/stitch/comment/music/title, YouTube visibility/tags/description, LinkedIn carousel mode, Pinterest board, Facebook story, etc.) with PT-BR + EN trigger phrases and smart defaults. Closes a v3.6 bug where posting "no Instagram como story" was silently going to feed because the MCP tool stripped per-platform settings. v3.7 adds a `settings` passthrough on `POSTZEE_CREATE_POST`.

---

## What's new in v3.6 — Winner-First Headlines + Visual Preview Artifact

Two structural UX upgrades on top of the v3.5 editorial methodology:

- **Headline surface: winner-first instead of a menu of 10** — the agent still generates 10 candidates internally (rejection checklist, pattern coverage rule, lift-table selection — all preserved), but surfaces ONE winner with a one-line defense. Three commands expand on demand: `boa, vai` continues with the winner, `outras` reveals the top-3, `todas` reveals all 10. Indexed commands (`mistura a 3 com a 7`, etc.) still work. Decision time drops from 30–180s to 5–15s.

- **Stage 7 split into 7a (visual preview) + 7b (render & ship)** — the agent composes the full slide HTMLs and outputs them as ONE aggregated HTML artifact (no iframes — see `carousel-visual-preview.md` §2 bug history) for the user to iterate on visually. "muda fundo do slide 3", "troca slide 4 e 5", "remove slide 7" — all happen locally, zero Postzee credit spent. Only on `renderiza` / `aprovado` does `POSTZEE_RENDER_CAROUSEL` get called. One render, zero retrabalho.

The carousel workflow is now **8 stages**, with stage 7a internally split into three steps (Step 0 image strategy added in v3.8.0; Step 1 compose; Step 2 iterate). `REPLACE_CAROUSEL_SLIDE` and `APPEND_CAROUSEL_SLIDE` are demoted to post-render escape hatches.

A reference file `carousel-visual-preview.md` documents the artifact structure, image inlining decision tree, iteration vocabulary, preview→render shape conversion (§5.1), and graceful degradation for surfaces without artifact rendering.

Companion backend bump: `MAX_HTML_SIZE` 250 KB → 7 MB per slide, new `MAX_PAYLOAD_SIZE` = 50 MB total per RENDER call. Enough headroom to embed images as base64 alongside fonts when the swap rule isn't applicable.

---

## What's new in v3.5 — Editorial Carousel Methodology

Carousels are produced through an **editorial workflow** (v3.6 expanded this to 8 stages; v3.8 added Step 0 to stage 7a) that delivers content indistinguishable from what a top human editorial team would publish:

- **Briefing Criativo** — 7 questions (brand, niche, color, visual style, narrative arc, CTA, slide count)
- **Triagem** — 4-layer analysis (Transformação / Fricção / Ângulo / Evidências) before any draft
- **Headline Engine** — 10 candidates internally (5 Investigative Cultural + 5 Magnetic Narrative) with empirical lift data, 5 patterns, 6 emotional triggers, rejection checklist. Surfaced winner-first since v3.6.
- **18-block / 9-slide structure** — every block has a target word count and a defined function
- **4 narrative arcs** — Tendência Interpretada / Tese Contraintuitiva / Case-Benchmark / Previsão-Futuro
- **Editorial Validation Gate** — 7 quality parameters scored ≥ 8/10, plus 5 final tests (Folha / Substitution / Promise / Article / Binary), plus 9-item visual checklist before render
- **Anti-AI-slop ruleset** — 32+ banned constructions, Portuguese grammar rules, AI-tone test
- **Mandatory frase-ponte** on the CTA slide — the bridge between content and action
- **Design system** — 6 design movements (since v3.7), 11-niche palette table, dark/light rhythm, font delivery via Google Fonts `<link>` for render and base64 `@font-face` for preview
- **Invisible scaffolding** — agent never narrates the methodology; user only sees output

---

## What's new in v3 (foundation)

- **Plan-aware & credit-aware** — agent reads the user's subscription tier, credit balance, and channel state via `POSTZEE_GET_CONTEXT` before any work, then makes intelligent CTAs (FREE → upgrade, low credits → matched pack, posts cap → TEAM, etc.)
- **Single source of truth** — model catalog, capabilities, durations, resolutions, platform specs, and best-times all come live from MCP tools. Skill no longer hardcodes any of these.
- **Costs in credits, never USD** — `POSTZEE_ESTIMATE_GENERATION_COST` is the only place pricing is shown to the user
- **Skill version self-check** — every session, agent compares its installed version against the published version returned by the MCP and warns the user if outdated (mid-session staleness UX added in v3.8.1)
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

### HTML rendering (carousels + single-image posts)

- **Carousels**: 1–15 slides composed as editorial HTML, rendered to PNG via Postzee Puppeteer (Path A) or local Playwright + Chromium (Path B, when available)
- **Single-image posts**: same architecture, N=1
- **Preview shape vs render shape**: preview is an aggregated single-document artifact for the user to iterate on locally; render is per-slide independent HTML at full canvas resolution. Mechanical conversion at hand-off (`carousel-visual-preview.md` §5.1).

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
            ├── carousel-mastery.md           # Carousel editorial workflow orchestrator (8 stages, §9.1 Image Strategy Step 0)
            ├── carousel-visual-preview.md    # Stage 7a Steps 1 + 2 — artifact protocol + preview→render conversion (§5.1)
            ├── carousel-headline-engine.md   # 10-headline discipline, winner-first surface, lift patterns
            ├── carousel-editorial-filter.md  # 32+ banned constructions, AI-tone test, 7 quality parameters
            ├── carousel-quality-manual.md    # 18-block structure, 4 narrative arcs, 5 final tests
            ├── carousel-design-principles.md # Slide types, dark/light rhythm, .img-box rules
            ├── carousel-references.md        # Two complete worked examples
            ├── image-mastery.md              # Single-image post workflow (6 stages)
            ├── editorial-design.md           # 6 design movements, typography pairings, brand bar, highlight system
            ├── copywriting-mastery.md        # 10 laws, 5 awareness levels, 12 hook patterns, 4 caption frameworks
            ├── smart-rendering.md            # Path A vs Path B (capability-first detection, Playwright-strict)
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
| `POSTZEE_RENDER_IMAGE` | HTML → single rendered PNG Media (Path A) |
| `POSTZEE_RENDER_CAROUSEL` | N HTML docs → atomic carousel MediaGroup (Path A) |
| `POSTZEE_UPLOAD_RENDERED_IMAGE` | Pre-rendered PNG bytes → Media (Path B) |
| `POSTZEE_UPLOAD_RENDERED_CAROUSEL` | N pre-rendered PNGs → carousel MediaGroup (Path B) |
| `POSTZEE_REPLACE_CAROUSEL_SLIDE` | Replace a slide post-render (escape hatch) |
| `POSTZEE_APPEND_CAROUSEL_SLIDE` | Append a slide post-render (escape hatch) |
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
7. **Stage 7a Step 0 — Image Strategy** — agent proposes which slides gain editorial impact from a background image
8. **Stage 7a Step 1 — Visual preview** — aggregated HTML artifact, iterate freely
9. **Stage 7a Step 2 — Iterate** — natural-language tweaks ("muda fundo do slide 3", "troca slide 4 e 5")
10. **Stage 7b — Render & ship** — one `POSTZEE_RENDER_CAROUSEL` call (or `POSTZEE_UPLOAD_RENDERED_CAROUSEL` on Path B)
11. **Publish** — `POSTZEE_CREATE_POST` with platform-specific settings

### Single-image post (text-heavy editorial)

```
"Make a single-image post for Instagram: 'O dev que lidera 2027 parou de esperar o próximo Opus.'"
```

Runs the 6-stage image workflow with editorial typography + photo overlay + brand bar, rendered to PNG via `POSTZEE_RENDER_IMAGE`.

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
- For Path B rendering: shell access in your agent environment + Node + Playwright + Chromium (the skill installs Playwright on demand once if the user agrees). **No engine substitutes** — see `smart-rendering.md` §1.1.
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
