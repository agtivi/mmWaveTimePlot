% This RSTD function call sets up a 
RSTD_Interface_Example
clear all; 
close all;

% These are chirps that are predefined to be used for the radar, configuration of these chirps will need to be studied. Let me know what you find out
scripts = ["C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\Myscript\\mychirp3.lua",...
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

% THERE IS MORE MIDDLEGROUND TO BE COVERED BEFORE THESE NEXT CODE SNIPPETS ARE EXECUTED, DO NOT RUN YET

% This is the timeplot I talked about in the README that I'm not sure if it'll be useful or not. We need to figure out how (wl-nov)/fs*[0:length(I)-1] translates into time
% We also need to figure out how (I-1)*fs/fftsize is a line that can logically be graphed with respect to time. These snippets appear at line 290 and 291 in experiment_quick_check.m
% I'm thinking that maybe working our way backwards could help figure this out given that we don't really have much real understanding of how these are plotted exactly.
figure; plot((wl-nov)/fs*[0:length(I)-1] , (I-1)*fs/fftsize);
xlabel('Time(s)'); ylabel('frequency (Hz)');