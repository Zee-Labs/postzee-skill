# Platform Settings — Per-Network Publish Customization

This file is the agent's reference for **per-platform settings** when publishing via `POSTZEE_CREATE_POST`. Without these, a user asking for "Instagram story" gets posted to the feed (real bug from v3.6).

The MCP tool `POSTZEE_CREATE_POST` exposes a `settings` parameter (added in v3.7 alongside this doc). The agent sends FLAT per-platform fields; the backend auto-derives the `__type` discriminator from the channel's platform — you don't think about it.

```typescript
POSTZEE_CREATE_POST({
  channelId: '<instagram-channel-id>',
  text: '<caption>',
  mediaUrls: ['<url>'],
  type: 'now',
  settings: {
    // Pick the fields relevant to the channel's platform.
    // The MCP discards what doesn't apply.
    post_type: 'story',
    collaborators: [{ label: '@cofounder' }],
  }
})
```

This doc covers the **top-8 networks** (95%+ of posts in 2026). Less-common platforms (Mastodon, Lemmy, Dribbble, WordPress, etc.) accept additional settings — see `dashboard/libraries/nestjs-libraries/src/dtos/posts/providers-settings/` for the source-of-truth DTOs.

---

## 1. Decision protocol — when to set what

The agent reads platform settings in 4 contexts:

### 1.1 User explicit request
The user says "story", "story do Instagram", "como reel", "no privado do TikTok" — the agent maps to the right field. **Highest precedence**.

### 1.2 Content-shape inference
The user uploaded 9:16 vertical video to Instagram → likely `reel` (not `post`). The user wrote a 50-word caption with `#tags` → standard feed `post`. The user asked for a sequence of 9 slides → carousel `post` (never `story`).

### 1.3 Channel-platform smart defaults
TikTok image-only posts: default `autoAddMusic: 'yes'` (otherwise the post feels static). YouTube uploads with no explicit visibility: default `type: 'public'`. Etc.

### 1.4 Brand-voice defaults (when cached in session)
If the brand has previously posted with `collaborators: ['@cofounder', '@designer']`, the agent CAN propose the same for follow-ups — but always SURFACES the inferred default for confirmation, never assumes.

**Surfacing the inference**: when applying a non-trivial setting, the agent tells the user once:

> *"Vou postar como Story (você falou 'story') com `@designer` marcada (vc costuma marcar). Posso?"*

---

## 2. Instagram

Postzee channel platforms: `instagram` (Facebook Business API) and `instagram-standalone`.

### 2.1 Settings

| Field | Type | Values | Default |
|---|---|---|---|
| `post_type` | string | `'post'` / `'story'` | `'post'` |
| `collaborators` | array | `[{ label: '@username' }, ...]` | `[]` |

### 2.2 Triggers (PT-BR / EN)

| User phrase | Setting |
|---|---|
| `story` / `stories` / `nos stories` / `na story` / `coloca no story` | `post_type: 'story'` |
| `feed` / `feed normal` / `post normal` / `na timeline` | `post_type: 'post'` |
| `marca o @X` / `tag @X` / `colab com @X` / `add @X como colaborador` | Add to `collaborators` |
| `as a story` / `to stories` | `post_type: 'story'` |
| `as a regular post` / `in feed` | `post_type: 'post'` |

### 2.3 Smart defaults

- Carousel (>1 image) → `post_type: 'post'` (IG stories don't support carousels)
- Single image vertical 9:16 → if user mentioned "reel", that's a separate channel concern (Postzee handles via the instagram-reel channel type — not via `post_type`); otherwise default to `post`
- Single image 1:1 or 4:5 → `post_type: 'post'`
- Single image 9:16 + caption ≤30 words + no mention of reel/feed → ASK once: *"É pro feed (post normal) ou pro story?"*

### 2.4 NOT supported by `post_type` field

- **Reels** — goes through a DIFFERENT channel/integration on Postzee (not via Instagram main; via the reel-specific endpoint). The agent recognizes "reel" but DOESN'T set `post_type: 'reel'` (not a valid value). Instead, surface: *"Reels passa por um canal separado — você tem o Instagram Reels conectado?"*. Check via `POSTZEE_LIST_CHANNELS` for reel-type integrations.
- **Lives** — not via this tool.
- **Notes / IG Notes** — not exposed.

### 2.5 Worked example

User: *"posta esse carrossel no insta como story"*

Agent:
1. Recognize the trigger phrase "como story".
2. Note: carousel → can't be story. Stories accept 1 image at a time.
3. Surface the conflict + propose: *"Stories só aceitam 1 imagem por vez. Posso (a) postar o carrossel no feed normal e em paralelo subir 1 slide chave como story, ou (b) postar APENAS 1 slide no story. Qual?"*
4. Wait for user decision. Don't silently fall back to feed (that's the v3.6 bug).

---

## 3. TikTok

Postzee channel platform: `tiktok`.

### 3.1 Settings

| Field | Type | Values | Default |
|---|---|---|---|
| `privacy_level` | string | `'PUBLIC_TO_EVERYONE'` / `'MUTUAL_FOLLOW_FRIENDS'` / `'FOLLOWER_OF_CREATOR'` / `'SELF_ONLY'` | `'PUBLIC_TO_EVERYONE'` |
| `duet` | boolean | `true` / `false` | `true` |
| `stitch` | boolean | `true` / `false` | `true` |
| `comment` | boolean | `true` / `false` | `true` |
| `title` | string | max 90 chars | derived from caption |
| `autoAddMusic` | string | `'yes'` / `'no'` | `'yes'` for image-only posts |

### 3.2 Triggers

| User phrase | Setting |
|---|---|
| `privado` / `só pra mim` / `só eu vejo` | `privacy_level: 'SELF_ONLY'` |
| `só pros amigos` / `mutual friends` | `privacy_level: 'MUTUAL_FOLLOW_FRIENDS'` |
| `só pros seguidores` / `followers only` | `privacy_level: 'FOLLOWER_OF_CREATOR'` |
| `público` / `todos podem ver` / `feed normal` | `privacy_level: 'PUBLIC_TO_EVERYONE'` (default) |
| `sem duet` / `desativa duet` / `no duets` | `duet: false` |
| `sem stitch` / `desativa stitch` | `stitch: false` |
| `desativa comentários` / `sem comentários` / `disable comments` | `comment: false` |
| `sem música` / `posta sem música` / `silent` | `autoAddMusic: 'no'` |
| `título: X` / `título do vídeo` | `title: 'X'` (clamp to 90 chars) |

### 3.3 Smart defaults

- TikTok **always** wants `duet: true` and `stitch: true` for organic reach — the algorithm penalizes posts that disable them. Don't disable unless user explicitly asks.
- Image-only posts (no video): `autoAddMusic: 'yes'` is the difference between "video post" and "lifeless slideshow". Default ON.
- TikTok title is the body — first 90 chars of the caption usually. If caption is longer, summarize the first 90 chars or let user supply explicit `title`.

### 3.4 Compliance note (CRITICAL)

TikTok has **specific compliance requirements** for connected commerce (paid promo declarations, branded content, etc.). The unified-creator UI presents persistent modals for these. The MCP doesn't expose those compliance fields yet — if the user is doing paid promo content, route through the dashboard UI manually. See `dashboard/CLAUDE.md` for the no-simplify rule on TikTok compliance.

---

## 4. YouTube

Postzee channel platform: `youtube`.

### 4.1 Settings

| Field | Type | Values | Default |
|---|---|---|---|
| `title` | string | max 100 chars | derived from caption first-line |
| `type` | string | `'public'` / `'private'` / `'unlisted'` | `'public'` |
| `tags` | array | `[{ value: 'tag1', label: 'Tag 1' }, ...]` | `[]` |
| `description` | string | up to ~5000 chars (Postzee maps from `text` automatically) | from `text` |

### 4.2 Triggers

| User phrase | Setting |
|---|---|
| `público` / `public` (default) | `type: 'public'` |
| `privado` / `private` / `só eu vejo` | `type: 'private'` |
| `não listado` / `unlisted` / `só com link` | `type: 'unlisted'` |
| `título: X` | `title: 'X'` |
| `tags: A, B, C` / `add tags X Y Z` | `tags: [{value: 'A', label: 'A'}, ...]` |

### 4.3 Smart defaults

- `title`: use the first sentence of the caption, truncated to 100 chars
- `type`: `public` unless user explicitly says otherwise (most creators default to public)
- `tags`: extract 5-10 hashtags from the caption if present; format as `{value, label}` pairs
- Description: YouTube allows ~5000 chars. The agent CAN expand the IG/Threads-length caption into a longer YT description (add timestamps, links, full content) — surface this proposal: *"Pra YouTube, expando a legenda em descrição longa? Posso incluir timestamps + links + CTA detalhado."*

---

## 5. LinkedIn (Personal + Page)

Postzee channel platforms: `linkedin` (personal) and `linkedin-page` (company page).

### 5.1 Settings

| Field | Type | Values | Default |
|---|---|---|---|
| `post_as_images_carousel` | boolean | `true` / `false` | `false` |

### 5.2 Triggers

| User phrase | Setting |
|---|---|
| `carrossel deslizável` / `swipeable carousel` / `como carrossel` | `post_as_images_carousel: true` |
| `imagens separadas` / `imagens normais` | `post_as_images_carousel: false` |

### 5.3 Smart defaults

- If user uploads 2+ images to LinkedIn → propose carousel format: *"LinkedIn pode render isso como carrossel deslizável (melhor performance) ou como imagens em grid. Carrossel?"*
- Default to `post_as_images_carousel: true` for 2-20 images (LinkedIn's max carousel = 20)
- Single image: setting irrelevant (no carousel)

### 5.4 LinkedIn-specific captions

LinkedIn captions can be up to 3000 chars (vs 2200 for IG). The platform rewards LONG-FORM:
- Use the Hook→Promise→Payoff→CTA framework from `copywriting-mastery.md` §5.4 with extended payoff section
- 800-1500 words is the sweet spot for LinkedIn organic
- First 3 lines visible before "see more" — those MUST hook
- Hashtags: 3-5 max, end of caption, niche-specific (#productdesign > #marketing)

---

## 6. X (Twitter)

Postzee channel platform: `x`.

### 6.1 Settings

| Field | Type | Values | Default |
|---|---|---|---|
| `tags` | array | content tags `[{ value, label }]` (used as a multi-tag association — NOT hashtags inline in tweet) | `[]` |

### 6.2 Triggers

| User phrase | Setting |
|---|---|
| `tags: X, Y` (admin-level tagging, not Twitter hashtags) | `tags: [...]` |

### 6.3 Smart defaults

X is the simplest platform — there's no `privacy_level` or `post_type` to set per post (settings live at the account level). Most posts just need `text` + `mediaUrls`.

### 6.4 Threads (X feature, not Threads-the-app)

X allows threading multiple tweets. Postzee doesn't currently expose thread creation via MCP — single-tweet only. If user asks for a thread, push back: *"Postzee MCP atualmente só faz tweet único. Pra thread, abre o dashboard e usa o thread builder."*

### 6.5 Character limit

X enforces 280 chars (4000 for X Premium). Postzee will fail-fast on long text — the agent should pre-validate before calling. Truncate at 270 with `[...continua]` if needed, or refuse and ask user to shorten.

---

## 7. Threads (Meta)

Postzee channel platform: `threads`.

### 7.1 Settings

Threads has no per-post settings exposed via Postzee yet (Meta's API surface is conservative). The agent just sends `text` + `mediaUrls`.

### 7.2 Smart defaults

- Threads allows 500-char posts (vs X's 280)
- No hashtag culture on Threads — DON'T add hashtags by default; remove them if migrating a tweet
- Tone is more conversational than X — softer hooks work better
- Threads carousels: up to 20 images, native (no setting needed — just send `mediaUrls`)

---

## 8. Pinterest

Postzee channel platform: `pinterest`.

### 8.1 Settings

| Field | Type | Values | Default |
|---|---|---|---|
| `board` | string | board ID | required — surface if missing |
| `title` | string | max 100 chars | derived from caption first-line |

### 8.2 Triggers

| User phrase | Setting |
|---|---|
| `board: X` / `no board X` / `pin to board X` | `board: '<board-id>'` |
| `título: X` | `title: 'X'` |

### 8.3 Smart defaults

- Pinterest REQUIRES `board`. Without it, the post fails. If user didn't specify a board, the agent MUST ask before calling. Don't silently default.
- Dimensions: Pinterest prefers 1000×1500 (2:3) — Postzee 1080×1350 (4:5) is close enough. Reels go through standalone Pinterest video flow (not via this MCP path currently).
- Description: Pinterest pays close attention to keywords — use the caption to embed SEO-style keywords naturally.

---

## 9. Facebook Page

Postzee channel platform: `facebook-page`.

### 9.1 Settings

| Field | Type | Values | Default |
|---|---|---|---|
| `post_type` | string | `'post'` / `'story'` | `'post'` |

### 9.2 Triggers

| User phrase | Setting |
|---|---|
| `story` / `stories` / `no story do Facebook` | `post_type: 'story'` |
| `feed do Facebook` / `página do Facebook` | `post_type: 'post'` |

### 9.3 Smart defaults

Same logic as Instagram (§2). Facebook + Instagram share Meta's API and have similar feed/story semantics.

---

## 10. Cross-cutting concerns

### 10.1 Multi-channel posting

Postzee MCP currently `POSTZEE_CREATE_POST` accepts a SINGLE `channelId`. To post to multiple channels (the dashboard "post to all" pattern), the agent loops:

```
For each channel in target list:
  POSTZEE_CREATE_POST({
    channelId: channel.id,
    text: <adapted caption>,
    mediaUrls: <same media>,
    settings: <platform-specific from this doc>,
  })
```

The adaptation per-channel: agent rewrites the caption for each platform's tone/length. Instagram caption ≠ LinkedIn caption ≠ X caption.

### 10.2 Caption adaptation per platform

The same content, written differently per channel:

| Platform | Length | Tone | Hashtags | Line breaks |
|---|---|---|---|---|
| Instagram | 200-400 chars | Conversational, emoji-friendly | 3-5 niche tags | Frequent |
| LinkedIn | 800-1500 words | Professional, opinionated | 3-5 niche tags at end | Generous |
| X | 240-280 chars | Punchy, declarative | 0-2 tags | Sparing |
| Threads | 200-500 chars | Conversational, low-effort | None | Frequent |
| TikTok | 100-150 chars (the body) | Hook-first, then explainer | 2-3 trending | Sparing |
| YouTube (description) | 500-2000 words | Structured, sections, timestamps | 5-10 tags at end | Generous + headers |
| Facebook | 80-200 chars | Conversational | 1-3 tags | Light |
| Pinterest | 200-500 chars | Keyword-rich, descriptive | None inline | Light |

The agent generates ONE master caption (per the framework in `copywriting-mastery.md` §5) and adapts it to each target platform. Don't post the IG caption verbatim to LinkedIn — wastes the platform's affordances.

### 10.3 Scheduling per-platform

Best time to post varies by platform + audience. Use `POSTZEE_GET_BEST_POSTING_TIMES` to get the recommended time for the user's channel. Don't hardcode "post at 6pm" — let the data lead.

If user says "agenda pra hoje à noite" → call `POSTZEE_GET_BEST_POSTING_TIMES` for that channel → pick the recommended slot within the user's time window.

### 10.4 Reposting / scheduling chains

The MCP doesn't currently expose "repost in 7 days" — that's a dashboard feature. If user wants a recurring schedule, surface: *"O MCP cria 1 post por vez. Pra agendar série recorrente, usa o calendário do dashboard."*

---

## 11. Anti-patterns

### 11.1 Silent default to feed when user asked story

The v3.6 bug. Now fixed: agent reads this doc, applies `settings.post_type: 'story'` when triggered. If the agent forgets and silently posts to feed → that's a regression. Test explicitly with "post no story" phrasing before shipping.

### 11.2 Hardcoded settings without surfacing

The agent should TELL the user once when applying a non-trivial setting:

> *"Vou postar com `comment: false` no TikTok porque o conteúdo é sensível. Posso ou prefere manter comentários?"*

Don't silently flip settings the user might want to control.

### 11.3 Skipping platform-required fields

Pinterest requires `board`. The agent MUST ask before publishing. If the user says "posta no Pinterest" without a board → ask. Don't fail at API level.

### 11.4 Cross-platform pasting

Pasting an IG caption verbatim to LinkedIn (or vice versa) is a tell of low-effort multi-channel. Always adapt per §10.2.

---

## 12. Cross-references

- MCP tool: `POSTZEE_CREATE_POST` (settings parameter added in v3.7)
- Backend DTOs: `dashboard/libraries/nestjs-libraries/src/dtos/posts/providers-settings/` — source of truth for what each platform accepts
- `image-mastery.md` §8.2 — auto-publish flow that reads from this doc
- `carousel-mastery.md` §POST-STAGE — publish step that reads from this doc
- `copywriting-mastery.md` §5 — caption frameworks per platform
- `smart-routing.md` — channel selection by content type

The full list of supported platforms beyond the top-8 documented here: Bluesky, Discord, Mastodon, Lemmy, Slack, Reddit, Telegram, VK, Medium, Dev.to, Hashnode, WordPress, Dribbble, Warpcast, Nostr, GMB (Google My Business), ListMonk. See the DTOs directly when supporting those.
