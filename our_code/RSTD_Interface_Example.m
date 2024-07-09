%% RSTD_Interface_Example.m

% Seems like this just generates a path for the program somehow but as to what it's used for exactly I don't know
addpath(genpath('.\'))

% Initialize mmWaveStudio .NET connection
RSTD_DLL_Path = 'C:/ti/mmwave_studio_02_01_01_00/mmWaveStudio/Clients/RtttNetClientController/RtttNetClientAPI.dll';

ErrStatus = Init_RSTD_Connection(RSTD_DLL_Path);
if (ErrStatus ~= 30000)
    disp('Error inside Init_RSTD_Connection');
    return;
end

%Example Lua Command
% strFilename ='C:\\ti\\mmwave_studio_02_01_01_00\\mmWaveStudio\\Scripts\\mycapture.lua';
% Lua_String = sprintf('dofile("%s")',strFilename);
% ErrStatus =RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);