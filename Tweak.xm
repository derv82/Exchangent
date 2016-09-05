CFStringRef const cfNotificationString = CFSTR("com.derv82.exchangentprefs/saved");
NSString *const nsPreferenceFile = @"/var/mobile/Library/Preferences/com.derv82.exchangentprefs.plist";

BOOL prefIsEnabled = YES;
NSMutableString *userAgent = [NSMutableString stringWithString:@"iPhone8C2/1307.36"];

static void reloadPrefs() {
  NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:nsPreferenceFile];
  HBLogDebug(@"Exchangent reloadPrefs(). prefs: %@", prefs);

  id _value;

  _value = [prefs objectForKey:@"enabled"];
  prefIsEnabled = (_value != nil) ? [_value boolValue] : YES;

  _value = [prefs objectForKey:@"useCustom"];
  BOOL shouldUseCustom = (_value != nil) ? [_value boolValue] : NO;

  if (shouldUseCustom) {
    HBLogDebug(@"Exchangent shouldUseCustom:true, using custom user agent");
    _value = [prefs objectForKey:@"customUserAgent"];
    [userAgent setString:(_value != nil) ? (NSString*) _value : @"iPhone8C2/1307.36"];
    HBLogDebug(@"Exchangent customUserAgent: %@", userAgent);
  }
  else {
    HBLogDebug(@"Exchangent shouldUseCustom:false, constructing user agent");
    _value = [prefs objectForKey:@"device"];
    NSString *device = (_value != nil) ? (NSString*) _value : @"iPhone8C2";
    HBLogDebug(@"Exchangent device: %@", device);

    _value = [prefs objectForKey:@"iosVersion"];
    NSString *iosVersion = (_value != nil) ? (NSString*) _value : @"1307.36";
    HBLogDebug(@"Exchangent iosVersion: %@", iosVersion);

    [userAgent setString:[NSString stringWithFormat:@"%@/%@", device, iosVersion]];
  }
  HBLogDebug(@"Exchangent userAgent: %@", userAgent);
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
  HBLogDebug(@"Exchangent userAgent: %@", userAgent);

  if (!prefIsEnabled) {
    HBLogDebug(@"Exchangent is disabled. Using default userAgent: %@", defaultUserAgent);
    return defaultUserAgent;
  } else {
    HBLogDebug(@"Exchangent is enabled. Using overridden userAgent: %@", userAgent);
    return userAgent;
  }
}

%end

