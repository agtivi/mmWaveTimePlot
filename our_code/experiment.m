% This RSTD function call sets up a cinnection with the radar
RSTD_Interface_Example
clear all; 
close all;

% These are chirps that are predefined to be used for the radar, configuration of these chirps will need to be studied. Let me know what you find out
scripts = ["C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\Myscript\\mychirp4.lua",...
    "C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\Myscript\\mycapture.lua"];

% This for loop executes whichever chirp that's specified in the earlier scripts array. I suggest taking a look at the mycapture.lua and the mychirp%d.lua's to get an idea of how this works
% My main wonders right now is where are these functions specified? Things like ar1.CaptureCardConfig_StartRecord or ar1.StartFrame are lua functions, but I can't find the documentation or
% API for them.
for ii=1:length(scripts)
    Lua_String = sprintf('dofile("%s")', scripts(ii));
    ErrStatus =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    if (ErrStatus ~= 30000)
        error('mmWaveStudio Connection Failed');
    end
end

% After the for loop executes we need to wait a little bit for the chirp profile to be fully executed, 3 seconds or more usually works
pause(3);

params = read_from_json(['test4.mmwave.json']);
%otherparams = read_from_json(['test4.setup.json']);
%disp("mmwave:");
disp(params);
%disp("setup:");
%disp(otherparams); 

for ii=1:10
    %disp(sprintf("## %d ##", ii));
    %!powershell Get-Content "C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\PostProc\\CLI_LogFile.txt" -Tail 5
    pause(1);
end

params.numFrames = 250;
numFrames = params.numFrames; %numBinFiles = ceil((4*params.numSamplePerChirp*4)*params.numChirps*numFrames/1024^3);
% ceil((4*params.numSamplePerChirp*4)*params.numChirps*params.numFrames/1024^3);
numBinFile = ceil((4*params.numSamplePerChirp*4)*params.numChirps*numFrames/1024^3);

sweepBandwidth = 1799e6; % Sweep bandwidth

plot_distance_over_time(numBinFile, params.numFrames, params.numChirps, params.numSamplePerChirp, params.sampleRate, sweepBandwidth);


function plot_distance_over_time(numBinFile, nFrame, numChirpPerFrame, numSamplePerChirp, fs, sweepBandwidth)
    % Read ADC data from binary files
    adcRawOutput = read_from_binfile(numBinFile, nFrame, numChirpPerFrame, numSamplePerChirp);

    % Pre-allocate the matrix to store distances
    maxDetections = 2; % Maximum number of object detections per chirp
    distances = NaN(nFrame, maxDetections);

    % Constants
    c = 3e8; % Speed of light in m/s
    rangeResolution = c / (2 * sweepBandwidth);

    % Process each frame
    for frameIdx = 1:nFrame
        for chirpIdx = 1:numChirpPerFrame
            % Extract the current chirp data
            chirpData = adcRawOutput(:, chirpIdx, frameIdx);

            % Apply FFT to the chirp data
            fftData = fft(chirpData);

            % Compute the range profile
            rangeProfile = abs(fftData(1:numSamplePerChirp/2)); % Only use the first half of FFT output

            % Find peaks in the range profile
            [pks, locs] = findpeaks(rangeProfile, 'SortStr', 'descend');

            % Convert peak locations to distance
            numDetections = min(maxDetections, length(locs));
            distances(frameIdx, 1:numDetections) = locs(1:numDetections) * rangeResolution;
        end
    end

    % Create a time vector
    timeVector = (0:nFrame-1) * (numChirpPerFrame / fs);

    % Plot the distances over time
    figure;
    hold on;
    for detectionIdx = 1:maxDetections
        plot(timeVector, distances(:, detectionIdx), 'DisplayName', sprintf('Object %d', detectionIdx));
    end
    hold off;
    xlabel('Time (s)');
    ylabel('Distance (m)');
    title('Distance of Objects Over Time');
    legend;
end
