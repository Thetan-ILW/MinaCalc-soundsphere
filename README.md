# Description
This mod adds difficulty calculator from Etterna to soundsphere.  
Only 4K charts. Version 505 (0.72.1) and 434 (0.70.3). See `/bin/` directory.  

# Installation
- Download this mod by clicking on green button on the top of the page > Download zip  
- Or by using this link https://github.com/Thetan-ILW/MinaCalc-soundsphere/archive/refs/heads/main.zip
  
- Extract MinaCalc folder into moddedgame directory inside your game root.
- (FOR DEFAULT SOUNDSPHERE THEME) Launch the game, open mounts menu, go to database tab and press "delete chartdiffs". Then press "compute chartdiffs". After that, go to settings and select MSD calculator. Restart the game.
- (FOR IRIZZ THEME) Launch the game, go to collections > mounts. Open database tab find "Charts difficulty / rating" section and press Delete and then Compute. After that, go to settings > UI > Difficulty and select MSD.
  
- Step above is required if you had already cached the charts. For new charts you just need to press "update" in mounts > select your locations.

# NOTE:
IN SONG SELECT, ONLY DIFFICULTY ON 1.0x RATE IS CORRECT.
In result screen showed difficulty is always correct, as it recalculates for each score and applies mods and rates.

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
