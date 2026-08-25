# Supplement — what the base kit doesn't have

The starter kit is the canonical material. Run `01`, then `01b_additions.cypher`, then
`02`. This file adds four things the kit predates or omits.

---

## 1. Verified expected numbers

**Run the simulation, not your memory.** These are computed from the seed data with the
kit's own scoring formula, including `01b_additions.cypher`. If Aura returns something
different, the seed didn't fully load — check block counts before you change anything.

### Assumption state (Query 2)

`balance` = Σ(direction × weight) over eligible evidence. `count = 0` means **unknown**,
which the formula penalises by +2 — scaling on an unknown is the actual error.

| Assumption | 10 Feb | 5 Aug |
|---|---|---|
| A_FORECAST | count 0, balance 0 → **UNKNOWN at both dates** | count 0, balance 0 |
| A_UNIT | count 2, balance −2 | count 2, balance −2 |
| A_THROUGHPUT | count 1, balance −1 | count 3, balance **−2** |
| A_LIQUIDITY | count 1, balance −2 | count 3, balance **−5** |
| A_FINANCING | count 1, balance +2 | count 2, balance 0 |
| A_DEMAND | count 1, balance +2 | count 2, balance **+4** ← *holds* |

Eligible evidence: **4 items at T0, 8 at Q2.**

### Scenario model score (Query 4) — lower is better

| Scenario | 10 Feb | 5 Aug | Change |
|---|---|---|---|
| Aggressive principal | **21** | **33** | +57% |
| Hybrid / partner | 11 | 15 | +36% |
| Capital-light | **2** | **2** | **unchanged** |

*(after `01c_evidence_revision.cypher`. Before the revision these read 21→45 / 11→19,
inflated by three overclaimed edges. See `11_limitations.md`.)*

**Call it a model score.** Not a risk measurement, not a probability. It is an ordering
heuristic built from a formula we chose. Always show the assumption-level changes
underneath it — those are the finding; the aggregate is just a summary of them.

**Capital-light does not move. At all.** That is the strongest single line in the demo:

> The capital-light alternative doesn't get better. Its number is identical. None of the
> new evidence touches the two assumptions it depends on, because it doesn't hold
> inventory. The graph cannot know how an unchosen strategy *would* have performed — it
> updates how that alternative would *currently be expected* to perform. Those are
> different claims and only the second one is honest.

### Tripwire (Query 6)

- At `2021-02-10`: **NO ELIGIBLE OBSERVATION**
- At `2021-08-05`: **TRIGGERED** — 1,169.601 vs a 1,000.0 threshold frozen on 10 Feb

---

## 2. Where this sits on the instructor's architecture slide

The kit was written before the Agentic GraphRAG slide. It maps onto it exactly:

| Slide box | This project |
|---|---|
| Query | "What had to be true for aggressive expansion to succeed, as of 10 Feb 2021?" |
| Graph Retrieval Agent | Coding agent over Neo4j MCP |
| **`3n` SME Cypher Template** | **`02_demo_queries.cypher` — the contribution** |
| `3b` Text2Cypher | Fallback for questions we didn't anticipate |
| Graph Database | The seeded ontology in Aura |
| LLM (Output) → Response | The assessment report |

**Say this if anyone asks whether it's really an AI project.** An SME Cypher Template is
an expert-authored, parameterised query the agent calls as a tool — a first-class box in
Neo4j's own reference architecture, not a database detail to apologise for. The agent
supplies the *parameter*; it does not get to invent the query *shape*.

---

## 3. Two extra judge answers

The kit's answers are good. These two aren't in it.

**"Why not just let the LLM write the Cypher — why hand-write templates?"**

> Accuracy, and containment. An expert-authored template does the same thing every time.
> And an LLM writing its own Cypher can reach anything the connection can reach — that's
> SQL injection where the attacker is your own model. SME templates fix the query shape,
> so the agent supplies parameters, not structure. For a product handling confidential
> strategy material, that difference *is* the security model.

**"How would you stop it leaking confidential internal information?"**

> Today's date gate is already that mechanism. `WHERE public_from <= $cutoff` and
> `WHERE clearance <= $user_level` are one line of Cypher with a different predicate —
> and it's enforced by the database, not by asking the model nicely. The model can't leak
> what retrieval never returned.
>
> In production that boundary carries Neo4j's fine-grained RBAC: deny by label, deny
> specific properties, deny traversal of relationship types, impersonate the requesting
> user. **Honestly, that's roadmap, not today — we're on Aura Free and RBAC is
> Enterprise.** And it doesn't solve everything: it won't stop a model *inferring* a
> confidential fact from permitted ones, and once evidence is in the context window it
> has left the database's jurisdiction. That becomes a model-hosting decision.

---

## 4. Two demo beats the base kit misses

**The two days that matter.** `01b` adds the FY2020 10-K as a real node with
`public_from = 2021-02-12`. Run the last query in `01b`:

> The annual report is sitting in the graph. It was filed on 12 February — two days after
> the checkpoint — so the query won't return it. A summariser handed "Zillow's annual
> report and the Q4 release" blends them without noticing. This refuses, because the
> filing date is a property of the evidence.

This was also a genuine correction found while preparing the kit — the first draft treated
the 10-K as available at T0. Good material for "challenges encountered."

**An assumption that holds.** Every assumption in the base kit deteriorates, which makes
the graph look like it can only say one thing. `01b` adds A_DEMAND, which stays positive
at both dates on evidence already in the kit:

> Demand isn't the problem and the graph says so — balance goes from +2 to +4. This isn't
> a machine that condemns everything you show it. It discriminates between the assumption
> that broke and the one that held.

It contributes zero risk signal, so it changes no scenario score. Verified above.

---

## Run order

```
01_seed_graph.cypher      → the base graph
01b_additions.cypher      → 10-K node + A_DEMAND
02_demo_queries.cypher    → set :param cutoff, run Q1–Q7
```

Both `01` and `01b` are `MERGE`-based and safe to re-run — which is what you do at 17:15
to prove reproducibility.
