clear all; close all;

% Modeling.m
%
% Summer '25 Research Project
% Modeling LoRa signals
% Author: Mathew Teague
%

% import putty log
filename = "714_m_1_12";
distance = 100; % distance between transmitter and receiver in meters
puttylog = importdata(filename, ","); %file needs to be in same folder as code
fprintf("Filename 1: %s\n", filename);
filename = "714_m_1_12";
distance2 = 100; % distance between transmitter and receiver in meters
puttylog2 = importdata(filename, ",");
fprintf("Filename 2: %s\n", filename);

% extract SF and BW from file 1 and print
data = puttylog(12);
datasplit = strsplit(cell2mat(data));
% Spread Factor
SF = datasplit(3);
SF = str2double(erase(SF,","));
fprintf("Spreading Factor: %d\n", SF);
% Bandwidth
BW = str2double(datasplit(5));
if BW == 0
    BW = 125;
elseif BW == 1
    BW = 250;
elseif BW == 2
    BW = 500;
else
    BW = -1; %in case of error
end

fprintf("Bandwidth: %d kHz\n", BW);

%%%%%%%%%%%% DATA GATHERING %%%%%%%%%%%%
datalength = length(puttylog2);
totalRSSI = 0;
totalSNR = 0;
totalRSSI2 = 0;
totalSNR2 = 0;
packets = datalength - 12; % exclude preamble
%PLlist = zeros(packets);
fprintf("Total Packets: %d\n", packets);

%find sum of RSSI and SNR values
for i = 13:datalength
    %extract RSSI
    data = puttylog(i);
    datasplit = strsplit(cell2mat(data));
    RSSI = datasplit(4);
    RSSI = str2double(erase(RSSI,","));
    totalRSSI = totalRSSI + RSSI;
    %extract SNR
    data = puttylog(i);
    datasplit = strsplit(cell2mat(data));
    SNR = datasplit(6);
    SNR = str2double(SNR);
    totalSNR = totalSNR + SNR;
    
    %calculate ESP
    ESP = RSSI + SNR - 10*log(1+10^(0.1*SNR));
    pathloss = 21 - ESP;
    PLlist1(i - 12) = round(pathloss,2);

    %extract RSSI again
    data = puttylog2(i);
    datasplit = strsplit(cell2mat(data));
    RSSI = datasplit(4);
    RSSI = str2double(erase(RSSI,","));
    totalRSSI2 = totalRSSI2 + RSSI;
    %extract SNR again
    data = puttylog2(i);
    datasplit = strsplit(cell2mat(data));
    SNR = datasplit(6);
    SNR = str2double(SNR);
    totalSNR2 = totalSNR2 + SNR;

    %calculate ESP again
    ESP = RSSI + SNR - 10*log(1+10^(0.1*SNR));
    pathloss = 21 - ESP;
    PLlist2(i - 12) = round(pathloss,2);

    packetcount(i - 12) = i - 12;
end

% find averages
averageRSSI = round(totalRSSI / (datalength - 12), 2);
averageSNR = round(totalSNR / (datalength - 12), 2);

fprintf("Average RSSI = %.2f dBm\n", averageRSSI);
fprintf("Average SNR = %.2f dB\n", averageSNR);

% calculate effective signal power
averageESP = averageRSSI + averageSNR - 10*log(1+10^(0.1*averageSNR));
fprintf("Average ESP = %.2f dBm\n", averageESP);

% 21 dBm is TX power
averagepathloss = 21 - averageESP;
fprintf("Average Path Loss = %.2f dB\n", averagepathloss);

% n = 2.5; % n is path loss exponenet (PLE)
newdistance = 300; % distance for estimating in meters
% calculate PLE
n = (PLlist2 - PLlist1) / (10*log(distance2/distance));

averagen = mean(n);
fprintf("Estimated PLE: %.2f\n", averagen);

estPL = averagepathloss + 10 * averagen * log(newdistance/distance);
fprintf("Estimated Path Loss at %d m: %.2f dB\n", newdistance, estPL);

scatter(packetcount, PLlist1, 'filled', 'Displayname', 'File 1'); %PL from first file
hold on;
scatter(packetcount, PLlist2, 'r', 'filled', 'Displayname', 'File 2'); %PL from second file
scatter(1, estPL, 'filled', 'g', 'Displayname', 'Estimated'); %estimated PL
xlabel('Packet Number');
ylabel('Path Loss (dB)');
title('Packet Number VS Path Loss');
legend;

% SF 7 BW 125 
% 100 m -> Path Loss = 94.92
% 200 m -> Path Loss = 106.7
% 300 m -> Path Loss = 121.85

%%%%%%%% modeling %%%%%%%%%%%
measurements = [PLlist1; PLlist2];
distances = [distance*ones(size(PLlist1)); distance2*ones(size(PLlist2))];

% Define logarithmic model: y = a * log(d) + b
modelFun = @(b, d) b(1) * log(d) + b(2);  % b = [a, b]

% Initial guess for parameters [a, b]
b0 = [1, 1];

% Fit model using nonlinear least squares
opts = optimoptions('lsqcurvefit', 'Display', 'off');
[b_est, resnorm] = lsqcurvefit(modelFun, b0, distances, measurements, [], [], opts);
fittedparams = [b_est, resnorm];

% Display estimated parameters
%disp('Estimated Parameters [a, b] for log model:');
%disp(b_est);

% Predict measurements at new distances
d_new = (50:10:700)';  % Example: predict from 50m to 300m
y_pred = modelFun(b_est, d_new);

PLavgs = [83.9, 92.09, 110.87, 121.68, 126.06, 122.47, 124,74];
%PLdistances = (100:100:700);

nrmse = goodnessOfFit(fittedparams, PLavgs, 'NRMSE');
fprintf("Nomralized RMSE: %.2f\n", nrmse);

% Plot original data and model prediction
figure;
scatter(distances, measurements, 'bo', 'filled'); hold on;
plot(d_new, y_pred, 'r-', 'LineWidth', 2);
xlabel('Distance (m)');
ylabel('Measurement');
legend('Measured Data', 'Log Model Prediction', 'Location', 'northeast');
title('Logarithmic Least Squares Fit to Distance-Based Measurements');
grid on;
