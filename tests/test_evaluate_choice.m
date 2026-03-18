function test_evaluate_choice()
%TEST_EVALUATE_CHOICE Unit tests for evaluate_choice.

    trial = struct();
    trial.correct_target_angle = 90;

    % Exact match
    r = evaluate_choice(trial, 90);
    assert(r.is_correct == true);
    assert(strcmp(r.status, 'correct'));
    assert(r.angular_error_deg == 0);

    % Small error within tolerance
    r = evaluate_choice(trial, 100, 'ToleranceDeg', 15);
    assert(r.is_correct == true);
    assert(strcmp(r.status, 'correct'));
    assert(r.angular_error_deg == 10);

    % Outside tolerance
    r = evaluate_choice(trial, 120, 'ToleranceDeg', 15);
    assert(r.is_correct == false);
    assert(strcmp(r.status, 'wrong_target'));
    assert(r.angular_error_deg == 30);

    % Circular wrap around
    trial.correct_target_angle = 350;
    r = evaluate_choice(trial, 10, 'ToleranceDeg', 25);
    assert(r.is_correct == true);
    assert(strcmp(r.status, 'correct'));
    assert(r.angular_error_deg == 20);

    % Another wrap case, incorrect
    r = evaluate_choice(trial, 40, 'ToleranceDeg', 20);
    assert(r.is_correct == false);
    assert(strcmp(r.status, 'wrong_target'));
    assert(r.angular_error_deg == 50);

    disp('test_evaluate_choice passed');
end