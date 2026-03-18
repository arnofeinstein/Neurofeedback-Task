function test_build_trial_table()
%TEST_BUILD_TRIAL_TABLE Unit tests for build_trial_table.

    params = default_params();
    trials = build_trial_table(params);

    n_expected = numel(params.sample_dirs) * ...
                 numel(params.sample_sides) * ...
                 numel(params.rules) * ...
                 params.n_repeats_per_condition;

    assert(numel(trials) == n_expected, 'Wrong number of trials.');

    for k = 1:numel(trials)
        assert(ismember(trials(k).sample_dir, params.sample_dirs));
        assert(ismember(trials(k).sample_side, params.sample_sides));
        assert(trials(k).distractor_dir == params.distractor_dir);
        assert(trials(k).distractor_side == -trials(k).sample_side);
        assert(ismember(trials(k).rule_id, params.rules));
        assert(trials(k).delay_dur_ms >= params.delay_min_ms);
        assert(trials(k).delay_dur_ms <= params.delay_max_ms);

        expected_angle = transform_rule(trials(k).sample_dir, trials(k).rule_id);
        assert(trials(k).correct_target_angle == expected_angle);
    end

    % Check balancing of all combinations
    counts = zeros(numel(params.sample_dirs), numel(params.sample_sides), numel(params.rules));

    for k = 1:numel(trials)
        i_dir = find(params.sample_dirs == trials(k).sample_dir, 1);
        i_side = find(params.sample_sides == trials(k).sample_side, 1);
        i_rule = find(params.rules == trials(k).rule_id, 1);

        counts(i_dir, i_side, i_rule) = counts(i_dir, i_side, i_rule) + 1;
    end

    assert(all(counts(:) == params.n_repeats_per_condition), ...
        'Condition balancing is incorrect.');

    disp('test_build_trial_table passed');
end