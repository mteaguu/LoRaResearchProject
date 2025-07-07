clear all; close all;

% Modeling.m
% Summer '25 Research Project
% Modeling LoRa Signals
% Author: Gabriel Jarvis
% Revision 2

%%%%%%%%%%%% MANDATORY FUNCTION GATHERINGs %%%%%%%%%%%%
% File Name for Directory
filename1 = "Gabe;6,9,25;SF9;T2";
filename2 = "Gabe;6,9,25;SF9;T2";
filename3 = "Gabe;6,9,25;SF9;T3";
filename4 = "Gabe;6,9,25;SF9;T4";
filename5 = "Gabe;6,9,25;SF9;T5";
filename6 = "Gabe;6,9,25;SF9;T6";
filename7 = "Gabe;6,9,25;SF9;T7";

% Assosicated Distance with File
f1d = 0;
f2d = 0;
f3d = 0;
f4d = 0;
f5d = 0;
f6d = 0;
f7d = 0;

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
%FinalF2Matrix = extractFileMatrix(F2Matrix);
%FinalF3Matrix = extractFileMatrix(F3Matrix);
%FinalF4Matrix = extractFileMatrix(F4Matrix);
%FinalF5Matrix = extractFileMatrix(F5Matrix);
%FinalF6Matrix = extractFileMatrix(F6Matrix);
%FinalF7Matrix = extractFileMatrix(F7Matrix);
