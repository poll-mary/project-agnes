# Demo Script

## 60-second pitch

Companies make high-stakes strategic bets using evidence scattered across filings, reports and management claims. A normal AI answer can summarize those documents, but the answer is difficult to rewind, recompute and audit.

I built a **strategy time machine** in Neo4j. It represents a strategic bet as assumptions, dated evidence, dependency paths, exposures, alternative scenarios and a pre-committed tripwire.

I use Zillow Offers as a historical replay. First, the graph behaves as if today were **10 February 2021**. It cannot see anything published later. Then I move the cutoff to **5 August 2021**. New Q2 evidence becomes eligible, the assumption state recomputes, and the graph exposes why aggressive principal iBuying becomes less defensible relative to capital-light or hybrid alternatives.

The claim is not that the graph predicted Zillow's failure. The claim is that it produced a traceable, decision-relevant change without importing hindsight.

## Three-minute demo

### 0:00–0:30 — Problem

> Strategic decisions are usually reconstructed from documents after the outcome is known. That makes hindsight leakage almost invisible. I wanted to test whether a graph can preserve exactly what was knowable at each decision point.

### 0:30–1:00 — Graph structure

Show the seeded Neo4j graph.

> The center is the bet: scale Zillow Offers. It connects to three scenarios, five critical assumptions, dated evidence and the financial or operational exposures created if those assumptions fail.

### 1:00–1:35 — T0

Set `cutoff = 2021-02-10` and run Query 1 or Query 2.

> At the primary checkpoint, management is confident and Zillow has substantial corporate liquidity. But the Homes segment is still loss-making, inventory risk was already disclosed, and some critical assumptions—especially forward forecasting and downstream throughput—remain insufficiently evidenced. The rational answer is not "Zillow will fail." It is "continue only with guardrails and prove these dependencies before scaling exposure."

### 1:35–2:10 — Unlock Q2

Set `cutoff = 2021-08-05` and rerun the same query.

> I have not changed the ontology or rewritten the graph. I changed only the historical cutoff. Q2 evidence now shows $772 million of Zillow Offers revenue and 2,086 homes sold, but inventory has risen from $491 million to $1.17 billion—approximately 138%—and holding costs have doubled year over year. The graph links that evidence through throughput and liquidity assumptions to inventory and holding-cost exposure.

### 2:10–2:35 — Scenario and tripwire

Run Query 4 and Query 6.

> Because the aggressive scenario owns the inventory, the same weak assumptions create much greater exposure than in the hybrid or capital-light alternatives. A prototype tripwire frozen at T0 now fires and maps the observation to REASSESS / PAUSE-SCALE.

### 2:35–3:00 — Why Neo4j / what next

> The graph's value is persistence and recomputation: the evidence, decision path and source stay connected as time changes. Next I would replace this curated seed with document extraction, run the matched blinded-LLM comparison from the pre-registered thesis, and test mixed successful and failed strategies so the system does not simply learn to be pessimistic.

## Questions judges may ask

### "Isn't this just an LLM with extra steps?"

> That is a testable question, not something I assume away. The full experiment gives a blinded LLM the same evidence. If it matches the graph on dependency reasoning, temporal consistency and scenario recomputation, I do not claim that Neo4j is necessary.

### "Did you choose Zillow because you already knew it failed?"

> Yes, Zillow is an architecture laboratory, not proof of generalization. The temporal cutoff prevents later facts from entering earlier answers. The next phase uses successful and failed matched cases, followed by unseen holdouts.

### "Where did the $1 billion tripwire come from?"

> It is explicitly labeled as a prototype governance threshold for the hackathon, not a validated universal rule. A real deployment would require the decision owner to freeze a defensible threshold before future evidence arrives.

### "Why not predict a probability of failure?"

> The product is not trying to predict winners. It makes assumptions, evidence gaps, exposure and decision conditions explicit so management can change diligence, guardrails, pace or strategic form.

### "What did you actually build today?"

> A persistent point-in-time Neo4j graph, an as-known-at query, transparent assumption ranking, scenario comparison, a traceable multi-hop exposure path and a frozen tripwire evaluation.

