# EVAL-OPS operating framework

## 1. Establish
Define the capability to measure, the user decision, risk level, success metric and exclusions. Convert vague goals such as “good report” into observable outcomes.

**Gate:** a reviewer can state what is being measured and why in one sentence.

## 2. Version
Record task ID, prompt version, source-file versions, environment, permitted tools, model/configuration, run date and evaluator ID. Separate public practice cases from hidden holdout cases.

**Gate:** another evaluator can recreate the same starting state.

## 3. Author
Create the user prompt, supporting files, constraints, expected deliverable, reference solution, accepted alternatives, edge cases and known traps. Remove hidden assumptions.

**Gate:** two qualified reviewers interpret the task the same way.

## 4. Lock
Freeze rubric dimensions, weights, evidence rules, partial-credit bands, critical-failure overrides and grader types before running the model. Prefer deterministic checks for exact facts and file state; use expert or model judges for judgment, calibrated against humans.

**Gate:** every scored criterion is observable from permitted evidence.

## 5. Observe
Run multiple trials under the same conditions. Preserve final outputs, created files, tool calls, timestamps, failures and relevant traces. Grade the outcome first; review the path when efficiency, policy or tool use matters.

**Gate:** evidence is complete enough to reproduce each rating.

## 6. Produce
Score each criterion independently, assign error category and severity, record confidence, quote or point to evidence, state business impact and prescribe a testable correction. Distinguish model error, task ambiguity, grader defect and environment failure.

**Gate:** the rationale is concise, specific and auditable.

## 7. Standardize
Calibrate reviewers on gold examples, measure agreement, adjudicate material disagreements, sample production work, monitor drift and convert recurring failures into prompt, data, rubric or product changes. Add every confirmed fix to a regression suite.

**Gate:** changes are versioned, approved and retested without degrading previous capabilities.

## Evaluation record formula

**Observation -> Evidence -> Criterion -> Severity -> Impact -> Correction**

Example: “The summary reports 5,009 transaction lines, but the validated model distinguishes 5,009 orders from 9,994 lines. This fails KPI grounding (high severity), can mislead operational planning, and should be corrected by mapping every headline KPI to the named model measure and grain.”
