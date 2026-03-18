function params = default_params()
%DEFAULT_PARAMS Default task parameters for the monkey task.
%
% Returns a struct containing timing, geometry, and condition parameters.
% This file should remain simple and become the single source of truth
% for default settings during early development.

    % =========================
    % Geometry
    % =========================
    params.fix_radius_deg = 3.0;           % fixation window radius
    params.target_radius_deg = 4.0;        % choice target window radius
    params.response_ring_radius_deg = 8.0; % eccentricity of response targets

    % RDK placement relative to fixation center
    params.rdk_eccentricity_deg = 6.0;
    params.sample_size_deg = 5.0;
    params.distractor_size_deg = 5.0;

    % =========================
    % Timing
    % =========================
    params.max_acquire_fix_ms = 2000;
    params.initial_fix_ms = 1000;
    params.sample_dur_ms = 500;
    params.delay_min_ms = 200;
    params.delay_max_ms = 400;
    params.distractor_dur_ms = 500;
    params.max_reaction_time_ms = 700;
    params.target_hold_ms = 150;
    params.reward_ms = 120;
    params.error_timeout_ms = 1000;
    params.iti_ms = 1000;

    % =========================
    % Conditions
    % =========================
    params.sample_dirs = [0 45 90 135 180 225 270 315];
    params.sample_sides = [-1 1];   % -1 = left, +1 = right
    params.rules = [1 2 3];         % 1=pro, 2=anti, 3=plus90

    params.rule_names = {'pro', 'anti', 'plus90'};

    % Distractor is fixed in v1
    params.distractor_dir = 180;

    % Number of repetitions when building a balanced condition table
    params.n_repeats_per_condition = 5;

    % =========================
    % Display conventions
    % =========================
    % Angle convention for response mapping:
    % 0   = right
    % 90  = up
    % 180 = left
    % 270 = down
    params.angle_convention = '0=right,90=up,180=left,270=down';

end