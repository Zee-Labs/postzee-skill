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
  channels.connected: number
  channels.withIssues: number
  storage.percentUsed: number
}
```

Combined with the **planned action**:

```
{
  intent: "generate-only" | "generate-and-post" | "post-existing" | "schedule"
  estimatedCredits: number
  slideCount: number
  needsChannel: boolean
}
```

---

## State matrix — what to do

### Intent: "generate-only" (user wants AI media, doesn't mention posting)

| State | Behavior |
|-------|----------|
| `credits.available >= estimatedCredits` | Proceed normally. After generation, ask if they want to post. |
| `credits.available < estimatedCredits` | **Block. CTA matched credit pack.** See `plans-and-pricing.md` template "credits insufficient". |
| `credits.available > 0` but `< 200` | Proceed BUT proactively warn: "Você tá com {n} créditos depois disso. Quer que eu sugira um pacote pra não travar?" |
| `tier === "FREE"` and `credits.available === 0` | They never bought a pack. Welcome flow with the cheapest pack from `POSTZEE_LIST_CREDIT_PACKAGES` (Starter): "Pra começar a criar, recomendo o {Starter.name} (${Starter.priceUSD} = {Starter.credits} créditos) só pra testar." |
| `storage.percentUsed >= 95` | Block generation. Tell user storage is full and offer upgrade or cleanup. |
| `storage.percentUsed >= 80` | Proceed but warn. |

### Intent: "generate-and-post" (user wants to publish)

Run all "generate-only" checks first. THEN add:

| State | Behavior |
|-------|----------|
| `plan.canPost === false` (FREE) | **Critical.** Either: (a) generate the asset and tell user "I generated it, but to publish via Postzee you need a paid plan — recommend STANDARD" with file delivery as fallback. (b) BEFORE generating, check if they care about posting; if yes, propose plan upgrade upfront. Default to (b) for transparency. |
| `plan.canPost === true` but `channels.connected === 0` | **Block.** Tell user to connect channels first at https://dashboard.postzee.app/channels. Don't generate yet — they'd waste credits. |
| `plan.postsRemaining === 0` (Standard hit 400 cap) | **Block posting** but allow generation if they have credits. CTA TEAM upgrade. |
| `channels.withIssues > 0` | Proceed with healthy channels. Mention which one needs reconnection. |

### Intent: "post-existing" (user already has files / text, just wants to post)

| State | Behavior |
|-------|----------|
| `plan.canPost === false` | CTA upgrade. Offer no fallback — they can't post without subscription. |
| `channels.connected === 0` | Send to /channels first. |
| `channels.withIssues > 0` | Specify which channel works, which doesn't. |

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
- What format will we generate?
- How many assets? (carousels = N slides)
- Will they post? Where?

This determines `intent` + estimated total credits.

### Moment 3 — Pre-generation (before any GENERATE_*)

```
1. POSTZEE_LIST_MODELS_DETAILED — pick model
2. POSTZEE_VALIDATE_GENERATION — pre-flight (FREE — no cost)
   → If invalid params: fix or change strategy
   → If shortfall: CTA + stop
3. POSTZEE_ESTIMATE_GENERATION_COST × slide count — confirm total
4. Show plan to user: "Vou usar {model} pra gerar {N} {type}, custo estimado total: {credits} créditos. Sigo?"
5. If yes → POSTZEE_ENHANCE_PROMPT → POSTZEE_GENERATE_*
```

### Moment 4 — Pre-posting

```
1. Verify channels.connected > 0
2. Verify plan.canPost === true (and postsRemaining > 0 if finite)
3. POSTZEE_LIST_CHANNELS to confirm specific channel id
4. POSTZEE_CREATE_POST
```

---

## Common state combos and their playbooks

### "FREE user with no credits, wants to generate"
→ Welcome to Postzee CTA. Recommend `starter` from `POSTZEE_LIST_CREDIT_PACKAGES` (cheapest entry pack) to test. Generate-only flow, no subscription push (yet).

### "FREE user with credits, wants to post"
→ Generate IF intent unambiguous. THEN explain: "Gerei tudo. Pra publicar pelo Postzee você precisa de plano. Recomendo STANDARD ($X/mês) que inclui {Y} créditos mensais — vai cobrir mais conteúdo desse tipo. Ou te mando os arquivos pra postar manual."

### "STANDARD user, low credits"
→ Generate. Mention credit pack option AFTER, not before — they're already paying. "Top — você ainda tem {N} créditos depois disso. Se for produzir muito mais essa semana, o pack Basic ($10 = 10.000 créditos) cobre bem."

### "STANDARD user, hit 400 posts/month"
→ Block posting. CTA TEAM upgrade. Mention rascunhos podem ficar prontos pra quando o mês virar.

### "PRO user, missing channels for the platform user wants"
→ Tell them which channel and link. Don't assume they're at limit (PRO has 30 channels, they probably just haven't connected the specific one).

### "ULTIMATE user, no problems"
→ Just ship. They paid for premium service. Maximum signal, minimum friction.

---

## Transparency principles

- **Always state cost in credits BEFORE generating.** "Esse vídeo vai custar 600 créditos."
- **Always explain why you're CTAing.** Not "buy this!" but "porque você quer postar e o FREE não inclui isso, recomendo X".
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

If the user says "não quero plano agora" / "não vou pagar":

1. Respect immediately. **Don't insist.**
2. Pivot to what they CAN do: "Sem problema. Posso te entregar os arquivos prontos aqui mesmo, e você posta manual nas redes."
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
