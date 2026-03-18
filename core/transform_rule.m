function correct_target_angle = transform_rule(sample_dir, rule_id)
%TRANSFORM_RULE Compute the correct response angle from sample direction.
%
% Inputs
%   sample_dir : direction of the sample in degrees
%   rule_id    : 1 = pro
%                2 = anti
%                3 = plus90
%
% Output
%   correct_target_angle : response angle in degrees, wrapped to [0, 360)

    validateattributes(sample_dir, {'numeric'}, ...
        {'scalar', 'real', 'finite'}, mfilename, 'sample_dir');

    validateattributes(rule_id, {'numeric'}, ...
        {'scalar', 'integer', '>=', 1, '<=', 3}, mfilename, 'rule_id');

    switch rule_id
        case 1   % pro
            correct_target_angle = mod(sample_dir, 360);

        case 2   % anti
            correct_target_angle = mod(sample_dir + 180, 360);

        case 3   % plus90
            correct_target_angle = mod(sample_dir + 90, 360);

        otherwise
            error('transform_rule:UnknownRule', ...
                'Unknown rule_id: %d', rule_id);
    end
end