function agent = default_agent()
%DEFAULT_AGENT Default simulated agent behavior.
%
% This agent is used only for offline logical simulation.

    % Probability of successfully acquiring fixation
    agent.p_acquire_fix = 0.98;

    % Probability of maintaining fixation during each fixation-locked state
    agent.p_hold_fix_initial = 0.97;
    agent.p_hold_fix_sample = 0.97;
    agent.p_hold_fix_delay = 0.98;
    agent.p_hold_fix_distractor = 0.96;

    % Probability of making any response after rule cue
    agent.p_make_response = 0.95;

    % Probability that the chosen response is the correct one
    agent.p_choose_correct = 0.85;

    % Probability of holding the chosen target long enough
    agent.p_hold_target = 0.95;

    % If the agent chooses the wrong target, pick one random wrong angle
    % among the possible response angles.
end