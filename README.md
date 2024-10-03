# Description
This plugin adds difficulty calculator from Etterna to soundsphere.  
Windows: Only 4K charts. Version 505 (0.72.1) and 434 (0.70.3). See `/bin/win64` directory.  
Linux: 4K - 10K charts. Version 514 (0.73), 505 and 434  

# Installation
1. Open the game.  
2. Open the package manager window (click on the 9 rectangles at the bottom left)  
3. Go to the `remote` tab and click on the `download` button next to the `msd_calculator` plugin.  
4. Restart the game. The next time you start the game, the plugin will restart the game and copy the files to the `bin/` folder.  

# Post installation
Only osu! UI and Irizz UI only support this plugin. Default UI does not display patterns and correct difficulty on rates.  

1. You need to select MSD difficulty in the settings.
2. In the mounts window, on the database tab, click `delete all chartdiffs`. Then update the cache as usual.

# Compiling the library
## Linux
```git clone https://github.com/kangalio/minacalc-standalone```  
```gcc MinaCalc/MinaCalc.cpp API.cpp -lstdc++ -lm -shared -fpic -o libminacalc.so```
## Windows
- Download Visual Studio 2022
- Make a C++ solution
- Clone this repo into the solution directory ```git clone https://github.com/kangalio/minacalc-standalone```
- In Visual Studio, include all files of cloned repo. (In the file explorer, click on 'Show all files', right click on minacalc-standalone directory and click 'Include'
- In the solution properties, select 'All configurations' and 'All architectures` in the upper part of the window.
- Make it a dynamic library
- In API.h and API.cpp add ```__declspec(dllexport)``` before each function.
- Compile the solution in ```release x64``` mode.

# Sources
Calculator from: https://github.com/etternagame/etterna  
Code for the library taken from: https://github.com/kangalio/minacalc-standalone
