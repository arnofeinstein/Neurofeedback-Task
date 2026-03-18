function taskobjects = ml_taskobjects_for_trial(ml_trial)
%ML_TASKOBJECTS_FOR_TRIAL Build placeholder MonkeyLogic TaskObjects.
%
% Input
%   ml_trial : struct returned by ml_prepare_trial()
%
% Output
%   taskobjects : struct containing TaskObject strings, stable indices,
%                 and per-state visibility groups for the timing file

    if ~isstruct(ml_trial)
        error('ml_taskobjects_for_trial:InvalidInput', ...
            'ml_trial must be a struct.');
    end

    required_fields = { ...
        'fix_pos_deg', ...
        'sample_pos_deg', ...
        'distractor_pos_deg', ...
        'response_targets', ...
        'display', ...
        'monkeylogic'};

    for i = 1:numel(required_fields)
        if ~isfield(ml_trial, required_fields{i})
            error('ml_taskobjects_for_trial:MissingField', ...
                'ml_trial is missing required field: %s', required_fields{i});
        end
    end

    n_targets = numel(ml_trial.response_targets);
    n_objects = 3 + n_targets;

    task_object_strings = cell(1, n_objects);
    task_object_names = cell(1, n_objects);

    fixation_index = 1;
    sample_index = 2;
    distractor_index = 3;
    response_target_indices = 4:(3 + n_targets);

    task_object_strings{fixation_index} = sprintf('fix(%.3f,%.3f)', ...
        ml_trial.fix_pos_deg(1), ml_trial.fix_pos_deg(2));
    task_object_names{fixation_index} = 'fixation_point';

    task_object_strings{sample_index} = format_square_object( ...
        ml_trial.display.sample_placeholder.size_deg, ...
        ml_trial.display.sample_placeholder.color_rgb, ...
        1, ...
        ml_trial.sample_pos_deg);
    task_object_names{sample_index} = 'sample_placeholder';

    task_object_strings{distractor_index} = format_square_object( ...
        ml_trial.display.distractor_placeholder.size_deg, ...
        ml_trial.display.distractor_placeholder.color_rgb, ...
        1, ...
        ml_trial.distractor_pos_deg);
    task_object_names{distractor_index} = 'distractor_placeholder';

    response_target_map = struct( ...
        'task_object_index', cell(1, n_targets), ...
        'angle_deg', cell(1, n_targets), ...
        'position_deg', cell(1, n_targets), ...
        'is_correct', cell(1, n_targets), ...
        'name', cell(1, n_targets));

    for k = 1:n_targets
        task_idx = response_target_indices(k);
        response_target = ml_trial.response_targets(k);

        task_object_strings{task_idx} = format_circle_object( ...
            ml_trial.display.response_target.radius_deg, ...
            ml_trial.display.response_target.color_rgb, ...
            ml_trial.display.response_target.fill, ...
            response_target.position_deg);

        task_object_names{task_idx} = response_target.label;

        response_target_map(k).task_object_index = task_idx;
        response_target_map(k).angle_deg = response_target.angle_deg;
        response_target_map(k).position_deg = response_target.position_deg;
        response_target_map(k).is_correct = logical(response_target.is_correct);
        response_target_map(k).name = response_target.label;
    end

    correct_target_map_index = find([response_target_map.is_correct], 1, 'first');
    if isempty(correct_target_map_index)
        error('ml_taskobjects_for_trial:MissingCorrectTarget', ...
            'Could not identify the correct response target.');
    end

    indices = struct();
    indices.fixation_point = fixation_index;
    indices.sample_placeholder = sample_index;
    indices.distractor_placeholder = distractor_index;
    indices.response_targets = response_target_indices;
    indices.correct_target = response_target_map(correct_target_map_index).task_object_index;

    state_taskobjects = struct();
    state_taskobjects.ACQUIRE_FIX = fixation_index;
    state_taskobjects.HOLD_FIX = fixation_index;
    state_taskobjects.SHOW_SAMPLE = [fixation_index, sample_index];
    state_taskobjects.DELAY = fixation_index;
    state_taskobjects.SHOW_DISTRACTOR = [fixation_index, distractor_index];
    state_taskobjects.SHOW_RULE = [fixation_index, response_target_indices];
    state_taskobjects.WAIT_FOR_SACCADE = response_target_indices;
    state_taskobjects.HOLD_TARGET = response_target_indices;
    state_taskobjects.REWARD = [];
    state_taskobjects.ERROR = [];
    state_taskobjects.ITI = [];

    taskobjects = struct();
    taskobjects.task_object_strings = task_object_strings;
    taskobjects.task_object_names = task_object_names;
    taskobjects.indices = indices;
    taskobjects.response_target_map = response_target_map;
    taskobjects.state_taskobjects = state_taskobjects;
    taskobjects.rule_cue = ml_trial.display.rule_cue;
    taskobjects.sample_rotation_deg = ml_trial.display.sample_placeholder.rotation_deg;
    taskobjects.distractor_rotation_deg = ml_trial.display.distractor_placeholder.rotation_deg;
    taskobjects.placeholder_mode = logical(ml_trial.monkeylogic.placeholder_mode);
    taskobjects.timing_file = ml_trial.monkeylogic.timing_file;
end


function out = format_square_object(size_deg, color_rgb, fill_flag, position_deg)
%FORMAT_SQUARE_OBJECT Create a MonkeyLogic square/rectangle TaskObject string.

    validateattributes(size_deg, {'numeric'}, {'vector', 'numel', 2, 'finite'});
    validateattributes(color_rgb, {'numeric'}, {'vector', 'numel', 3, '>=', 0, '<=', 1});
    validateattributes(position_deg, {'numeric'}, {'vector', 'numel', 2, 'finite'});

    out = sprintf('sqr([%.3f %.3f],[%.3f %.3f %.3f],%d,%.3f,%.3f)', ...
        size_deg(1), size_deg(2), ...
        color_rgb(1), color_rgb(2), color_rgb(3), ...
        fill_flag, ...
        position_deg(1), position_deg(2));
end


function out = format_circle_object(radius_deg, color_rgb, fill_flag, position_deg)
%FORMAT_CIRCLE_OBJECT Create a MonkeyLogic circle TaskObject string.

    validateattributes(radius_deg, {'numeric'}, {'scalar', 'positive', 'finite'});
    validateattributes(color_rgb, {'numeric'}, {'vector', 'numel', 3, '>=', 0, '<=', 1});
    validateattributes(position_deg, {'numeric'}, {'vector', 'numel', 2, 'finite'});

    out = sprintf('crc(%.3f,[%.3f %.3f %.3f],%d,%.3f,%.3f)', ...
        radius_deg, ...
        color_rgb(1), color_rgb(2), color_rgb(3), ...
        fill_flag, ...
        position_deg(1), position_deg(2));
end
