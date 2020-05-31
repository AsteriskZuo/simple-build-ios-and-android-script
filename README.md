# simple-build-ios-and-android-script
## Documentation
### Introduction
> #### A common build project for building mobile platform native libraries.
### Target users
> #### Mobile platform C&&C++ native library.
### Build target library list:
> | id | name | version | dependent libraries | note |
> | :- | :--- | :------ | :------------------ | :--- |
> | 1  | openssl | 1.1.1d | no | Configure is perl script |
> | 2  | nghttp2 | 1.40.0 | no | no |
> | 3  | curl | 7.68.0 | openssl,nghttp2 | no |
### Extended instructions
> #### Use the entry script to build the target library.  
> #### ios.sh is the ios platform entry script.  
> #### android.sh is the android platform entry script.  
> #### Advanced use:  
> | target version | test result |  
> | :---- | :---- | 
> | default | pass |   
> | higher | generally pass |  
> | low | maybe not pass |  
### Contribution notes
> #### Adding subscripts requires some experience in scripting and project building.
> #### Adding subscripts can generally be a contributor to the project.
> #### Adding subscript details:
> * Update parameters:
>   + `COMMON_LIBRARY_ID_LIST`
>   + `COMMON_LIBRARY_NAME_LIST`
>   + `COMMON_LIBRARY_VERSION_LIST`
>   + `COMMON_LIBRARY_URL_LIST`
> * Update method:
>   + `common_get_library_id_from_name`
> * script:
>   + Usage agreement:
>     - A script method or function needs to use the keyword `function`.
>     - Global variables need to use the keyword `export` and are combined with uppercase alphanumeric and underlined characters.
>     - Script methods or local variables within functions use the keyword `local`.
>     - Methods within the common.sh script need to use the prefix `common_`.
>     - ios-*.sh script methods need to use the prefix `ios_`.
>     - android-*.sh script methods need to use the prefix `android_`.
>     - Methods in the util. Sh script require the prefix `util_`.
>     - Methods within the subscript need to use the prefix `xxx_`.
>     - Composite scripts require the use of composite prefixes.
>   + Method implementation:
>     - `${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_printf_variable`: (optional)
>     - `${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_pre_tool_check`: (must)
>     - `${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_pre_download_zip`: (must)
>     - `${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_build_unzip`: (must)
>     - `${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_build_config_make`: (must)
>     - `${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_archive`: (must)
> * Contribution notes:
>   + asteriskzuo: Create the project and complete the main frame design.
## Architecture design
### Programming language
> #### bash shell script
### Build platform:
> #### MaoOS
> #### Linux: **`TODO`**
### Target platform:
> #### iOS
> #### Android
### Core ideas:
> * Plug-in programming:
>   + You can build the target library by writing a corresponding subscript and adding parameters.
> * Dynamic call:
>   + Similar to C++ polymorphism.
> * High reusability:
>   + All code blocks are encapsulated using methods (functions).
> * Dependent detection:
>   + Build target library dependency detection:
>     - manual build
>     - auto build all dependency target library: **`TODO`**
> * To reconstruct the configure: **`TODO`**
### Project structure:
> * Input:
>   + Source directory:
>     - GNU make project: 
>     - cmake project: No build script is required. The iOS platform has a better way, and the Android platform directly introduces cmakelist files.
>   + Build tools:
>     - iOS independent compiler tool chain
>     - Android independent compiler tool chain.
>     - More ...
> * Output:
>   + Interim interim documents:
>     - Temporary intermediate file.
>     - Build the library product.
>   + Build library products:
> * Script:
>   + Entry script:
>     - ios.sh: iOS platform entry script.
>     - android.sh: Android platform entry script.
>   + Tool script:
>     - util.sh: Provide various basic functions.
>     - log.sh: Provide various basic functions.
>     - common.sh: Provide common functions for iOS and Android platforms.
>     - ios-common.sh: Provide common functions for iOS platform.
>     - android-common.sh: Provide common functions of Android platform.
>   + Subscript(plug-in script):
>     - ios-openssl.sh:
>     - android-openssl.sh:
>     - ios-curl.sh:
>     - android-curl.sh:
>     - More ...
## Problems to be solved
### Only current list item builds are supported.
### Project-made versions can be built, but may not be built properly for lower versions.
### Building the dependencies of the target project requires manual construction.
## Reference
> [openssl_for_ios_and_android](https://github.com/AsteriskZuo/openssl_for_ios_and_android)
## Document
> [simple-build-ios-and-android-script](./document/simple-build-ios-and-android-script.html)