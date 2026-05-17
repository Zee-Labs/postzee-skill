# Credit-Aware Flow — State Matrix

This file is the **operational playbook**: given the user's state (from `POSTZEE_GET_CONTEXT` + estimates from `POSTZEE_VALIDATE_GENERATION`), what do you do?

Read this as a state machine, not a recipe. The right behavior depends on combinations.

---

## The state vector

Every interaction starts by mapping the user to a state vector:

```
{
  plan.tier: "FREE" | "STANDARD" | "TEAM" | "PRO" | "ULTIMATE"
  plan.canPost: boolean
  plan.postsRemaining: number | null
  credits.available: number
  channels.connected: number       // total complete integrations
  channels.active: number          // ready to post NOW
  channels.requiresReauth: number  // user must reconnect (token expired)
  channels.disabled: number        // explicitly disabled (admin/billing)
  channels.withIssues: number      // legacy = requiresReauth + disabled
  storage.percentUsed: number
}
```

Combined with the **planned action**:

```
{
  intent: "generate-only" | "generate-and-post" | "post-existing" | "schedule"
  estimatedCredits: number    // total expected, including all items
  itemCount: number           // batch images (variations of same prompt) — NOT carousel slides
  needsChannel: boolean
}
```

**Carousel rendering is credit-free** — `POSTZEE_RENDER_CAROUSEL`, `POSTZEE_REPLACE_CAROUSEL_SLIDE`, and `POSTZEE_APPEND_CAROUSEL_SLIDE` do not consume credits (see SKILL.md §2.1). Only AI image generation (`POSTZEE_GENERATE_IMAGE` for optional slide backgrounds) and AI video generation cost credits. `itemCount` is for batch image generation (N variations of one prompt), not carousel slides.

---

## State matrix — what to do

### Intent: "generate-only" (user wants AI media, doesn't mention posting)

| State | Behavior |
|-------|----------|
| `credits.available >= estimatedCredits` | Proceed normally. After generation, ask if they want to post. |
| `credits.available < estimatedCredits` | **Block. CTA matched credit pack.** See `plans-and-pricing.md` template "credits insufficient". |
| `credits.available > 0` but `< 200` | Proceed BUT proactively warn: "You'll have {n} credits left after this. Want me to suggest a top-up so you don't stall?" |
| `tier === "FREE"` and `credits.available === 0` | They never bought a pack. Welcome flow with the cheapest pack from `POSTZEE_LIST_CREDIT_PACKAGES` (Starter): "To start creating, I recommend {Starter.name} (${Starter.priceUSD} = {Starter.credits} credits) just to test." |
| `storage.percentUsed >= 95` | Block generation. Tell user storage is full and offer upgrade or cleanup. |
| `storage.percentUsed >= 80` | Proceed but warn. |

### Intent: "generate-and-post" (user wants to publish)

Run all "generate-only" checks first. THEN add:

| State | Behavior |
|-------|----------|
| `plan.canPost === false` (FREE) | **Critical.** Either: (a) generate the asset and tell user "I generated it, but to publish via Postzee you need a paid plan — recommend STANDARD" with file delivery as fallback. (b) BEFORE generating, check if they care about posting; if yes, propose plan upgrade upfront. Default to (b) for transparency. |
| `plan.canPost === true` but `channels.active === 0` | **Block.** If `channels.connected === 0` → tell user to connect channels at https://dashboard.postzee.app/channels. If `channels.requiresReauth > 0` → tell them to **reconnect** the expired token. If `channels.disabled > 0` → tell them to **re-enable** (different from reconnect). Don't generate yet — they'd waste credits. |
| `plan.postsRemaining === 0` (subscriber hit cap) | **Block posting** but allow generation if they have credits. CTA next-tier upgrade (live values via `POSTZEE_LIST_PLANS`). |
| `channels.requiresReauth > 0` AND `channels.active > 0` | Proceed with active channels. Mention which one needs **reconnection** (use the per-channel `actionMessage` from `POSTZEE_LIST_CHANNELS`). |
| `channels.disabled > 0` AND `channels.active > 0` | Proceed with active channels. Mention which is **disabled** — re-enable, not reconnect. |

### Intent: "post-existing" (user already has files / text, just wants to post)

| State | Behavior |
|-------|----------|
| `plan.canPost === false` | CTA upgrade. Offer no fallback — they can't post without subscription. |
| `channels.active === 0` | Block. Branch on `requiresReauth` / `disabled` / `connected === 0` for the right user action. |
| `channels.requiresReauth > 0` OR `channels.disabled > 0` (but `active > 0`) | Specify which channel works, which doesn't, with the right action verb (reconnect vs re-enable). |

### Intent: "schedule"

Same as "generate-and-post" + ensure date is in the future (server uses UTC; convert from `context.organization.timezone`).

---

## The 4 decision moments

### Moment 1 — Session start (always)

```
1. POSTZEE_GET_CONTEXT
2. Compare skill version (warn once if outdated, see SKILL.md §1)
3. Cache the context for the session
4. Read state vector mentally
```

### Moment 2 — Brief building

While building the brief (§5 of SKILL.md), at the end have a sense of:
- What format will we generate? (single image / video / multi-scene video / **carousel**)
- How many items? For carousels this is "how many slides" — but cost is computed by `POSTZEE_RENDER_CAROUSEL` itself, not by multiplying image generations.
- Will they post? Where?

This determines `intent` + estimated total credits.

### Moment 3 — Pre-generation (before any GENERATE_*)

```
1. POSTZEE_LIST_MODELS_DETAILED — pick model
2. POSTZEE_VALIDATE_GENERATION — pre-flight (FREE — no cost)
   → If invalid params: fix or change strategy
   → If shortfall: CTA + stop
3. POSTZEE_ESTIMATE_GENERATION_COST per item — confirm total
4. Show plan to user (in their language): "I'll use {model} to generate {N} {type}, estimated total cost: {credits} credits. Shall I proceed?"
5. If yes → POSTZEE_ENHANCE_PROMPT → POSTZEE_GENERATE_*
```

**For carousels**, this Moment is replaced by:
```
1. Validate balance via POSTZEE_GET_CONTEXT — confirm credits cover any backgrounds
   you plan to generate (Nano Banana). Carousel render itself is compute-side.
2. Compose Phase 2 script (see SKILL.md §8.3 + reference/carousel-mastery.md §A).
3. After user approval, call POSTZEE_RENDER_CAROUSEL.
```

### Moment 4 — Pre-posting

```
1. Verify channels.active > 0 (if zero, branch on requiresReauth/disabled/connected)
2. Verify plan.canPost === true (and postsRemaining > 0 if finite)
3. POSTZEE_LIST_CHANNELS to confirm specific channel id
4. POSTZEE_CREATE_POST
```

---

## Common state combos and their playbooks

### "FREE user with no credits, wants to generate"
→ Welcome to Postzee CTA. Recommend `starter` from `POSTZEE_LIST_CREDIT_PACKAGES` (cheapest entry pack) to test. Generate-only flow, no subscription push (yet).

### "FREE user with credits, wants to post"
→ Generate IF intent unambiguous. THEN explain: "I generated everything. To publish through Postzee you need a paid plan. I recommend {plan.tier} (${plan.monthPriceUSD}/mo) which includes {plan.monthlyCredits} monthly credits — covers more content like this. Or I can send you the files to post manually." (Use live values from `POSTZEE_LIST_PLANS`.)

### "STANDARD user, low credits"
→ Generate. Mention credit pack option AFTER, not before — they're already paying. Fetch the right pack from `POSTZEE_LIST_CREDIT_PACKAGES` (typically Basic if low usage, Standard if higher), then quote live `priceUSD` and `credits`: "Nice — you'll still have {N} credits after this. If you plan to produce a lot more this week, the {pack.name} pack (${pack.priceUSD} = {pack.credits} credits) covers it well."

### "Subscriber hit posts-per-month cap"
→ Block posting. CTA next-tier upgrade (live values via `POSTZEE_LIST_PLANS`). Mention drafts can be queued for when the month rolls over.

### "PRO user, missing channels for the platform user wants"
→ Tell them which channel and link. Don't assume they're at limit (PRO has 30 channels, they probably just haven't connected the specific one).

### "ULTIMATE user, no problems"
→ Just ship. They paid for premium service. Maximum signal, minimum friction.

---

## Transparency principles

- **Always state cost in credits BEFORE generating.** "Esse vídeo vai custar 600 créditos."
- **Always explain why you're CTAing.** Not "buy this!" but "because you want to post and FREE doesn't include that, I recommend X".
- **Never hide constraints.** If Sora 2 only supports 10 or 15s, say so when user asks for 8s — don't silently round up.
- **Surface plan period to inform buying decisions.** "Lembra que tem o yearly que sai por X% mais barato — vale considerar se vai usar a longo prazo."

---

## Anti-patterns (what NOT to do)

- ❌ Generate FREE user's assets, post fails with `subscription_required`, surprise upsell after credits already burned
- ❌ Quote prices in dollars to user
- ❌ Hardcode plan/pack numbers from memory — they may have changed
- ❌ Push subscription to a user who explicitly said "só quero baixar arquivos"
- ❌ Refuse to engage in creative work because they're FREE — FREE users with credits are valid customers
- ❌ Repeat the same CTA copy verbatim every time — adapt to context
- ❌ Translate templates literally across languages — adapt culturally
- ❌ Ignore `features.*` from context and propose features the MCP can't fulfill (e.g. Sora Storyboard when `features.soraStoryboard === false`)

---

## Multi-step plan handling

When the user wants something multi-step (e.g., "produza 30 dias de conteúdo"):

1. Estimate total credits (rough: N posts × avg cost per post)
2. Compare against `credits.available + (plan.monthlyCredits if subscriber)`
3. If shortfall: CTA upfront, propose phased approach if budget-tight
4. Then break into batches and execute

Never burn 60% of someone's monthly credits on day 1 of a "30-day plan" without warning.

---

## When user pushes back on CTA

If the user says "I don't want a plan now" / "I'm not paying" (in any language):

1. Respect immediately. **Don't insist.**
2. Pivot to what they CAN do: "No problem. I can deliver the finished files here and you post manually on the networks."
3. Don't bring it up again unless they hit a hard block.

The agent earns trust by knowing when to stop selling.

---

## Summary checklist

Before each generate / post call, verify:

- [ ] Context loaded this session (`POSTZEE_GET_CONTEXT`)
- [ ] Plan permits the intended action
- [ ] Credits sufficient for planned volume
- [ ] Channels exist (if posting)
- [ ] No storage red flag
- [ ] User informed of credit cost
- [ ] CTA staged if any blocker

This is what makes the agent a great "social media manager" — anticipating issues before they cost the user money or time.
