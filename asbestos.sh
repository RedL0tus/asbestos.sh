#!/usr/bin/env bash

set -euo pipefail;

ASBESTOS_PROGRAM_DIR="@ASBESTOS_LIB_DIR@";

# source "${ASBESTOS_PROGRAM_DIR}/config.sh";
source "${ASBESTOS_PROGRAM_DIR}/utils.sh";
source "${ASBESTOS_PROGRAM_DIR}/workspace.sh";
source "${ASBESTOS_PROGRAM_DIR}/vm.sh";

read -r -d '\0' _GENERAL_HELP_MESSAGE << EOM
asbestos.sh 0.0.1
A simple set of scripts for managing Firecracker MicroVMs

USAGE:
    asbestos.sh [SUBCOMMAND]

SUBCOMMANDS:
    rootfs    Manage rootfs images
    kernel    Manage kernel images
    vm        VM state and configuration managemenet
    help      Print this help message
\0
EOM

function _rootfs_subcommands {
	case "${1-help}" in
		"list")
			_list_rootfs "${ASBESTOS_WORK_DIR}";
		;;
		"download" | "dl")
			_download_rootfs "${ASBESTOS_WORK_DIR}" "${2}";
		;;
		"help")
			cat <<- EOM
			asbestos.sh rootfs 0.0.1
			rootfs subcommand for managing rootfs images

			USAGE:
			    asbestos.sh rootfs [SUBCOMMAND] [URL]

			SUBCOMMANDS:
			    list      List currently downloaded rootfs images
			    download  Download new rootfs image from the given URL
			    help      Print this help message
			EOM
		;;
		*)
			_eprint "Subcommand \"$1\" not found";
		;;
	esac
}

function _kernel_subcommands {
	case "${1-help}" in
		"list")
			_list_kernel "${ASBESTOS_WORK_DIR}";
		;;
		"download" | "dl")
			_download_kernel "${ASBESTOS_WORK_DIR}" "${2}";
		;;
		"help")
			cat <<- EOM
			asbestos.sh kernel 0.0.1
			kernel subcommand for managing kernel images

			USAGE:
			    asbestos.sh kernel [SUBCOMMAND] [URL]

			SUBCOMMANDS:
			    list      List currently downloaded kernel images
			    download  Download new kernel image from the given URL
			    help      Print this help message
			EOM
		;;
		*)
			_eprint "Subcommand \"$1\" not found";
		;;
	esac
}

function _vm_subcommands {
	case "${1-help}" in
		"list")
			_vm_list "${ASBESTOS_WORK_DIR}";
		;;
		"configure")
			_list_kernel "${ASBESTOS_WORK_DIR}";
			_list_rootfs "${ASBESTOS_WORK_DIR}";
			_vm_config_create "${ASBESTOS_WORK_DIR}" "${2}";
		;;
		"start")
			_vm_start "${ASBESTOS_WORK_DIR}" "${2}";
		;;
		"attach")
			_vm_attach "${ASBESTOS_WORK_DIR}" "${2}";
		;;
		"kill")
			_vm_kill "${ASBESTOS_WORK_DIR}" "${2}";
		;;
		"api")
			_vm_api "${ASBESTOS_WORK_DIR}" "${2}" "${3}" "${4}";
		;;
		"help")
			cat <<- EOM
			asbestos.sh vm 0.0.1
			VM sub command for virtual machine and configuration management

			USAGE:
			    asbestos.sh vm [SUBCOMMAND] [VM_NAME] [API_ENDPOINT] [DATA]

			SUBCOMMANDS:
			    list       List configured virtual machines
			    configure  Configure new virtual machine
			    start      Start a configured virtual machine
			    attach     Attach to the console of a running virtual machine
			    kill       Kill a virtual machine
			    api        Send API request to the virtual machine's API endpoint
			    help       Print this help message
			EOM
		;;
		*)
			_eprint "Subcommand \"$1\" not found";
		;;
	esac
}

function _main {
	if [[ "${1-help}" == "help" ]]; then
		echo "${_GENERAL_HELP_MESSAGE}";
		exit 0;
	fi

	if [[ -z "${ASBESTOS_WORK_DIR+x}" ]]; then
		_eprint "Environment variable ASBESTOS_WORK_DIR not set, abort";
		exit 1;
	fi

	# Check work directory hierachy and metadata
	_check_work_dir "${ASBESTOS_WORK_DIR}";

	# Parse command
	case "${1}" in
		"rootfs")
			_rootfs_subcommands "${@:2}";
		;;
		"kernel")
			_kernel_subcommands "${@:2}";
		;;
		"vm")
			_vm_subcommands "${@:2}";
		;;
		*)
			_eprint "Subcommand \"$1\" not found";
		;;
	esac
}

_main "$@";
