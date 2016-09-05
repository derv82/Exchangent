CFStringRef const cfNotificationString = CFSTR("com.derv82.exchangentprefs/saved");
NSString *const nsPreferenceFile = @"/var/mobile/Library/Preferences/com.derv82.exchangentprefs.plist";

BOOL prefIsEnabled,
     prefUseCustom;
NSString *prefDevice;

static void reloadPrefs() {
  NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:nsPreferenceFile];
  HBLogDebug(@"Exchangent reloadPrefs(). prefs: %@", prefs);

  id _value;

  _value = [prefs objectForKey:@"enabled"];
  prefIsEnabled = (_value != nil) ? [_value boolValue] : YES;

  _value = [prefs objectForKey:@"useCustom"];
  prefUseCustom = (_value != nil) ? [_value boolValue] : NO;

  _value = [prefs objectForKey:@"device"];
  prefDevice = (_value != nil) ? _value : @"iPhone8C2";
}

static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  reloadPrefs();
}

%ctor {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
      NULL,
      &prefsChanged,
      cfNotificationString,
      NULL,
      CFNotificationSuspensionBehaviorDeliverImmediately);
  reloadPrefs();
};

%hook DATaskManager

-(id)userAgent {
  id defaultUserAgent = %orig;

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

