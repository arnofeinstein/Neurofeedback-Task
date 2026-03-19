function test_userloop_visual_smoke()
%TEST_USERLOOP_VISUAL_SMOKE Unit test for the ML visual smoke userloop.

    clear userloop_visual_smoke

    [C_init, timingfile_init, holder_init] = userloop_visual_smoke(struct(), struct());

    assert(isempty(C_init));
    assert(strcmp(timingfile_init, 'tf_visual_smoke_test.m'));
    assert(ischar(holder_init) || isempty(holder_init));

    [C_trial, timingfile_trial, holder_trial] = userloop_visual_smoke(struct(), struct());

    assert(iscell(C_trial));
    assert(isempty(C_trial));
    assert(strcmp(timingfile_trial, 'tf_visual_smoke_test.m'));
    assert(ischar(holder_trial) || isempty(holder_trial));

    clear userloop_visual_smoke

    disp('test_userloop_visual_smoke passed');
end
