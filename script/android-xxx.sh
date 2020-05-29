
function android_pre_tool_check_xxx() {
  local library_name=$1
  local library_version=$2
  common_pre_tool_check $library_name
  if [[ -z ${ANDROID_HOME} ]]; then
    echo "ANDROID_HOME not defined, example 'export ANDROID_HOME=/Users/zuoyu/Library/Android/sdk'"
    exit 1
  fi

  if [[ -z ${ANDROID_NDK_ROOT} ]]; then
    echo "ANDROID_NDK_ROOT not defined, example 'ANDROID_NDK_ROOT=$ANDROID_HOME/ndk-bundle'"
    exit 1
  fi
}

function android_pre_download_zip_xxx() {
  local library_name=$1
  local download_url=$2
  local saved_zip_path=$3
  common_pre_download_zip $library_name $download_url $saved_zip_path
  if [ ! -r ${saved_zip_path} ]; then
    curl -SL "$download_url" -o "$saved_zip_path" || ret="no"
    if [ "no" = $ret ]; then
      rm -rf "$saved_zip_path" && exit 1
    fi
  fi
}

function android_build_unzip_xxx() {
  local library_name=$1
  local saved_zip_path=$2
  local unzip_output_dir=$3
  local unzip_src=$4
  common_build_unzip $library_name $saved_zip_path $unzip_output_dir $unzip_src
  if [ -d "${unzip_output_dir}/${unzip_src}" ]; then
    rm -rf "${unzip_output_dir}/${unzip_src}"
  fi
  local ret="yes"
  tar -x -C "$unzip_output_dir" -f "$saved_zip_path" || ret="no"
  if [ "no" = ret ]; then
    rm -rf "$saved_zip_path" && exit 1
  fi
}

function android_build_config_xxx() {
  local library_name=$1
  local arch=$2
  common_build_config $library_name $arch
}

function android_buid_make_xxx() {
  local library_name=$1
  common_buid_make $library_name
}

function android_archive_xxx() {
  local library_name=$1
  common_archive $library_name
}
