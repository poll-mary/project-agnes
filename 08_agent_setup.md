# Agent layer — Neo4j MCP + Skills

**Timebox: 20 minutes.** If it isn't answering by then, abandon it and demo in Browser.
The core demo never depended on this.

## Why bother

It turns the project from "a graph with queries" into the instructor's Agentic GraphRAG
picture: Query → Graph Retrieval Agent → **SME Cypher Template (`3n`)** → Graph DB →
LLM output → Response. The report is the Response box.

## Setup

Working locally rather than in the workshop Codespace — the project and the coding agent
are already here. The Codespace stays as fallback if an instructor needs to look.

1. `.env` filled in from `.env.example` (Aura URI, user, password).
2. Configure the Neo4j MCP server against that `.env`.
3. `npx skills add neo4j-contrib/neo4j-skills`
4. **Start a fresh agent chat** — MCP servers aren't picked up mid-session.
5. Confirm it works: *"What labels and relationship types are in this database?"*
   Expect six labels and seven relationship types.

## What to ask it

Work up from cheap to impressive:

1. *"What must be true for the aggressive principal scenario to succeed? Use only
   evidence with public_from on or before 2021-02-10."*
2. *"Now answer the same question with a cutoff of 2021-08-05. What changed, and which
   evidence caused each change?"*
3. *"Which tripwires fire at each cutoff? Quote the frozen threshold and the observed
   value."*
4. *"Write a one-page assessment for a board, as of 2021-08-05. Every claim must cite
   the evidence id and its public_from date. Say explicitly where evidence is
   insufficient rather than guessing."*

Number 4 is the deliverable. Save the output.

## Guardrails to put in the agent's instructions

> Only use evidence returned by the query. Never use knowledge about Zillow from your
> training data — in particular anything after the cutoff date. If the returned rows
> don't support a claim, say the evidence is insufficient. Cite evidence ids and
> public_from dates for every claim.

The graph enforces the boundary structurally, but saying it explicitly stops the model
volunteering what it already knows about November 2021 from its own memory.

**Check the output for leakage.** If the report mentions anything after the cutoff, that
came from the model, not from the graph. Worth checking honestly — and worth mentioning
under "challenges" if it happens, because it's exactly the problem the design targets.
