RSTD_Interface_Example
clear all; 
close all;
scripts = ["C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\Myscript\\mychirp3.lua",...
    "C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\Myscript\\mycapture.lua"];
%for iii=1:5
    for ii=1:length(scripts)
        Lua_String = sprintf('dofile("%s")', scripts(ii));
        ErrStatus =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
        if (ErrStatus ~= 30000)
            error('mmWaveStudio Connection Failed');
        end
    end
    
    pause(4);

    % check output
    for ii=1:10
        disp(sprintf("## %d ##", ii));
        !powershell Get-Content "C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\PostProc\\CLI_LogFile.txt" -Tail 5
        pause(1);
    end
    
    loadfromfile = 0;
    params = read_from_json('test2.mmwave.json');
    numFrames = 5;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    params.numFrames = numFrames;
    disp(params);
    if loadfromfile
        load(sprintf('%s/%s.mat', foldername, filename));
    else
        numBinFiles = ceil((4*params.numSamplePerChirp*4)*params.numChirps*numFrames/1024^3);
        adc_data =  read_from_binfile(numBinFiles, numFrames, params.numChirps, params.numSamplePerChirp);
        % adc_data (chirpsamples, chirps, frames)
        datacube.adcdata = adc_data;
        datacube.params = params;
    %      figure; plot(real(adc_data(:,1,1))); hold on; plot(imag(adc_data(:,1,1)));
    end
    
    % range fft
    
    [fftout, I] = rangeFFT(datacube.adcdata(:,1,1), datacube.params);
%end
