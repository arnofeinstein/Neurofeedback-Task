function runlog = run_trial_flow(flow, agent)
%RUN_TRIAL_FLOW Execute a trial flow specification with a simulated agent.
%
% Inputs
%   flow  : struct returned by build_trial_flow_spec()
%   agent : struct returned by default_agent()
%
% Output
%   runlog : struct containing execution trace and final outcome

    % -------------------------
    % Validate inputs
    % -------------------------
    if ~isstruct(flow)
        error('run_trial_flow:InvalidFlow', 'flow must be a struct.');
    end

    if ~isfield(flow, 'nominal_states') || ~isfield(flow, 'error_branches')
        error('run_trial_flow:IncompleteFlow', ...
            'flow must contain nominal_states and error_branches.');
    end

    if ~isstruct(agent)
        error('run_trial_flow:InvalidAgent', 'agent must be a struct.');
    end

    % -------------------------
    % Initialize run log
    % -------------------------
    runlog = struct();
    runlog.trial_id = get_field_if_present(flow, 'trial_id', NaN);
    runlog.rule_name = get_field_if_present(flow, 'rule_name', '');
    runlog.sample_dir = get_field_if_present(flow, 'sample_dir', NaN);
    runlog.correct_target_angle = get_field_if_present(flow, 'correct_target_angle', NaN);

    runlog.state_logs = {};
    runlog.final_outcome = 'internal_error';
    runlog.terminal_state = 'ERROR';
    runlog.completed = false;
    runlog.response_angle = NaN;
    runlog.response_result = [];

    % -------------------------
    % Step through nominal states
    % -------------------------
    for k = 1:numel(flow.nominal_states)
        state = flow.nominal_states{k};

        state_log = struct();
        state_log.state_name = state.name;
        state_log.duration_ms = state.duration_ms;
        state_log.fixation_required = state.fixation_required;
        state_log.stimuli = state.stimuli;
        state_log.transition_rule = state.transition_rule;
        state_log.status = 'entered';
        state_log.outcome = '';
        state_log.next_state = '';

        switch state.name
            case 'ACQUIRE_FIX'
                if bernoulli(agent.p_acquire_fix)
                    state_log.status = 'success';
                    state_log.outcome = 'acquired_fixation';
                    state_log.next_state = next_nominal_state(flow, state.name);
                else
                    state_log.status = 'error';
                    state_log.outcome = 'no_fixation';
                    state_log.next_state = 'ERROR';
                    runlog.state_logs{end+1} = state_log;
                    runlog.final_outcome = 'no_fixation';
                    runlog.terminal_state = 'ERROR';
                    return;
                end

            case 'HOLD_FIX'
                if bernoulli(agent.p_hold_fix_initial)
                    state_log.status = 'success';
                    state_log.outcome = 'held_fixation';
                    state_log.next_state = next_nominal_state(flow, state.name);
                else
                    state_log.status = 'error';
                    state_log.outcome = 'break_fixation';
                    state_log.next_state = 'ERROR';
                    runlog.state_logs{end+1} = state_log;
                    runlog.final_outcome = 'break_fixation';
                    runlog.terminal_state = 'ERROR';
                    return;
                end

            case 'SHOW_SAMPLE'
                if bernoulli(agent.p_hold_fix_sample)
                    state_log.status = 'success';
                    state_log.outcome = 'sample_encoded';
                    state_log.next_state = next_nominal_state(flow, state.name);
                else
                    state_log.status = 'error';
                    state_log.outcome = 'break_fixation';
                    state_log.next_state = 'ERROR';
                    runlog.state_logs{end+1} = state_log;
                    runlog.final_outcome = 'break_fixation';
                    runlog.terminal_state = 'ERROR';
                    return;
                end

            case 'DELAY'
                if bernoulli(agent.p_hold_fix_delay)
                    state_log.status = 'success';
                    state_log.outcome = 'delay_completed';
                    state_log.next_state = next_nominal_state(flow, state.name);
                else
                    state_log.status = 'error';
                    state_log.outcome = 'break_fixation';
                    state_log.next_state = 'ERROR';
                    runlog.state_logs{end+1} = state_log;
                    runlog.final_outcome = 'break_fixation';
                    runlog.terminal_state = 'ERROR';
                    return;
                end

            case 'SHOW_DISTRACTOR'
                if bernoulli(agent.p_hold_fix_distractor)
                    state_log.status = 'success';
                    state_log.outcome = 'distractor_presented';
                    state_log.next_state = next_nominal_state(flow, state.name);
                else
                    state_log.status = 'error';
                    state_log.outcome = 'break_fixation';
                    state_log.next_state = 'ERROR';
                    runlog.state_logs{end+1} = state_log;
                    runlog.final_outcome = 'break_fixation';
                    runlog.terminal_state = 'ERROR';
                    return;
                end

            case 'SHOW_RULE'
                state_log.status = 'success';
                state_log.outcome = 'rule_displayed';
                state_log.next_state = next_nominal_state(flow, state.name);

            case 'WAIT_FOR_SACCADE'
                if ~bernoulli(agent.p_make_response)
                    state_log.status = 'error';
                    state_log.outcome = 'no_response';
                    state_log.next_state = 'ERROR';
                    runlog.state_logs{end+1} = state_log;
                    runlog.final_outcome = 'no_response';
                    runlog.terminal_state = 'ERROR';
                    return;
                end

                if bernoulli(agent.p_choose_correct)
                    observed_angle = flow.correct_target_angle;
                else
                    observed_angle = choose_wrong_angle_from_flow(flow);
                end

                trial_for_eval = struct();
                trial_for_eval.correct_target_angle = flow.correct_target_angle;

                response_result = evaluate_choice(trial_for_eval, observed_angle, ...
                    'ToleranceDeg', 22.5);

                runlog.response_angle = observed_angle;
                runlog.response_result = response_result;

                if response_result.is_correct
                    state_log.status = 'success';
                    state_log.outcome = 'correct_target_selected';
                    state_log.next_state = next_nominal_state(flow, state.name);
                else
                    state_log.status = 'error';
                    state_log.outcome = 'wrong_target';
                    state_log.next_state = 'ERROR';
                    runlog.state_logs{end+1} = state_log;
                    runlog.final_outcome = 'wrong_target';
                    runlog.terminal_state = 'ERROR';
                    return;
                end

            case 'HOLD_TARGET'
                if bernoulli(agent.p_hold_target)
                    state_log.status = 'success';
                    state_log.outcome = 'target_hold_success';
                    state_log.next_state = next_nominal_state(flow, state.name);
                else
                    state_log.status = 'error';
                    state_log.outcome = 'broke_target_hold';
                    state_log.next_state = 'ERROR';
                    runlog.state_logs{end+1} = state_log;
                    runlog.final_outcome = 'broke_target_hold';
                    runlog.terminal_state = 'ERROR';
                    return;
                end

            case 'REWARD'
                state_log.status = 'success';
                state_log.outcome = 'reward_delivered';
                state_log.next_state = next_nominal_state(flow, state.name);

            case 'ITI'
                state_log.status = 'success';
                state_log.outcome = 'iti_completed';
                state_log.next_state = next_nominal_state(flow, state.name);

            otherwise
                error('run_trial_flow:UnknownState', ...
                    'Unknown state: %s', state.name);
        end

        runlog.state_logs{end+1} = state_log;
    end

    runlog.final_outcome = 'correct';
    runlog.terminal_state = 'REWARD';
    runlog.completed = true;
end


function next_state = next_nominal_state(flow, current_state_name)
%NEXT_NOMINAL_STATE Return next nominal state from transition map.

    next_state = 'END_TRIAL';

    for k = 1:numel(flow.transitions)
        if strcmp(flow.transitions{k}.state_name, current_state_name)
            next_state = flow.transitions{k}.next_on_success;
            return;
        end
    end
end


function angle = choose_wrong_angle_from_flow(flow)
%CHOOSE_WRONG_ANGLE_FROM_FLOW Pick a wrong response angle from nominal targets.

    if ~isfield(flow, 'nominal_states')
        error('run_trial_flow:MissingNominalStates', ...
            'flow must contain nominal_states.');
    end

    candidate_angles = [0 45 90 135 180 225 270 315];
    wrong_angles = candidate_angles(candidate_angles ~= mod(flow.correct_target_angle, 360));

    if isempty(wrong_angles)
        error('run_trial_flow:NoWrongAngle', ...
            'Could not find a wrong candidate angle.');
    end

    idx = randi(numel(wrong_angles));
    angle = wrong_angles(idx);
end


function tf = bernoulli(p)
%BERNOULLI Return true with probability p.
    tf = rand() < p;
end


function value = get_field_if_present(s, field_name, default_value)
%GET_FIELD_IF_PRESENT Safe field getter.

    if isfield(s, field_name)
        value = s.(field_name);
    else
        value = default_value;
    end
end