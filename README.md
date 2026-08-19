# ROS 2 + Gazebo, Containerized

A reproducible robotics simulation environment: **ROS 2 Jazzy**, **Gazebo Harmonic**,
RViz2, rqt, and a TurtleBot3 model, in one image that runs the same on macOS and
Linux.

Getting ROS 2 and Gazebo running locally usually means matching an Ubuntu release to
a ROS distro to a Gazebo version, then getting GUI applications out of the container
and onto your screen. On a Mac there is no native X server at all. This repo reduces
all of that to `docker compose up`.

---

## What you get

| | |
|---|---|
| **ROS 2 Jazzy** | `osrf/ros:jazzy-desktop`, which includes RViz2, rqt, and demo nodes |
| **Gazebo Harmonic** | via `ros-jazzy-ros-gz`, the bridge between ROS 2 and Gazebo |
| **TurtleBot3** | description, Gazebo worlds, Nav2 stack, and teleop |
| **A desktop** | XFCE over VNC on port 5901, so GUI tools work without an X server |
| **Persistent model cache** | Gazebo models survive restarts instead of re-downloading |

---

## Quick start

```bash
git clone https://github.com/aakashvardhan/ros2-gazebo-docker.git
cd ros2-gazebo-docker
docker compose up --build
```

Then open a shell inside the running container:

```bash
docker exec -it ros2_gazebo bash
```

Launch a simulated TurtleBot3 in an empty world:

```bash
ros2 launch turtlebot3_gazebo empty_world.launch.py
```

Drive it from a second shell:

```bash
docker exec -it ros2_gazebo bash
ros2 run turtlebot3_teleop teleop_keyboard
```

---

## Seeing the GUI

Two options, depending on your setup.

### VNC (works everywhere, nothing to install on the host)

The container runs an XFCE desktop on **port 5901**. Connect any VNC client to
`localhost:5901` with the password `password`. On macOS, Finder > Go > Connect to
Server > `vnc://localhost:5901` works with no extra software.

This is the path to use if X11 forwarding is being difficult.

### X11 forwarding (lower latency, macOS needs XQuartz)

Install [XQuartz](https://www.xquartz.org/), then enable network clients:

```bash
# XQuartz → Settings → Security → "Allow connections from network clients"
xhost + 127.0.0.1
```

`.env` already points `DISPLAY` at `host.docker.internal:0`, which is Docker
Desktop's DNS name for the host. On Linux, set `DISPLAY=$DISPLAY` and mount
`/tmp/.X11-unix` instead.

`docker-compose.yml` sets `LIBGL_ALWAYS_SOFTWARE=1`. Without GPU passthrough,
Gazebo's renderer falls back to software rasterization. That is slower, but it
actually starts, which hardware GL in a container often does not.

---

## Your own packages

`./workspace` on the host is mounted at `/root/ros2_ws/src` in the container, so
packages you drop there are visible immediately:

```bash
mkdir -p workspace
# put your package in workspace/my_package, then inside the container:
cd /root/ros2_ws && colcon build && source install/setup.bash
```

The entrypoint sources `/opt/ros/jazzy/setup.bash` on every shell, and sources your
workspace overlay too once `install/setup.bash` exists. Both `ros2` and your own
nodes land on the path in every new terminal with no manual sourcing.

---

## Layout

| File | |
|---|---|
| `Dockerfile` | ROS 2 Jazzy + Gazebo Harmonic + TurtleBot3 + XFCE/VNC |
| `docker-compose.yml` | Service definition, ports, volumes, GL and X11 environment |
| `entrypoint.sh` | Sources the ROS 2 underlay and any workspace overlay on shell start |
| `.env` | `DISPLAY` default for macOS + XQuartz |
| `ROS2_Gazebo_Install_Guide.pdf` | Notes from installing this stack natively, before containerizing |

---

## Notes

- `TURTLEBOT3_MODEL=burger` by default. That is the two-wheel differential drive
  model, the quickest to spawn and debug. `waffle` and `waffle_pi` ship too.
- The Dockerfile sets `ROS_DOMAIN_ID=0` explicitly rather than leaving it to the
  default, so DDS traffic doesn't collide with other ROS 2 machines on the network.
- The container runs `--privileged` for `/dev` access, which you need when
  attaching real hardware over USB later.
- The VNC password is the literal string `password`, baked into the image. That is
  fine for a local simulator on `localhost`. Change it in the `Dockerfile` before
  exposing port 5901 anywhere else.
