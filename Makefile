GO_EASY_ON_ME = 1

ARCHS = arm64

include $(THEOS)/makefiles/common.mk

TOOL_NAME = ioclient
ioclient_FILES = $(wildcard *.mm *.m *.c)
ioclient_CODESIGN_FLAGS = -Sent.xml
ioclient_PRIVATE_FRAMEWORKS = IOKit
ioclient_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tool.mk
