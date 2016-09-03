include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Exchangent
Exchangent_FRAMEWORKS = UIKit
Exchangent_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileMail"
include $(THEOS_MAKE_PATH)/aggregate.mk
