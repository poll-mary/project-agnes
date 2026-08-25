# Agnes

A company making a big decision normally needs a team to hold it together — strategy,
finance, operations, market research — each watching one piece, none of them holding the
whole thing, and nobody re-reading the original reasoning six months later.

**Agnes does that job.** It holds what the decision depends on, watches every input that
bears on it, and says when something has changed. The same information those people would
have. Continuously. Without forgetting.

It is not trying to see more than a company can see. It is doing what a company's own
people would do if they never stopped looking.

Built at the Neo4j Mini Agentic Hack, Berlin, 25 August 2026.

---

## The test case

We tested it on Zillow's 2021 bet on buying homes because the evidence is public, so
anyone can check our work. Inside a company, Agnes would have the internal numbers too.

Every piece of evidence carries the date it became public, and Agnes refuses to look at
anything published later. Move the date and it recomputes from nothing — so you see what
could genuinely have been known at the time, not what you know now.

**The finding.** Zillow had teams and far better data than this graph. The information was not the
problem.

The problem is that a decision's reasoning lives in a slide deck nobody opens again. The
assumption that ended the company — that it could predict what a home would resell for —
was never re-examined in public once. It took a competitor's filing in May and record
price data in July to challenge it, and neither landed on anyone's desk next to the
original argument.

**Agnes is the thing that keeps them next to each other.** Not a smarter analyst — the
same work a department already does, done continuously and without forgetting.

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
