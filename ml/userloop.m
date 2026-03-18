function [ml_trial, trial_index] = userloop(runtime, trial_index)
%USERLOOP Prepare one trial for the future MonkeyLogic execution layer.
%
% Inputs
%   runtime     : struct returned by task_main()
%   trial_index : index of the requested trial
%
% Outputs
%   ml_trial    : MonkeyLogic-facing trial struct
%   trial_index : echoed validated index

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