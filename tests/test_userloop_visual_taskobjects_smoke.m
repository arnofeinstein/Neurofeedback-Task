function test_userloop_visual_taskobjects_smoke()
%TEST_USERLOOP_VISUAL_TASKOBJECTS_SMOKE Unit test for TaskObject smoke userloop.

    clear userloop_visual_taskobjects_smoke

    [C_init, timingfile_init, holder_init] = ...
        userloop_visual_taskobjects_smoke(struct(), struct());

    assert(isempty(C_init));
    assert(strcmp(timingfile_init, 'tf_visual_taskobjects_smoke.m'));
    assert(ischar(holder_init) || isempty(holder_init));

    mock_trial_record = struct();
    [C_trial, timingfile_trial, holder_trial] = ...
        userloop_visual_taskobjects_smoke(struct(), mock_trial_record);

    assert(iscell(C_trial));
    assert(numel(C_trial) == 3);
    assert(strncmp(C_trial{1}, 'crc(', 4));
    assert(strncmp(C_trial{2}, 'sqr(', 4));
    assert(strncmp(C_trial{3}, 'sqr(', 4));
    assert(strcmp(timingfile_trial, 'tf_visual_taskobjects_smoke.m'));
    assert(ischar(holder_trial) || isempty(holder_trial));

    clear userloop_visual_taskobjects_smoke

    disp('test_userloop_visual_taskobjects_smoke passed');
end
