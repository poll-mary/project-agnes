# Agnes — the concept

**One document. Supersedes every scattered framing in the working notes.**
The spine is Mary's six capabilities. Everything else slots into them.

---

## What Agnes is

> A living decision graph that models what must be true for a strategic bet to succeed,
> compares alternative paths, and detects when reality no longer supports the chosen
> strategy.

**The hackathon question**, which is much smaller than the product:
*Can a graph make the reasoning behind one strategic decision visible, recomputable and
responsive to new evidence?*

**The pitch spine:**
1. Companies make expensive bets using scattered and changing evidence.
2. An LLM can generate an answer; our graph preserves the structure behind the decision and updates it over time.
3. Zillow is our first controlled test of whether that structure creates real decision value.

---

## The six capabilities

### 1. VALIDATE
*Define a strategic bet and identify everything that must be true for it to succeed. Then
assess which conditions are supported, uncertain or fragile.*

| | |
|---|---|
| **Today** | Query 2 ranks assumptions by attention needed. Query 3 isolates the ones with *no* eligible evidence. |
| **Graph** | `StrategicBet` → `DEPENDS_ON` → `Assumption` ← `BEARS_ON` ← `Evidence` |
| **Key property** | Three outcomes, not two: supported, contradicted, and **insufficiently evidenced**. A system that never says "we don't know" is asserting, not assessing. |
| **Full product** | Agnes proposes the assumptions from the user's documents; the user confirms or corrects. Agnes proposes, the human decides — and the human's commitment is what makes the record mean anything later. |

### 2. SIMULATE
*Change a variable — or replace the entire strategy — and recompute the downstream
consequences.*

| | |
|---|---|
| **Today** | Query 4 scores three scenarios against identical evidence. The same assumption failing costs different amounts depending on the scenario's structure. |
| **Graph** | `Scenario -[:DEPENDS_ON {criticality}]-> Assumption`, `Scenario -[:CREATES_EXPOSURE {intensity}]-> Exposure` |
| **Key property** | Criticality comes from *structure* (does this form of the bet own inventory?), which is knowable up front — not from what happened. |
| **Full product** | User-created and AI-generated scenarios, including alternatives the user never named. |

### 3. DECIDE
*Select the most defensible path based on evidence, exposure and trade-offs.*

| | |
|---|---|
| **Today** | The model score plus the assumption-level detail underneath it. |
| **Key property** | **DECIDE is the human's act.** Agnes supplies the basis, never the verdict. And the aggregate is a **model score** — an ordering heuristic from a formula we chose. Not a risk measurement, not a probability. Always show the assumption-level changes; those are the finding. |
| **Full product** | A decision brief the user commits to, with a named owner and a date. |

### 4. MONITOR
*Continuously check whether the evidence supporting the chosen path is strengthening or
deteriorating.*

| | |
|---|---|
| **Today** | Every `Evidence` node carries `public_from`. Change only the cutoff date and the assessment recomputes. The graph is never rebuilt — later evidence is physically present and simply not eligible. |
| **Key property** | This is a **retrieval boundary**. An agent grounded in the graph cannot reach post-cutoff evidence, because the rows don't come back. It can't leak what it was never handed. |
| **Full product** | Continuous ingestion and alerting instead of two discrete checkpoints. |

### 5. CONTROL
*Predefine tripwires: "if this metric crosses X, slow down, investigate, pivot or stop."*

| | |
|---|---|
| **Today** | `Tripwire` stores metric, threshold, action and `frozen_at`. Query 6 evaluates it against eligible observations. |
| **Key property** | **Nothing links evidence to the tripwire.** Whether it fired is computed at query time. Storing the answer would bake in the outcome. Frozen 10 February, fires on August data, unmoved in between. |
| **Full product** | Many tripwires, each with a named owner and a notification path. |

### 6. SHADOW-MONITOR
*Keep alternative strategies alive in the graph and detect when one becomes more attractive
than the chosen path.*

| | |
|---|---|
| **Today** | Capital-light scores 2 at both checkpoints while aggressive moves 21 → 33. |
| **Mary's caveat, said out loud** | Agnes **cannot know how an unchosen strategy would have performed.** It updates how that alternative would *currently be expected* to perform. Capital-light does not improve — it is simply not exposed to the evidence that moved. Say it as **lower modelled exposure under the assumptions currently represented**, never as objectively safer: we modelled it in less depth, and a scenario modelled less thoroughly will look safer. |
| **Full product** | Rejected alternatives preserved along with the reasons they were rejected. |

---

## What feeds the graph

Four feeds, not three.

| Feed | Contains | Who supplies it |
|---|---|---|
| **Decision context** | The bet, alternatives, success criteria, timeframe, constraints, acceptable risk | User (with Agnes's help — see below) |
| **Internal evidence** | Financials, operational metrics, forecasts, research, strategy docs, test results | Company |
| **External evidence** | Market conditions, competitors, regulation, technology, macro signals | Agnes retrieves |
| **Decision history** | What was previously chosen, rejected, expected, and why | Agnes preserves |

**Every fact carries two dates: when it was observed, and when it became publicly
knowable.** Retrieval filters on the second.

### External evidence is harder than it looks

**Historical vintages, not revised modern values.** Economic data gets restated months
later. "What was knowable on 10 February 2021" means *the figure as printed then*, not
today's corrected value. SEC filings are easy — a filing is immutable. Market data is not.

**Comparator, not denominator.** External evidence can show that a macro explanation is
unconvincing — *"the losses occurred despite favourable tailwinds."* It cannot establish
an internal operational failure. "US homes were selling quickly" does not prove Zillow's
inventory should have turned quickly; Zillow's cycle includes acquisition and renovation.
Throughput stays CHALLENGED or unevidenced until Zillow-specific evidence exists:
purchases vs sales, inventory age, days-to-resale, renovation duration, property mix.

---

## Agnes as decision-setup partner

Requiring users to arrive with perfect success criteria, alternatives and organised
evidence would be demanding the strategic work Agnes exists to help with. So Agnes helps
build the brief — and the user confirms, because what success *means* is a value judgement,
not a factual extraction.

| Input | Agnes helps by | User confirms |
|---|---|---|
| Success | Proposing measurable outcomes, timeframe, failure criteria | What actually matters |
| Time and budget | Estimating resources, exposing unrealistic combinations | Real limits |
| Directions | Generating alternatives from assets, market, constraints | Which are genuinely possible |
| Interviews | Ingesting transcripts, extracting claims, finding contradictions | Source credibility |
| Test results | Reading reports and logs, converting to evidence | Whether conditions reflect reality |

### Safeguards against strategic bias

Because retrieval inherits the framing of the query, and review turns into rubber-stamping:

- Search deliberately for **both supporting and disconfirming** evidence
- Ask the user for **their** assumptions *before* revealing Agnes's suggestions
- Generate **competing framings**, not one authoritative framing
- Hunt for **unnamed alternatives** via competitors, analogues, adjacent models
- **Preserve rejected alternatives** and why they were rejected

The last one matters most: the expensive strategic error is usually the option nobody put
on the table. A system that inherits your option set inherits your blind spot — and will
feel rigorous while doing it.

---

## Prototype versus product

| Today | Full product |
|---|---|
| One company: Zillow | Any company or strategic bet |
| One checkpoint, moved once | Continuous real-time assessment |
| Manually curated evidence | Automatic document and data ingestion |
| Small predefined graph model | Flexible graph generated per decision |
| Three scenarios | User-created and AI-generated scenarios |
| A few demonstration questions | Complete decision interface |
| One tripwire | Continuous monitoring and notification |
| Sources linked manually | Automated provenance, permissions, auditing |

---

## Why the corrections strengthen the concept

The evidence corrections changed what Agnes *concludes from particular evidence*. They did
not change the product.

Agnes saying **"this is concerning, but the decisive metric is missing"** demonstrates the
concept better than a confident Zillow-failure prediction would. A tool that always
produces a verdict is not assessing — it is performing. Naming the missing evidence is the
capability, not a shortfall of it.

## The three claims, kept separate

1. **The machinery works** — Zillow can demonstrate this. Acceptance tests, not narrative.
2. **The product helps** — today cannot demonstrate this. Needs forward use.
3. **The architecture predicts** — needs matched successful and failed cases, scored blind.

Conflating them is the fastest way to lose credibility. Today is claim 1 only.

---

## Roadmap

**Order matters: interaction before ingestion.** The natural-language question against a
date-bounded graph is the product's actual shape. Automated ingestion feeds it, but
building the pipeline before the interaction exists means building toward nothing.


- Point-in-time market-data vintages (as-printed, not as-revised)
- Deliberate supporting **and disconfirming** retrieval
- Competing decision framings rather than one
- Discovery of unnamed alternatives
- Decision history as the fourth feed
- Automated ingestion via Document Intelligence
- **Permissions as a retrieval predicate** — `public_from <= $cutoff` and
  `clearance <= $user_level` are one line of Cypher with a different predicate, enforced by
  the database rather than the prompt. Production carries Neo4j fine-grained RBAC. Honest
  limits: it does not stop a model *inferring* a restricted fact from permitted ones, and
  once evidence is in the context window it has left the database's jurisdiction.
- Agent memory alongside the graph, split by audit requirement: the graph holds the
  decision of record, agent memory holds interaction state.
