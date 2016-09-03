include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = Exchangent
Exchangent_FILES = exchangentRootListController.m
Exchangent_INSTALL_PATH = /Library/PreferenceBundles
Exchangent_FRAMEWORKS = UIKit
Exchangent_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/Exchangent.plist$(ECHO_END)
