function test_userloop_visual_taskobjects_smoke()
%TEST_USERLOOP_VISUAL_TASKOBJECTS_SMOKE Unit test for TaskObject smoke userloop.

    clear userloop_visual_taskobjects_smoke

    [C_trial, timingfile_trial, holder_trial] = ...
        userloop_visual_taskobjects_smoke(struct(), struct());

    assert(iscell(C_trial));
    assert(numel(C_trial) == 3);
    assert(strncmp(C_trial{1}, 'crc(', 4));
    assert(strncmp(C_trial{2}, 'sqr(', 4));
    assert(strncmp(C_trial{3}, 'sqr(', 4));
    assert(strcmp(timingfile_trial, 'tf_visual_taskobjects_smoke.m'));
    assert(ischar(holder_trial) || isempty(holder_trial));

    disp('test_userloop_visual_taskobjects_smoke passed');
end
