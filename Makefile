# Convenience targets; ninja still performs the build.
# Extra flags: make configure CONFIGURE_ARGS="--version GZ2P01 --map"

.PHONY: help configure build rebuild check-env

CONFIGURE_ARGS ?=

help:
	@echo "Targets:"
	@echo "  make configure    python3 configure.py  (optional: CONFIGURE_ARGS=\"...\")"
	@echo "  make build          ninja"
	@echo "  make rebuild        configure then build"
	@echo "  make check-env      verify tools and orig/ layout"

configure:
	python3 configure.py $(CONFIGURE_ARGS)

build:
	ninja

rebuild: configure build

check-env:
	@bash scripts/check-env.sh
