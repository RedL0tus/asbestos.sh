source "${ASBESTOS_PROGRAM_DIR}/utils.sh";

function _request_api {
	curl -sS --unix-socket "${1}/run/${2}-api.sock" -i \
		-X PUT "http://localhost/${3}" \
		-H 'Accept: application/json' \
		-H 'Content-Type: application/json' \
		-d "${4}";
}

function _vm_setup {
	_print "Setting up \"${3}\"";
	_request_api "${1}" "${2}" "${3}" "${4}" > /dev/null;
}

function _vm_config_create {
	_print "Creating virtual machine configuration for ${2}";
	read -p "Enter core count: " _core_count;
	read -p "Enter size of RAM (in MB): " _size_ram;
	read -p "Enter kernel to use: " _kernel_name;
	read -p "Enter rootfs to use: " _rootfs_name;
	_config="CORE_COUNT=${_core_count};\nSIZE_RAM=${_size_ram};\nKERNEL_NAME=${_kernel_name};\nROOTFS_NAME=${_rootfs_name};\n";
	_print "Got this config: ";
	echo -e "${_config}";
	read -p "Save? (y/N)" _save
	if ! [[ "${_save}" == "y" || "${_save}" == "Y" ]]; then
		_eprint "Abort";
		exit 1;
	fi
	_config_path="${1}/machines/${2}.conf";
	echo -e "${_config}" > "${_config_path}";
	_print "Configuration saved to ${_config_path}";
}

function _vm_list {
	_print "Listing VM name and status:";
	printf "%-20s %-7s %-10s\n" "NAME" "STATE" "[PID]";
	for _conf in $(ls "${1}/machines"); do
		_vm_name="${_conf%.conf}";
		if [[ -S "${1}/run/${_vm_name}-console.sock" && -S "${1}/run/${_vm_name}-api.sock" ]]; then
			_vm_state="Started";
		else
			_vm_state="Stopped";
		fi
		if [[ -f "${1}/run/${_vm_name}.pid" ]]; then
			_vm_pid=$(cat "${1}/run/${_vm_name}.pid");
			_vm_pid="[${_vm_pid}]";
		fi
		printf "%-20s %-7s %-10s\n" "${_vm_name}" "${_vm_state}" "${_vm_pid-}";
	done
}

function _vm_start {
	if ! [[ -f "${1}/machines/${2}.conf" ]]; then
		_eprint "VM configuration file not found, aborting...";
		exit 1;
	fi

	if [[ -S "${1}/run/${2}-api.sock" || -f "${1}/run/${2}.pid" ]]; then
		_eprint "VM ${2} has already been loaded, quitting...";
		exit 1;
	fi

	_print "Loading VM ${2}";
	_start_command="echo \$PPID > ${1}/run/${2}.pid; /usr/bin/env firecracker --api-sock \"${1}/run/${2}-api.sock\" --id \"${2}\"; rm \"${1}/run/${2}.pid\" \"${1}/run/${2}-api.sock\"";
	/usr/bin/env dtach -n "${1}/run/${2}-console.sock" /bin/bash -c "${_start_command}";

	_print "Checking if firecracker has been correctly started...";
	while ! [[ -S "${1}/run/${2}-api.sock" ]]; do
		sleep 1;
	done
	_print "API socket created, setting up the virtual machine...";
	(
		source "${1}/machines/${2}.conf";
		_vm_setup "${1}" "${2}" "boot-source" "{ \"kernel_image_path\": \"${1}/kernel/${KERNEL_NAME}\", \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\" }";
		_vm_setup "${1}" "${2}" "drives/rootfs" "{ \"drive_id\": \"rootfs\", \"path_on_host\": \"${1}/rootfs/${ROOTFS_NAME}\", \"is_root_device\": true, \"is_read_only\": false }";
		_vm_setup "${1}" "${2}" "machine-config" "{ \"vcpu_count\": ${CORE_COUNT}, \"mem_size_mib\": ${SIZE_RAM}, \"ht_enabled\": false }";
		_vm_setup "${1}" "${2}" "actions" "{ \"action_type\": \"InstanceStart\" }";
	)

	_print "VM ${2} started, use \"asbestos.sh vm attach ${2}\" to attach to the console";
}

function _vm_attach {
	if ! [[ -S "${1}/run/${2}-console.sock" ]]; then
		_eprint "Console socket not found, abort";
		exit 1;
	fi
	_print "Press RIGHT control and ] (right square bracket) to detach from VM console";
	read -p "Press Enter to continue attaching to the console" _confirm;
	dtach -a "${1}/run/${2}-console.sock" -e '^]';
}

function _vm_kill {
	_print "Attempting to kill VM \"${2}\"";
	if [[ -f "${1}/run/${2}.pid" ]]; then
		_pid=$(cat "${1}/run/${2}.pid");
		kill -9 "${_pid}";
		if ps -p "${_pid}" > /dev/null; then
			_eprint "VM is still running after sending SIGKILL, probably stuck because I/O error, quitting...";
			exit 1;
		fi
		rm -v "${1}/run/${2}.pid";
	fi
	_print "Trying to remove socket files...";
	rm -v "${1}/run/${2}-console.sock" "${1}/run/${2}-api.sock";
}

function _vm_api {
	if ! [[ -S "${1}/run/${2}-api.sock" ]]; then
		_eprint "API socket not found for VM ${2}, abort";
		exit 1;
	fi
	_print "Sending ${4} to VM ${2}'s ${3} endpoint...";
	_request_api "${1}" "${2}" "${3}" "${4}";
}
