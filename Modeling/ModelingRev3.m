clear all; close all;

% Modeling.m
% Summer '25 Research Project
% Modeling LoRa Signals
% Author: Gabriel Jarvis
% Revision 3

%%%%%%%%%%%% MANDATORY FUNCTION GATHERINGs %%%%%%%%%%%%
% File Name for Directory
filename1 = "714_m_1_12";
filename2 = "714_m_2_12";
filename3 = "714_m_3_12";
filename4 = "714_m_4_12";
filename5 = "714_m_5_12";
filename6 = "714_m_6_12";
filename7 = "714_m_7_12";

% Assosicated Distance with File
f1d = 100;
f2d = 200;
f3d = 300;
f4d = 400;
f5d = 500;
f6d = 600;
f7d = 700;

% File Info Matrix
% [filename1, f1rssi, f1snr, f1esp, testnum, f1d, f1avRSSI, f1avSNR, f1STDRSSI, f1STDRSNR]
F1Matrix = {filename1, 0, 0, 0, 1, f1d, 0, 0, 0, 0};
F2Matrix = {filename2, 0, 0, 0, 2, f2d, 0, 0, 0, 0};
F3Matrix = {filename3, 0, 0, 0, 3, f3d, 0, 0, 0, 0};
F4Matrix = {filename4, 0, 0, 0, 4, f4d, 0, 0, 0, 0};
F5Matrix = {filename5, 0, 0, 0, 5, f5d, 0, 0, 0, 0};
F6Matrix = {filename6, 0, 0, 0, 6, f6d, 0, 0, 0, 0};
F7Matrix = {filename7, 0, 0, 0, 7, f7d, 0, 0, 0, 0};

%%%%%%%%%%%%%% EXPORT DATA %%%%%%%%%%%%%%%%
%Ref: fileVname 1,rssiVname 2,snrVname 3, espVname 4, testnum 5, distance 6, 
%        aRSSIV 7,    aSNRV 8, RSSIstd 9,   SNRstd 10

function [fileMatrix] = extractFileMatrix(fileMatrix)
    RSSISummation = 0;
    SNRSummation = 0;

    % Import File
    FileInQuestion = importdata(fileMatrix{1}, ",");
    datalength = length(FileInQuestion);
    fprintf("Loaded file %d: %s\n", fileMatrix{5}, fileMatrix{1});
    
    % Initialize Values. // Just in Case
    totalRSSI = 0;
    totalSNR = 0;

    % Save Data
    for i = 13:datalength
        %extract RSSI
        data = FileInQuestion(i);
        datasplit = strsplit(cell2mat(data));
        RSSI = datasplit(4);
        RSSI = str2double(erase(RSSI,","));
        totalRSSI = totalRSSI + RSSI;
        fileMatrix{2}(1,i-12) = RSSI;

        %extract SNR
        data = FileInQuestion(i);
        datasplit = strsplit(cell2mat(data));
        SNR = datasplit(6);
        SNR = str2double(SNR);
        totalSNR = totalSNR + SNR;
        fileMatrix{3}(1,i-12) = SNR;

        %extract ESP
        fileMatrix{4}(1,i-12) = RSSI + SNR - 10*log(1+10^(0.1*SNR));

    end
    % find averages
    fileMatrix{7} = round(totalRSSI / (datalength - 12), 2);
    fileMatrix{8} = round(totalSNR / (datalength - 12), 2);
    
    % find STD
    for i = 13:datalength
        RSSISummation = RSSISummation + (fileMatrix{2}(1,i-12) - fileMatrix{7})^2;
        SNRSummation = SNRSummation + (fileMatrix{3}(1,i-12) - fileMatrix{8})^2;
    end
    fileMatrix{9} = sqrt(RSSISummation / (datalength - 12));
    fileMatrix{10} = sqrt(SNRSummation / (datalength - 12));
end

%%% Export Final Results
FinalF1Matrix = extractFileMatrix(F1Matrix);
FinalF2Matrix = extractFileMatrix(F2Matrix);
FinalF3Matrix = extractFileMatrix(F3Matrix);
FinalF4Matrix = extractFileMatrix(F4Matrix);
FinalF5Matrix = extractFileMatrix(F5Matrix);
FinalF6Matrix = extractFileMatrix(F6Matrix);
FinalF7Matrix = extractFileMatrix(F7Matrix);


%%%% Creating Plots %%%%
%% RAW RSSI PLOT vs Distance
figure(1)
scatter(FinalF1Matrix{6}, FinalF1Matrix{2});
hold on
xlabel("Distance (m)");
ylabel("RSSI (dB)");
title("Raw RSSI Data vs Distance");
scatter(FinalF2Matrix{6}, FinalF2Matrix{2});
scatter(FinalF3Matrix{6}, FinalF3Matrix{2});
scatter(FinalF4Matrix{6}, FinalF4Matrix{2});
scatter(FinalF5Matrix{6}, FinalF5Matrix{2});
scatter(FinalF6Matrix{6}, FinalF6Matrix{2});
scatter(FinalF7Matrix{6}, FinalF7Matrix{2});
    % highlight averages
scatter(FinalF1Matrix{6}, FinalF1Matrix{7}, "black", "filled");
scatter(FinalF2Matrix{6}, FinalF2Matrix{7}, "black", "filled");
scatter(FinalF3Matrix{6}, FinalF3Matrix{7}, "black", "filled");
scatter(FinalF4Matrix{6}, FinalF4Matrix{7}, "black", "filled");
scatter(FinalF5Matrix{6}, FinalF5Matrix{7}, "black", "filled");
scatter(FinalF6Matrix{6}, FinalF6Matrix{7}, "black", "filled");
scatter(FinalF7Matrix{6}, FinalF7Matrix{7}, "black", "filled");
hold off

%% RAW SNR PLOT vs Distance
figure(2)
scatter(FinalF1Matrix{6}, FinalF1Matrix{3});
hold on
xlabel("Distance (m)");
ylabel("SNR");
title("Raw SNR Data vs Distance");
scatter(FinalF2Matrix{6}, FinalF2Matrix{3});
scatter(FinalF3Matrix{6}, FinalF3Matrix{3});
scatter(FinalF4Matrix{6}, FinalF4Matrix{3});
scatter(FinalF5Matrix{6}, FinalF5Matrix{3});
scatter(FinalF6Matrix{6}, FinalF6Matrix{3});
scatter(FinalF7Matrix{6}, FinalF7Matrix{3});
    % highlight averages
scatter(FinalF1Matrix{6}, FinalF1Matrix{8}, "black", "filled");
scatter(FinalF2Matrix{6}, FinalF2Matrix{8}, "black", "filled");
scatter(FinalF3Matrix{6}, FinalF3Matrix{8}, "black", "filled");
scatter(FinalF4Matrix{6}, FinalF4Matrix{8}, "black", "filled");
scatter(FinalF5Matrix{6}, FinalF5Matrix{8}, "black", "filled");
scatter(FinalF6Matrix{6}, FinalF6Matrix{8}, "black", "filled");
scatter(FinalF7Matrix{6}, FinalF7Matrix{8}, "black", "filled");
hold off


%% Raw ESP PLOT vs Distance
figure(3)
scatter(FinalF1Matrix{6}, FinalF1Matrix{4});
hold on
xlabel("Distance (m)");
ylabel("dBm"); %%% Check later if true
title("Raw Effective Signal Power Data vs Distance");
scatter(FinalF2Matrix{6}, FinalF2Matrix{4});
scatter(FinalF3Matrix{6}, FinalF3Matrix{4});
scatter(FinalF4Matrix{6}, FinalF4Matrix{4});
scatter(FinalF5Matrix{6}, FinalF5Matrix{4});
scatter(FinalF6Matrix{6}, FinalF6Matrix{4});
scatter(FinalF7Matrix{6}, FinalF7Matrix{4});
hold off

%% Create Boxplot of RSSI
figure(4)
boxplot(FinalF1Matrix{2},'Positions',1);
hold on
boxplot(FinalF2Matrix{2},'Positions',2);
boxplot(FinalF3Matrix{2},'Positions',3);
boxplot(FinalF4Matrix{2},'Positions',4);
boxplot(FinalF5Matrix{2},'Positions',5);
boxplot(FinalF6Matrix{2},'Positions',6);
boxplot(FinalF7Matrix{2},'Positions',7);
axis tight;
set(gca(),'XTick',[1 2, 3, 4, 5, 6, 7], 'XTickLabel',{FinalF1Matrix{6}, ...
    FinalF2Matrix{6}, FinalF3Matrix{6}, FinalF4Matrix{6}, FinalF5Matrix{6}, ...
    FinalF6Matrix{6}, FinalF7Matrix{6},})
hold off


%%%%%%%%%%%%%%%%%%%% Testing
%%%%%%%% ChatGPT modeling %%%%%%%%%%%
measurements = [abs(FinalF1Matrix{7}); abs(FinalF2Matrix{7}); abs(FinalF3Matrix{7});
                abs(FinalF4Matrix{7}); abs(FinalF5Matrix{7}); abs(FinalF6Matrix{7}); 
                abs(FinalF7Matrix{7})];
distances = [f1d; f2d; f3d; f4d; f5d; f6d; f7d];

% Define logarithmic model: y = a * log(d) + b
modelFun = @(b, d) b(1) * log(d) + b(2);  % b = [a, b]

% Initial guess for parameters [a, b]
b0 = [1, 1];

% Fit model using nonlinear least squares
opts = optimoptions('lsqcurvefit', 'Display', 'off');
[b_est, resnorm] = lsqcurvefit(modelFun, b0, distances, measurements, [], [], opts);

% Display estimated parameters
disp('Estimated Parameters [a, b] for log model:');
disp(b_est);

% Predict measurements at new distances
d_new = (50:10:700)';  % Example: predict from 50m to 700m
y_pred = modelFun(b_est, d_new);

% Plot original data and model prediction
figure(5);
scatter(distances, measurements, 'bo', 'filled'); hold on;
plot(d_new, y_pred, 'r-', 'LineWidth', 2);
xlabel('Distance (m)');
ylabel('Measurement');
legend('Measured Data', 'Log Model Prediction', 'Location', 'northeast');
title('Logarithmic Least Squares Fit to Distance-Based Measurements');
grid on;
