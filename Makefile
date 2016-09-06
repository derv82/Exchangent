include $(THEOS)/makefiles/common.mk

# Saw other people add this to their Makefile, so I added it.
ARCHS = armv7 armv7s arm64

TWEAK_NAME = Exchangent
Exchangent_FILES = Tweak.xm
# Don't need any frameworks... apparently?
#
include $(THEOS_MAKE_PATH)/tweak.mk

# Tweak needs to restart MobileMail and Preferences.
after-install::
	install.exec "killall -9 MobileMail; killall -9 Preferences; exit 0"

# Include the Preference Bundle subproject
SUBPROJECTS += exchangentprefs

include $(THEOS_MAKE_PATH)/aggregate.mk
