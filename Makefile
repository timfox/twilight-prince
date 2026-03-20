# Convenience targets; ninja still performs the build.
# Extra flags: make configure CONFIGURE_ARGS="--version GZ2P01 --map"

.PHONY: help configure build rebuild check-env native-port-setup tp-port-ubuntu-deps apply-tp-port-patches sync-tp-port-assets

CONFIGURE_ARGS ?=

help:
	@echo "Targets:"
	@echo "  make configure    python3 configure.py  (optional: CONFIGURE_ARGS=\"...\")"
	@echo "  make build          ninja"
	@echo "  make rebuild        configure then build"
	@echo "  make check-env      verify tools and orig/ layout"
	@echo "  make native-port-setup   clone mbayonal/tp-port + Aurora (see docs/native-port-resources.md)"
	@echo "  make tp-port-ubuntu-deps apt packages for tp-port on Ubuntu (see docs/native-port-ubuntu.md)"
	@echo "  make apply-tp-port-patches  apply contrib/patches to TP_PORT_DIR checkout"
	@echo "  make sync-tp-port-assets  copy build/<VER>/include/assets -> tp-port/assets (after decomp ninja)"

configure:
	python3 configure.py $(CONFIGURE_ARGS)

build:
	ninja

rebuild: configure build

check-env:
	@bash scripts/check-env.sh

native-port-setup:
	@bash scripts/setup-native-port.sh

tp-port-ubuntu-deps:
	@bash scripts/setup-tp-port-ubuntu-deps.sh

apply-tp-port-patches:
	@bash scripts/apply-tp-port-patches.sh

sync-tp-port-assets:
	@bash scripts/sync-tp-port-assets.sh
