# Porting To MonkeyLogic v2

## Current architecture

- `core/` remains the source of truth for task logic, condition generation, and choice evaluation.
- `ml/` is now the thin MonkeyLogic-facing layer.
- `ml_prepare_trial()` converts one core trial into a MonkeyLogic-facing trial struct.
- `ml_taskobjects_for_trial()` converts one prepared trial into placeholder TaskObject definitions and stable object indices.
- `userloop()` now supports two modes:
  - offline repository mode: `[ml_trial, trial_index] = userloop(runtime, trial_index)`
  - MonkeyLogic mode: `[C, timingfile, userdefined_trialholder] = userloop(MLConfig, TrialRecord)`
- `tf_rule_rdk.m` is the first real timing-file scaffold.
- `ml_log_trial_result()` normalizes timing-file outcomes back to the existing behavioral schema fields.

## What is implemented in this first MonkeyLogic pass

- Central fixation acquisition and fixation-hold states.
- Placeholder sample stimulus on the sample side.
- Variable delay with fixation hold.
- Placeholder distractor stimulus on the opposite side.
- Placeholder rule cue at fixation.
- Response ring as multiple saccade targets.
- Choice evaluation via the existing `evaluate_choice()` core logic.
- Reward vs error flow with behavioral logging fields prepared for `bhv_variable()`.

## Placeholder stimulus strategy

- Sample placeholder: oriented bar TaskObject at the sample location.
- Distractor placeholder: oriented bar TaskObject at the distractor location.
- Rule cue: shape-coded placeholder at fixation.
  - `pro` = carré
  - `anti` = rond
  - `plus90` = triangle
- Response ring: circular TaskObjects placed from the existing response-angle geometry.

This keeps the future path open for replacing the sample and distractor placeholders with `RandomDotMotion` adapters later without moving any rule logic out of `core/`.

## Repository-facing behavior

- The export schema is unchanged.
- Core condition generation is unchanged.
- `ml_log_trial_result()` returns canonical schema fields plus a small set of MonkeyLogic debug fields (`reaction_time_ms`, target indices, `trialerror_code`, and flat `bhv_variables`).

## MonkeyLogic runtime assumptions

- `userloop()` initializes task runtime once and returns `tf_rule_rdk.m` as the timing file.
- `userloop()` stores per-trial metadata in `TrialRecord.CurrentConditionInfo` via `setCurrentConditionInfo()` when the MonkeyLogic runtime provides that method.
- `tf_rule_rdk.m` expects MonkeyLogic v2 scene functions and adapters such as `create_scene`, `run_scene`, `SingleTarget`, `MultiTarget`, `WaitThenHold`, `trialerror`, `bhv_variable`, and `goodmonkey`.
- `SHOW_RULE` remains an instantaneous logical state in this first pass; the visible rule cue appears with the response scene.
- The rule cue now uses MonkeyLogic graphic adapters instead of a rule-cue TaskObject so the three rules can have distinct shapes.

## What still remains for real Windows + MonkeyLogic execution

- Validate exact runtime behavior inside MonkeyLogic on Windows with the installed v2 runtime.
- Confirm the `userloop()`/`TrialRecord.setCurrentConditionInfo()` bridge against the local MonkeyLogic version.
- Replace placeholder sample and distractor bars with `RandomDotMotion` adapters.
- Decide whether the final rule cue should stay color-coded or switch to a different visual encoding.
- Tune scene timing, event codes, reward delivery options, and dashboard/debug text on the real rig.
- Add rig-specific hotkeys, eye calibration handling, and hardware I/O configuration.
- Build a real MonkeyLogic session-log importer if downstream export should read `.bhv2` output directly instead of the current offline simulation path.

## Validation status

- Repository-level unit tests cover the new `ml_prepare_trial()` fields, the task-object bundle, the result logger, and the MonkeyLogic-style `userloop()` bridge.
- Actual execution of `tf_rule_rdk.m` is not validated in this repository because MonkeyLogic and MATLAB are not available on the current machine.

For the first real runtime test on Windows, use [FIRST_MONKEYLOGIC_LAUNCH_CHECKLIST.md](/Users/arnofeinstein/Documents/Ibos_Lab/NeurofeedbackTask/docs/FIRST_MONKEYLOGIC_LAUNCH_CHECKLIST.md).
