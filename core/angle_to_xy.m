function [x, y] = angle_to_xy(angle_deg, radius)
%ANGLE_TO_XY Convert polar angle in degrees to Cartesian coordinates.
%
% Inputs
%   angle_deg : angle in degrees
%   radius    : radius
%
% Outputs
%   x, y      : Cartesian coordinates
%
% Convention:
%   0 deg   = right
%   90 deg  = up
%   180 deg = left
%   270 deg = down

    validateattributes(angle_deg, {'numeric'}, ...
        {'scalar', 'real', 'finite'}, mfilename, 'angle_deg');

    validateattributes(radius, {'numeric'}, ...
        {'scalar', 'real', 'finite', '>=', 0}, mfilename, 'radius');

    theta = deg2rad(mod(angle_deg, 360));
    x = radius * cos(theta);
    y = radius * sin(theta);
end