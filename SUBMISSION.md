# Submission draft

## Project Name
**Agnes**

## Project Description
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

We tested it on Zillow's 2021 bet on buying homes, because the evidence is public and
anyone can check our work. Inside a company, Agnes would have the internal numbers too.

Every fact carries the date it became public. Agnes refuses to look at anything later, so
you see what was genuinely knowable at the time.

**The finding.** Zillow had teams, and far better data than this graph. The information was not the
problem.

A decision's reasoning lives in a deck nobody opens again. The assumption that ended the
company — that it could predict what a home would resell for — was never re-examined once.

Agnes keeps the original argument sitting next to the new evidence.

## Team Lead Name and Email
Mary Rojas — mcrw.de@gmail.com

## Which Neo4j technologies or tools did you utilize?
☑ **Neo4j AuraDB**  — everything runs on Aura. Nothing else was used.

*(Document Intelligence, NAMS, Skills and Aura MCP were evaluated but not used —
reasoning under "anything missing" below.)*

## Which coding agents are you working with?
☑ **Claude** (Claude Code)

## What is your graph problem, and how / why did you implement these technologies?

**The same piece of news is good for one part of your decision and bad for another.**

In July 2021 house prices hit an all-time record. For Zillow that was good news — the
houses they already owned were worth more. It was also bad news — their software guessed
what a house would sell for, and it had never seen prices this high, so nobody could know
if it still worked.

A report has to pick one. It says "prices are up, good." A graph can say both, because one
fact can point at two things at once and disagree with itself. Six of our eighteen facts do
exactly that, and Agnes flags it rather than hiding it.

**The second problem is time.** Every fact has a date it became public. If you ask Agnes
what was known in February, it refuses to show you anything from March. That is what makes
it a real rewind instead of hindsight dressed up.

**Why a graph and not a spreadsheet.** Every decision has a different shape — different
things that must be true, different evidence, different consequences. A spreadsheet has
fixed columns, so a new decision means a new spreadsheet. A graph does not care what shape
the decision is. And the useful questions are chains, not lookups: this fact affects this
belief, which affects this risk, which hurts one strategy three times more than another.
Following chains is what a graph is for.

We used Neo4j Aura and Cypher only.

## What was the biggest technical challenge?

Proving to ourselves that the replay contained no hindsight.

It is easy to build something that tells a good story about a company you already know
failed. Making it *verifiably* honest took three passes:

**Supersession.** We first let every market reading accumulate, so three Case-Shiller
releases stacked as three separate pieces of evidence for one phenomenon. Separating
permanent facts from superseded readings needed `public_until` and a `kind` property.

**Tests that can fail.** An off-by-one boundary check — a 10-K filed 12 February must be
invisible on the 11th — and a negative control: one assumption that must stay *supported*
throughout, or we had built a pessimism machine rather than an assessment tool.

**Our own scoring was broken, and the tests caught it.** The strategy comparison summed
risk in absolute terms, so the option with fewest dependencies won regardless of evidence.
Worse, we had scored one strategy on only three of six categories, which flattered it
badly. The fix was to score a ratio — what fraction of what this strategy needs is
currently unproven — with every strategy judged on all six. The graph contradicted us more
than once and was right each time.

## Was there anything missing in the Neo4j service offer?

**"Aura Free" and the signup flow disagree.** The workshop said *create a Neo4j Aura Free
database*. Signup ran a five-step wizard and started a 14-day trial instead. In a timeboxed
hack you cannot tell whether you have landed on the thing you were told to create, and it
leaves an expiry to remember. A clearly labelled Free path from the workshop link would fix it.

**Multi-statement runs hide their final result.** Pasting a 250-line seed script runs every
statement and green-ticks each one, but the closing `RETURN` reported *"Fetch limit hit at
0 records"* and no rows. Ending a seed script with a sanity-check count is a very common
pattern, and it currently reads as failure when everything worked.

**Fine-grained RBAC is out of reach for prototyping.** The capability we most wanted to try
was access control as a retrieval predicate — `WHERE clearance <= $user_level` is the same
shape as our `public_from <= $cutoff`, enforced by the database rather than by a prompt.
Label- and property-level access control is Enterprise, so we could not prototype the
feature most likely to decide adoption. Even a toy-sized version on a free instance would
be valuable.

**On the products we did not use.** Document Intelligence was the one we most wanted and
had no time for. We skipped Agent Memory Service deliberately, and the reasoning may be
useful: our graph already stores decisions and their rationale as first-class nodes, so a
separate memory service raised "which is the source of truth?". The clean split is probably
by audit requirement — the graph holds the decision of record, agent memory holds
interaction state — but we found no guidance on that boundary and had to reason it out.

## GitHub repository
https://github.com/poll-mary/project-agnes
