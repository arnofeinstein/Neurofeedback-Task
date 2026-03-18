function output_path = export_session_csv(sessionlog, output_path)
%EXPORT_SESSION_CSV Export a session log as a CSV file.
%
% Inputs
%   sessionlog   : struct returned by run_session_flow()
%   output_path  : optional full output path for the CSV file
%
% Output
%   output_path  : full path of the written CSV file

    % -------------------------
    % Validate input
    % -------------------------
    if ~isstruct(sessionlog)
        error('export_session_csv:InvalidInput', ...
            'sessionlog must be a struct.');
    end

    % -------------------------
    % Convert to table
    % -------------------------
    T = sessionlog_to_table(sessionlog);

    % -------------------------
    % Default output path
    % -------------------------
    if nargin < 2 || isempty(output_path)
        output_path = default_output_path();
    end

    validateattributes(output_path, {'char', 'string'}, ...
        {'nonempty'}, mfilename, 'output_path');

    output_path = char(output_path);

    % -------------------------
    % Ensure parent folder exists
    % -------------------------
    parent_dir = fileparts(output_path);
    if ~isempty(parent_dir) && ~exist(parent_dir, 'dir')
        mkdir(parent_dir);
    end

    % -------------------------
    % Write CSV
    % -------------------------
    writetable(T, output_path);

    fprintf('Session CSV exported to:\n%s\n', output_path);
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
    filename = sprintf('session_table_%s.csv', timestamp);

    output_path = fullfile(output_dir, filename);
end