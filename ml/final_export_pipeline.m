function result = final_export_pipeline(sessionlog, output_path)
%FINAL_EXPORT_PIPELINE Build, validate, and export the final session table.
%
% Inputs
%   sessionlog   : struct returned by run_session_flow()
%   output_path  : optional CSV output path
%
% Output
%   result : struct containing
%       .table_raw
%       .table_valid
%       .schema
%       .validation_report
%       .output_path

    % -------------------------
    % Validate input
    % -------------------------
    if ~isstruct(sessionlog)
        error('final_export_pipeline:InvalidInput', ...
            'sessionlog must be a struct.');
    end

    % -------------------------
    % Build schema and raw table
    % -------------------------
    schema = build_behavior_schema();
    table_raw = sessionlog_to_table(sessionlog);

    % -------------------------
    % Validate and reorder table
    % -------------------------
    [table_valid, validation_report] = validate_session_table(table_raw, schema);

    % -------------------------
    % Choose output path
    % -------------------------
    if nargin < 2 || isempty(output_path)
        output_path = default_output_path();
    end

    validateattributes(output_path, {'char', 'string'}, ...
        {'nonempty'}, mfilename, 'output_path');

    output_path = char(output_path);

    parent_dir = fileparts(output_path);
    if ~isempty(parent_dir) && ~exist(parent_dir, 'dir')
        mkdir(parent_dir);
    end

    % -------------------------
    % Export validated table
    % -------------------------
    writetable(table_valid, output_path);

    % -------------------------
    % Pack output
    % -------------------------
    result = struct();
    result.table_raw = table_raw;
    result.table_valid = table_valid;
    result.schema = schema;
    result.validation_report = validation_report;
    result.output_path = output_path;

    fprintf('Final export pipeline completed.\n');
    fprintf('CSV written to:\n%s\n', output_path);
    fprintf('Schema valid: %d\n', validation_report.is_valid);
end


function output_path = default_output_path()
%DEFAULT_OUTPUT_PATH Create a default timestamped CSV path in ./output

    caller_path = mfilename('fullpath');
    ml_dir = fileparts(caller_path);
    project_root = fileparts(ml_dir);

    output_dir = fullfile(project_root, 'output');
    if ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    timestamp = datestr(now, 'yyyy-mm-dd_HHMMSS');
    filename = sprintf('final_session_table_%s.csv', timestamp);

    output_path = fullfile(output_dir, filename);
end