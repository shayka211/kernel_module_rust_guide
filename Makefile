# SPDX-License-Identifier: GPL-2.0

KDIR ?= /lib/modules/`uname -r`/build

default:
	$(MAKE) LLVM=1 -C $(KDIR) M=$$PWD

modules_install: default
	$(MAKE) -C $(KDIR) M=$$PWD modules_install

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean

# --- ADD THIS SECTION ---
# This generates rust-project.json for your IDE
rust-analyzer:
	$(MAKE) LLVM=1 -C $(KDIR) M=$$PWD rust-analyzer
