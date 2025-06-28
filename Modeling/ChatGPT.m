clear all; close all;

% I genereated this example code with chatGPT, to refresh myself on
% MATLAB code syntax - Mathew

% Distances (in meters)
d = [repmat(100, 1, 20), repmat(200, 1, 20), repmat(300, 1, 20)];

% RSSI measurements (sample of 20 values per distance)
rssi_100 = [-53, -56, -55, -52, -55, -54, -56, -54, -69, -58, ...
            -56, -55, -56, -57, -56, -57, -55, -54, -55, -57];
rssi_200 = [-76, -62, -84, -69, -66, -64, -68, -69, -74, -72, ...
            -68, -69, -69, -67, -73, -71, -73, -68, -68, -71];
rssi_300 = [-82, -92, -79, -84, -85, -81, -78, -81, -78, -80, ...
            -85, -98, -88, -100, -86, -86, -85, -91, -86, -94];

rssi = [rssi_100, rssi_200, rssi_300];

% Transform distances using log10 for the model
X = log10(d)';  % column vector
y = rssi';      % column vector

% Least squares estimation: y = A * theta
A = [X, ones(size(X))];      % [log10(d), 1]
theta = (A' * A) \ (A' * y); % Solve normal equations

% Extract path loss exponent n and RSSI_0
n = -theta(1) / 10;
RSSI0 = theta(2);

% Display the results
fprintf('Estimated path loss exponent n: %.4f\n', n);
fprintf('Estimated RSSI at 1 meter (RSSI0): %.2f dBm\n', RSSI0);

% Plot results
d_range = 50:1:350;
pred_rssi = theta(1) * log10(d_range) + theta(2);

figure;
scatter(d, rssi, 'b', 'DisplayName', 'Measured RSSI');
hold on;
plot(d_range, pred_rssi, 'r-', 'LineWidth', 2, 'DisplayName', 'Fitted Model');
xlabel('Distance (m)');
ylabel('RSSI (dBm)');
title('RSSI vs Distance (Log-distance Model)');
legend;
grid on;