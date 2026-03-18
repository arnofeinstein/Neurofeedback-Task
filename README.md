# Neurofeedback Task Project

MATLAB project for developing and validating a monkey behavioral task before porting it to MonkeyLogic.

## Project goal

This project implements the core logic of a macaque task in which the animal must:

- maintain central fixation
- encode the motion direction of a sample RDK
- ignore a distractor RDK
- apply a visual rule
- generate a saccade to the correct location on a response ring

The current stage is **offline development in pure MATLAB**, without MonkeyLogic runtime.

---

## Task summary

### Trial structure

1. **Acquire fixation**
2. **Hold fixation**
3. **Show sample RDK**
4. **Delay**
5. **Show distractor RDK**
6. **Show rule cue**
7. **Wait for saccade**
8. **Hold target**
9. **Reward or error**
10. **ITI**

### Rules

- **pro**: saccade in the same direction as the sample motion
- **anti**: saccade in the opposite direction
- **plus90**: saccade in the sample direction rotated by +90 degrees

### Angle convention

- `0` = right
- `90` = up
- `180` = left
- `270` = down

---

## Current project structure

```text
monkey_task/
  core/
    default_params.m            # Central place for default task parameters.
    transform_rule.m            # Converts sample direction and rule into the correct response angle.
    build_trial_table.m         # Generates a balanced randomized list of trials.
    evaluate_choice.m           # Evaluates whether an observed response angle is correct.
    angle_to_xy.m               # Converts an angle on the response ring into x/y coordinates.
    default_agent.m             # Defines a simple simulated agent for offline testing.
    simulate_trial.m            # Simulates the logic of a single trial.
    simulate_session.m          # Simulates a full session and computes summary statistics.

  tests/                        # Unit tests for each major core component.
    test_transform_rule.m 
    test_build_trial_table.m
    test_evaluate_choice.m
    test_simulate_trial.m
    test_simulate_session.m

  preview/ # Simple MATLAB visualization tools to inspect the geometry of the task.
    preview_trial_layout.m

  ml/

  run_all_tests.m
  inspect_trials.m
  demo_evaluate_choice.m
  demo_preview_trials.m
  demo_simulate_trials.m
  demo_simulate_session.m
  README.md
```

---

### How to run the project

Open the project root folder in MATLAB.

Run all tests
```text
run_all_tests
```

Inspect example trials
```text
inspect_trials
```

Preview layouts
```text
demo_preview_trials
```

Simulate a few trials
```text
demo_simulate_trials
```

Simulate a full session
```text
demo_simulate_session
```

---

### Core conventions

#### Trial representation

Each trial is represented as a struct containing fields such as:
- trial_id
- sample_dir
- sample_side
- distractor_dir
- distractor_side
- rule_id
- rule_name
- delay_dur_ms
- correct_target_angle

#### Side convention

- -1 = left
- +1 = right

#### Rule convention

- 1 = pro
- 2 = anti
- 3 = plus90

#### Outcome labels

Current simulation uses the following outcomes:
- correct
- no_fixation
- break_fixation
- no_response
- wrong_target
- broke_target_hold
- internal_error

---

### Current assumptions in v1

- The sample RDK appears either left or right of fixation.
- The distractor direction is fixed.
- The distractor appears on the opposite side of the sample.
- The response ring uses the same angular convention as the motion directions.
- The response becomes allowed only after the rule cue appears.

These assumptions may be updated later if the task design changes.

---