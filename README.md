
# Arbotix Arm Quickstart

Navigate to the directory you want to use to hold all the files and run:
```
curl https://raw.githubusercontent.com/1386161/arbotix-arm-quickstart/master/arbotix-quickstart.sh | bash
```

**This script has only been tested on Ubuntu 16.04**

This script downloads and initialises an arbotix workspace in the current directory, installing everything needed to use the Arbotix PhantomX arm into a local directory.

- **Attempts to install if not found:**
  - ros-kinetic-desktop-full
  - ros-kinetic-arbotix

- **Downloads:**
  - Processing 2.2.1
  - Arduino 1.8.9

- **Initialises Workspaces:**
  - Arduino Workspace (+Intrabotix/Arbotix Repos)
  - Processing Workspace (+controlP5, +dynaManager)
  - Catkin Workspace (+PhantomX and +Turtlebot hardware descriptions by Intrabotix, +Arbotix-Ros by VanadiumLabs)

------------------------------------------------------------------------

# TL;DR Arbotix:

> The information below does not relate one to one with the project above, but are snippets of info I found useful.

## 1️⃣ Software Versions:

### Arduino:

> If your goal is to use ROS, arduino is only needed the first time to copy across ros.ino to the board.

- Arduino 1.8.x is compatible with 1.6.x
  (The arduino community was forked prior to 1.8, and needed to keep compatibility).
- FILES:
    - .ino files are arduino entry points.
    - "<NAME>.ino" files must be in a directry called "<NAME>"
- WORKSPACE: Uses a workspace folder that can be set in preferences. Has the following structure:
    - libraries
        - {after install} ./*
    - hardware
        - {after install} ./arbotix/avr/*

### Software Vendors:
- vanadiumlabs
    - produce arbotix board
- interbotix
    - A product range from trossenrobotics
    - interbotix is open source, including PhantomX Pincher (very similar to turtlebot arm)

### Arbotix (github.com: arbotix) (Arduino Libraries & Examples):
- vanadiumlabs/arbotix:master     [arduino 1.0.x]       (6 y/o) (origional)
    - The origional repo for the arbotix boards.
- interbotix/arbotix:master       [arduino 1.0.x]       (4 y/o)
    - (fork of vanadiumlabs/arbotix:master) Fixes and extra examples for arms
- palashn/arbotix:master          [arduino 1.6.x-1.8.x]
    - hardware only updated for arduino 1.6.x
- interbotix/arbotix:arduino-1-6  [arduino 1.6.x-1.8.x] (3 y/o)
    *** USE ME ***
    - (fork of interbotix/arbotix:master) seems to merge patches from various places around the community.
    - states fix for ros example
- westleydavis/arbotix:master     [arduino 1.6.x-1.8.x] (2 y/o)
    - (fork of interbotix/arbotix:arduino-1-6) has one line of ros patch, but doesn't seem to work properly.

### OPTIONAL: Processing {latest 2.x.x}
- Scripting IDE for visual artists, very similar to arduino in looks and function, including workspaces.
- FILES:
    - .pde files are processing entry points.
    - "<NAME>.pde" files must be in a directry called "<NAME>"
- WORKSPACE: Uses a workspace folder that can be set in preferences. Has the following structure:
    - libraries
        - {after install} ./ControlP5 {first 2.x.x, later versions of 2 are incompatible}
    
### Arbotix_Ros (ros.org: arbotix) (github.com: arbotix_ros) (Ros integration)
- arbotix_controllers
- arbotix_firmware
- arbotix_msgs
- arbotix_python
    - terminal
- arbotix_sensors


## 2️⃣ Power Supply (12V + 2A/5A/10A):

### Servos:
- AX-12A servos draw between 50mA and 900mA

### PhantomX Pincher:
- The basic pincher needs 12V, 5A supply.
    - ***NOTE*** 2A supply can be used for only 1 servo! Otherwise servo voltage is too low, and they may not be detected properly. (If servos seem to be detected incorrectly, try connecting each and checking their id's - Make sure they are not all the same. Servos can only be mapped individually if they are the same because commands are sent to both simultaniously.)

### Powering Board:
- The board only can be powered by USB, but then the pins need to be swapped, see manual.
    - power from usb & psu at same time is possible.

### Incorrect Amperages vs. Voltages:
- High Voltage:  **Bad** (damage components)
- Low Voltage:   **Bad** (damage components)
- High Amperage: **OK**  (only required current is drawn from psu)
- Low Amperage:  **Kinda Bad** (PSU is overworked and low amperage might lead to voltage drop.)


## 3️⃣ Serial USB Cable (FTDI):

### Physical Orientation:
- cable colors must match text next to port on Arbotix. (blk on left in corner, grn on right)

### Mount Point:
- /dev/ttyUSB0
    - Some programs cannot handle other mount points.
    - Disconnects may cause ttyUSB<N> to increment.

### Permissions:
- Each time /dev/ttyUSB0 is connected, permissions must be changed to 777.
    $ `chmod 777 /dev/ttyUSB0`

### Manual FTDI driver installation is not necesary on modern systems.

### Access Manually:
- $ `screen /dev/ttyUSB0 {baud-rate}`


## 4️⃣ Guides:

### Arms:
- https://www.interbotix.com/Robotic-Arms
- https://learn.trossenrobotics.com/interbotix/robot-arms/pincher-arm
- https://learn.trossenrobotics.com/demos/phantomx-pincher-robot-arm-demos.html

### Resources:
- Arbotix:     https://github.com/Interbotix/arbotix/tree/arduino-1-6
- Arbotix_Ros: https://github.com/vanadiumlabs/arbotix_ros
- Arbotix_Ros: https://github.com/Interbotix/arbotix_ros/tree/parallel_gripper
- tutorial:    https://www.youtube.com/watch?v=AdA1l22FDU8
    * Alt link in video: https://edu.gaitech.hk/turtlebot/turtlebot-arm-pincher.html
- Ros_Arm:     https://github.com/Interbotix/phantomx_pincher_arm
- Ros_Arm:     https://github.com/turtlebot/turtlebot_arm

    
## 5️⃣ Getting Started:

**WARNING**: servos and the arm are suprisingly violent - the device may damage itself.
**WARNING**: Do not run the arbitrary servo test scripts without limitations on the range of motion and torque.

### ArbotiX Getting Started Guide / Arduino IDE 1.6.X Setup
- https://learn.trossenrobotics.com/projects/182-arbotix-getting-started-guide-arduino-ide-1-6-x-setup.html
    - NOTE: PincherTest is probably the best for debugging, in arduino open (Tools -> Serial Monitor) to see output.
- Step Modifications:
    - 1 - Arduino 1.8.x can probably be used.
    - 2 - SKIP (although still $ `chmod 777 {usb device}` )
    - 6 - **WARNING**: Use PincherTest instead of AXSimpleTest - See WARNINGS above.
    NOTE: dont forget to properly set (Tools -> programmer, Tools -> board, Tools -> Port) in arduino.

### Info/Problems:
- DynaManager Not Finding Servos: http://forums.trossenrobotics.com/showthread.php?10044
- Can't See Arbotix-M on Board List: http://forums.trossenrobotics.com/showthread.php?9971
- ArbotiX 1.6.x Files & Libraries: http://forums.trossenrobotics.com/showthread.php?7971
- Alternative to arbotix_terminal: https://github.com/KurtE/AX12_Test/

### Pincher:
    - Pincher Product Page, Info, Guides: https://learn.trossenrobotics.com/interbotix/robot-arms/pincher-arm.html
    - Servo IDs - Use Interbotix dynaManager (also sets correct baud rate):
        - Setting the ID's of servos with the same ID will change both. Unplug one before doing this.
        - The numbering of the servos on the pincher should be from 1 to 5, with 1 being the base rotational servo, 2 being the shoulder, 3 being the middle elbow, 4 the wrist and, 5 the pincer.


## 6️⃣ Getting Started ROS:

-- TODO: ROS ROS ROS --

-- TODO: Baud Rate (newer firmware) 115200 --

-- TODO: Servos also use serial connection --



