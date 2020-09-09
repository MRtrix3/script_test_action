git clone -b $1 --depth 1 https://github.com/MRtrix3/mrtrix3.git .
./configure -nogui
./build
run_tests scripts || ( cat testing_scripts.log && exit 1 )

