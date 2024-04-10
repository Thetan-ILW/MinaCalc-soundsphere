# Description
This mod adds difficulty calculator from the game Etterna to soundsphere.

# Installation
- Download this mod by clicking on green button on the top of the page > Download zip  
- Or by using this link https://github.com/Thetan-ILW/MinaCalc-soundsphere/archive/refs/heads/main.zip  
- Extract folder named 'MinaCalc-soundsphere-main` from the ZIP and place it into 'moddedgame' directory inside your the root of your game.  
- Launch the game.
- If you already have the chart cache, then go to mounts menu (Folder icon in the left bottom side of the screen) and click on the button "delete chartdiffs" on the every location with 4K charts you have.
- If not, then make the cache like you you always do.  

# Note
Any time rate that isn't 1.0x, will show incorrect difficulty value. But it will be correct on the result screen, because the game calculate the difficulty each time you enter it.  

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
- Compile the solution in ```release x64``` mode.

# Sources
Calculator from: https://github.com/etternagame/etterna  
Code for the library taken from: https://github.com/kangalio/minacalc-standalone
