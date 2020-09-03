git clone https://github.com/MRtrix3/mrtrix3.git .
git checkout $1
./configure -nogui
./build
run_tests scripts || ( cat testing_scripts.log && exit 1 )

