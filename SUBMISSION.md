# Submission draft

## Project Name
**Agnes**

## Project Description
Agnes is a decision graph. It records what has to be true for a strategic bet to succeed,
scores each condition against dated evidence, and re-scores as new evidence is published —
so you can always see what was actually knowable at any point in time, and when the case
for the bet started to fail.

We tested it on a real, resolved decision: Zillow's 2021 bet on buying homes directly.
Every piece of evidence carries the date it became public, and the graph refuses to return
anything published later. Moving the date recomputes the whole assessment from scratch.

The finding: Zillow's own filings never once addressed the assumption its CEO later blamed
for shutting the business down. External evidence challenged that assumption from January
onward. Zillow's first public retreat came in October.

## Team Lead Name and Email
Mary Rojas — mcrw.de@gmail.com

## Which Neo4j technologies or tools did you utilize?
☑ **Neo4j AuraDB**  — everything runs on Aura. Nothing else was used.

*(Document Intelligence, NAMS, Skills and Aura MCP were evaluated but not used —
reasoning under "anything missing" below.)*

## Which coding agents are you working with?
☑ **Claude** (Claude Code)

## What is your graph problem, and how / why did you implement these technologies?

**The problem is that one fact points in several directions at once, and its meaning
depends on when you ask.**

A single external fact — "US house prices hit an all-time record", published 27 July 2021 —
*supports* the belief that homes will resell easily, and simultaneously *undermines* the
belief that a pricing model calibrated on history can still be trusted. A summary has to
pick one reading. A graph holds both, as two edges with opposite polarity from the same
node, and can report the tension as a finding.

Layered on that is time. Every evidence node carries `public_from`, and market readings
also carry `public_until` — because a monthly index reading is superseded by the next one,
while a quarterly filing is a permanent fact. Eligibility is
`public_from <= cutoff AND (public_until IS NULL OR public_until > cutoff)`. That single
predicate is what makes a historical replay honest, and it is a natural graph traversal
filter rather than a schema change.

**Why AuraDB specifically:** the ontology is six domain-neutral labels — StrategicBet,
Scenario, Assumption, Evidence, Exposure, Tripwire. Nothing in it mentions real estate.
The same shape holds for any consequential decision, and a graph lets each decision carry
its own structure without redefining a schema. Traversal also does the work a relational
model would need joins for: evidence → assumption → exposure → strategy, with the same
failure priced differently depending on how the bet was built.

**What we built on it:** 29 nodes, 50 relationships, 18 dated evidence items (8 from
Zillow's SEC filings, 10 from the surrounding world — S&P/Case-Shiller, NAR, Federal
Reserve Beige Book, Freddie Mac, a competitor's results, Redfin), plus a tripwire frozen
at the February checkpoint, and explicit MissingEvidence nodes recording what the graph
cannot see and what would settle it.

## What was the biggest technical challenge?

**Proving to ourselves that the replay contained no hindsight.**

It is easy to build something that tells a good story about a company you already know
failed. Making it verifiably honest was the hard part, and it took three passes:

1. **Supersession.** We initially let every market reading accumulate, so three
   Case-Shiller releases stacked as three separate pieces of evidence for one phenomenon.
   Distinguishing permanent facts from superseded readings required `public_until` and a
   `kind` property.
2. **A falsifiable test suite.** We wrote acceptance tests that could fail — including an
   off-by-one boundary check (a 10-K filed 12 February must be invisible on the 11th) and
   a negative control (one assumption that must stay *supported* throughout, or we have
   built a pessimism machine rather than an assessment tool).
3. **Our own scoring model was broken, and the tests caught it.** The strategy comparison
   summed risk in absolute terms, so the option with fewest dependencies won regardless of
   evidence. Worse, we had scored one strategy on only three of six categories, which
   flattered it badly. Fixing it meant scoring a *ratio* — what fraction of what this
   strategy needs is currently unproven — with every strategy judged on all six.

The graph contradicted us more than once and was right each time.

## Was there anything missing in the Neo4j service offer?

**1 · "Aura Free" and the signup flow disagree.** The workshop material says *create a
Neo4j Aura Free database*. The signup ran a five-step wizard (goal / role / use case) and
started a 14-day trial. In a timeboxed hack you cannot tell whether you have landed on the
thing you were told to create, and it introduces an expiry to remember. A clearly labelled
"Free instance" path from the workshop link would remove the doubt.

**2 · Multi-statement runs hide their final result.** Pasting a ~250-line seed script runs
every statement and shows a green tick for each — but the closing `RETURN` reported
*"Fetch limit hit at 0 records"* and no rows. Ending a seed script with a sanity-check
count is a very common pattern, and it currently reads as failure when everything
succeeded.

**3 · Fine-grained RBAC is out of reach for prototyping.** The capability we most wanted to
try was access control as a retrieval predicate — `WHERE clearance <= $user_level` is the
same shape as our `public_from <= $cutoff`, enforced by the database rather than by a
prompt. Label- and property-level access control is Enterprise, so we could not prototype
the feature most likely to decide adoption. Even a toy-sized version on a free instance
would be valuable.

**4 · On the products we did not use.** Document Intelligence was the one we most wanted
and had no time for — automated ingestion is the top row of our prototype-vs-product gap.
We deliberately skipped Agent Memory Service, and the reason may be useful feedback: our
graph already stores decisions and their rationale as first-class nodes, so a separate
memory service raised "which is the source of truth?". On reflection the clean split is by
audit requirement — the graph holds the decision of record, agent memory holds interaction
state — but we could not find guidance on that boundary and had to reason it out.

## GitHub repository
*(To fill in — the repo exists locally with full commit history but has not been pushed.)*
