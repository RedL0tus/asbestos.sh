PREFIX="/usr/local"
BINDIR="$(PREFIX)/bin"
LIBDIR="$(PREFIX)/lib/asbestos-sh"

asbestos.sh-new: asbestos.sh
	sed -e 's|@ASBESTOS_LIB_DIR@|$(LIBDIR)/|g' asbestos.sh > asbestos.sh-new

install: asbestos.sh-new
	install -Dvm755 asbestos.sh-new $(BINDIR)/asbestos.sh
	install -Dvm755 utils.sh $(LIBDIR)/utils.sh
	install -Dvm755 vm.sh $(LIBDIR)/vm.sh
	install -Dvm755 workspace.sh $(LIBDIR)/workspace.sh
