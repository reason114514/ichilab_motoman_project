# base_image setting
FROM ros:indigo

RUN mv /bin/sh /bin/sh_tmp && ln -s /bin/bash /bin/sh

#enviroment
ENV PATH $PATH:/opt/ros/indigo/bin/
ENV PYTHONPATH /opt/ros/indigo/lib/python2.7/dist-packages

#compile install
RUN apt-get -y update
RUN apt-get install -y build-essential

# workspace create
RUN mkdir -p /motoman_project_ws/src
WORKDIR /motoman_project_ws/src
RUN catkin_init_workspace
WORKDIR /motoman_project_ws
RUN source /opt/ros/indigo/setup.bash && catkin_make && source devel/setup.bash

# Nishida-Lab motomanproject
# git clone
WORKDIR /motoman_project_ws/src
RUN git clone https://github.com/Nishida-Lab/motoman_project.git
# package install
WORKDIR /motoman_project_ws
RUN wstool init src src/motoman_project/dependencies.rosinstall
RUN apt-get install -y\
	ros-indigo-industrial-msgs\
	ros-indigo-industrial-robot-simulator\
	ros-indigo-industrial-robot-client\
	ros-indigo-ros-controllers\
	ros-indigo-jsk-visualization\
	ros-indigo-velodyne-pointcloud\
	ros-indigo-rosserial-arduino\
	liblapack-dev\
	ros-indigo-rosserial\
	ros-indigo-moveit-ros-planning-interface\
	libv4l-dev\
	ros-indigo-moveit-ros-visualization\
	ros-indigo-robot-state-publisher\
	ros-indigo-ros-control\
	ros-indigo-moveit-commander\
	ros-indigo-moveit-planners-ompl
RUN apt-get install -y apt-file
RUN apt-file update
RUN apt-file search add-apt-repository
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:floe/libusb && apt-get update -qq && apt-get install -y libusb-1.0-0-dev && apt-get install -y ros-indigo-rosbridge-server
RUN apt-get install -y libturbojpeg libjpeg-turbo8-dev
RUN dpkg -i debs/libglfw3*deb; sudo apt-get install -f; apt-get install -y libgl1-mesa-dri-lts-vivid
RUN add-apt-repository ppa:pmjdebruijn/beignet-testing; apt-get update -qq; apt-get install -y beignet-dev;
RUN git clone https://github.com/OpenKinect/libfreenect2.git
RUN cd libfreenect2\
	mkdir build
WORKDIR /motoman_project_ws/libfreenect2/build
RUN cmake ..
RUN make
RUN make install
RUN ldconfig
RUN apt-get install -y ros-indigo-gazebo-ros
# rosdep
WORKDIR /motoman_project_ws
RUN rosdep install -i --from-paths src
# compile
#RUN catkin_make
# gazebo
#CMD [ "roslaunch","motoman_gazebo sia5_empty_world.launch" ]
#RUN rm /bin/sh && mv /bin/sh_tmp /bin/sh
