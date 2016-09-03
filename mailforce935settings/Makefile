include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MailForce935Settings
MailForce935Settings_FILES = MailForce935RootListController.m
MailForce935Settings_INSTALL_PATH = /Library/PreferenceBundles
MailForce935Settings_FRAMEWORKS = UIKit
MailForce935Settings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/MailForce935Settings.plist$(ECHO_END)
