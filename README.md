
## Winboat Monitor Service by Kuritsu
I'm sure like most of you, I've been really enjoying [WinBoat](https://github.com/TibixDev/winboat)as an alternative to WinApps or Cassowary. However, if you're limited on memory, battery life etc. it'd be a nice touch to have the docker container auto-shutdown after a certain period of inactivity. 

So! I've written a very very basic bash script and service that can do this for you.

## How to use
1. Clone this repository either by clicking `Code -> Download as ZIP` or by running `git clone https://github.com/Kuritsu243/WinboatMonitorService.git` via git CLI. 
2. Open up a terminal of your preference and ensure the `setup.sh` file is executable by running `chmod +x setup.sh` 
3. Run the setup via `sudo ./setup.sh`. Follow the prompts in your Terminal and that should all be done! 

If you want to make any modifications to the script post-install, then the file will be located under `/usr/bin/`. 

**PLEASE NOTE**
- If you want to customise the install directory or have a non-conventional systemd location, you'll need to edit the `monitor_winboat.sh` file beforehand.
- This is a small hackjob pieced together by a sleep-deprived me tinkering around with Linux late at night. It may not work for everyone. This was tested on Arch w/ Linux 6.17 if that even matters.
