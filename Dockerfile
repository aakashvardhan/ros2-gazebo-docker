# -------- ROS 2 Jazzy + Gazebo Harmonic | Ubuntu 24.04 ----------------
# ======================================================================
# Base: OSRF ROS 2 Jazzy desktop image (includes rvis2 and rqt*)
# For reference:
# rvis2 --> ROS 2's 3D visualization tool which is used to render
# your robot's sensor data, TF Frames, point clouds, laser scans,
# camera feeds, and URDF model in a 3D viewport -- visualizes ROS 2 topics
# rqt --> A Qt-based framework for ROS 2 debugging GUIs
# hosts modular panels -- rqt_graph, rqt_topic, rqt_console, rqt_plot

# Official ROS2 Docker Image (ros-base + rviz2 + rqt + demo nodes + tutorial packages)
FROM osrf/ros:jazzy-desktop

# This tells `apt-get` to never prompt for user input during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Installing Core tools + Gazebo Harmonic
# ros-jazzy-ros-gz: the bridge package that wires ROS 2 <-> Gazebo Harmonic
#  Pulls in gz-harmonic as a dependency, so no separate Gazebo install needed.
# ros-jazzy-turtlebot3: Turtlebot3 description (URDF/SDF) + Gazebo launch files
# xauth + mesa-utils: needed for GUI forwarding from container -> host

RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-jazzy-ros-gz \
    ros-jazzy-turtlebot3 \
    ros-jazzy-turtlebot3-gazebo \
    ros-jazzy-turtlebot3-description \
    ros-jazzy-turtlebot3-navigation2 \
    ros-jazzy-turtlebot3-teleop \
    mesa-utils \
    xauth \
    x11-apps \
    nano \
    htop \
    && rm -rf /var/lib/apt/lists/*
# tigervnc-common provides the vncpasswd binary; must be explicit with --no-install-recommends
RUN apt-get update && apt-get install -y \
    tigervnc-standalone-server \
    xfce4 \
    xfce4-terminal \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc \
    && echo "password" | vncpasswd -f > /root/.vnc/passwd \
    && chmod 600 /root/.vnc/passwd
# Environment Defaults
# TURTLEBOT3_MODEL: burger is the simplest (2 wheel diff drive)
# Other options: waffle, waffle_pi. Burger = fastest to spawn + debug
# ROS_DOMAIN_ID: isolates your DDS traffic. 0 is default but explicit is better
ENV TURTLEBOT3_MODEL=burger
ENV ROS_DOMAIN_ID=0

# Entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /robot
RUN echo "source /opt/ros/jazzy/setup.bash" >> /root/.bashrc
ENTRYPOINT [ "/entrypoint.sh" ]
CMD ["bash"]