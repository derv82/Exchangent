// Exchangent, author: derv82
// Spoofs the Exchange/ActiveSync User-Agent sent by MobileMail/Calendar for iOS
// Tested on iPhone 6S+ on iOS 9.3.3

////////////////////////////////
// "Global" variables
CFStringRef const cfNotificationString = CFSTR("com.derv82.exchangentprefs/saved");
NSString *const nsPreferenceFile = @"/var/mobile/Library/Preferences/com.derv82.exchangentprefs.plist";

BOOL prefIsEnabled = YES;
NSMutableString *userAgent = [NSMutableString stringWithString:@"iPhone8C2/1307.36"];

/**
 * Reload preferences from file and set global variables/flags.
 */
static void reloadPrefs() {
  NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:nsPreferenceFile];

  id _value;

  _value = [prefs objectForKey:@"enabled"];
  prefIsEnabled = (_value != nil) ? [_value boolValue] : YES;

  _value = [prefs objectForKey:@"useCustom"];
  BOOL shouldUseCustom = (_value != nil) ? [_value boolValue] : NO;

  if (shouldUseCustom) {
    HBLogDebug(@"Using custom user agent");
    _value = [prefs objectForKey:@"customUserAgent"];
    [userAgent setString:(_value != nil) ? (NSString*) _value : @"iPhone8C2/1307.36"];
  }
  else {
    HBLogDebug(@"Exchangent constructing user agent from Device and iOS Version defined in Preferences");
    _value = [prefs objectForKey:@"device"];
    NSString *device = (_value != nil) ? (NSString*) _value : @"iPhone8C2";

    _value = [prefs objectForKey:@"iosVersion"];
    NSString *iosVersion = (_value != nil) ? (NSString*) _value : @"1307.36";

    [userAgent setString:[NSString stringWithFormat:@"%@/%@", device, iosVersion]];
  }
  HBLogDebug(@"Exchangent userAgent to use: %@", userAgent);
}

/**
 * Callback for when preferences have changed.
 * This should only be called by the Darwin notification center when Preferences have changed..
 */
static void prefsChanged(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  reloadPrefs();
}

%ctor {
  // Add observer to be notified when Preferences for this bundle change
  // When preferences change, call prefsChanged() to reload the preferences into this Tweak's global variables.
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
      NULL,
      &prefsChanged,
      cfNotificationString,
      NULL,
      CFNotificationSuspensionBehaviorDeliverImmediately);
  // Reload them anyway.
  reloadPrefs();
};

// Tweak entry point, overriding the DataAccess (DA) Task Manager
// See also https://github.com/kennytm/iphone-private-frameworks/blob/master/DataAccess/DATaskManager.h
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
