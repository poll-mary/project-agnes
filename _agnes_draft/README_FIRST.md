# Project Agnes — read this first

**A living decision graph: what must be true for a strategic bet to succeed, which
alternative paths exist, and when reality stops supporting the one you chose.**

Test case: Zillow Offers, replayed at two point-in-time checkpoints.

---

## The one idea

Every `Evidence` node carries `public_from`. Every query filters on it. Move the date
and the assessment recomputes — **the graph is never rebuilt**. The later evidence sits
in the database the whole time and is simply not eligible.

That makes it a retrieval boundary: an agent grounded in this graph *cannot* reach
evidence from after the cutoff. Not because we asked it not to — because the rows
don't come back.

---

## Files

| File | What it is |
|---|---|
| `01_seed_graph.cypher` | Paste-and-run. Idempotent (`MERGE`) — safe to re-run. Ends in a sanity check. |
| `02_demo_queries.cypher` | The SME Cypher Templates. Parameterised versions first, literal-date versions at the bottom. |
| `03_demo_script.md` | Pitch, beat sheet, verified numbers, prepared answers. **The stage document.** |
| `04_evidence_manifest.csv` | Point-in-time source register. The audit trail. |
| `05_optional_blinded_llm_prompt.md` | The naked-LLM contrast. Do it early, it's cheap. |
| `06_agent_setup.md` | Neo4j MCP + Skills, and what to ask the agent. |

---

## Order of work

| Slot | Goal | Done when |
|---|---|---|
| — | Aura Free database live, credentials into `.env` | Connection works |
| — | Paste `01` | Sanity check returns `SEED OK` (24 nodes, 51 rels) |
| — | T1 + T2 | Both dates return different eligible evidence |
| — | T3 + T4 | Scores computed; tripwire fires at Q2 only |
| 14:00–15:00 | Break | — |
| 15:00–15:20 | Neo4j MCP + Skills, fresh agent chat | Agent sees the schema |
| 15:20–16:00 | Agent answers in natural language → report | Grounded in returned rows |
| **16:00** | **FREEZE. No new features.** | Screenshots + saved queries |
| 16:30–17:15 | Rehearse | Three minutes, no improvisation |
| 17:15–17:30 | Buffer | Wipe, re-seed from scratch, confirm clean |

---

## Scope gates

**GREEN** — graph + both checkpoints + scenarios + tripwire + agent-generated report.

**YELLOW** — Neo4j Browser only: seed, two cutoffs, one exposure path. *This is already
a successful hack.* The idea is fully demonstrable without an agent.

**RED** — seeded graph, one working cutoff, and an honest account of what blocked us.
Still demoable. "Challenges encountered" is a judging criterion, not an admission.

**At 16:00, stop adding things.** A stable Browser demo beats a broken clever one.

---

## Break-glass

| Symptom | Move |
|---|---|
| Seed script errors | Run the numbered blocks in `01` one at a time. Don't edit the ontology under pressure. |
| Query returns nothing | Run the sanity check at the bottom of `01` first. |
| Results render as a table | Switch the result visualization to Graph. |
| `:param` unsupported | Use the literal-date variants at the bottom of `02`. |
| Scores look wrong | Check `01` block 6 loaded — 18 `REQUIRES` edges. |
| MCP won't connect | Timebox 20 min, then abandon it. The core demo never depended on MCP. |
| Under 60 minutes left | Freeze on YELLOW. Screenshot everything. Rehearse. |

---

## Secrets

`.env` is gitignored and stays that way. Aura password and the OpenAI key go there and
nowhere else. `.env.example` documents the variable names and is safe to commit.

Repo is **private** for now. Whether it goes public after the demo is a decision to make
at the freeze, not while moving fast.

---

## Final operating rule

You don't need to hold the whole product in your head. At each moment, build the
smallest next thing that makes the final demo more real.
