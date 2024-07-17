function [detectedDistances, absFFTOutputs, distanceIntervals] = experiment2(numFrames, periodicity)
    % Clear the workspace and close all figures
    RSTD_Interface_Example
    %clear all; 
    %close all;
    
    % Define the paths to the Lua scripts for chirp configuration and data capture
    scripts = ["C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\Myscript\\mychirp3.lua",...
               "C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\Myscript\\mycapture.lua"];
    
    % Execute each Lua script using mmWave Studio API
    for ii = 1:length(scripts)
        Lua_String = sprintf('dofile("%s")', scripts(ii));
        ErrStatus = RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
        if (ErrStatus ~= 30000)
            error('mmWaveStudio Connection Failed');
        end
    end
     
    pause(4);
    temp_time = numFrames * periodicity * 0.001;
    
    % Check the output log file
    for ii = 1:temp_time
        disp(sprintf("## %d ##", ii));
        !powershell Get-Content "C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\PostProc\\CLI_LogFile.txt" -Tail 5
        pause(1);
    end
    
    % Load radar parameters from JSON configuration file
    loadfromfile = 0;
    params = read_from_json('test5.mmwave.json');
    params.framePeriodicity = periodicity;
    % Adjust numFrames to cover 60 seconds
    %framePeriodicity = params.framePeriodicity; % Assuming this is defined in the JSON configuration
 
    %numFrames = temp_time / framePeriodicity; % Calculate the number of frames for 60 seconds
    absFFTOutputs = zeros(8192,1,numFrames);
    distanceIntervals = zeros(1, 8192, numFrames);
    params.numFrames = numFrames;
    disp(params);
    
    % Load ADC data either from a file or directly from binary data
    if loadfromfile
        load(sprintf('%s/%s.mat', foldername, filename));
    else
        numBinFiles = ceil((4 * params.numSamplePerChirp * 4) * params.numChirps * numFrames / 1024^3);
        adc_data = read_from_binfile(numBinFiles, numFrames, params.numChirps, params.numSamplePerChirp);
        datacube.adcdata = adc_data;
        datacube.params = params;
    end
    
    % Calculate range axis (distance) in meters 
    c = 3e8; % Speed of light in meters/second
    Fs = params.sampleRate; % Sampling rate
    N = params.numSamplePerChirp; % Number of samples per chirp
    rangeResolution = c / (2 * Fs); % Range resolution
    rangeAxis = (0:N-1) * rangeResolution;
    
    % Initialize array to store detected distances
    detectedDistances = zeros(1, numFrames);
    
    % Perform range FFT for each frame and each chirp
    % plot on, plot all the subplots in one graph 
    
    for frame = 1:numFrames
       
        % Assuming we are taking the first chirp for simplicity
        chirpData = datacube.adcdata(:, 1, frame);
        [fftout, ~, distance, absFFTOutputs(:,:,frame), distanceIntervals(:,:,frame)] = rangeFFT2(chirpData, datacube.params);
        % Identify the peak in the FFT output
        [~, peakIndex] = max(abs(fftout));
        
        % Store the detected distance
        detectedDistances(1, frame) = distance;
    end
    
    % Plot the detected distance over time
    %timeAxis = (0:numFrames-1) * framePeriodicity; % Using the framePeriodicity defined in params
    %figure;
    %plot(timeAxis, detectedDistances, '-o');
    %title('Detected Distance Over Time');
    %xlabel('Time (s)');
    %ylabel('Distance (m)');  
    %grid on;
end