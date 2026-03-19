# First Real MonkeyLogic Launch Checklist

This checklist is for the first real launch of the current repository on a Windows machine with MATLAB and NIMH MonkeyLogic v2 installed.

It is intentionally focused on a **smoke test** of the current scaffold:

- `ml/userloop.m`
- `ml/tf_rule_rdk.m`
- placeholder sample / distractor stimuli
- shape-coded rule cue
- response ring
- reward / error flow

## 1. Pre-flight

- Confirm the local repository is up to date.
- In MATLAB, open the project root and make sure the repository is on the path.
- Run:

```text
run_all_tests
demo_ml_skeleton
which userloop
which tf_rule_rdk
which task_main
```

- Confirm `run_all_tests` passes.
- Confirm `demo_ml_skeleton` produces a coherent `ml_trial`.
- Confirm `which` points to the repository files, not another `userloop.m` somewhere else on the MATLAB path.

## 2. Machine requirements

- Windows 10 or later.
- 64-bit MATLAB.
- NIMH MonkeyLogic v2 installed.
- If needed by the machine, Microsoft Visual C++ Redistributable for Visual Studio 2022 (x64).

## 3. MonkeyLogic GUI setup

- Start NIMH MonkeyLogic from MATLAB.
- Use **Load a conditions file** and switch the file dialog filter from `*.txt` to `*.m`.
- Load `ml/userloop.m`.
- Verify MonkeyLogic accepts the file as a userloop-based task.
- Expect the timing-file display to show that the timing file is user-defined through the userloop.
- Set the subject-screen geometry correctly:
  - monitor size
  - viewing distance
  - screen resolution / display routing

## 4. First launch should use simulation mode

Do not start with real eye hardware unless you already know the full software path is stable.

- Open the Pause menu.
- Turn **Simulation mode** on.
- Use the documented simulation mapping:
  - Eye #1 = mouse cursor
  - Start / resume = `Space`
  - Simulation toggle = `S`
  - I/O test = `I`

## 5. If hardware is connected

Before the first task run with real signals:

- Open the I/O test window.
- Verify the assigned eye input changes in real time.
- Verify reward output can be tested safely.
- Calibrate eye position after the screen geometry is correct.
- Do not attempt real fixation control before the calibration looks reasonable.

## 6. First smoke-test run

Goal: complete at least one full trial in simulation mode.

Expected sequence:

1. The task loads without MATLAB or MonkeyLogic errors.
2. A fixation point appears at center.
3. A sample placeholder bar appears left or right of fixation.
4. Delay occurs with fixation maintained.
5. A distractor placeholder bar appears on the opposite side.
6. The rule cue appears with the response scene:
   - `pro` = square
   - `anti` = circle
   - `plus90` = triangle
7. The response ring appears.
8. A saccade to one ring target is detected.
9. The trial ends with reward or error handling.

## 7. Repository-specific checks

- `userloop.m` should return without error on the very first call, even before the first trial starts.
- The first real trial should use `tf_rule_rdk.m`.
- The response ring should contain 8 targets.
- The current placeholder task-object count should be:
  - fixation
  - sample placeholder
  - distractor placeholder
  - 8 response targets
  - total = 11 task objects
- The rule cue should be shape-coded, not color-coded.

## 8. Known integration risk to check immediately

The current repository passes trial metadata from `userloop` into the timing file through `TrialRecord.CurrentConditionInfo` via `setCurrentConditionInfo()`.

This is a deliberate scaffold assumption that must be validated on the real MonkeyLogic installation.

If the first runtime error is about missing condition info:

- inspect `TrialRecord.CurrentConditionInfo`
- inspect whether `setCurrentConditionInfo()` exists on the installed MonkeyLogic object
- if needed, switch the bridge to `TrialRecord.User`, which is the officially documented custom-value path

## 9. If the task crashes, record these facts

- Exact MATLAB / MonkeyLogic error text.
- Whether the crash happens:
  - while loading `userloop`
  - when clicking `Run`
  - at trial start
  - at first scene creation
  - at response detection
  - at reward delivery
- Whether Simulation mode was on or off.
- The output of:

```text
which userloop
which tf_rule_rdk
which task_main
```

- A screenshot of the MonkeyLogic main menu and Pause menu if helpful.

## 10. Minimum success criteria

The first launch is considered successful if all of the following are true:

- The task loads from `ml/userloop.m`.
- MonkeyLogic starts the task without a fatal error.
- One full trial completes in simulation mode.
- The rule cue shape matches the rule identity.
- A correct or incorrect saccade is detected on the response ring.
- Reward or error flow executes without crashing.

## 11. After the first successful launch

Only after the scaffold works in simulation mode should you move on to:

- testing with real eye input
- validating reward output
- validating event-code behavior
- replacing the placeholder sample / distractor with real `RandomDotMotion`

## Official references used for this checklist

- MonkeyLogic download and system requirements:
  https://monkeylogic.nimh.nih.gov/download.html
- Starting MonkeyLogic and simulation mode:
  https://monkeylogic.nimh.nih.gov/docs_GettingStarted.html
- Loading a userloop file and running tasks:
  https://monkeylogic.nimh.nih.gov/docs_RunningTask.html
- Creating tasks with userloop + timing script:
  https://monkeylogic.nimh.nih.gov/docs_CreatingTask.html
- TrialRecord structure:
  https://monkeylogic.nimh.nih.gov/docs_TrialRecordStructure.html
- Runtime functions:
  https://monkeylogic.nimh.nih.gov/docs_RuntimeFunctions.html
- TaskObjects:
  https://monkeylogic.nimh.nih.gov/docs_TaskObjects.html
- Eye calibration:
  https://monkeylogic.nimh.nih.gov/docs_CalibratingEyeJoy.html
- I/O test:
  https://monkeylogic.nimh.nih.gov/docs_IOTest.html
