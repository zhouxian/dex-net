#!/bin/sh

# read cmd line inputs
VERSION=$1 # cpu or gpu
MODE=$2 # python or ros

# set cpu/gpu conditional libraries
case "${VERSION}"
in
cpu)
	TENSORFLOW_LIB=tensorflow
	;;
gpu)
	TENSORFLOW_LIB=tensorflow-gpu
	;;
*)
	echo "Usage: $0 {cpu|gpu} {python|ros}"
	exit 1
esac

echo "Installing Dex-Net in ${MODE} mode with ${VERSION} support"

# set workspace
case "${MODE}"
in
python)
	MODULES_DIR=deps # installs modules in deps folder
	;;
ros)
	MODULES_DIR=../ # installs in catkin workspace
	;;
*)
	echo "Usage: $0 {cpu|gpu} {python|ros}"
	exit 1
esac

# install apt deps
sudo apt-get install cmake libvtk5-dev python-vtk python-sip python-qt4 libosmesa6-dev meshlab libhdf5-dev libboost-python-dev

# if necessary (probably when without discrete gpu)
# sudo apt-get install freeglut3-dev libxmu-dev libxi-dev

# if necessary
# sudo apt-get install python-tk

# install pip deps
pip install numpy scipy scikit-learn scikit-image opencv-python pyassimp tensorflow h5py mayavi matplotlib catkin_pkg multiprocess dill cvxopt ipython==5.5.0 pillow pyhull setproctitle trimesh meshpy
pip install msgpack

# install assimp
cd ..
git clone https://github.com/assimp/assimp.git
cd assimp
cmake CMakeLists.txt -G 'Unix Makefiles'
sudo make
sudo make install
cd ..
sudo rm -rf assimp
cd dex-net

# install deps from source
mkdir deps
cd deps

# install SDFGen
git clone https://github.com/jeffmahler/SDFGen.git
cd SDFGen
sudo sh install.sh
cd ..

# install Boost.NumPy
git clone https://github.com/jeffmahler/Boost.NumPy.git
cd Boost.NumPy
sudo sh install.sh
sudo sh -c "echo '/usr/local/lib
/usr/local/lib64' > /etc/ld.so.conf.d/boost_numpy.conf"
sudo ldconfig
cd ..

# return to dex-net directory
cd ..

# install autolab modules
cd ${MODULES_DIR}
git clone https://github.com/BerkeleyAutomation/autolab_core.git
git clone https://github.com/zhouxian/perception.git
git clone https://github.com/BerkeleyAutomation/gqcnn.git
git clone https://github.com/zhouxian/meshpy_berkeley.git
git clone https://github.com/BerkeleyAutomation/visualization.git
git clone https://github.com/BerkeleyAutomation/meshrender.git

# install meshpy_berkeley
cd meshpy_berkeley
sudo python setup.py develop
cd ../

# install meshrender
cd meshrender
sudo python setup.py develop
cd ../

# install all Berkeley AUTOLAB modules
case "${MODE}"
in
python)
	# autolab_core
	cd autolab_core
	sudo python setup.py develop
	cd ..

	# perception
	cd perception
	sudo python setup.py develop
	cd ..

	# gqcnn
	cd gqcnn
	sudo python setup.py develop
	cd ..

	# visualization
	cd visualization
	sudo python setup.py develop
	cd ..
	cd ..
	;;
ros)
	# catkin
	cd ..
	catkin_make
	source devel/setup.bash
	cd src/dex-net
	;;
*)
	echo "Usage: $0 {cpu|gpu} {python|ros}"
	exit 1
esac

# install dex-net
sudo python setup.py develop
