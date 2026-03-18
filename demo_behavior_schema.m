function demo_behavior_schema()
%DEMO_BEHAVIOR_SCHEMA Print the canonical behavioral schema.

    project_root = fileparts(mfilename('fullpath'));
    addpath(fullfile(project_root, 'ml'));

    schema = build_behavior_schema();

    fprintf('\n=== Behavior schema ===\n');
    fprintf('Description: %s\n', schema.metadata.description);
    fprintf('Version    : %s\n\n', schema.metadata.version);

    print_group('Condition fields', schema.condition);
    print_group('Timing fields', schema.timing);
    print_group('Response fields', schema.response);
    print_group('Outcome fields', schema.outcome);
    print_group('Execution fields', schema.execution);

    fprintf('Allowed final outcomes:\n');
    for i = 1:numel(schema.allowed_values.final_outcome)
        fprintf('  - %s\n', schema.allowed_values.final_outcome{i});
    end

    fprintf('\nRecommended field order:\n');
    for i = 1:numel(schema.recommended_order)
        fprintf('  %2d. %s\n', i, schema.recommended_order{i});
    end
end


function print_group(title_str, fields)
%PRINT_GROUP Helper for console display.

    fprintf('%s:\n', title_str);
    for i = 1:numel(fields)
        fprintf('  - %s\n', fields{i});
    end
    fprintf('\n');
end