clc; close all;

%% Calibration Accelerations 
% Low g
% a1p = [ 9.975113, 0.396280, -0.184676 ]';   % +x
% a1n = [-9.533770, -0.107105, 0.481328 ]';   % -x
% 
% a2p = [ -0.002453, 9.769963, 0.324655 ]';   % +y
% a2n = [ 0.507053, -9.740908, 0.031087 ]';   % -y
% 
% a3p = [ 0.636985, -0.050985, 10.124125 ]';   % +z
% a3n = [ -0.208125, 0.143905, -9.669601 ]';   % -z

% High g
a1p = [ 18.262427, 8.755777, 0.653105 ]';   % +x
a1n = [ -1.226269, 10.014580, 0.829213 ]';   % -x

a2p = [ 8.806548, 20.173581, 1.050405 ]';   % +y
a2n = [ 8.665104, 0.285398, 0.406510 ]';   % -y

a3p = [ 8.542123, 9.615942, 10.084436 ]';   % +z
a3n = [ 8.328015, 10.134971, -8.294616 ]';   % -z

g = 9.80;

%%  The Bias Vector
bx = ((a1p(1) + a1n(1))/2 + (a2p(1) + a2n(1))/2 + (a3p(1) + a3n(1))/2)/3;
by = ((a1p(2) + a1n(2))/2 + (a2p(2) + a2n(2))/2 + (a3p(2) + a3n(2))/2)/3;
bz = ((a1p(3) + a1n(3))/2 + (a2p(3) + a2n(3))/2 + (a3p(3) + a3n(3))/2)/3;

b = [bx; by; bz];

fprintf('Bias Vector:\n');
disp(b);

%  Remove Bias
a1 = a1p - b;
a2 = a2p - b;
a3 = a3p - b;

A = [a1 a2 a3];  % Unbiased Matrix

%%  Calibration Matrix
C = g * inv(A);

fprintf('Calibration Matrix:\n');
disp(C);

S = det(C);

fprintf('Calibration Matrix Determinant:\n');
disp(S);

%%  Import Raw Data
pico_us = accelerometer_data.pico_us';

ax = accelerometer_data.ax';
ay = accelerometer_data.ay';
az = accelerometer_data.az';

T = 1e-6 * (pico_us - pico_us(1));   %  Time Vector
Araw = [ax; ay; az];                 %  Data Matrix

%%  Apply Calibration
Acal = C * (Araw - b);

%  Remove Static Gravity
A_motion = Acal - [0;0;g];

%  Calibrated Components
axcal = A_motion(1,:);
aycal = A_motion(2,:);
azcal = A_motion(3,:);

%% Calibrated Accelerations - Separate Plots
figure('Position', [100 100 900 700]);
set(gcf, 'WindowStyle', 'docked');   % Auto-dock

subplot(3,1,1);
plot(T, axcal, 'o', 'MarkerSize', 2, 'LineStyle', 'none', ...
     'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
ylabel('a_x (m/s²)'); title('Calibrated Acceleration - X Axis'); grid on;

subplot(3,1,2);
plot(T, aycal, 'o', 'MarkerSize', 2, 'LineStyle', 'none', ...
     'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
ylabel('a_y (m/s²)'); grid on;

subplot(3,1,3);
plot(T, azcal, 'o', 'MarkerSize', 2, 'LineStyle', 'none', ...
     'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
xlabel('Time (s)'); ylabel('a_z (m/s²)'); grid on;

sgtitle('Calibrated Acceleration Data');


%% Raw (Uncalibrated) Accelerations - Separate Plots 
figure('Position', [1050 100 900 700]);
set(gcf, 'WindowStyle', 'docked');   % Auto-dock

subplot(3,1,1);
plot(T, Araw(1,:), 'o', 'MarkerSize', 2, 'LineStyle', 'none', ...
     'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');
ylabel('Raw a_x (m/s²)'); title('Raw Acceleration Data'); grid on;

subplot(3,1,2);
plot(T, Araw(2,:), 'o', 'MarkerSize', 2, 'LineStyle', 'none', ...
     'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'r');
ylabel('Raw a_y (m/s²)'); grid on;

subplot(3,1,3);
plot(T, Araw(3,:), 'o', 'MarkerSize', 2, 'LineStyle', 'none', ...
     'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');
xlabel('Time (s)'); ylabel('Raw a_z (m/s²)'); grid on;

sgtitle('Raw Acceleration Data');


%% Uncertainty Analysis 
t0 = 0.27;    
t1 = 1.1;

% Uncertainties
delta_16g = .00479;
delta_400g = 1.91;

% Uncertainty Input
delta_a_tilde = delta_400g;

idx = T >= t0 & T <= t1;
t_plot = T(idx);

a_mat = A_motion(:, idx);                                       
inner = 2*[1;1;1] + (1/g) * sum(a_mat, 1);         
delta_a_vec = (1 + 1/sqrt(6)) * delta_a_tilde * (C * inner);         

delta_ax = abs(delta_a_vec(1,:));
delta_ay = abs(delta_a_vec(2,:));
delta_az = abs(delta_a_vec(3,:));

%% Plot - X, Y, Z with Error Bars 
figure('Position',[150 100 950 700]);
set(gcf, 'WindowStyle', 'docked');   % Auto-dock

% X Axis - Blue
subplot(3,1,1);
errorbar(t_plot, axcal(idx), delta_ax, 'b.', 'MarkerSize',6, 'CapSize',2, 'LineStyle','none');
ylabel('a_x (m/s²)');
title('Calibrated Acceleration with Uncertainty');
grid on;
legend('a_x ± \deltaa_x', 'Location','best');

% Y Axis - Red
subplot(3,1,2);
errorbar(t_plot, aycal(idx), delta_ay, 'r.', 'MarkerSize',6, 'CapSize',2, 'LineStyle','none');
ylabel('a_y (m/s²)');
grid on;
legend('a_y ± \deltaa_y', 'Location','best');

% Z Axis - Green
subplot(3,1,3);
errorbar(t_plot, azcal(idx), delta_az, 'g.', 'MarkerSize',6, 'CapSize',2, 'LineStyle','none');
xlabel('Time (s)');
ylabel('a_z (m/s²)');
grid on;
legend('a_z ± \deltaa_z', 'Location','best');

sgtitle(sprintf('Calibrated Acceleration with Error Bars  [%.3f – %.3f] s', t0, t1));

% Integrate acceleration → velocity (v(0) = 0)
vx = cumtrapz(T, axcal);
vy = cumtrapz(T, aycal);
vz = cumtrapz(T, azcal);

% Integrate velocity → position (x(0) = 0)
px = cumtrapz(T, vx);
py = cumtrapz(T, vy);
pz = cumtrapz(T, vz);

%% Velocity Figure
figure('Position', [200 100 950 700]);
set(gcf, 'WindowStyle', 'docked');

subplot(3,1,1); plot(T, vx, 'b-', 'LineWidth', 1.3); ylabel('v_x (m/s)'); title('Velocity Profiles'); grid on;
subplot(3,1,2); plot(T, vy, 'r-', 'LineWidth', 1.3); ylabel('v_y (m/s)'); grid on;
subplot(3,1,3); plot(T, vz, 'g-', 'LineWidth', 1.3); xlabel('Time (s)'); ylabel('v_z (m/s)'); grid on;
sgtitle('Velocity (Integrated from Calibrated Acceleration)');

%% Position Figure
figure('Position', [250 100 950 700]);
set(gcf, 'WindowStyle', 'docked');

subplot(3,1,1); plot(T, px, 'b-', 'LineWidth', 1.3); ylabel('p_x (m)'); title('Position Profiles'); grid on;
subplot(3,1,2); plot(T, py, 'r-', 'LineWidth', 1.3); ylabel('p_y (m)'); grid on;
subplot(3,1,3); plot(T, pz, 'g-', 'LineWidth', 1.3); xlabel('Time (s)'); ylabel('p_z (m)'); grid on;
sgtitle('Position (Double Integrated from Calibrated Acceleration)');

%% Data Grab
axcalT = axcal';
aycalT = aycal';
azcalT = azcal';
% copygraphics(figure(3), 'Resolution', 300)