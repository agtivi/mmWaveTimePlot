if (ar1.ChirpConfig(0, 511, 2, 0, 0, 0, 0, 1, 1, 0) == 0) then
    WriteToLog("ChirpConfig Success\n", "green")
else
    WriteToLog("ChirpConfig failure\n", "red")
end

if (ar1.FrameConfig(0, 52, 5, 185, 1340, 0, 0, 1) == 0) then
    WriteToLog("FrameConfig Success\n", "green")
else
    WriteToLog("FrameConfig failure\n", "red")
end