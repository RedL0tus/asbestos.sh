__RED='\033[0;31m';
__GREEN='\033[0;32m';
__CLEAR='\033[0m';

function _print {
	echo -e "${__GREEN}>>>${__CLEAR} asbestos.sh: ${1}";
}

function _eprint {
	echo -e "${__RED}>>>${__CLEAR} asbestos.sh: ${1}";
}

function _download {
        _print "Downloading ${1} from: ${3}";
        pushd "${2}";
        curl -fOL "${3}";
        popd
}
