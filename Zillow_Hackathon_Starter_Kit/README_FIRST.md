# Zillow Strategy Time Machine — Hackathon Starter Kit

## The idea in one sentence

A point-in-time evidence graph that shows what a strategic bet depends on, what dated evidence supports or contradicts those assumptions, and how the recommended action changes when new evidence becomes knowable.

## The only thing you need to prove tomorrow

At **10 February 2021**, the graph can use only evidence public by that date. At **5 August 2021**, new Q2 evidence becomes eligible. The same graph recomputes and exposes why aggressive principal iBuying became less defensible.

Do not claim that the graph "predicted Zillow." Claim that it produced a traceable, decision-relevant change using only point-in-time evidence.

## Your minimum successful demo

1. Paste `01_seed_graph.cypher` into Neo4j and run it.
2. Run Query 1 from `02_demo_queries.cypher` with cutoff `2021-02-10`.
3. Change the cutoff to `2021-08-05` and run it again.
4. Run the scenario comparison and tripwire queries.
5. Explain one visible path:

   `Q2 inventory evidence -> throughput/liquidity assumption -> inventory exposure -> aggressive scenario -> REASSESS`

That is already a valid hackathon project.

## Tomorrow's build order

| Time | Goal | Definition of done |
|---|---|---|
| 10:00–11:30 | Check in and learn the supplied tools | You know where to create/open the Aura database and where to run Cypher. |
| 11:30–11:45 | Team/open mic | Say the 20-second version below. Ask for a teammate only if they clearly reduce technical risk. |
| 11:45–12:15 | Create the database | Aura connection works; Neo4j query screen is open. |
| 12:15–12:35 | Seed the graph | `01_seed_graph.cypher` completes and the count query returns nodes/relationships. |
| 12:35–13:15 | Make the time-machine queries work | Both cutoff dates produce visibly different evidence. |
| 13:15–14:00 | Scenario + tripwire | Aggressive/capital-light/hybrid comparison runs; Q2 tripwire fires. |
| 15:00–16:00 | Optional explanation layer | Add an LLM or tiny interface only if the Neo4j demo is already stable. |
| 16:00–16:30 | Freeze the demo | Stop adding features. Save every query and take screenshots. |
| 16:30–17:15 | Rehearse | You can deliver the 3-minute script without improvising the architecture. |
| 17:15–17:30 | Buffer | Reopen everything once from scratch. |

## What to tell the instructor

> I am building a point-in-time strategic evidence graph. The same graph must answer as if today were 10 February 2021 and then recompute after Q2 2021 evidence becomes public. I need help only with getting the seed Cypher into Aura, returning a path filtered by `public_from`, and—if time permits—grounding an LLM explanation in that path.

## 20-second team-formation explanation

> Companies make high-stakes bets from fragmented evidence. I am using Zillow Offers as a historical replay: a Neo4j graph connects the bet to assumptions, dated evidence, exposures, alternative scenarios and a frozen tripwire. Then I change the historical cutoff and show why the decision changes without importing hindsight.

## Scope control

### Green version

- Neo4j graph works.
- Two cutoff dates work.
- Scenario comparison works.
- Tripwire works.
- Optional LLM explains returned paths.

### Yellow version — still a successful hack

- Neo4j Browser is the entire interface.
- Seed graph + two cutoff queries + one exposure path.
- No custom app and no LLM integration.

### Red version — emergency fallback

- Seed graph displays in Neo4j.
- One cutoff query works.
- You explain the second cutoff from the prepared query and clearly state what blocked you and what you learned.

The event explicitly accepts working experiments and useful learnings. Do not sacrifice a demonstrable graph for a broken interface.

## Files

- `01_seed_graph.cypher` — copy-paste graph creation.
- `02_demo_queries.cypher` — the exact demo sequence.
- `03_demo_script.md` — 60-second pitch and 3-minute demo script.
- `04_evidence_manifest.csv` — point-in-time source register.
- `05_optional_blinded_llm_prompt.md` — only if the core demo is already stable.
- `06_optional_coding_agent_prompt.md` — only if you decide to add a tiny interface.
- `Zillow_Hackathon_Survival_Guide.docx` — printable/readable version of the operating plan.

## Tonight / morning checklist

- Laptop and charger.
- GitHub login works.
- Coding agent login works.
- This starter kit is downloaded locally.
- Thesis v7 is available for questions, but do not use it as tomorrow's build checklist.
- Open the event page and map before leaving.
- Arrive with the pitch, not with the obligation to know Neo4j already.
