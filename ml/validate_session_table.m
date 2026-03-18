function [T_valid, report] = validate_session_table(T, schema)
%VALIDATE_SESSION_TABLE Validate and reorder a session table.
%
% Inputs
%   T      : MATLAB table, typically from sessionlog_to_table()
%   schema : struct returned by build_behavior_schema()
%
% Outputs
%   T_valid : validated and reordered table
%   report  : struct with validation details

    % -------------------------
    % Validate inputs
    % -------------------------
    if ~istable(T)
        error('validate_session_table:InvalidTable', ...
            'T must be a MATLAB table.');
    end

    if nargin < 2 || isempty(schema)
        schema = build_behavior_schema();
    end

    if ~isstruct(schema) || ~isfield(schema, 'recommended_order')
        error('validate_session_table:InvalidSchema', ...
            'schema must be a struct returned by build_behavior_schema().');
    end

    expected_vars = schema.recommended_order;
    current_vars = T.Properties.VariableNames;

    % -------------------------
    % Find missing / extra vars
    % -------------------------
    missing_vars = expected_vars(~ismember(expected_vars, current_vars));
    present_expected_vars = expected_vars(ismember(expected_vars, current_vars));
    extra_vars = current_vars(~ismember(current_vars, expected_vars));

    % -------------------------
    % Reorder table
    % -------------------------
    reordered_vars = [present_expected_vars, extra_vars];
    T_valid = T(:, reordered_vars);

    % -------------------------
    % Report
    % -------------------------
    report = struct();
    report.is_valid = isempty(missing_vars);
    report.n_rows = height(T);
    report.n_cols_input = width(T);
    report.n_cols_output = width(T_valid);
    report.expected_vars = expected_vars;
    report.present_expected_vars = present_expected_vars;
    report.missing_vars = missing_vars;
    report.extra_vars = extra_vars;
    report.reordered_vars = reordered_vars;
end