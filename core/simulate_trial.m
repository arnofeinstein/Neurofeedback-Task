function sim = simulate_trial(trial, params, agent)
%SIMULATE_TRIAL Simulate one trial with a simple probabilistic agent.
%
% Inputs
%   trial  : one trial struct from build_trial_table()
%   params : task parameters struct
%   agent  : simulated agent struct
%
% Output
%   sim : struct containing state progression and outcome

    % -------------------------
    % Validate inputs
    % -------------------------
    if ~isstruct(trial)
        error('simulate_trial:InvalidTrial', 'trial must be a struct.');
    end
    if ~isstruct(params)
        error('simulate_trial:InvalidParams', 'params must be a struct.');
    end
    if ~isstruct(agent)
        error('simulate_trial:InvalidAgent', 'agent must be a struct.');
    end

    % -------------------------
    % Initialize output
    % -------------------------
    sim = struct();
    sim.trial_id = get_field_if_exists(trial, 'trial_id', NaN);
    sim.sample_dir = trial.sample_dir;
    sim.sample_side = trial.sample_side;
    sim.rule_id = trial.rule_id;
    sim.rule_name = trial.rule_name;
    sim.correct_target_angle = trial.correct_target_angle;

    sim.state_history = {};
    sim.outcome = 'internal_error';
    sim.response_angle = NaN;
    sim.response_result = [];
    sim.completed = false;

    % -------------------------
    % START_TRIAL
    % -------------------------
    sim.state_history{end+1} = 'START_TRIAL';

    % -------------------------
    % ACQUIRE_FIX
    % -------------------------
    sim.state_history{end+1} = 'ACQUIRE_FIX';
    if ~bernoulli(agent.p_acquire_fix)
        sim.outcome = 'no_fixation';
        return;
    end

    % -------------------------
    % HOLD_FIX
    % -------------------------
    sim.state_history{end+1} = 'HOLD_FIX';
    if ~bernoulli(agent.p_hold_fix_initial)
        sim.outcome = 'break_fixation';
        return;
    end

    % -------------------------
    % SHOW_SAMPLE
    % -------------------------
    sim.state_history{end+1} = 'SHOW_SAMPLE';
    if ~bernoulli(agent.p_hold_fix_sample)
        sim.outcome = 'break_fixation';
        return;
    end

    % -------------------------
    % DELAY
    % -------------------------
    sim.state_history{end+1} = 'DELAY';
    if ~bernoulli(agent.p_hold_fix_delay)
        sim.outcome = 'break_fixation';
        return;
    end

    % -------------------------
    % SHOW_DISTRACTOR
    % -------------------------
    sim.state_history{end+1} = 'SHOW_DISTRACTOR';
    if ~bernoulli(agent.p_hold_fix_distractor)
        sim.outcome = 'break_fixation';
        return;
    end

    % -------------------------
    % SHOW_RULE
    % -------------------------
    sim.state_history{end+1} = 'SHOW_RULE';

    % -------------------------
    % WAIT_FOR_SACCADE
    % -------------------------
    sim.state_history{end+1} = 'WAIT_FOR_SACCADE';

    if ~bernoulli(agent.p_make_response)
        sim.outcome = 'no_response';
        return;
    end

    if bernoulli(agent.p_choose_correct)
        observed_angle = trial.correct_target_angle;
    else
        observed_angle = choose_wrong_angle(params.sample_dirs, trial.correct_target_angle);
    end

    sim.response_angle = observed_angle;
    sim.response_result = evaluate_choice(trial, observed_angle, 'ToleranceDeg', 22.5);

    if ~sim.response_result.is_correct
        sim.outcome = 'wrong_target';
        return;
    end

    % -------------------------
    % HOLD_TARGET
    % -------------------------
    sim.state_history{end+1} = 'HOLD_TARGET';
    if ~bernoulli(agent.p_hold_target)
        sim.outcome = 'broke_target_hold';
        return;
    end

    % -------------------------
    % REWARD
    % -------------------------
    sim.state_history{end+1} = 'REWARD';
    sim.outcome = 'correct';
    sim.completed = true;
end


function tf = bernoulli(p)
%BERNOULLI Return true with probability p.
    tf = rand() < p;
end


function angle = choose_wrong_angle(candidate_angles, correct_angle)
%CHOOSE_WRONG_ANGLE Pick a random wrong angle from candidate list.

    wrong_angles = candidate_angles(candidate_angles ~= mod(correct_angle, 360));

    if isempty(wrong_angles)
        error('simulate_trial:NoWrongAngle', ...
            'Could not find any wrong angle candidate.');
    end

    idx = randi(numel(wrong_angles));
    angle = wrong_angles(idx);
end


function value = get_field_if_exists(s, field_name, default_value)
%GET_FIELD_IF_EXISTS Safe field access helper.
    if isfield(s, field_name)
        value = s.(field_name);
    else
        value = default_value;
    end
end