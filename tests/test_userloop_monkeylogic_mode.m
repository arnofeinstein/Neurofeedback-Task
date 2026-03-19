function test_userloop_monkeylogic_mode()
%TEST_USERLOOP_MONKEYLOGIC_MODE Unit test for ML-style userloop bridge.

    clear userloop

    [C_init, timingfile_init, holder_init] = userloop(struct(), struct());

    assert(iscell(C_init));
    assert(~isempty(C_init));
    assert(strcmp(timingfile_init, 'tf_rule_rdk.m'));
    assert(ischar(holder_init) || isempty(holder_init));

    mock_trial_record = struct();
    mock_trial_record.CurrentTrialNumber = 0;

    [C_trial, timingfile_trial, holder_trial] = userloop(struct(), mock_trial_record);

    assert(iscell(C_trial));
    assert(~isempty(C_trial));
    assert(strcmp(timingfile_trial, 'tf_rule_rdk.m'));
    assert(ischar(holder_trial) || isempty(holder_trial));
    assert(strncmp(C_trial{1}, 'fix(', 4));

    clear userloop

    disp('test_userloop_monkeylogic_mode passed');
end
