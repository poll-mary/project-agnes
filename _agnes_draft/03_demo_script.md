# Demo script — Project Agnes

**Three minutes. Four queries live. Everything else held for Q&A.**

---

## The 60-second pitch

> Companies make expensive bets using scattered and changing evidence.
>
> An LLM can generate an answer; our graph preserves the structure behind the decision
> and updates it over time.
>
> Zillow is our first controlled test of whether that structure creates real decision value.

Then the frame:

> We built a living decision graph. It models what must be true for a strategic bet to
> succeed, compares alternative forms of that bet, and detects when reality stops
> supporting the one you chose.
>
> The hackathon question is much smaller than the product: **can a graph make the
> reasoning behind one decision visible, recomputable and responsive to new evidence?**

---

## Beat sheet

| Time | Show | Say |
|---|---|---|
| 0:00–0:25 | Nothing — just talk | The three sentences. |
| 0:25–0:50 | **T5** in Graph view | "Bet, scenarios, assumptions, evidence, exposures. Every evidence node carries the date it became public." |
| 0:50–1:30 | **T1** at `2021-02-10` | "Judged only on what was public that day. Liquidity is supported — $3.9bn. Unit economics already contradicted — a $320m segment loss. And two assumptions the graph refuses to score: **we don't know**." |
| 1:30–2:10 | **T2** (both dates) | "I changed one date. Not the graph, not the ontology, not the prompt. Throughput goes from unknown to contradicted. Holding costs the same. **Demand doesn't move** — that side was genuinely fine." |
| 2:10–2:35 | **T4** tripwire | "This $1bn threshold was frozen on 10 February. The graph doesn't store whether it fired — that's computed. At February: no eligible evidence. At August: fired, $1.169bn." |
| 2:35–3:00 | **T3** scores | "Aggressive goes from +0.22 to **−0.28**. It crosses zero. Capital-light barely moves, because almost none of the new evidence touches it." Then the close. |

**The close:**

> We are not claiming the graph predicted Zillow. We are claiming that using only
> then-available evidence, it produced a traceable, decision-relevant change — and
> showed exactly which assumption caused it.

---

## The numbers (verified — say these with confidence)

**Assumption states**

| Assumption | 10 Feb 2021 | 5 Aug 2021 |
|---|---|---|
| Forecast accuracy | INSUFFICIENTLY_EVIDENCED | INSUFFICIENTLY_EVIDENCED |
| Resale throughput | INSUFFICIENTLY_EVIDENCED | **CONTRADICTED** |
| Liquidity absorption | SUPPORTED | **CHALLENGED** |
| Unit economics | CONTRADICTED | CONTRADICTED |
| Holding costs | CHALLENGED | **CONTRADICTED** |
| Consumer demand | SUPPORTED | SUPPORTED — *unchanged* |

**Scenario scores**

| Scenario | 10 Feb | 5 Aug | Action at 5 Aug |
|---|---|---|---|
| Aggressive principal | **+0.217** | **−0.283** | REASSESS / PAUSE-SCALE |
| Hybrid / partner | +0.257 | −0.149 | REASSESS / PAUSE-SCALE |
| Capital-light referral | +0.488 | +0.312 | CONTINUE |

Critical broken assumptions for aggressive: **1 → 3**. Tripwires: **0 fired → 2 fired**.

---

## The five judging criteria — answers ready

**Problem.** Strategic bets are decided on evidence scattered across filings, releases
and management claims. You can summarise that with an LLM, but you cannot rewind it,
recompute it, or audit it. When the bet goes wrong nobody can reconstruct what was
actually knowable at the time.

**Data / documents used.** Eight dated evidence items from Zillow's SEC filings and
earnings releases — FY2019 10-K, Q4/FY2020 earnings release, FY2020 10-K, Q2 2021 10-Q.
Every one carries a `public_from` date and a source. Full register in
`04_evidence_manifest.csv`.

**Neo4j / GraphRAG application.** This is Agentic GraphRAG with the retrieval layer
date-gated. Our date-filtered Cypher templates are **SME Cypher Templates** — box `3n`
on your architecture slide — called as tools by a coding agent over Neo4j MCP. The
ontology is six domain-neutral labels: StrategicBet, Scenario, Assumption, Evidence,
Exposure, Tripwire.

**Challenges.** Two worth naming. First, the FY2020 10-K was filed on 12 February, two
days after our checkpoint — our own first draft wrongly treated it as available at T0.
The date discipline caught our mistake. Second, deciding what the tripwire should *store*:
we deliberately store no link between evidence and tripwire, because pre-computing
whether it fired would bake in the outcome.

**Future development.** Automated ingestion via Document Intelligence; continuous
monitoring instead of two discrete checkpoints; AI-generated scenarios. And the next
scope we care most about — **permissions as a retrieval predicate**.

---

## Prototype vs product

| Today | Full product |
|---|---|
| One company: Zillow | Any company or strategic bet |
| One checkpoint moved once | Continuous real-time assessment |
| Manually curated evidence | Automatic document and data ingestion |
| Small predefined graph model | Flexible graph generated per decision |
| Three scenarios | User-created and AI-generated scenarios |
| A few demonstration questions | Complete decision interface |
| One tripwire set | Continuous monitoring and notification |
| Sources linked manually | Automated provenance, permissions, auditing |

---

## Hostile questions — prepared answers

**"Isn't this just hindsight? You knew how it ended."**

> We knew the ending, and we used that to *pick the case* — you can only validate a
> decision system on outcomes that already resolved. What we didn't do is let it into
> the assessment. Three things stop that. The tripwire threshold is frozen on 10
> February and fires on August data. Two assumptions are still marked *insufficiently
> evidenced* at both dates — a hindsight-fitted model never admits ignorance. And at
> February the graph says **continue**, not abandon. It only turns in August, and only
> on the assumptions the August evidence actually touches.

**"Why not just ask an LLM?"**

> Ask any model about Zillow in February 2021 and it already knows the company wound
> the business down that November. You can't get an uncontaminated answer, and telling
> it to pretend doesn't reliably work. Our graph is a retrieval boundary — the
> post-cutoff evidence is physically present in the database and simply not returned.
> The model can't leak what it was never handed. Beyond that: an LLM re-derives a
> different assumption set every run. The graph commits to one and updates it.

**"How do you know capital-light would have been better?"**

> We don't, and the system doesn't claim to. It cannot know how an unchosen strategy
> *would* have performed. It updates how that alternative would *currently be expected*
> to perform. Look at the numbers — capital-light doesn't improve. It barely moves.
> Almost none of the new evidence bears on its assumptions, because it doesn't hold
> inventory. That's a statement about exposure, not about outcome.

**"Did you tune the weights to get that result?"**

> The weights come from capital intensity, which is a property of each scenario's
> structure and knowable in February. And note there's **no ranking crossover** —
> capital-light scores highest on both dates. If we'd been fitting the numbers, a
> dramatic overtake is exactly what we'd have manufactured. The signal is the sign
> change on aggressive, which is a much harder thing to fake.

**"Why not use Text2Cypher for everything?"**

> Two reasons, and the second is the interesting one. Accuracy — an expert-authored
> template does the same thing every time. And containment: an LLM writing its own
> Cypher can reach anything the connection can reach. SME templates fix the query
> *shape*, so the agent supplies parameters, not structure. In a product handling
> confidential strategy material, that difference is the security model.

**"Does this generalise beyond Zillow?"**

> The ontology has no Zillow-specific labels — StrategicBet, Scenario, Assumption,
> Evidence, Exposure, Tripwire. Entering a market, changing a supplier, an acquisition,
> a large platform investment: same shape. Zillow is the test case because it's
> documented, dated and resolved, which is what you need to check the machinery works.

**"How do you stop it leaking confidential information?"**

> Today's date gate is the same mechanism. `WHERE public_from <= $cutoff` and
> `WHERE clearance <= $user_level` are one line of Cypher with a different predicate —
> and it's enforced by the database, not by asking the model nicely. In production that
> carries Neo4j's fine-grained RBAC: deny by label, deny properties, deny traversal,
> impersonate the requesting user. Honestly though — that's roadmap, not today. We're
> on Aura Free and RBAC is Enterprise. And it doesn't solve everything: it won't stop a
> model *inferring* a confidential fact from permitted ones, and once evidence is in the
> context window it's left the database's jurisdiction.

---

## If something breaks mid-demo

- **A query returns nothing** — run the sanity check at the bottom of `01`. Then say
  what you expected and move to the next beat. Don't debug on stage.
- **Results show as a table when you wanted the graph** — result view switcher, pick Graph.
- **`:param` fails** — use the literal-date variants at the bottom of `02`.
- **MCP won't answer** — drop to Browser and narrate. The core demo never depended on it.
- **Total failure** — you still have this file, the manifest and screenshots. The
  reasoning is the contribution, and you can walk them through it on the slides.
