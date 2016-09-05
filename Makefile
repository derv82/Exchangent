include $(THEOS)/makefiles/common.mk

ARCHS = armv7 armv7s arm64

TWEAK_NAME = Exchangent
#Exchangent_FRAMEWORKS = UIKit
Exchangent_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileMail; exit 0"

SUBPROJECTS += exchangentprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
