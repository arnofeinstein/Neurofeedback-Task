# Neurofeedback Task Project

MATLAB project for building and validating a macaque behavioral task before full deployment in NIMH MonkeyLogic v2.

## Project goal

The task requires the animal to:

- maintain central fixation
- encode the motion direction of a sample RDK shown left or right of fixation
- ignore a distractor RDK
- apply a visual rule cue shown at fixation
- generate a saccade to the correct location on a response ring
- receive reward if the response is correct

## Current status

The repository now has two layers:

- `core/`: source of truth for task logic, condition generation, simulation, and response evaluation
- `ml/`: thin MonkeyLogic-facing scaffold built on top of the core logic

The project is still primarily developed and tested offline in MATLAB. A first MonkeyLogic timing-file skeleton now exists, but it has not been runtime-validated on this machine because MATLAB + MonkeyLogic are not installed here.

## Task summary

### Trial structure

1. Acquire fixation
2. Hold fixation
3. Show sample
4. Delay
5. Show distractor
6. Show rule
7. Wait for saccade
8. Hold target
9. Reward or error
10. ITI

### Rules

- `pro`: saccade in the same direction as the sample motion
- `anti`: saccade in the opposite direction
- `plus90`: saccade in the sample direction rotated by `+90`

### Angle convention

- `0` = right
- `90` = up
- `180` = left
- `270` = down

## Repository structure

```text
NeurofeedbackTask/
  core/
    default_params.m
    transform_rule.m
    build_trial_table.m
    evaluate_choice.m
    angle_to_xy.m
    default_agent.m
    simulate_trial.m
    simulate_session.m

  ml/
    task_main.m
    userloop.m
    ml_prepare_trial.m
    ml_taskobjects_for_trial.m
    tf_rule_rdk.m
    ml_log_trial_result.m
    build_timing_blueprint.m
    build_error_blueprint.m
    build_trial_flow_spec.m
    run_trial_flow.m
    run_session_flow.m
    build_behavior_schema.m
    sessionlog_to_table.m
    validate_session_table.m
    export_session_csv.m
    final_export_pipeline.m

  preview/
    preview_trial_layout.m

  tests/
    ...

  docs/
    PORTING_TO_MONKEYLOGIC.md
```

## Architecture principles

- Keep task logic in `core/`
- Do not duplicate rule logic between `core/` and `ml/`
- Keep MonkeyLogic as a thin execution layer
- Keep the behavioral schema stable across offline simulation and future MonkeyLogic runs
- Prefer small, testable changes

## What is already implemented

### Core logic

- default task parameters
- rule transform
- balanced trial-table generation
- choice evaluation
- angle-to-position conversion
- offline trial simulation
- offline session simulation

### Flow and export layer

- timing blueprint
- error blueprint
- trial flow spec
- flow runner
- session flow runner
- behavior schema
- session-table validation
- final export pipeline

### First MonkeyLogic scaffold

- `userloop.m` supports the repository's offline mode and a MonkeyLogic-style mode
- `ml_prepare_trial.m` converts one core trial into a MonkeyLogic-facing struct
- `ml_taskobjects_for_trial.m` builds placeholder task objects
- `tf_rule_rdk.m` is the first timing-file skeleton
- `ml_log_trial_result.m` maps timing-file outcomes back to schema-aligned fields

This first MonkeyLogic pass uses placeholders instead of real RDK stimuli:

- fixation point
- sample placeholder
- distractor placeholder
- response ring
- shape-coded rule cue at fixation
  - `pro` = square
  - `anti` = circle
  - `plus90` = triangle

## How to run the project

Open the project root folder in MATLAB.

Run all tests:

```text
run_all_tests
```

Preview example trials:

```text
inspect_trials
demo_preview_trials
```

Run offline simulations:

```text
demo_simulate_trials
demo_simulate_session
```

Preview the MonkeyLogic-facing scaffold:

```text
demo_ml_skeleton
```

Run the final export pipeline:

```text
demo_final_export_pipeline
```

## Core conventions

### Trial representation

Each trial is represented as a struct with fields such as:

- `trial_id`
- `sample_dir`
- `sample_side`
- `distractor_dir`
- `distractor_side`
- `rule_id`
- `rule_name`
- `delay_dur_ms`
- `correct_target_angle`

### Side convention

- `-1` = left
- `+1` = right

### Rule convention

- `1` = pro
- `2` = anti
- `3` = plus90

### Outcome labels

Current simulation and export layers use:

- `correct`
- `no_fixation`
- `break_fixation`
- `no_response`
- `wrong_target`
- `broke_target_hold`
- `internal_error`

## Current assumptions in v1

- The sample appears either left or right of fixation
- The distractor appears on the opposite side of the sample
- The distractor direction is fixed in v1
- The response ring uses the same angular convention as the motion directions
- The response is allowed only after the rule cue appears
- The MonkeyLogic timing file currently uses placeholders, not real RDK stimuli

## MonkeyLogic note

The current `ml/` layer is a clean porting scaffold, not a fully validated MonkeyLogic task yet. Actual runtime validation must be done on a Windows machine with MATLAB and MonkeyLogic v2 installed.

For MonkeyLogic-specific details and remaining porting work, see [docs/PORTING_TO_MONKEYLOGIC.md](/Users/arnofeinstein/Documents/Ibos_Lab/NeurofeedbackTask/docs/PORTING_TO_MONKEYLOGIC.md).

For the first real Windows launch, use [docs/FIRST_MONKEYLOGIC_LAUNCH_CHECKLIST.md](/Users/arnofeinstein/Documents/Ibos_Lab/NeurofeedbackTask/docs/FIRST_MONKEYLOGIC_LAUNCH_CHECKLIST.md).
