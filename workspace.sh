source "${ASBESTOS_PROGRAM_DIR}/utils.sh";

_ASBESTOS_WORKSPACE_UTIL_VERSION=0;
_ASBESTOS_WORKSPACE_VERSION_MAX=0;
_ASBESTOS_WORKSPACE_VERSION_MIN=0;

function _create_hierachy {
	_print "Creating workspace (version ${_ASBESTOS_WORKSPACE_UTIL_VERSION})...";
	{
		echo "_ASBESTOS_WORKSPACE_VERSION=\"${_ASBESTOS_WORKSPACE_UTIL_VERSION}\"";
	} > "${1}/meta.sh";
	mkdir -p "${1}/rootfs" "${1}/kernel" "${1}/machines" "${1}/run";
}

function _check_work_dir {
	if [[ -f "${1}" || ! -d "${1}" ]]; then
		_eprint "Workspace directory not found or is a file, quitting...";
		exit 1
	fi

	if [[ ! -f "${1}/meta.sh" ]]; then
		_eprint "Metadata not found in the working area, initializing...";
		_create_hierachy "${1}";
	fi

	source "${1}/meta.sh";
	if [[ _ASBESTOS_WORKSPACE_VERSION -gt _ASBESTOS_WORKSPACE_VERSION_MAX || \
		_ASBESTOS_WORKSPACE_VERSION -lt _ASBESTOS_WORKSPACE_VERSION_MIN ]]; then
		_eprint "Workspace version (${_ASBESTOS_WORKSPACE_VERSION}) not supported, quitting...";
	fi
	_print "Found supported workspace at ${1}";
}

function _list_vm {
	for file in $(ls "${1}/run"); do
		echo "${file}";
	done
}

function _list_rootfs {
	_rootfs_files=$(ls "${1}/rootfs");
	_print "Available rootfs images: ${_rootfs_files}";
}

function _list_kernel {
	_kernel_files=$(ls "${1}/kernel");
	_print "Available kernel images: ${_kernel_files}";
}

function _download_rootfs {
	_download "rootfs image" "${1}/rootfs" "${2}"
}

function _download_kernel {
	_download "kernel image" "${1}/kernel" "${2}"
}
