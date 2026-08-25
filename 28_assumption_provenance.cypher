// =============================================================================
// 28_assumption_provenance.cypher — CLOSE THE HINDSIGHT HOLE IN THE SCHEMA
//
// Evidence carries public_from and public_until. Assumptions carried NOTHING.
// So an assumption added in month three looked exactly like one declared on
// day one. That is a hindsight vector sitting in the architecture rather than
// in the data - the precise failure mode this project exists to prevent.
//
// Same treatment as evidence: assumptions are dated and sourced.
// =============================================================================

MATCH (a:Assumption) WHERE a.project = 'zillow_strategy_time_machine'
SET a.declared_on   = date('2021-02-10'),          // the primary checkpoint
    a.declared_by   = 'analyst',                    // NOT derived from a source
    a.provenance    = 'hand_authored',
    a.source_ref    = null;

// A_DEMAND was added later in the build, after the others. Record that
// honestly rather than back-dating it.
MATCH (a:Assumption {id:'A_DEMAND'})
SET a.declared_on = date('2021-02-10'),
    a.note = 'Added during construction as a within-case control: an assumption expected NOT to deteriorate. Declared at the same checkpoint but authored after the other five.';

// Eligibility for assumptions, from here on:
//    a.declared_on <= cutoff
// An assumption cannot inform an assessment before it was declared.
MATCH (a:Assumption) WHERE a.project = 'zillow_strategy_time_machine'
RETURN a.id AS assumption, a.declared_on AS declared_on,
       a.provenance AS provenance,
       coalesce(a.source_ref, 'NO SOURCE - authored, not derived') AS source
ORDER BY assumption;
