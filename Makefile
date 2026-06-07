PROJECT_NAME ?= minebridge
SDK_NAME ?= macosx
DEPLOYMENT_TARGET ?= 14.0
TARGET_TRIPLE ?= arm64-apple-ios$(DEPLOYMENT_TARGET)-macabi
CONFIG ?= release
VERBOSE ?= 0

BUILD_DIR ?= build
DIST_DIR ?= dist
OUT ?= $(DIST_DIR)/$(PROJECT_NAME).dylib
OBJ_VARIANT = $(CONFIG)$(if $(filter 1 yes true,$(VERBOSE)),-verbose)
OBJ_DIR = $(BUILD_DIR)/obj/$(OBJ_VARIANT)

ifneq ($(words $(OUT)),1)
$(error OUT must not contain whitespace: $(OUT))
endif

XCRUN ?= xcrun
CLANG ?= $(XCRUN) --sdk $(SDK_NAME) clang
CODESIGN ?= codesign
SDK_PATH ?= $(shell $(XCRUN) --sdk $(SDK_NAME) --show-sdk-path)

SOURCES = $(sort $(wildcard bridge/*.m bridge/*/*.m))
OBJECTS = $(patsubst %.m,$(OBJ_DIR)/%.o,$(SOURCES))
DEPS = $(OBJECTS:.o=.d)

TARGET_FLAGS = -target $(TARGET_TRIPLE) -isysroot $(SDK_PATH)
DEPFLAGS = -MMD -MP -MF $(@:.o=.d) -MT $@
OPTFLAGS_release ?= -O2
OPTFLAGS_debug ?= -O0 -g
OPTFLAGS = $(OPTFLAGS_$(CONFIG))

CPPFLAGS += $(if $(filter 1 yes true,$(VERBOSE)),-DMC_KEYBOARD_BRIDGE_VERBOSE=1)
OBJCFLAGS += $(OPTFLAGS) -fobjc-arc -fblocks -fvisibility=hidden -Wall -Wextra -Wno-unused-parameter
LDFLAGS += -dynamiclib
LDLIBS += -framework Foundation
CODESIGN_FLAGS ?= --force --sign -

.DELETE_ON_ERROR:

.PHONY: all build release debug verbose clean clean-dist help print-config inspect FORCE

all: $(OUT)

build: all

release:
	$(MAKE) CONFIG=release VERBOSE=$(VERBOSE) OUT="$(OUT)" all

debug:
	$(MAKE) CONFIG=debug VERBOSE=$(VERBOSE) OUT="$(OUT)" all

verbose:
	$(MAKE) CONFIG=$(CONFIG) VERBOSE=1 OUT="$(OUT)" all

$(OUT): $(OBJECTS) FORCE
	mkdir -p "$(@D)"
	$(CLANG) $(TARGET_FLAGS) $(LDFLAGS) $(OBJECTS) -o "$@" $(LDLIBS)
	$(CODESIGN) $(CODESIGN_FLAGS) "$@" >/dev/null

$(OBJ_DIR)/%.o: %.m Makefile
	mkdir -p "$(@D)"
	$(CLANG) $(TARGET_FLAGS) $(CPPFLAGS) $(OBJCFLAGS) $(DEPFLAGS) -c "$<" -o "$@"

clean:
	rm -rf $(BUILD_DIR)

clean-dist:
	rm -f $(OUT)

help:
	@printf '%s\n' \
	  'Targets:' \
	  '  make                 Build dist/minebridge.dylib' \
	  '  make verbose         Build with MC_KEYBOARD_BRIDGE_VERBOSE=1' \
	  '  make debug           Build debug objects and dylib' \
	  '  make clean           Remove build objects and dependency files' \
	  '  make clean-dist      Remove OUT only' \
	  '  make inspect         Show Mach-O target and dylib dependencies' \
	  '' \
	  'Variables:' \
	  '  OUT=/path/file.dylib Override output path' \
	  '  VERBOSE=1            Enable trace logging define' \
	  '  CONFIG=debug         Use debug object directory and flags' \
	  '  DEPLOYMENT_TARGET=14.0 Override Mac Catalyst deployment target'

print-config:
	@printf 'PROJECT_NAME=%s\n' '$(PROJECT_NAME)'
	@printf 'CONFIG=%s\n' '$(CONFIG)'
	@printf 'VERBOSE=%s\n' '$(VERBOSE)'
	@printf 'TARGET_TRIPLE=%s\n' '$(TARGET_TRIPLE)'
	@printf 'SDK_PATH=%s\n' '$(SDK_PATH)'
	@printf 'OBJ_DIR=%s\n' '$(OBJ_DIR)'
	@printf 'OUT=%s\n' '$(OUT)'

inspect: $(OUT)
	file "$(OUT)"
	vtool -show-build "$(OUT)"
	otool -L "$(OUT)"

FORCE:

-include $(DEPS)
