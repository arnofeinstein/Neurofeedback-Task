function varargout = userloop(arg1, arg2)
%USERLOOP Support offline inspection and MonkeyLogic v2 condition delivery.
%
% Offline mode
%   [ml_trial, trial_index] = userloop(runtime, trial_index)
%
% MonkeyLogic mode
%   [C, timingfile, userdefined_trialholder] = userloop(MLConfig, TrialRecord)

    if nargin ~= 2
        error('userloop:InvalidInputCount', ...
            'userloop expects exactly two input arguments.');
    end

    if is_offline_runtime_request(arg1, arg2)
        [ml_trial, trial_index] = prepare_offline_trial(arg1, arg2);
        varargout = {ml_trial, trial_index};
        return;
    end

    [task_object_strings, timingfile, userdefined_trialholder] = ...
        prepare_monkeylogic_trial(arg1, arg2);
    varargout = {task_object_strings, timingfile, userdefined_trialholder};
end


function tf = is_offline_runtime_request(runtime, trial_index)
%IS_OFFLINE_RUNTIME_REQUEST Detect the repository's offline userloop call shape.

    tf = isstruct(runtime) && ...
        isfield(runtime, 'trials') && ...
        isfield(runtime, 'params') && ...
        isnumeric(trial_index) && ...
        isscalar(trial_index);
end


function [ml_trial, trial_index] = prepare_offline_trial(runtime, trial_index)
%PREPARE_OFFLINE_TRIAL Existing non-MonkeyLogic helper path.

    if ~isstruct(runtime)
        error('userloop:InvalidRuntime', 'runtime must be a struct.');
    end

    if ~isfield(runtime, 'trials') || ~isfield(runtime, 'params')
        error('userloop:IncompleteRuntime', ...
            'runtime must contain trials and params.');
    end

    validateattributes(trial_index, {'numeric'}, ...
        {'scalar', 'integer', '>=', 1, '<=', numel(runtime.trials)}, ...
        mfilename, 'trial_index');

    core_trial = runtime.trials(trial_index);
    ml_trial = ml_prepare_trial(core_trial, runtime.params);
end


function [task_object_strings, timingfile, userdefined_trialholder] = ...
        prepare_monkeylogic_trial(~, TrialRecord)
%PREPARE_MONKEYLOGIC_TRIAL Prepare task objects and condition info for ML.

    persistent runtime initialized_timing_file

    timingfile = 'tf_rule_rdk.m';
    userdefined_trialholder = '';
    task_object_strings = {};

    if isempty(runtime)
        runtime = task_main();
    end

    if isempty(initialized_timing_file)
        initialized_timing_file = true;
        return;
    end

    if ~isstruct(TrialRecord) && ~isobject(TrialRecord)
        error('userloop:InvalidTrialRecord', ...
            'MonkeyLogic mode expects TrialRecord as a struct or object.');
    end

    trial_index = current_trial_index_from_record(TrialRecord);

    if trial_index > runtime.n_trials
        set_trial_record_field(TrialRecord, 'NextBlock', -1);
        return;
    end

    core_trial = runtime.trials(trial_index);
    ml_trial = ml_prepare_trial(core_trial, runtime.params);
    taskobjects = ml_taskobjects_for_trial(ml_trial);

    condition_info = struct();
    condition_info.ml_trial = ml_trial;
    condition_info.taskobjects = strip_taskobject_strings(taskobjects);
    condition_info.placeholder_mode = logical(taskobjects.placeholder_mode);

    set_current_condition_info(TrialRecord, condition_info);
    set_trial_record_field(TrialRecord, 'NextCondition', trial_index);

    task_object_strings = taskobjects.task_object_strings;
    timingfile = taskobjects.timing_file;
end


function trial_index = current_trial_index_from_record(TrialRecord)
%CURRENT_TRIAL_INDEX_FROM_RECORD Translate ML trial counters to table index.

    if isstruct(TrialRecord)
        if isfield(TrialRecord, 'CurrentTrialNumber')
            trial_index = TrialRecord.CurrentTrialNumber + 1;
        else
            trial_index = 1;
        end
        return;
    end

    if isprop(TrialRecord, 'CurrentTrialNumber')
        trial_index = TrialRecord.CurrentTrialNumber + 1;
    else
        trial_index = 1;
    end
end


function taskobjects = strip_taskobject_strings(taskobjects_in)
%STRIP_TASKOBJECT_STRINGS Keep condition info compact and ML-facing.

    taskobjects = rmfield(taskobjects_in, 'task_object_strings');
end


function set_current_condition_info(TrialRecord, condition_info)
%SET_CURRENT_CONDITION_INFO Pass condition metadata into MonkeyLogic runtime.

    if isobject(TrialRecord) && ismethod(TrialRecord, 'setCurrentConditionInfo')
        TrialRecord.setCurrentConditionInfo(condition_info);
    elseif isstruct(TrialRecord)
        % No-op outside MonkeyLogic. Struct inputs are used only for tests/scaffolds.
    end
end


function set_trial_record_field(TrialRecord, field_name, field_value)
%SET_TRIAL_RECORD_FIELD Best-effort write for runtime-managed TrialRecord fields.

    if isobject(TrialRecord)
        if isprop(TrialRecord, field_name)
            TrialRecord.(field_name) = field_value;
        end
    elseif isstruct(TrialRecord)
        % No-op outside MonkeyLogic. Struct inputs are used only for tests/scaffolds.
    end
end
