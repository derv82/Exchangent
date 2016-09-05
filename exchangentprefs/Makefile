include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ExchangentPrefs
ExchangentPrefs_FILES = ExchangentPrefsRootListController.m
ExchangentPrefs_INSTALL_PATH = /Library/PreferenceBundles
ExchangentPrefs_FRAMEWORKS = UIKit
ExchangentPrefs_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/ExchangentPrefs.plist$(ECHO_END)

after-install::
	install.exec "killall -9 Preferences; exit 0"
