# simple-build-ios-and-android-script
Build iOS and Android C&&C++ library cross compile shell script on MacOS.
## Use build script
- ios.sh is main build script on iOS platform.
- android.sh is main build script on Android platform.
- Other scripts do not need to be used directly. 
## Support library list
- Only items in the list are supported to be built. 
- See the currently supported build items in _common.sh (${COMMON_LIBRARY_NAME_LIST}).
## Add subscript considerations
### The project architecture supports extended subscripts.
### The specific parameters involved in adding the subscript are as follows:
 - COMMON_LIBRARY_ID_LIST
 - COMMON_LIBRARY_NAME_LIST
 - COMMON_LIBRARY_VERSION_LIST
 - COMMON_LIBRARY_URL_LIST
 - common_get_library_id_from_name
### The following rules apply to adding subscripts:
 - Implement the following methods:  
  1. ${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_printf_variable         : (optional)
  2. ${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_pre_tool_check          : (must)
  3. ${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_pre_download_zip        : (must)
  4. ${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_build_unzip             : (must)
  5. ${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_build_config_make       : (must)
  6. ${COMMON_PLATFORM_TYPE}_${COMMON_LIBRARY_NAME}_archive                 : (must)
 - Please follow the naming conventions and rules.  
  1. Use the keyword function for the method.
  2. Use the keyword local for local variable.
  3. Use common_ prefix in _common.sh script.
  4. Use ios_ prefix in ios-*.sh script.
  5. Use android_ prefix in android-*.sh script.
  6. Use util_ prefix in __util.sh script.
  7. Use ${COMMON_LIBRARY_NAME}_ prefix in subscript.
## Contributor
 - asteriskzuo, zuoyuhsywn@hotmail.com