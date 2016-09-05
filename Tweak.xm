#include <substrate.h>

@interface NSUserDefaults (Private)
- (id)objectForKey:(NSString *)key inDomain:(NSString *)domain;
- (void)setObject:(id)value forKey:(NSString *)key inDomain:(NSString *)domain;
@end

static NSString *nsDomainString = @"com.derv82.exchangent";
static NSString *nsNotificationString = @"com.derv82.exchangent/saved";

NSMutableDictionary *settings;
BOOL prefIsEnabled;
BOOL prefUseCustom;
NSString *prefDevice;
NSString *prefIosVersion;
NSString *prefCustomUserAgent;
NSString *prefPresetUserAgent;
NSString *settingsPath = @"/var/mobile/Library/Preferences/com.derv82.exchangent.plist";
NSString *userAgentToUse;

static void notificationCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {
  HBLogDebug(@"Exchangent notificationCallback()");
  NSNumber *n = (NSNumber *) [[NSUserDefaults standardUserDefaults] objectForKey:@"enabled" inDomain:nsDomainString];
  prefIsEnabled = (n) ? [n boolValue] : YES;

  n = (NSNumber *) [[NSUserDefaults standardUserDefaults] objectForKey:@"useCustom" inDomain:nsDomainString];
  prefUseCustom = (n) ? [n boolValue] : NO;

  settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
  //prefIsEnabled       = [[settings objectForKey:@"enabled"]   boolValue];
  //prefUseCustom       = [[settings objectForKey:@"useCustom"] boolValue];
  prefDevice          = [settings objectForKey:@"device"];
  prefIosVersion      = [settings objectForKey:@"iosVersion"];
  prefCustomUserAgent = [settings objectForKey:@"userAgent"];

  prefPresetUserAgent = [NSString stringWithFormat:@"%@/%@", prefDevice, prefIosVersion];

  if (prefUseCustom) {
    userAgentToUse = prefCustomUserAgent;
  }
  else {
    userAgentToUse = prefPresetUserAgent;
  }
  HBLogDebug(@"Exchangent (notificationCallback) isEnabled: %d", prefIsEnabled);
  HBLogDebug(@"Exchangent (notificationCallback) useCustom: %d", prefUseCustom);
  HBLogDebug(@"Exchangent (notificationCallback) device: %@", prefDevice);
  HBLogDebug(@"Exchangent (notificationCallback) iosVersion: %@", prefIosVersion);
  HBLogDebug(@"Exchangent (notificationCallback) customUserAgent: %@", prefCustomUserAgent);
  HBLogDebug(@"Exchangent (notificationCallback) userAgentToUse: %@", userAgentToUse);
}

%ctor {
  notificationCallback(NULL, NULL, NULL, NULL, NULL);
  CFNotificationCenterAddObserver(
      CFNotificationCenterGetDarwinNotifyCenter(),
      NULL,
      notificationCallback,
      (CFStringRef)nsNotificationString,
      NULL,
      CFNotificationSuspensionBehaviorDeliverImmediately);
}

%hook DATaskManager

-(id)userAgent {
  id defaultUserAgent = %orig;

  /*
  HBLogDebug(@"Exchangent (hook) customUserAgent: %@", prefCustomUserAgent);
  HBLogDebug(@"Exchangent (hook) device: %@", prefDevice);
  HBLogDebug(@"Exchangent (hook) iosVersion: %@", prefIosVersion);
  */

  if (!prefIsEnabled) {
    HBLogDebug(@"Exchangent (hook) is disabled. Using default userAgent: %@", defaultUserAgent);
    return defaultUserAgent;
  }

  id newAgent = @"iPhone8C2/1307.36";
  HBLogDebug(@"Exchangent (hook) is enabled. Using overridden userAgent: %@", newAgent);
  return newAgent;
}

%end
