@interface NSUserDefaults (Private)
- (instancetype)_initWithSuiteName:(NSString *)suiteName container:(NSURL *)container;
- (instancetype)initWithSuiteName:(NSString *)suitename;
@end

static NSString *const kPreferencesDomain = @"com.derv82.exchangentprefs";
NSUserDefaults *userDefaults;

%ctor {
  // Initialize settings 
  userDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];
  [userDefaults registerDefaults:@{
       @"enabled": @YES,
     @"useCustom": @NO,
        @"device": @"iPhone8C2",
    @"iosVersion": @"1307.36",
  }];
};

%hook DATaskManager

-(id)userAgent {
  id defaultUserAgent = %orig;

  BOOL prefIsEnabled = [userDefaults boolForKey:@"enabled"];
  BOOL prefUseCustom = [userDefaults boolForKey:@"useCustom"];
  NSString *prefDevice = [userDefaults stringForKey:@"device"];

  HBLogDebug(@"Exchangent userDefaults: %@", [userDefaults dictionaryRepresentation]);

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

