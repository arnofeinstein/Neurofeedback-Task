function test_transform_rule()
%TEST_TRANSFORM_RULE Unit tests for transform_rule.

    assert(transform_rule(0,   1) == 0);
    assert(transform_rule(0,   2) == 180);
    assert(transform_rule(0,   3) == 90);

    assert(transform_rule(90,  1) == 90);
    assert(transform_rule(90,  2) == 270);
    assert(transform_rule(90,  3) == 180);

    assert(transform_rule(180, 1) == 180);
    assert(transform_rule(180, 2) == 0);
    assert(transform_rule(180, 3) == 270);

    assert(transform_rule(315, 1) == 315);
    assert(transform_rule(315, 2) == 135);
    assert(transform_rule(315, 3) == 45);

    disp('test_transform_rule passed');
end