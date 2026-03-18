function demo_evaluate_choice()
%DEMO_EVALUATE_CHOICE Quick demo of response evaluation.

    root_dir = fileparts(mfilename('fullpath'));
    addpath(fullfile(root_dir, 'core'));

    trial = struct();
    trial.correct_target_angle = 180;

    test_angles = [180 170 200 225 10];

    fprintf('Correct target angle = %d deg\n\n', trial.correct_target_angle);

    for k = 1:numel(test_angles)
        result = evaluate_choice(trial, test_angles(k), 'ToleranceDeg', 22.5);

        fprintf('Observed = %3d deg | error = %5.1f deg | status = %s\n', ...
            result.observed_angle, ...
            result.angular_error_deg, ...
            result.status);
    end
end