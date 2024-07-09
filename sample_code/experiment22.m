% Clear the workspace and close all figures
RSTD_Interface_Example

% Clear the workspace and close all figures

clear all;

close all;

 

% Define the paths to the Lua scripts for chirp configuration and data capture

scripts = ["C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\Myscript\\mychirp3.lua", ...
           "C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\Myscript\\mycapture.lua"];

 

% Execute each Lua script using mmWave Studio API

for ii = 1:length(scripts)

    Lua_String = sprintf('dofile("%s")', scripts(ii));

    ErrStatus = RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);

    if (ErrStatus ~= 30000)

        error('mmWaveStudio Connection Failed');

    end

end

 

% Increase pause to ensure scripts have enough time to complete

pause(5);

 

% Check the output log file

for ii = 1:10

    disp(sprintf("## %d ##", ii));

    !powershell Get-Content "C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\PostProc\\CLI_LogFile.txt" -Tail 5


end

 

% Load radar parameters from JSON configuration file

loadfromfile = 0;

params = read_from_json('test5.mmwave.json');

 

% Adjust numFrames to cover 60 seconds

framePeriodicity = params.framePeriodicity; % Assuming this is defined in the JSON configuration

numFrames = round(60 / framePeriodicity); % Calculate the number of frames for 60 seconds, rounding to nearest whole number

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

 

% Validate the captured data

if isempty(datacube.adcdata) || all(datacube.adcdata(:) == 0)

    error('ADC data is empty or contains only zeros.');

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

for frame = 1:numFrames

    % Assuming we are taking the first chirp for simplicity

    chirpData = datacube.adcdata(:, 1, frame);

   

    % Debug: Display the chirp data for verification

    disp(['Chirp data for frame ', num2str(frame), ': ', num2str(chirpData')]);

   

    % Ensure chirp data is valid before processing

    if all(chirpData == 0)

        warning(['Chirp data for frame ', num2str(frame), ' is all zeros. Skipping this frame.']);

        detectedDistances(frame) = NaN; % Mark as NaN to indicate invalid data

        continue;

    end

   

    [fftout, ~, distance] = rangeFFT2(chirpData, datacube.params);

   

    % Identify the peak in the FFT output

    [~, peakIndex] = max(abs(fftout));

   

    % Debug: Display the FFT output for verification

    disp(['FFT output for frame ', num2str(frame), ': ', num2str(abs(fftout)')]);

   

    % Store the detected distance

    detectedDistances(frame) = distance;

end

 

% Replace NaNs with the previous valid value for continuity in the plot

for frame = 2:numFrames

    if isnan(detectedDistances(frame))

        detectedDistances(frame) = detectedDistances(frame - 1);
    end

end

 

% Plot the detected distance over time

timeAxis = (0:numFrames-1) * framePeriodicity; % Using the framePeriodicity defined in params

figure;

plot(timeAxis, detectedDistances, '-o');

title('Detected Distance Over Time');

xlabel('Time (s)');

ylabel('Distance (m)');

grid on;