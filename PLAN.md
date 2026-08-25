# Project Agnes — working plan
### Global AI Construct Berlin · Neo4j Mini Agentic Hack · 25 Aug 2026
*(rewritten — concept now lives in `CONCEPT.md`; this file is execution only)*

## Where the concept lives

**`CONCEPT.md` is the single source of truth** for what Agnes is. It is organised on
Mary's six capabilities — VALIDATE, SIMULATE, DECIDE, MONITOR, CONTROL, SHADOW-MONITOR —
with what implements each today and what it becomes in the product. It supersedes every
other framing produced during the session. This plan does not restate it.

## The standard

Mary's, and it governs everything:

> I don't care how pretty the story is. I care whether the model gives what was
> requested. Otherwise it's not a useful tool.

Success is **behavioural, not narrative**. Hence `10_acceptance_tests.cypher`, where every
test can fail.

**The three claims, kept separate** — conflating them is the fastest way to lose a judge:

1. **The machinery works** — Zillow demonstrates this. **This is today, and only this.**
2. The product helps — today cannot demonstrate it. Needs forward use.
3. The architecture predicts — needs matched wins and losses, scored blind.

## Files

| File | Role | Status |
|---|---|---|
| `CONCEPT.md` | **What Agnes is.** Six capabilities, four feeds, safeguards, roadmap | done |
| `01_seed_graph.cypher` | Base graph (kit) | ready, untouched |
| `01b_additions.cypher` | FY2020 10-K node + `A_DEMAND` | ready |
| `01c_evidence_revision.cypher` | Overclaim corrections + `MissingEvidence` | ready |
| `02_demo_queries.cypher` | Seven demo queries (kit) | ready, untouched |
| `03_demo_script.md` | Stage document (kit) | ready |
| `04_evidence_manifest.csv` | Source register (kit) | ready |
| `07_supplement.md` | Verified numbers, GraphRAG mapping, extra judge answers | updated |
| `08_agent_setup.md` | Neo4j MCP + Skills | stretch only |
| `09_feedback_notes.md` | **Live capture — add during the day** | in progress |
| `10_acceptance_tests.cypher` | Eight falsifiable checks | ready |
| `11_limitations.md` | What this does not do | updated |
| `05` / `06` (kit) | Blinded-LLM prompt / UI prompt | optional / not doing |

Local git only, private, `.env` gitignored and verified before commit #1. No GitHub remote
— Mary's call.

## What the three seed files do

**`01`** — the kit's graph, unmodified. Real SEC accession URLs, `project`-scoped nodes,
`MetricObservation` separating `valid_at` from `public_from`, `reason` on every edge.

**`01b`** — two additions:
- `E_FY2020_10K` (`public_from = 2021-02-12`) — filed two days *after* the checkpoint. The
  kit describes this correction but had no node. With the node, the boundary can be shown
  rejecting a real document, and test T1 becomes a genuine off-by-one check.
- `A_DEMAND` — an assumption that does **not** deteriorate, on evidence already in the kit.
  Balance stays positive, contributes zero to any score. The within-case negative control.

**`01c`** — three overclaims corrected:
- `E_Q2_INVENTORY → A_THROUGHPUT`: weight 3 → 2. Inventory growth is also what deliberate
  scaling looks like; separating them needs a ratio, not a total.
- `E_Q2_INVENTORY → A_LIQUIDITY`: weight 3 → 2. Direction sound, magnitude a judgement.
- `E_Q2_HOLDING_COST`: **edge removed entirely.** The tempting normalisation
  (2.6/491.293 vs 5.3/1,169.601) is invalid — those divide three-month flows by
  balance-sheet stocks six months apart, and the Q2 2020 base is COVID-distorted. We can
  show neither rise nor fall. Node retained, dated, flagged `HELD_NOT_INTERPRETABLE`,
  bearing on nothing. No replacement edge: the inventory edge to `A_FINANCING` already
  carries "absolute exposure grew."
- Four `MissingEvidence` nodes naming what would settle each open question.

## Verified numbers

Simulation of the kit's own formula, after `01b` + `01c`. **Not yet run in Aura.**

| Scenario | 10 Feb | 5 Aug |
|---|---|---|
| Aggressive | 21 | **33** |
| Hybrid | 11 | 15 |
| Capital-light | **2** | **2** |

Capital-light is flat because `A_FINANCING` genuinely nets to zero at Q2 (cash +2,
inventory −2), not because anything was arranged. No criticality values were tuned.

**Call it a model score.** Not risk, not probability. Always show the assumption-level
changes underneath — those are the finding.

## The honest headline

Not *"the Q2 evidence proved the bet was breaking."* `A_FORECAST` has **zero evidence at
both checkpoints**:

> The public evidence available to our model did not establish key assumptions, while
> disclosed capital exposure increased.

`A_FORECAST` has zero eligible evidence at **both** checkpoints. Note carefully what this
does and does not say: **absence of public evidence is not absence of internal
verification.** Zillow may well have measured forecast accuracy internally. Our graph sees
only what was disclosed, and says so. The claim needs none of the contested Q2 readings.

## Order of work

| Step | Done when |
|---|---|
| Aura Free instance; credentials into `.env` | Query editor opens |
| Run `01` → `01b` → `01c` | Counts return |
| Run `10_acceptance_tests.cypher` | Eight PASS, or we know which failed and why |
| Query 2/3 at T0, then move cutoff to Q2 | Assessment changes, nothing else touched |
| Query 4 scenarios, Query 6 tripwire | NO ELIGIBLE OBSERVATION → TRIGGERED |
| 15:00 — pick **one** stretch | see below |
| **16:00 — freeze, screenshots, no new features** | — |
| 16:30–17:15 — rehearse three minutes | No improvisation |
| 17:15–17:30 — buffer. **Do not wipe the database.** | Re-run `01` only if truly needed |

## The 15:00 stretch — one, not both

**Neo4j MCP** *(chosen)* — ask Agnes a natural-language strategic question, get a
graph-grounded, date-bounded answer. This completes today's **core interaction**: it is the
product's actual shape, not a side pipeline. It also makes the Agentic GraphRAG mapping
live rather than asserted — the SME Cypher templates become tools the agent calls.

**Document Intelligence** — deferred to immediately after the hackathon. Automated
ingestion is genuinely the next thing, but it feeds a pipeline that isn't yet connected to
an interaction. Interaction first, ingestion second.

**Market-data nodes — not today.** And when added, as an external **comparator**, never as
Zillow's operational denominator. Favourable housing conditions can make a macro
explanation unconvincing; they cannot prove throughput failed. Throughput stays CHALLENGED
or unevidenced until Zillow-specific evidence exists — purchases vs sales, inventory age,
days-to-resale, renovation duration, property mix. **Weight 3 does not come back.**

**Agent Memory** — not today, and not because it competes. Split by audit requirement: the
graph holds the decision of record, agent memory holds interaction state. In `09` as
feedback.

## Limitations — say these before a judge finds them

1. The `+2` uncertainty penalty is a magic number. Concede it; the *ordering* is the output.
2. `weight` conflates evidence strength with decision importance. They should be separate.
3. **One case, so plain pessimism is not ruled out.** Tests T4 and T5 are within-case
   controls — real, but they only show the machinery *can* stay flat, not that it
   discriminates across cases. Architecture demonstration, not predictive evidence.

Full detail in `11_limitations.md`.

## Risks

- **Nothing has run in Neo4j.** Every number above comes from simulating the formula in
  Python. Until the seed runs, none of it is confirmed.
- `:param` may not work in the Aura editor — substitute literal `date('2021-02-10')`.
- Stretch work eating the freeze — timebox to 20 minutes, then stop.
