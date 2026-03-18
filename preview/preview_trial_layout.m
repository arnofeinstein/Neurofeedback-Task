function preview_trial_layout(trial, params)
%PREVIEW_TRIAL_LAYOUT Preview one trial layout in a MATLAB figure.
%
% Inputs
%   trial  : one element from build_trial_table()
%   params : struct returned by default_params()
%
% This preview shows:
%   - fixation point at center
%   - sample location (left or right)
%   - distractor location (opposite side in v1)
%   - response ring
%   - 8 possible response targets
%   - correct response target highlighted

    % -------------------------
    % Validate inputs
    % -------------------------
    if ~isstruct(trial)
        error('preview_trial_layout:InvalidTrial', ...
            'trial must be a struct.');
    end

    required_trial_fields = { ...
        'sample_dir', ...
        'sample_side', ...
        'distractor_dir', ...
        'distractor_side', ...
        'rule_id', ...
        'rule_name', ...
        'correct_target_angle'};

    for i = 1:numel(required_trial_fields)
        if ~isfield(trial, required_trial_fields{i})
            error('preview_trial_layout:MissingField', ...
                'trial is missing field: %s', required_trial_fields{i});
        end
    end

    % -------------------------
    % Basic positions
    % -------------------------
    fix_x = 0;
    fix_y = 0;

    sample_x = trial.sample_side * params.rdk_eccentricity_deg;
    sample_y = 0;

    distractor_x = trial.distractor_side * params.rdk_eccentricity_deg;
    distractor_y = 0;

    ring_r = params.response_ring_radius_deg;

    response_angles = params.sample_dirs;

    % Correct target position
    [correct_x, correct_y] = angle_to_xy(trial.correct_target_angle, ring_r);

    % -------------------------
    % Figure
    % -------------------------
    figure('Name', 'Trial Preview');
    clf;
    hold on;
    axis equal;

    lim = max([ ...
        params.response_ring_radius_deg + 3, ...
        params.rdk_eccentricity_deg + params.sample_size_deg]);

    xlim([-lim lim]);
    ylim([-lim lim]);

    xlabel('Horizontal position (deg)');
    ylabel('Vertical position (deg)');

    title(sprintf(['Trial %d | sample=%d deg | side=%d | distractor=%d deg | ' ...
                   'rule=%s | correct=%d deg'], ...
                  get_trial_id_if_present(trial), ...
                  trial.sample_dir, ...
                  trial.sample_side, ...
                  trial.distractor_dir, ...
                  trial.rule_name, ...
                  trial.correct_target_angle));

    % -------------------------
    % Draw response ring
    % -------------------------
    th = linspace(0, 2*pi, 400);
    plot(ring_r * cos(th), ring_r * sin(th), 'k-');

    % -------------------------
    % Draw all possible response targets
    % -------------------------
    for k = 1:numel(response_angles)
        [tx, ty] = angle_to_xy(response_angles(k), ring_r);
        plot(tx, ty, 'ko', 'MarkerSize', 8, 'LineWidth', 1.2);
        text(tx + 0.25, ty + 0.25, sprintf('%d', response_angles(k)), ...
            'FontSize', 9);
    end

    % -------------------------
    % Highlight correct target
    % -------------------------
    plot(correct_x, correct_y, 'o', 'MarkerSize', 14, 'LineWidth', 2);
    text(correct_x + 0.35, correct_y - 0.45, 'correct', 'FontSize', 10);

    % -------------------------
    % Draw fixation point
    % -------------------------
    plot(fix_x, fix_y, 'k+', 'MarkerSize', 12, 'LineWidth', 2);
    viscircles_compat([fix_x, fix_y], params.fix_radius_deg);

    % -------------------------
    % Draw sample placeholder
    % -------------------------
    rectangle( ...
        'Position', [sample_x - params.sample_size_deg/2, ...
                     sample_y - params.sample_size_deg/2, ...
                     params.sample_size_deg, ...
                     params.sample_size_deg], ...
        'Curvature', [1 1], ...
        'LineWidth', 1.5);
    text(sample_x, sample_y, sprintf('S\n%d°', trial.sample_dir), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'FontWeight', 'bold');

    % -------------------------
    % Draw distractor placeholder
    % -------------------------
    rectangle( ...
        'Position', [distractor_x - params.distractor_size_deg/2, ...
                     distractor_y - params.distractor_size_deg/2, ...
                     params.distractor_size_deg, ...
                     params.distractor_size_deg], ...
        'Curvature', [1 1], ...
        'LineStyle', '--', ...
        'LineWidth', 1.5);
    text(distractor_x, distractor_y, sprintf('D\n%d°', trial.distractor_dir), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle');

    % -------------------------
    % Draw rule label
    % -------------------------
    text(0, -lim + 1.2, sprintf('Rule: %s (id=%d)', trial.rule_name, trial.rule_id), ...
        'HorizontalAlignment', 'center', ...
        'FontSize', 11, ...
        'FontWeight', 'bold');

    grid on;
    hold off;

end


function viscircles_compat(center_xy, radius)
%VISCIRCLES_COMPAT Draw a simple circle without Image Processing Toolbox.

    th = linspace(0, 2*pi, 200);
    x = center_xy(1) + radius * cos(th);
    y = center_xy(2) + radius * sin(th);
    plot(x, y, 'k:');
end


function trial_id = get_trial_id_if_present(trial)
%GET_TRIAL_ID_IF_PRESENT Return trial_id if available, otherwise 0.

    if isfield(trial, 'trial_id')
        trial_id = trial.trial_id;
    else
        trial_id = 0;
    end
end