#define kIdentifier CFSTR("com.derv82.exchangentprefs")

BOOL pref_bool(CFStringRef key, BOOL defaultValue) {
 id value = (id) CFPreferencesCopyAppValue(key, kIdentifier);
 HBLogDebug(@"Exchangent pref_bool key: %@ value: %@", key, value);
 return value ? [value boolValue] : defaultValue;
}

NSString *pref_string(CFStringRef key, NSString *defaultValue) {
  id value = (id) CFPreferencesCopyAppValue(key, kIdentifier);
  HBLogDebug(@"Exchangent pref_string key: %@ value: %@", key, value);
  return value ? (NSString *) value : defaultValue;
}

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  HBLogDebug(@"Exchangent notificationCallback() for %@", name);
  CFPreferencesAppSynchronize(kIdentifier);
}

%hook DATaskManager

-(id)userAgent {
  id defaultUserAgent = %orig;

  BOOL prefIsEnabled = pref_bool(CFSTR("enabled"), YES);
  BOOL prefUseCustom = pref_bool(CFSTR("useCustom"), NO);
  NSString *prefDevice = pref_string(CFSTR("device"), @"iPhone8C2");

  HBLogDebug(@"Exchangent isEnabled: %d", prefIsEnabled);
  HBLogDebug(@"Exchangent useCustom: %d", prefUseCustom);
  HBLogDebug(@"Exchangent device: %@", prefDevice);

  if (!prefIsEnabled) {
    HBLogDebug(@"Exchangent is disabled. Using default userAgent: %@", defaultUserAgent);
    //return defaultUserAgent;
  }

  id newAgent = @"iPhone8C2/1307.36";
  HBLogDebug(@"Exchangent is enabled. Using overridden userAgent: %@", newAgent);
  return newAgent;
}

%end

%ctor {
  notificationCallback(NULL, NULL, NULL, NULL, NULL);
  CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(),
      NULL,
      (CFNotificationCallback)notificationCallback,
      CFStringCreateWithFormat(NULL, NULL, CFSTR("%@/saved"), kIdentifier),
      NULL,
      CFNotificationSuspensionBehaviorCoalesce);
}

