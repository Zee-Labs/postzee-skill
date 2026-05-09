# Carousel Headline Engine

This file is the heart of the carousel headline craft. It governs **how the agent generates 10 headlines** for every carousel, the structural rules each must obey, the empirical patterns that perform, and the iteration commands the user can issue.

The headline is the carousel. A weak slide-1 hook wastes the other eight slides — no matter how good they are. So this stage is **non-negotiable**: the agent generates exactly 10 numbered headlines, runs the rejection checklist on each, and only then offers them to the user.

---

## 1. The inviolable rule

> **For every carousel, generate exactly 10 headlines: 5 in *Investigative Cultural* format (variations 1-5) and 5 in *Magnetic Narrative* format (variations 6-10). Numbered. No more, no less.**

Not 9. Not 11. **Ten.** This is structural — the user will reference them by number ("a 3 mais provocativa", "mistura a 2 com a 7"), so the index must be stable.

If the user asks for something specific ("só preciso de 3 ideias rápidas"), still generate the full 10 internally and offer them. The user does not pay the cost — the agent does the discipline.

---

## 2. Empirical lift data — what actually performs

These multipliers are **observed engagement lifts** across high-performing carousel content (compared to baseline declarative headlines on the same niche). Internalize them before generating. They drive variation selection: when the user says "a mais forte", you reach for the patterns at the top.

| Pattern | Lift | When it works |
|---|---|---|
| **Regional / cultural anchor** ("no Brasil", "em SP", "geração brasileira") | **+155%** | Topic has a local angle that contradicts global narrative |
| **Death / End framing** ("A morte de X", "O fim de X", "Por que X está morrendo") | **+119%** | A practice / role / belief is genuinely declining |
| **Generational behavior** ("Por que [Geração] está [comportamento]") | **+119%** | Audience can locate themselves or someone they know |
| **Novelty / Recent** ("Agora", "Esta semana", "Recentemente") | **+99%** | Topic is news-cycle adjacent (≤ 14 days old) |
| **Question framing** ("Por que…?") | **+20%** | Premise is genuinely investigable |
| **Transformation** ("Como X virou Y") | **−1%** | Use only as filler — neutral |
| **Negation** ("X não é…") | **−2%** | Avoid unless the negation is the actual news |
| **Plain declaration** ("X é importante") | **−29%** | Default-skip |
| **Pure revelation** ("O segredo de X") | **−42%** | **Banned** — reads as low-trust IA copy |

Frame these as performance heuristics, not hard truths. The agent should explain to the user (when relevant) *why* a given variation has higher expected reach — but not lecture.

---

## 3. The 5 empirical headline patterns

Variations 1-10 must collectively cover 3-5 of these patterns. Repeating the same pattern across all 10 is a generation failure.

### 3.1 Death / End Pattern

**Shape:** "A Morte de [X]" / "O Fim de [X]" / "Por Que [X] Está Morrendo"

**When:** A practice, role, or genre is genuinely declining (with evidence).

**Examples:**
- "A morte do gosto pessoal."
- "O fim do criador generalista."
- "Por que o portfólio está morrendo (e o que vem depois)."

**Failure modes:** Don't use when the thing isn't actually dying — readers detect the bluff in 2 seconds.

### 3.2 Generational Behavior Pattern

**Shape:** "Por Que [Geração] Está [Comportamento Inesperado]"

**When:** A demographic cohort is doing something that contradicts what their stereotype predicts.

**Examples:**
- "Por que a Geração Z está voltando para o jornal de papel."
- "Por que millennials brasileiros estão comprando casa em Portugal."
- "Por que adolescentes pararam de tirar selfie."

**Failure modes:** Generic "millennials são X" is dead. Pair generation with **specific** behavior.

### 3.3 Investigation Pattern

**Shape:** "Investigando Por Que [Fenômeno]" / "[Fenômeno]: a explicação que ninguém quer dar"

**When:** There's a visible pattern in culture / market that hasn't been named yet.

**Examples:**
- "Investigando por que a corrida virou a droga favorita dos adultos ansiosos."
- "Investigando por que ninguém da sua faculdade abriu mão do LinkedIn."

**Failure modes:** "Investigando" precisa de fato investigável. Não use como ornamento.

### 3.4 Brand / Name Reveal Pattern

**Shape:** "[Nome próprio / Marca] e a [revelação contraintuitiva]"

**When:** A specific named entity (person, brand, product, place) embodies the tension better than a generic noun.

**Examples:**
- "Apple e a marca que parou de inovar (mas está vencendo mesmo assim)."
- "Nubank e o produto que quase ninguém usa (mas paga as contas)."

**Failure modes:** Don't drop names you can't back up with one concrete fact in slide 2-3.

### 3.5 Two-Colon Formula (Investigative Cultural format core)

**Shape:** "[Setup]: [twist]: [payoff]." — exactly two colons, total length 20-24 words.

**Examples:**
- "Por que comer sozinho na rua virou: o esporte favorito: dos solteiros pós-pandemia."
- "Sua estante de livros é: o currículo invisível: que toda primeira impressão lê primeiro."

**Failure modes:** A single colon is plain declaration. Three colons confuse rhythm. Exactly two.

---

## 4. The 6 emotional triggers

Every effective hook activates **one** of these. Variations 1-10 should collectively hit 4-6 of the six.

| Trigger | Activates by | Example surface |
|---|---|---|
| **Nostalgia** | Pointing at a thing the audience used to love and naming what replaced it | "A última geração que ainda lembra o som do modem." |
| **Fear / Alert** | Naming a slow-moving threat that the audience hasn't connected yet | "O sinal que aparece nos extratos antes de uma demissão." |
| **Indignação** | Pointing at an injustice or absurd asymmetry | "Por que advogado de banco ganha 3x o do cliente final — e ninguém reclama." |
| **Identidade** | Letting the reader recognize themselves in 7 words | "Por que você abre o Instagram dez vezes e não posta nenhuma." |
| **Curiosidade** | Setting up a question the brain refuses to leave unanswered | "O que separa criadores de 1k seguidores dos de 100k em 2026." |
| **Aspiração** | Naming the next level the audience already wants | "O movimento silencioso que está enriquecendo professores particulares no Brasil." |

When the user says "a 4 mais emocional" / "a 7 com mais peso", read this table — it tells you which lever to pull.

---

## 5. The two formats — strict structures

### 5.1 Format A — Investigative Cultural (variations 1-5)

**Word count:** 20-24 words.
**Structure:** Two-colon formula (§3.5) **OR** "Investigando por que…" (§3.3) **OR** Death pattern with cultural backdrop.
**Tone:** Editorial / journalistic. Reads like a Folha or NYT longread headline.
**Punctuation:** Period at the end. Two colons in the middle (when applicable). No exclamation marks.

**Template skeleton:**
```
[ANCHOR]: [INTERPRETIVE PIVOT]: [PAYOFF].
20-24 words total. Two colons. One period.
```

**Worked variations (different topics):**

```
1. Por que comer sozinho na rua virou: o esporte favorito: dos
   solteiros que escaparam da pandemia. (20 palavras)

2. A morte do gosto pessoal: como o algoritmo do TikTok virou:
   o curador estético da geração que cresceu nele. (22 palavras)

3. Investigando por que cinco em cada dez millennials brasileiros
   compraram caderno de papel em 2025: e ainda dizem que escrevem mais. (24 palavras)
```

### 5.2 Format B — Magnetic Narrative (variations 6-10)

**Word count:** ~30-45 words total.
**Structure:** Three sentences. Setup → Tension → Hook.
**Tone:** Personal-conversational. Sentences land like punches.
**Punctuation:** Each sentence ends with a period. No semi-colons. No em-dashes within sentences.

**Template skeleton:**
```
[SETUP — observation that locates the reader].
[TENSION — the friction nobody is naming].
[HOOK — the line that forces the swipe].
```

**Worked variations:**

```
6. Sua estante de livros diz mais sobre você do que seu CV.
   E ninguém percebeu isso ainda.
   Nem você.

7. Você não está cansado.
   Você está acumulando vinte abas que nenhum minuto livre vai fechar.
   E o problema é exatamente esse.

8. O criador mais bem pago da sua bolha posta menos do que você.
   Não porque é preguiçoso.
   Porque entendeu o que você ainda finge não saber.
```

---

## 6. Generation algorithm (the agent's silent process)

Before delivering the 10 to the user, run this internally — never narrate it (see "invisible scaffolding" rule, §11).

```
1. From the brief, extract the central friction (one sentence).
2. List 3-5 possible angles on that friction (different patterns, §3).
3. Map each angle to a likely emotional trigger (§4).
4. Generate 5 Investigative Cultural variations (§5.1):
     - At least 1 Death pattern
     - At least 1 Investigation pattern
     - At least 1 Two-Colon formula
     - 5 must collectively cover 3+ triggers
     - Each must hit 20-24 words
5. Generate 5 Magnetic Narrative variations (§5.2):
     - All three-sentence structure
     - 5 must collectively cover 3+ triggers
     - Each sentence must stand on its own (test: does the second
       sentence still punch if you delete the first?)
6. Run rejection checklist (§7) on all 10. Replace any that fail.
7. Number them 1-10 and deliver.
```

---

## 7. Rejection checklist — kill on sight

A headline fails (and must be regenerated, not "softened") if it contains ANY of these:

| Failure | Why | Replace by |
|---|---|---|
| Decorative adjective ("poderoso", "incrível", "transformador", "essencial") | AI tell — empty intensity | A concrete fact |
| Cliché opening ("Imagine…", "E se eu te dissesse…", "A verdade é que…") | Tutorial-bot register | Direct claim |
| Antithesis ("Não é X, é Y") | AI cadence; 2024 marketing slop | Say it directly |
| Filler connector ("Vale destacar", "Nesse sentido", "Diante disso") | Hedge bot | Cut |
| Empty closer ("E isso muda tudo", "É aí que a mágica acontece") | Vacuous flourish | Concrete consequence |
| Pure revelation framing ("O segredo de X", "O que ninguém te conta sobre X") | Lift = −42%; reads as low-trust | Investigation pattern |
| Promise without anchor ("Vai mudar sua vida") | Abstract lift, no ground | Specific consequence |
| Mixed languages within one variation | Discipline failure | Pick one |
| Headline shorter than the floor (IC < 20 words, NM < 3 sentences) | Format violation | Re-shape |
| Headline longer than the ceiling (IC > 24 words) | Won't fit on slide 1 at min 88px | Compress |
| Missing article ("o", "a", "um", "uma") where Portuguese requires it | AI translation tell | Add it |
| Colon count wrong on IC (must be 0 or 2, never 1 or 3) | Rhythm break | Re-shape |

If a variation fails 2+ items, regenerate it whole rather than patching.

---

## 8. Iteration commands — what the user can ask

The user will not regenerate from scratch — they will request surgical changes. Map their phrases to actions:

| User phrase (PT/EN equivalents) | Action |
|---|---|
| `refazer headlines` / `redo headlines` | Generate a fresh batch of 10. Throw the old ones out. Do not preserve any. |
| `ajusta a [N]` / `tweak headline [N]` | Rewrite only variation N. Keep the other 9 as-is. Same format slot (IC stays IC, NM stays NM). |
| `mistura a [N] com a [M]` / `blend [N] and [M]` | Synthesize: take N's hook + M's payoff (or vice versa, whichever is stronger). Replace one of the two; keep the other. |
| `a [N] mais provocativa` / `[N] more provocative` | Rewrite N with a stronger tension lever. Keep the format slot. Push toward Indignação or Fear trigger if it was previously Curiosidade. |
| `a [N] com ângulo brasileiro` / `[N] with brazilian angle` | Rewrite N with a regional anchor (lift +155%). Keep the format slot. |
| `a [N] mais curta` / `[N] shorter` | Trim N within format limits (IC: never below 20 words; NM: keep 3 sentences). |
| `troca o ângulo` / `change the angle` | Means: the central friction was wrong. Re-run §6 from step 1. |

The agent **always responds with the full updated list of 10**, not just the changed variation. Reduces user cognitive load.

---

## 9. Pattern coverage rule for the batch of 10

When you finish generation, the batch must satisfy:

- ✅ At least **3 of the 5 patterns** represented across the 10
- ✅ At least **4 of the 6 triggers** represented across the 10
- ✅ At least **2 variations** have a regional / cultural anchor (the +155% lift family)
- ✅ At least **1 variation** uses a specific name (brand, person, place, product)
- ✅ No two variations are interchangeable rewrites of each other (test: would the user pick differently between them based on something other than tone?)

If any rule fails, replace the offending variation(s) before delivering.

---

## 10. Cover headline rule (slide 1)

Once the user picks a variation, **use it whole on the cover**. The cover slide's typography is sized for the full headline. Do not summarize, condense, or re-cut.

Sole exception: if the chosen variation cannot fit on 5 lines at the minimum cover size (88px), shrink the typography first; only as last resort, ask the user to re-pick.

If the user says "use a 3 na capa" and you secretly decide "vou cortar a parte final pra caber" — that's a discipline break. Don't.

---

## 11. The invisible scaffolding rule

The agent never narrates this process to the user. The user sees:

```
Aqui estão 10 ideias de headline:

VARIAÇÃO 1 — [headline]
VARIAÇÃO 2 — [headline]
...
VARIAÇÃO 10 — [headline]

Qual te chama a atenção? Pode dizer "a 3", "mistura a 2 com a 7",
ou "refazer headlines" se nenhuma serve.
```

**No** "I generated using the Two-Colon formula", **no** "I optimized for the +155% lift pattern", **no** "I checked the rejection list against each variation". The work is invisible. Only the result is shown.

If the user asks why a specific variation was chosen, *then* you can explain the lever you pulled — but in their language, briefly. Never volunteer it.

---

## 12. Worked example — full batch

Topic: "Why your home network is faster than the country's average."
Audience: tech / SaaS Brazil.
Trigger goal: Identidade + Curiosidade.

```
VARIAÇÃO 1 — Por que sua casa tem internet mais rápida: do que a média
do país: e isso explica mais do que você imagina sobre o Brasil. (24 palavras, IC, two-colon, regional anchor)

VARIAÇÃO 2 — A morte da gambiarra: como o brasileiro virou o cliente:
mais exigente do mundo em redes domésticas. (20 palavras, IC, Death pattern, regional)

VARIAÇÃO 3 — Investigando por que três em cada cinco lares brasileiros:
trocaram de provedor: nos últimos doze meses. (21 palavras, IC, Investigation)

VARIAÇÃO 4 — A geração que cresceu com discada agora cobra: latência
de 8 ms: e ninguém está dimensionando o impacto disso. (22 palavras, IC, Generational)

VARIAÇÃO 5 — O Brasil tem uma das infraestruturas residenciais: mais
modernas do mundo: e a maioria dos brasileiros não sabe. (22 palavras, IC, regional)

VARIAÇÃO 6 — A internet da sua casa é mais rápida que a do escritório.
A do seu escritório é mais rápida que a do banco que cuida do seu salário.
Ninguém está dizendo isso em voz alta. (NM, Indignação)

VARIAÇÃO 7 — Você acha que sua conexão é normal.
Ela é, na verdade, melhor que 92% das conexões corporativas do país.
E é por isso que você reclama com razão do Wi-Fi do trabalho. (NM, Identidade)

VARIAÇÃO 8 — Cinco anos atrás, 8 ms de ping era luxo de gamer.
Agora é o piso da casa do brasileiro médio.
A pergunta certa não é por quê. É: e agora? (NM, Curiosidade)

VARIAÇÃO 9 — A operadora que ninguém estava prestando atenção
levantou 4 milhões de assinantes em 18 meses.
E o segredo dela cabe em uma palavra: latência. (NM, Brand-reveal proxy)

VARIAÇÃO 10 — Seu Wi-Fi venceu a infraestrutura pública.
Ninguém comemorou.
A pergunta sobre quem deveria pagar por isso ainda não foi feita. (NM, Indignação)
```

Coverage check:
- ✅ Patterns: Death (#2), Investigation (#3), Generational (#4), Two-Colon (#1, #5)
- ✅ Triggers: Identidade (#7), Curiosidade (#1, #8), Indignação (#6, #10), regional anchor (#1, #2, #5)
- ✅ Specific name: not present — could swap #9 for an actual provider name if user wants
- ✅ All 5 IC are 20-24 words; all 5 NM are exactly 3 sentences

---

## 13. When the user gives a vague brief

If the user says "carrossel sobre marketing" — too vague to extract a friction.

Don't generate generic headlines. Ask once:

> "Pra ficar afiado: qual é o ângulo que está te incomodando dentro de marketing? Pode ser um dado recente, uma prática que está virando, uma frustração com como o setor opera. Uma frase basta."

After the user answers, generate 10. Never default to "10 erros que…" headlines — that's what every IA-driven content tool produces, and it's exactly the noise the audience scrolls past.

---

The headline engine is not a list of templates. It is a discipline. Run it on every carousel, no matter how rushed the user is.
