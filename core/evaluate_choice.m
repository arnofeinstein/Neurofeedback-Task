function result = evaluate_choice(trial, observed_angle, varargin)
%EVALUATE_CHOICE Evaluate whether an observed response angle is correct.
%
% Inputs
%   trial          : struct with field .correct_target_angle
%   observed_angle : scalar angle in degrees
%
% Optional name-value pairs
%   'ToleranceDeg' : angular tolerance in degrees, default = 22.5
%
% Output
%   result : struct with fields
%       .is_correct
%       .status
%       .angular_error_deg
%       .correct_target_angle
%       .observed_angle
%       .tolerance_deg

    % -------------------------
    % Parse inputs
    % -------------------------
    p = inputParser;
    addParameter(p, 'ToleranceDeg', 22.5, ...
        @(x) isnumeric(x) && isscalar(x) && isfinite(x) && x > 0);
    parse(p, varargin{:});

    tolerance_deg = p.Results.ToleranceDeg;

    % -------------------------
    % Validate inputs
    % -------------------------
    if ~isstruct(trial) || ~isfield(trial, 'correct_target_angle')
        error('evaluate_choice:InvalidTrial', ...
            'trial must be a struct containing correct_target_angle.');
    end

    validateattributes(trial.correct_target_angle, {'numeric'}, ...
        {'scalar', 'real', 'finite'}, mfilename, 'trial.correct_target_angle');

    validateattributes(observed_angle, {'numeric'}, ...
        {'scalar', 'real', 'finite'}, mfilename, 'observed_angle');

    % -------------------------
    % Wrap angles to [0, 360)
    % -------------------------
    correct_angle = mod(trial.correct_target_angle, 360);
    observed_angle = mod(observed_angle, 360);

    % -------------------------
    % Compute smallest circular angular difference
    % -------------------------
    angular_error_deg = circular_angle_diff_deg(observed_angle, correct_angle);

    % -------------------------
    % Decision
    % -------------------------
    is_correct = angular_error_deg <= tolerance_deg;

    if is_correct
        status = 'correct';
    else
        status = 'wrong_target';
    end

    % -------------------------
    % Output
    % -------------------------
    result = struct();
    result.is_correct = is_correct;
    result.status = status;
    result.angular_error_deg = angular_error_deg;
    result.correct_target_angle = correct_angle;
    result.observed_angle = observed_angle;
    result.tolerance_deg = tolerance_deg;

end


function d = circular_angle_diff_deg(a, b)
%CIRCULAR_ANGLE_DIFF_DEG Smallest absolute difference between two angles.

    d = abs(mod(a - b + 180, 360) - 180);

end