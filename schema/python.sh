persistent_path="${persistent_path}/python/$image_version}"
entrypoint="python"
volume=(
    "$current_path:$current_path"
    "$persistent_path:$persistent_path_container"
)
env=(
    "PATH=$persistent_path_container/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
    "PYTHONUSERBASE=$persistent_path_container"
)

