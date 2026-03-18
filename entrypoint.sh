#!/bin/bash

# Runs on every container start
# Purpose is to source the ROS 2 underlay so every shell has ros2 CLI available.

set -e

# Source ROS 2 Jazzy underlay
source /opt/ros/jazzy/setup.bash

# If a workspace overlay exists
if [ -f /root/ros2_ws/install/setup.bash ]; then
    source /root/ros2_ws/install/setup.bash
    echo "[entrypoint] Source workspace overlay: /root/ros2_ws"
fi

echo "[entrypoint] ROS 2 Jazzy ready | TURTLEBOT3_MODEL=${TURTLEBOT3_MODEL}"


exec "$@"