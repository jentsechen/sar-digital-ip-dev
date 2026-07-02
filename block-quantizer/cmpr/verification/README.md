## How to build
```
mkdir build
cd build
rm CMakeCache.txt
cmake ..
make
```
## How to run compressor
* Run by default input and save by default output
    * `./build/data_comp`
* Run by self-defined input `<file_name>.json` and save by default output
    * `./build/data_comp <file_name>.json`
* Run by self defined-input `<file_name>.json` and save by self-defined output `<folder_path>/<test_mode>_golden.json`
    * `./build/data_comp <file_name>.json`
* Default input: `./simset.json`
* Default output: `./<test_mode>_golden.json`
    * `<test_mode>`: `bypass`, `baq`, `bfpq`
