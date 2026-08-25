# Agnes

Companies make high-stakes strategic bets using fragmented documents and disconnected
evidence. I built a living evidence graph that lets decision-makers rewind to what was
knowable at a specific moment, see which assumptions their strategy depends on, and
understand how new evidence should change the decision.

It does three things, continuously:

- **Validate** — what has to be true for this to work, and does the evidence support it,
  or has nobody actually checked?
- **Simulate** — run the alternatives in parallel against the same evidence. Change the
  variables and see which version the evidence supports.
- **Monitor** — re-score every time something new is published, and say when the case has
  changed enough to act.

That is the work a strategy department does. Agnes does it without forgetting what was
originally assumed.

Built at the Neo4j Mini Agentic Hack, Berlin, 25 August 2026.

---

## The test case

We tested it on Zillow's 2021 bet on buying homes, because the evidence is public and
anyone can check our work. Inside a company, Agnes would have the internal numbers too.

Every fact carries the date it became public. Agnes refuses to look at anything later, so
you see what was genuinely knowable at the time.

**The finding.** Zillow had teams, and far better data than this graph. The information was not the
problem.

A decision's reasoning lives in a deck nobody opens again. The assumption that ended the
company — that it could predict what a home would resell for — was never re-examined once.

**Agnes keeps the original argument sitting next to the new evidence.**

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
