# mmWaveTimePlot
Prerequisites **(Look at the Parenthesis before you open the links)**
1. https://www.mathworks.com/products/compiler/matlab-runtime.html **(Get the 8.5.1 Version)**
2. https://www.mathworks.com/academia/tah-portal/the-ohio-state-university-304226.html **(If you have MATLAB already then you can skip this)**
3. https://software-dl.ti.com/ccs/esd/documents/xdsdebugprobes/emu_xds_software_package_download.html **(Get the topmost 64-bit one, I got the Windows one, will be needed to use the UART and Data ports on the Radar)**
4. https://www.ti.com/tool/MMWAVE-STUDIO#downloads **(Click Download Options for MMWAVE-STUDIO — mmWave studio GUI tools for 1st-generation parts (xWR1243, xWR1443, xWR1642, xWR1843, xWR6843, xWR6443), download and run the installer)**
5. Download the code in this Github and unzip it in a folder somewhere.

Setup
1. Plug the radar into your computer **(Assuming you have the equipment we usually use then you'll need to have 2 power outlets, 1 USB (or 2 if you use the Network to USB adapter), and 1 Network port (if you don't use the Network to USB adapter))**
2. Whichever Network Adapter you connected the radar to will need to be configured for the Software **(I go to the control panel-> Network and Sharing Center-> Change Adapter Settings... then find which ethernet adapter the device is using... right click it-> properties-> enable IPv4-> highlight IPv4-> Properties-> Do this ![image](https://github.com/agtivi/mmWaveTimePlot/assets/95649224/3cbc042b-7a56-4472-ac3c-4d172df71b9f) ... and that should be fine after you click OK)**
3. Open the mmWave Studio and keep clicking the blue buttons in order **(You'll need to click all the blue buttons in the order they turn blue, and continue the same thing on these tabs in the order in the image, I usually set up the DCA1000 once I finish the 4th tab but wait for that until step 5)** ![image](https://github.com/agtivi/mmWaveTimePlot/assets/95649224/86dc9f51-facf-4418-aa22-bf103d6c755c)

4.  For your computer to be able to connect to the radar you need to turn off your firewall **(To be safe I disconnect from the internet when I do this)**
5.  Now set up the DCA1000 and let it connect **(Usually this is where problems arise so if you need help with it just send me a message, also you might need to use the bottom scrollbar to scroll left to even see the setup button for it)**
6.  **...\Sample Code\sample_code\Myscript** copy this folder into **C:\ti\mmwave_studio_02_01_01_00\mmWaveStudio\Scripts** 
7.  Open **...\Sample Code\sample_code\exp** **(Should open in MATLAB)**
8.  Go to the editor view and click Run to execute the preset experiment ![image](https://github.com/agtivi/mmWaveTimePlot/assets/95649224/2d0a7e1d-0f00-49bd-b85d-96ab4299f476)
**Note that neither Rash or I know how to modify the parameters on the SensorConfig tab meaningfully yet, the main concern seems to be just pushing results out so I'm just focusing on trying to figure out how to plot whatever we're getting over time.
My main concern though is that if we don't know how to modify these parameters, then how are we supposed to know what signals we're sending out are supposed to be with respect to time? Because right now we're sending signals out which seem to be giving us just one singular reading, but if we can't meaningfully change these parameters in the SensorConfig tab or understand what they mean then how would we switch over to a plot with respect to time? We'll have to figure this out.**
