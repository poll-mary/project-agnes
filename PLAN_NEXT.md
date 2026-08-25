# Agnes — what to build next
### Written 25 Aug 2026, after the Zillow instance ran end to end

## Where we are, measured not asserted

**Ontology: domain-neutral.** `StrategicBet · Scenario · Assumption · Evidence ·
Exposure · Tripwire · WorldIndicator · MissingEvidence`. Nothing in the schema mentions
real estate. The expensive design decision is already right.

**Query layer: Zillow-shaped.** Of seven queries, **zero are portable**: four hardcode the
checkpoint dates, three hardcode node ids (`A_THROUGHPUT` ×9, `T_INVENTORY_1B` ×4,
`BET_SCALE` ×3).

**Known defects:** the scenario score is risk-only and can only ever prefer inaction;
~30 evidence weights are hand-assigned; readings do not decay; assessments are not
persisted; coverage gaps do not qualify the output.

**The honest sentence until proven otherwise:** *the ontology is domain-agnostic; today's
implementation is a Zillow instance; portability is the next validation test.*

---

## Phase 1 · Remove the defect *(half a day)*

### 1.1 Delete the scenario score
The flaw is not the number, it is having a number. Risk-only scoring always prefers
inaction; adding an upside term means inventing figures for captured economics. Both bad.

Replace with an **exposure profile**: under aggressive your exposure concentrates in
inventory value and holding cost; under capital-light in growth forgone. Different shapes
of risk, not a ranking. **Agnes shows structure, she does not pick.**

Removes: the defect in `11_limitations.md` §7, and the false "capital-light wins" result.

### 1.2 Name supersession events
`27_monitor_timeline.cypher` sweeps `public_from` only, so when a reading is superseded the
external count changes with no explanation. "Evidence expired" is a distinct event from
"evidence arrived" and a monitor must say which.

---

## Phase 2 · Make the application layer portable *(one day)*

**This is the precondition for testing agnosticism. Do not skip to Phase 3.**

### 2.1 Parameterise checkpoints
Dates become `$t0` / `$t1`, or better, come from `(:StrategicBet)-[:HAS_CHECKPOINT]->(:Checkpoint {on})`.
Fixes four queries.

### 2.2 Remove hardcoded node ids
- `13_demo_tripwire` — iterate all `Tripwire` nodes, not `T_INVENTORY_1B`
- `27_monitor_timeline` — parameterise the assumption, not `A_FORECAST`
- `10_acceptance_tests` — the tests check *mechanism* (date boundary, unknown ≠ negative),
  so they should be case-agnostic; the Zillow ids in them are incidental

### 2.3 Derive roles instead of naming instances
`S_AGGRESSIVE` becomes "the scenario with the highest capital intensity". Structural
description rather than an identifier.

**Definition of done:** every query runs against any bet without editing its text.

---

## Phase 3 · Prove portability with a second case *(one to two days)*

**Which case is Mary's call. It is not decided, and this plan does not assume one.**

Whatever the case, the test is the same: **load a second decision without changing the
schema, the scoring engine, the monitoring logic or the output format.** Only these may
change: objective, options, assumptions, evidence sources, exposures, thresholds, actions.

**If new node types are needed, or calculations rewritten, or bespoke queries written —
the prototype is Zillow-shaped and Phase 2 failed.**

What this test does and does not show:
- **Does show:** whether the machinery accepts a different domain. Portability.
- **Does NOT show:** whether the output is useful. That needs a user acting on it, which
  is a separate test with a separate design.

A second case with **no known outcome** is more informative for portability than another
historical replay, because it cannot be unconsciously fitted. But it also cannot validate
the assessment — only that the structure holds.

## Phase 4 · Attack the input bottleneck *(the real viability risk)*

Today's measured input cost: **one strategist, one working day, six assumptions and eight
evidence items, for one bet.** If that is the true cost per decision, Agnes does not scale.

### 4.1 Source assumptions from the company's own risk factors
10-K Item 1A is a dated, company-authored list of what could go wrong. Zillow themselves
wrote that they might misprice homes, might not resell quickly enough, might carry holding
costs. Deriving assumptions from there:
- collapses the input cost
- destroys the hindsight objection, because the company pre-registered its own risks
- gives every assumption a source instead of an author

**Open problem:** this works where a company publishes a risk register. Where none exists,
the input-cost problem is unsolved and simply relabelled. No answer yet.

### 4.2 Weight by rule, not by judgement
~30 hand-picked weights today. Replace with **weight = source authority × specificity**.
An audited filing about the company outranks a press release about the market. One rule,
no per-edge invention.

---

## Phase 5 · Model quality *(incremental)*

- **Decay readings, not facts.** A market reading six months old is weaker evidence about
  current conditions; a quarterly result is permanent. The `kind` distinction already
  exists — apply decay to `READING` only.
- **Persist assessments.** Designed, never built. Enables *"when did we stop believing
  this, and what changed our mind?"* — the actual "living" in living decision graph.
- **Coverage qualifies the output.** Agnes knows five of six indicators are unloaded. That
  should qualify every conclusion — *"throughput challenged, on 2 of 6 indicators"* — not
  sit in a separate report.
- **Flag tensions as first-class.** When one fact both supports and challenges (the
  record-hot market), that is the graph-native insight and it is currently buried in a
  query. It should be an output: *"this evidence cuts both ways."*

---

## Phase 6 · Validation *(only after 1–4)*

Matched cases: at least one bet that **succeeded**, scored blind. Until then we cannot
distinguish "detects deterioration" from "pessimistic about everything". Today's
within-case controls (demand stays positive; the world rehabilitated unit economics from
−1 to 0) are real but weak.

---

## Sequencing

```
1 (defect)  →  2 (portable)  →  3 (second case: the real test)
                                    ↓
                              4 (input cost)  →  6 (validation)
                                    ↓
                              5 (quality, anytime)
```

Phase 3 is the decision point. If a second decision loads cleanly, Agnes is a product with
two instances. If it does not, Agnes is Zillow analysis and we learn that cheaply.

---

## Found while building the confidence layer *(25 Aug, late)*

**Agnes is most confident about the assumption that mattered least.**

Observed directly from `32_confidence.cypher`:
- `A_DEMAND` — 6 sources, company + world, 0 blind spots → **GOOD**
- `A_FORECAST` — 3 sources, **all external**, company silent → **MODERATE, one side only**

Demand was never the problem. Forecasting is what Barton named as the reason the business
closed. Agnes's confidence is inversely related to what mattered.

**Cause:** confidence is computed from source count and breadth alone. It has no notion of
how much the assumption *matters*. A well-covered irrelevance and a thinly-covered decider
currently look similar.

**Fix:** weight confidence by criticality — an assumption that decides the outcome should
complain louder when thinly sourced. Requires a criticality measure that is not the broken
risk-only score, so it depends on the scoring fix.

**Why this matters beyond Zillow:** a decision tool that is confident about the wrong
things is worse than one that admits uncertainty everywhere. This is a real defect class,
and it only became visible after building the confidence layer and looking at the output.

---

## The agentic layer — Mary's formulation

> 1. You ask Agnes an unstructured strategic question.
> 2. Agnes determines what it needs to know.
> 3. It interviews you for internal context.
> 4. It researches the relevant external context.
> 5. It constructs and evaluates the decision.
> 6. It remembers the reasoning and monitors whether it continues to hold.

**Why this is not a feature but the viability answer.** Today measured the input cost: one
strategist, one working day, six assumptions and eight evidence items, for one bet. Step 3
is what collapses that. Without it, Agnes requires the strategic work it exists to help
perform.

**Two layers, complementary:**
- What exists now = the **state** layer. Given a structured decision, evaluate it over time
  with dated provenance.
- What is described above = the **construction and maintenance** layer.

**The graph is what makes the agent trustworthy.** An agent that proposes assumptions is
doing strategy. The graph records *who proposed what and when* — `declared_by` and
`declared_on` already exist on every assumption — so the influence is auditable instead of
invisible.

### Risks, in order of severity

**1 · Anchoring.** If Agnes proposes and the human approves, Agnes decided. Design
constraints: elicit the user's assumptions *before* revealing Agnes's; generate competing
framings rather than one authoritative framing; require at least one assumption Agnes did
not propose.

**2 · Step 4 is the hardest engineering problem in the product.** Automatic external
research means getting publication vintages right. It took a full afternoon to do this
correctly for *two* Case-Shiller releases, and the thesis's forbidden list exists precisely
because this is easy to get wrong. An agent that mis-dates `public_from` destroys the
point-in-time property, which everything else rests on.

**3 · Step 6 needs persistence.** Assessments stored and diffed, with each change attributed
to the evidence that caused it. Designed, not built.

### What already supports it

| Built today | Feeds |
|---|---|
| `MissingEvidence` nodes | what the agent should ask about |
| `WorldIndicator` panel with `NOT_LOADED` | what the agent should go and find |
| Decision-health KPIs | which gap the agent should close first |
| `declared_by` / `declared_on` on assumptions | the anchoring audit trail |
| `origin` INTERNAL/EXTERNAL | which of steps 3 and 4 supplied each fact |
