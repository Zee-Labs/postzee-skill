# Plans & Credit Packages — Source of Truth

This file gives you the architecture of Postzee's monetization so you can match the right offer to the user's situation. **Always fetch live values via `POSTZEE_LIST_PLANS` and `POSTZEE_LIST_CREDIT_PACKAGES` before quoting prices** — these tables document the structure, not the live prices.

Postzee follows two parallel monetization rails:
1. **Subscriptions** (the social suite — needed to post)
2. **Credit Packages** (one-time AI credits — never expire)

---

## The credit currency

- Display ratio: **$1 USD = 1,000 credits**
- Credits are stored as USD in DB and presented as integers (e.g., `2.000 credits` for $2 of value)
- Two credit pools:
  - **Monthly** (from subscription) — reset every month
  - **Purchased** (from credit packs) — eternal, never expire, survive plan cancellation
- Available balance = monthly + purchased − used

When you talk to users, always show **credits**, never USD. ("Isso vai custar 600 créditos.")

---

## The 5 subscription plans

Live values are returned by `POSTZEE_LIST_PLANS`. Structure below for understanding:

| Plan | Use it when... |
|------|-----------------|
| **FREE** | User is exploring AI generation, has no posting needs, or wants to test before paying |
| **STANDARD** | Solo creator / small business — first paid tier with social suite |
| **TEAM** | Small team / agency — collaboration matters, more channels |
| **PRO** | Growing brand or solo with many accounts — most channels, robust limits |
| **ULTIMATE** | Power user / agency — multi-brand management at scale |

### Plan dimensions (always check via `POSTZEE_LIST_PLANS`)

Each plan exposes these fields:
- `monthPriceUSD`, `yearPriceUSD`, `yearMonthlyDisplayUSD`
- `channelsLimit` (0 for FREE, finite for paid)
- `postsPerMonth` (0 for FREE; finite for STANDARD; "unlimited" for TEAM/PRO/ULTIMATE — `postsUnlimited: true`)
- `monthlyCredits` (0 for FREE; positive for paid)
- `storageLimitGB`
- `canPost`, `canUseAi`, `teamMembers`, `publicApi`, `webhooks`

**Critical rule:** FREE has `canPost: false` and `channelsLimit: 0` — they cannot connect channels nor publish via Postzee. They CAN buy credit packs and use AI generation.

---

## The 5 credit packages (one-time, never expire)

Live values via `POSTZEE_LIST_CREDIT_PACKAGES`:

| Package id | Why a user picks it |
|------------|---------------------|
| `starter` | Cheapest taste — first AI test, low commitment |
| `basic` | Casual creator who needs more than starter but not much |
| `standard` ⭐ **MOST POPULAR** | Sweet spot — covers serious creator volume |
| `pro` | Heavy AI user, video-heavy production |
| `enterprise` | High volume — agencies, repeat business |

Pricing follows a 1:1 paridade — no bonus, no progressive discount. Pay $10, get 10,000 credits.

When recommending a pack, **show the live `priceUSD` and `credits` from the tool** — don't hardcode.

---

## When to recommend WHAT

This is the heart of conversion. Read the user's state from `POSTZEE_GET_CONTEXT` and match.

### Decision tree

```
USER WANTS TO POST → needs subscription (since FREE can't post)
│
├── Just needs basic posting + some AI                   → STANDARD
├── Has team members or wants more channels              → TEAM
├── Manages many channels                                 → PRO
└── Agency / huge volume                                   → ULTIMATE


USER WANTS ONLY AI MEDIA (no posting, downloads files manually) → credit pack
│
├── First test, lowest commitment                         → starter
├── Casual / occasional AI use                            → basic
├── Serious creator (most users)                          → standard ⭐ (popular: true)
├── Heavy AI / video-heavy                                → pro
└── Agency-level                                          → enterprise


USER ALREADY HAS A SUBSCRIPTION but is running low on credits
│
└── Recommend matching credit pack:
    ├── Subscriber + occasional shortfall                 → starter or basic
    ├── Subscriber + serious volume                       → standard pack
    └── High-tier subscriber + heavy AI                   → pro or enterprise pack


USER HIT POSTS-PER-MONTH CAP (any finite-cap plan)
│
└── Suggest the next-tier plan with more (or unlimited) posts


USER HIT CHANNELS LIMIT
│
└── Suggest the next plan tier with more channels
```

Always look up exact thresholds from `POSTZEE_LIST_PLANS` / `POSTZEE_LIST_CREDIT_PACKAGES` before quoting.

### Single-CTA rule

**Never list multiple options at once.** Pick ONE recommendation matching the user's state. Offer alternatives only if they push back.

**Always pull the live `monthPriceUSD`, `channelsLimit`, `postsPerMonth`, `monthlyCredits` from `POSTZEE_LIST_PLANS` before quoting.** Hardcoded numbers below are illustrative only — they may have changed.

Bad: "We have STANDARD, TEAM, PRO, ULTIMATE. Which one?" (dump)
Good: "Based on what you produce, **{plan.tier} (${plan.monthPriceUSD}/mo)** covers it all: {plan.channelsLimit} channels, {plan.postsPerMonth} posts/month, {plan.monthlyCredits} AI credits per month. Want to go with this?"

---

## CTA copy templates

These templates are written in English as the canonical structure. **Always render the final message in the user's language** — translate naturally, adapt the tone, and substitute placeholders with **live values from `POSTZEE_LIST_PLANS` / `POSTZEE_LIST_CREDIT_PACKAGES`** — don't hardcode prices or credits.

### When user is FREE and wants to post

```
Cool, your asset is ready.

But to publish through Postzee you need a plan with the social suite
(FREE focuses only on media creation).

For you, **{recommendedPlan} (${planPrice}/mo)** covers everything:
• {channelsLimit} connected channels
• {postsPerMonth} posts/month
• {monthlyCredits} AI credits included
• {storageLimitGB}GB of storage

Activate here: https://dashboard.postzee.app/billing

Alternative route: I can deliver the files and you post manually.
Tell me which you prefer.
```

### When credits are insufficient for the planned generation

```
To create this, you'll need **{estimatedCredits} credits**, and you
have {available} right now — short by {shortfall}.

Suggested for your usage:

**{recommendedPackage} (${packagePrice})** = {packageCredits} credits.
Covers this generation plus about {remainingGenerations} more like it.

Link: https://dashboard.postzee.app/credits

Want me to proceed as soon as you activate?
```

### When credits are getting low (proactive warning, no current shortfall)

```
Before we keep planning a content series: you're at
**{available} credits**. For the volume we discussed, I recommend
activating **{recommendedPackage} (${packagePrice}, {credits} credits)**
now so you don't stall mid-way.

Link: https://dashboard.postzee.app/credits

I'll keep planning meanwhile.
```

### When subscriber hit posts-per-month cap

```
You've hit the {postsPerMonth} posts/month limit on your {currentPlan} plan.

**{nextPlan} (${nextPrice}/mo)** gives you unlimited posts plus {nextChannels}
channels and {nextCredits} credits/month.

Given your volume, upgrading makes sense. Link:
https://dashboard.postzee.app/billing

Want to upgrade? I can also queue drafts for when the month rolls over.
```

### When channels limit is hit

```
{currentPlan} allows {currentLimit} connected channels — you're at the cap.

The natural next plan for your case is **{nextPlan} (${nextPrice}/mo)**:
{nextChannels} channels. Link: https://dashboard.postzee.app/billing
```

### When user is happy with FREE + credit packs (just generating, not posting)

Acknowledge the model — don't push subscription. Power-user pattern.

```
Got it, keeping you on pure creation mode. Reminder that
**{recommendedPack} (${price})** gives you {credits} eternal credits
(never expire, survive cancellation). Link: https://dashboard.postzee.app/credits
```

---

## Proactive vs reactive

- **Proactive CTA** (warn before issue): when you SEE the user planning more than they have credits/posts for, mention it BEFORE they hit the wall.
- **Reactive CTA** (handle the error): when MCP returns `subscription_required` or `willExceedBalance`, swap from "let's generate" to "here's why we need to top up first".

Always reactive at minimum. Proactive is what makes the agent feel premium.

---

## Multilingual CTAs

Translate the templates above to the user's language. Cultural adaptations:

- **PT-BR** — direct, warm, "tu" or "você" depending on context. Avoid stiff Portuguese.
- **EN** — punchy, second-person, no fluff. "Here's the deal:".
- **ES** — relational, "tú/usted" by audience. Lead with the why.
- **FR** — more formal acceptable, avoid too-casual slang in B2B.
- Other languages — match the formality the user used.

---

## Common mistakes to avoid

- ❌ Quoting USD numbers from this file (they may be stale) — always pull live from `POSTZEE_LIST_PLANS` / `POSTZEE_LIST_CREDIT_PACKAGES`
- ❌ Showing all 5 plans/packs at once — pick ONE and recommend it
- ❌ Letting the user generate then discover they can't post — check plan first
- ❌ Recommending the most-expensive pack to someone clearly at first contact (the Starter pack is the right entry)
- ❌ Pushing subscription to a user who explicitly said "I just want to download files"
- ❌ Mixing the two rails — "buy a plan" when they actually need a credit pack, or vice versa
