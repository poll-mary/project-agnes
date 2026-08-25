# Agnes

**A decision graph.** It records what has to be true for a strategic bet to succeed, scores
each condition against dated evidence, and re-scores as new evidence is published — so you
can see what was actually knowable at any point in time, and when the case for the bet
started to fail.

Built at the Neo4j Mini Agentic Hack, Berlin, 25 August 2026.

---

## The test case

Zillow's 2021 bet on buying homes directly. Every piece of evidence carries the date it
became public; the graph refuses to return anything published later. Move the date and the
whole assessment recomputes from nothing.

**The finding:** Zillow's own filings never once addressed the assumption its CEO later
blamed for shutting the business down. Evidence from outside the company challenged that
assumption from January onward. Zillow's first public retreat came in October.

## The demo

Open **`agnes-deck.html`** in a browser. Nine slides, arrow keys to move. Slide 7 is a
draggable timeline — Agnes above the line, Zillow below.

## The graph

Six domain-neutral labels: `StrategicBet · Scenario · Assumption · Evidence · Exposure ·
Tripwire`. Nothing in the ontology mentions real estate.

| | |
|---|---|
| `01_seed_graph.cypher` | base graph |
| `01b` `01c` | extra evidence, and corrections to three overclaimed edges |
| `24` `25` | external world context; one unified evidence model with supersession |
| `26` `27` | the assessment, and the monitoring timeline |
| `37` `38` `40` | strategy exposure, sensitivity, and the same-six-questions fix |
| `10_acceptance_tests_ONE_QUERY.cypher` | eight checks that can fail |

Run `01` → `01b` → `01c` → `24` → `25` → `40`, then anything else.

## Honesty machinery

Every evidence node carries `public_from`; market readings also carry `public_until`,
because a monthly index reading is superseded by the next one while a quarterly filing is
permanent. Eligibility is always:

```cypher
public_from <= cutoff AND (public_until IS NULL OR public_until > cutoff)
```

`MissingEvidence` nodes record what the graph *cannot* see and what would settle it.
`11_limitations.md` records what this does not do — including two modelling flaws our own
tests caught, and how they were fixed.

## Setup

Copy `.env.example` to `.env` and fill in your Aura connection details. `.env` is
gitignored and must stay that way.
