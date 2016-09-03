include $(THEOS)/makefiles/common.mk

TWEAK_NAME = MailForce935
MailForce935_FRAMEWORKS = UIKit
MailForce935_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 MobileMail"
SUBPROJECTS += mailforce935settings
include $(THEOS_MAKE_PATH)/aggregate.mk
