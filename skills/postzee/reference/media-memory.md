# Media Memory & Reuse — never lose track of an asset

When the user says *"now turn that image into a video"* or *"post the dog photo to Instagram"*, you must reuse the asset's URL — never ask the user to paste it again.

This file is your operating manual for that. Memorize the manifest pattern. Apply on every generation, every upload, every reuse.

---

## The hierarchy of recall (top wins)

```
1. SESSION MANIFEST (mental, in this conversation)   → instant, free
       ↓ (if empty / contextually compressed / new session)
2. POSTZEE_LIST_MEDIA (search, since, type, source)  → ~50ms, returns persisted records
       ↓ (only when the asset is external)
3. POSTZEE_UPLOAD_MEDIA (import a public URL)        → adds it to your manifest going forward
```

Never skip up the hierarchy. Never ask the user "what's the URL?" when the manifest or LIST_MEDIA could answer.

---

## 1. The session manifest (track this mentally)

After every `POSTZEE_CHECK_JOB` that returns success, AND after every `POSTZEE_UPLOAD_MEDIA` success, register the asset in your mental manifest using this canonical shape:

```
short_key  →  { mediaId, url, type, label, createdAt }
```

### Naming the `short_key`

- Snake_case ASCII, ≤ 24 chars
- Inferred from the user's prompt or context, **not** sequential
- Examples: `dog_beach`, `paris_view`, `product_box`, `user_upload_1`, `dog_beach_v2`

A good `short_key` is something the user would naturally say out loud ("the dog photo" → `dog_photo`).

### Example manifest after a session

```
🗂️ Media Manifest
- dog_beach     → { mediaId: m-abc123, url: https://cdn.postzee.app/abc.jpg, type: image, label: "dog on the beach at sunset", createdAt: 2026-05-07T14:23 }
- paris_view    → { mediaId: m-def456, url: https://cdn.postzee.app/def.jpg, type: image, label: "Eiffel Tower at dawn",       createdAt: 2026-05-07T14:24 }
- product_box   → { mediaId: m-ghi789, url: https://cdn.postzee.app/ghi.jpg, type: image, label: "product box on white",       createdAt: 2026-05-07T14:25 }
- dog_video     → { mediaId: m-jkl012, url: https://cdn.postzee.app/jkl.mp4, type: video, label: "animated dog_beach",         createdAt: 2026-05-07T14:31 }
```

When the user says **"post the dog photo to IG"**, look up `dog_photo` → fuzzy match `dog_beach` → use its `url`.

When they say **"animate the Paris one"**, match `paris_view` → reuse `url` as `imageUrl` for `POSTZEE_GENERATE_VIDEO`.

---

## 2. `POSTZEE_LIST_MEDIA` — the persistent fallback

Use when the manifest doesn't have what you need:

- **New session** — yesterday's session is gone from your context
- **Long conversation** — context was compressed and your manifest dropped
- **Cross-check** — you want to confirm an asset exists before promising the user

### Filters

| Filter | Use when |
|--------|----------|
| `type: 'image' \| 'video'` | User said "the photo" / "the video" |
| `source: 'generated' \| 'uploaded'` | Disambiguate AI-made vs user-imported |
| `search: 'dog'` | User referenced asset by content ("the dog") |
| `since: '<ISO date>'` | "the one from yesterday" / "this week" |
| `limit: 1..100` | Default 20. Use small numbers for confirmation, larger for discovery |

### Multilingual search

The user may speak Portuguese while the original prompt was English (the agent enhanced it before generation). If `search: "cachorro"` returns empty, **retry with English** (`"dog"`). Likewise EN → PT, EN → ES, EN → FR. Try the user's language first, then English.

```
User (PT): "anima o cachorro de ontem"
Try 1: LIST_MEDIA({ search: "cachorro", since: yesterday })  → 0 results
Try 2: LIST_MEDIA({ search: "dog",      since: yesterday })  → 1 result ✓
```

### Confirming with the user before acting

When LIST_MEDIA returns multiple candidates, **show them and ask** instead of guessing:

> "I found 3 photos that match 'dog' from this week:
>  1. 'cachorro na praia ao pôr do sol' — May 7 14:23
>  2. 'golden retriever em close-up' — May 6 09:11
>  3. 'cachorro com brinquedo' — May 5 17:45
>  
>  Which one would you like to animate?"

Single match? Just use it, mention which one ("usando a foto 'cachorro na praia' que você criou ontem às 14:23").

---

## 3. `POSTZEE_UPLOAD_MEDIA` — when the user brings their own asset

Use this when the user wants to use **an external image/video** as input — for image-to-video, image-to-image, posts with custom photos, etc.

### When to call

- User pastes a URL: `https://example.com/photo.jpg`
- User uploads a file in a chat client that gives you a URL (Telegram bot, WhatsApp media link, S3 share, Drive public link, etc.)
- The asset will be reused — even one reuse justifies importing into Postzee, because external URLs may expire, rate-limit, or block our backend

### The schema is intentionally narrow

```
POSTZEE_UPLOAD_MEDIA({
  url: string,           // http or https, public, no auth required
  description?: string,  // short label for your manifest
})
```

**No headers, no base64, no auth tokens** — by design, for security. If the user gave you a URL that needs a Bot Token (e.g. a Telegram `getFile` URL with token in the path), the **chat client must re-host it** to a public URL first. Tell the user politely if you hit this case:

> "I can't import that URL directly because it requires a private token. Could you share the photo through a public link, or attach it again so I can import it?"

### Validations the tool runs (so you don't have to)

The tool rejects automatically:
- Non-http/https schemes
- Localhost / private IPs / cloud metadata endpoints
- Unreachable URLs / 4xx / 5xx
- Files larger than 50 MB
- Content-Type that isn't `image/*` or `video/*`
- Storage quota full (returns `error: "storage_full"`)

When any of those happen, the tool returns `success: false` with an `error` code and a `message`. Surface a friendly version of `message` to the user; don't retry the same URL unless they fix it.

### After success

The tool returns `{ mediaId, url, type, sizeBytes, dimensions }`. **Add it to your manifest immediately** under a meaningful `short_key`.

---

## 4. Decision tree

```
User mentions an asset?
├── Asset is in current SESSION MANIFEST?
│       ├── YES (single match) → use its url; mention what you used
│       ├── YES (multiple match) → ask user to disambiguate
│       └── NO  → continue
│
├── Asset is in PERSISTED LIBRARY?
│       └── POSTZEE_LIST_MEDIA({ search, type, since })
│           ├── 1 result  → use it; show what you found, then proceed
│           ├── N results → list them, ask user to pick
│           ├── 0 results in user's language → retry in English
│           └── still 0 → continue
│
└── Asset is EXTERNAL (URL or chat upload)?
        └── POSTZEE_UPLOAD_MEDIA({ url, description })
            ├── success → register in manifest, then proceed
            └── error  → explain to user; do NOT silently fall back
```

---

## 5. Worked examples

### A) Generate then reuse — same session

```
User: "gera uma imagem de um cachorro na praia"
You:  POSTZEE_GENERATE_IMAGE → POSTZEE_CHECK_JOB → mediaUrl=X, mediaId=Y
You:  Manifest: dog_beach → { Y, X, image, "cachorro na praia", now }
You:  "Pronto! Aqui está a foto." [show url X]

User: "agora transforma em vídeo"
You:  manifest.dog_beach.url = X (instant lookup)
You:  POSTZEE_GENERATE_VIDEO({ model: 'kling-2.5-turbo-pro', imageUrl: X, ... })
✓ no question asked
```

### B) Three images, post one specific

```
User: "gera 3 imagens: cachorro, Paris, produto"
You:  3× GENERATE → 3× CHECK_JOB
You:  Manifest:
        dog       → { m-1, url-1, image, "cachorro" }
        paris     → { m-2, url-2, image, "Paris" }
        product   → { m-3, url-3, image, "produto" }

User: "posta a do cachorro no IG"
You:  manifest.dog.url = url-1
You:  POSTZEE_CREATE_POST({ mediaUrls: [url-1], channelId: ig, ... })
✓ correct asset, no ambiguity
```

### C) New session, reference yesterday's work

```
User: "anima o cachorro que gerei ontem"
You:  manifest empty (new session)
You:  POSTZEE_LIST_MEDIA({ type: 'image', source: 'generated', search: 'cachorro', since: yesterday })
      → 0 results  (user's language miss)
You:  POSTZEE_LIST_MEDIA({ type: 'image', source: 'generated', search: 'dog',      since: yesterday })
      → [{ mediaId: m-1, url: url-1, prompt: "dog on the beach at sunset", createdAt: 2026-05-06T14:23 }]
You:  "Achei a foto 'dog on the beach at sunset' que você gerou ontem às 14:23 — vamos animar essa?"
User: "isso"
You:  Manifest: dog_beach → { m-1, url-1, image, "dog on the beach", yesterday }
You:  POSTZEE_GENERATE_VIDEO({ imageUrl: url-1, ... })
✓ recovered across sessions
```

### D) User-uploaded photo (Telegram/WhatsApp/Drive)

```
User: pastes https://drive.google.com/uc?id=xyz (a public Drive link)
You:  POSTZEE_UPLOAD_MEDIA({ url: "https://drive.google.com/uc?id=xyz", description: "user-uploaded brand photo" })
      → { success: true, mediaId: m-x, url: cdn-url, type: image, sizeBytes: 524288, ... }
You:  Manifest: brand_photo → { m-x, cdn-url, image, "user-uploaded brand photo", now }

User: "posta isso no IG e LinkedIn"
You:  POSTZEE_CREATE_POST per channel using manifest.brand_photo.url
✓ external asset becomes first-class Postzee media
```

---

## 6. Anti-patterns (do NOT do these)

- ❌ **Asking the user "what's the URL?"** when manifest or LIST_MEDIA could answer.
- ❌ **Pasting the temporary URL the user shared** (Telegram, WhatsApp, signed S3, expiring CDN) directly into `POSTZEE_GENERATE_VIDEO.imageUrl`. fal.ai will fetch it 30s–5min later — by then it may be dead. **Always import via `POSTZEE_UPLOAD_MEDIA` first** when the URL looks temporary.
- ❌ **Trusting the manifest blindly across days** — long-running sessions (Telegram bots) may have stale entries. Validate by calling `POSTZEE_LIST_MEDIA` if the user mentions assets older than ~6 hours.
- ❌ **Importing the same URL twice** — if you already imported and have it in the manifest, reuse the manifest entry.
- ❌ **Inventing `mediaId` values** — always copy from a tool response.
- ❌ **Using `description` to encode internal state** — it's user-visible if anyone inspects the library. Keep it human-readable.

---

## 7. Telegram / WhatsApp / chat-app uploads — special note

When the user attaches media in a client like the Hermes Telegram bot:
- The client gives you a temporary URL (often with auth token in path)
- That URL may expire in hours and isn't reachable by fal.ai
- `POSTZEE_UPLOAD_MEDIA` rejects it if the URL requires authentication

**Pattern**: the chat client wrapper should re-host the file to a public URL **before** asking you to call the tool. If you receive a URL that fails validation:

> "Tive problema importando o anexo (a URL parece privada). Pode reenviar o arquivo? O bot vai me passar uma versão pública."

This is a *client orchestration concern*, not yours. Just surface the error message clearly.

---

## 8. IMAGE_REGISTRY — carousel + image composition discipline

When composing carousels or single-image posts, the agent maintains a structured **IMAGE_REGISTRY** in working memory — a richer subset of the session manifest scoped to the current composition. It binds each slide / asset role to its real Postzee CDN URL, so that when slides reference an image, the URL is always real (never improvised).

### 8.1 Structure

```
IMAGE_REGISTRY = {
  // per-slide images from POSTZEE_GENERATE_IMAGE in Stage 7 (§9.1)
  slide_1_cover: { mediaId, mediaUrl, role: 'cover', source: 'generated' },
  slide_3_case:  { mediaId, mediaUrl, role: 'inline', source: 'generated' },

  // user-uploaded assets (avatar, logo, brand photo)
  avatar:        { mediaId, mediaUrl, role: 'avatar', source: 'user-uploaded' },
  brand_logo:    { mediaId, mediaUrl, role: 'logo',   source: 'user-uploaded' },

  // assets the user pasted a URL for and the agent imported
  reference_pic: { mediaId, mediaUrl, role: 'inline', source: 'imported' },
}
```

The registry is **populated as each asset is acquired** — not at the end. Three populating events:

| Event | Populate when |
|---|---|
| `POSTZEE_GENERATE_IMAGE` + `POSTZEE_CHECK_JOB` returns `success` | Stage 7 image strategy generation |
| `POSTZEE_UPLOAD_MEDIA` returns `success` | User pasted a URL the agent imported, OR user attached a file the agent uploaded |
| Pre-existing media from `POSTZEE_LIST_MEDIA` selected | Agent retrieved a previous-session asset for reuse |

### 8.2 User-uploaded asset routine (avatar / logo / brand photo)

This is the routine that prevents incidents like the "lucas_avatar.jpg fabricated path" pattern.

```
User attaches a photo in the chat OR pastes a URL
   ↓
Step 1. Capture
   - If file attachment: get the bytes the client surfaces, OR the
     temporary URL the client wrapper provided
   - If URL: take it as-is

Step 2. Upload to Postzee CDN FIRST (before composing any slide)
   POSTZEE_UPLOAD_MEDIA({
     url: <public URL the agent can reach>,
     description: 'user-uploaded avatar' | 'brand logo' | 'reference photo'
   })
   → { success: true, mediaId, url, type, sizeBytes, dimensions }

   If UPLOAD_MEDIA returns `success: false`:
   - Surface the friendly version of `error.message` to the user
   - Common cases + ask copy:
     * Private URL (auth required): "essa URL parece privada. Pode
       reenviar a foto pública, ou me mandar um link sem token?"
     * 4xx/5xx unreachable: "não consegui buscar a foto (erro X).
       Pode re-anexar?"
     * >50 MB or wrong content-type: "esse arquivo é grande/inválido
       (limite 50 MB, image/* ou video/*). Pode mandar comprimido?"
     * Storage quota full: "seu storage tá cheio. Posso te listar
       o que dá pra apagar?" (run POSTZEE_LIST_MEDIA + suggest)
   - Wait for the user to provide a fixed source; then re-run Step 2.

Step 3. Register in IMAGE_REGISTRY immediately
   IMAGE_REGISTRY[<role_key>] = { mediaId, mediaUrl: url, role, source: 'user-uploaded' }

Step 4. Reference in the slide composition
   <img src="${IMAGE_REGISTRY[role_key].mediaUrl}">

Step 5. Confirm to user (one line, in their language)
   "Subi sua foto pro Postzee — vou usar como avatar nos slides 1 e 9."
```

### 8.3 Anti-pattern — NEVER fabricate a path

⛔ **NEVER write a `src="..."` or `url(...)` referencing an asset path the agent doesn't actually have.**

Examples of the anti-pattern:
- `<img src="lucas_avatar.jpg">` — invented path, no upload ever happened
- `<img src="cdn1.postzee.app/user_photo.png">` — agent guessed a CDN URL
- `<div style="background: url('avatar_path.jpg')">` — same, inline style
- `.avatar { background-image: url('photo.jpg'); }` — same, in a `<style>` block or stylesheet
- `<image href="logo.png" />` inside SVG — same anti-pattern, different element

If the agent is about to write a `src=`, `url(...)`, `href=`, or any other attribute referencing an asset, and IMAGE_REGISTRY does NOT have an entry for that role: **STOP**. Run §8.2 first (upload the asset, get the real URL, register), then come back and compose the HTML with the real URL.

This pattern showed up in the 2026-05-15 carousel render incident: the agent composed slides referencing `lucas_avatar.jpg` (a path that never existed), the render produced empty avatars on slides 1 and 9, and required two follow-up `POSTZEE_REPLACE_CAROUSEL_SLIDE` calls to fix. The IMAGE_REGISTRY discipline + the §8.2 routine prevent that class of bug.

### 8.4 Cross-references

- `carousel-mastery.md` §10.1.5 — image source rule (slides reference Postzee CDN URLs from IMAGE_REGISTRY)
- `carousel-mastery.md` §9.1.6.1 — populates IMAGE_REGISTRY after each `POSTZEE_CHECK_JOB` success in Stage 7 parallel polling
- `SKILL.md` workflow box Stage 8 (Render) — references IMAGE_REGISTRY for slide URLs
