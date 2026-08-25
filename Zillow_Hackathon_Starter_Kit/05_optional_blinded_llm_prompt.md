# Optional Blinded LLM Control

Use only if the Neo4j demo is already stable. This is a single illustrative control, not the full benchmark described in thesis v7.

## System prompt

You are evaluating a high-stakes corporate strategy at a historical decision point. Use only the evidence packet supplied below. You have no web access. Do not use outside knowledge, identify the company, or infer later outcomes. "Insufficient evidence" is valid. Every substantive conclusion must cite an evidence ID.

## User prompt

Company X is considering aggressively scaling Program A, a principal inventory business in which it purchases, renovates and resells residential assets.

Using only evidence public by the stated cutoff:

1. Rank the five most decision-critical assumptions.
2. Classify each as supported, contradicted, uncertain or insufficiently evidenced.
3. Choose one action: CONTINUE / CONTINUE WITH GUARDRAILS / REASSESS / PAUSE / PIVOT.
4. Compare:
   - A: aggressive principal ownership;
   - B: capital-light marketplace;
   - C: hybrid / partner ownership.
5. State which evidence most changes the decision.
6. State what new evidence would change your recommendation.
7. Propose one observable tripwire and mapped action. Do not fabricate a numeric threshold if the packet cannot support one.

Evidence packet:

- E1 (public 19 February 2020): Principal ownership is cash- and inventory-intensive. Slower resale can increase holding costs and pressure profitability.
- E2 (public 10 February 2021): Management says demand is strong, it is investing aggressively, and it is positioned to capitalize in 2021.
- E3 (public 10 February 2021): Program A's segment loss before income taxes was $320.254 million for FY2020 and $66.621 million in Q4.
- E4 (public 10 February 2021): Company X ended 2020 with $3.9 billion in cash and investments.

Historical cutoff: 10 February 2021.

## What to compare against the graph

- Did the LLM explicitly distinguish current demand from forward resale-price forecasting?
- Did it connect acquisition pace to renovation/resale throughput and inventory exposure?
- Did it preserve unknowns instead of filling them?
- Can the answer be recomputed consistently when the Q2 packet is added?
- Is every recommendation traceable to evidence IDs?

