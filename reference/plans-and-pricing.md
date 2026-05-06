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
Good: "Pelo que você produz, **{plan.tier} (${plan.monthPriceUSD}/mês)** cobre tudo: {plan.channelsLimit} canais, {plan.postsPerMonth} posts/mês, {plan.monthlyCredits} créditos IA por mês. Vamos com esse?"

---

## CTA copy templates

Adapt these to the user's language and tone. Show the **live price** from `POSTZEE_LIST_PLANS` / `POSTZEE_LIST_CREDIT_PACKAGES` — don't hardcode.

### When user is FREE and wants to post

```
Beleza, esse conteúdo tá pronto. 

Mas pra postar pelo Postzee você precisa de plano com suíte social
(o FREE foca só em criação de mídias).

Pra você, **{recommendedPlan} (${planPrice}/mês)** cobre por inteiro:
• {channelsLimit} canais conectados
• {postsPerMonth} posts/mês
• {monthlyCredits} créditos IA inclusos
• {storageLimitGB}GB de storage

Link pra ativar: https://dashboard.postzee.app/billing

Outra rota se preferir: te mando os arquivos prontos e você posta
manual mesmo. Fala como prefere.
```

### When credits are insufficient for the planned generation

```
Pra criar isso vai precisar de **{estimatedCredits} créditos**, e você 
tem {available} agora — faltam {shortfall}.

Sugestão pro teu uso:

**{recommendedPackage} (${packagePrice})** = {packageCredits} créditos.
Cobre essa criação e mais ~{remainingGenerations} parecidas.

Link: https://dashboard.postzee.app/credits

Quer que eu siga e gere assim que ativar?
```

### When credits are getting low (proactive warning, no current shortfall)

```
Antes de a gente continuar planejando série de conteúdo: você tá com
**{available} créditos**. Pra o volume que conversamos, recomendo
ativar **{recommendedPackage} (${packagePrice}, {credits} créditos)**
agora pra não travar no meio.

Link: https://dashboard.postzee.app/credits

Sigo planejando enquanto isso.
```

### When STANDARD subscriber hit posts-per-month cap

```
Você bateu os {postsPerMonth} posts/mês do {currentPlan}. 

**TEAM (${teamPrice}/mês)** te dá ilimitado + {teamChannels} canais 
+ {teamCredits} créditos/mês.

Pro teu volume, faz sentido subir pra TEAM. Link: 
https://dashboard.postzee.app/billing

Quer? Posso seguir agendando rascunhos pra quando virar o mês também.
```

### When channels limit is hit

```
{currentPlan} permite {currentLimit} canais conectados — você já 
tá no máximo. 

Próximo plano natural pro teu caso é **{nextPlan} (${nextPrice}/mês)**:
{nextChannels} canais. Link: https://dashboard.postzee.app/billing
```

### When user is happy with FREE + credit packs (just generating, not posting)

Acknowledge the model — don't push subscription. Power-user pattern.

```
Top, segui no fluxo de criação pura. Lembra que o **{recommendedPack} 
(${price})** te dá {credits} créditos eternos (não expiram nunca, 
sobrevivem cancelamento). Link: https://dashboard.postzee.app/credits
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
