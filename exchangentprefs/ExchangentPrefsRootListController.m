#import <Preferences/PSListController.h> // We're overriding this controller here.
#import <Preferences/PSSpecifier.h> // We need this to refer to PSSpecifier's "propreties" property.

#define nsPreferencesPath @"/User/Library/Preferences/com.derv82.exchangentprefs.plist"

@interface ExchangentPrefsRootListController : PSListController {
  BOOL shouldReload; // If the Specifiers should be reloaded from the Plist file.
}
@end

@implementation ExchangentPrefsRootListController

// Method for fetching the list of Specifies (i.e. elements in the Preferences pane)
-(id) specifiers {
  // Reload all elements if 1) they aren't loaded yet, or 2) something changed in the UI
  if (shouldReload) {
    shouldReload = NO;
    [_specifiers release];
    _specifiers = nil;
  }

  if (!_specifiers) {
    // Using MutableArray so we can remove certain elements as needed.
    NSMutableArray *specifiers = [[self loadSpecifiersFromPlistName:@"ExchangentPrefs" target:self] mutableCopy];

    // Get preference values, so we know what is enabled/disabled.
    NSDictionary *exchangentSettings = [NSDictionary dictionaryWithContentsOfFile:nsPreferencesPath];

    id _tempValue;

    // Check if tweak is enabled.
    _tempValue = [exchangentSettings objectForKey:@"enabled"];
    BOOL isTweakEnabled = _tempValue ? [_tempValue boolValue] : NO;

    // Check if "Use Custom user Agent" is enabled.
    _tempValue = [exchangentSettings objectForKey:@"useCustom"];
    BOOL isCustomEnabled = _tempValue ? [_tempValue boolValue] : NO;

    // Iterate over specifiers, tracking which elements that should not be displayed.
    NSMutableArray *specifiersToRemove = [[NSMutableArray alloc] init];
    for (PSSpecifier *specifier in specifiers) {
      // Huzzah for boolean logic.
      if (isCustomEnabled || !isTweakEnabled) {
        // Custom is enabled (or tweak is disabled), hide custom-related specifiers.
        if ([specifier.identifier isEqualToString:@"User-Agent for Device and Version"]) {
          [specifiersToRemove addObject:specifier];
        } else if ([specifier.identifier isEqualToString:@"Preset Versions"]) {
          [specifiersToRemove addObject:specifier];
        } else if ([specifier.identifier isEqualToString:@"Device"]) {
          [specifiersToRemove addObject:specifier];
        } else if ([specifier.identifier isEqualToString:@"iOS Version"]) {
          [specifiersToRemove addObject:specifier];
        } else if ([specifier.identifier isEqualToString:@"User-Agent"]) {
          [specifiersToRemove addObject:specifier];
        }
      }
      // Custom is disabled (or tweak disabled), hide custom-related specifiers.
      if (!isCustomEnabled || !isTweakEnabled) {
        if ([specifier.identifier isEqualToString:@"User-Agent:"]) {
          [specifiersToRemove addObject:specifier];
        }
      }

      // Tweak is disabled, hide everything except the Enable switch.
      if (!isTweakEnabled) {
        if ([specifier.identifier isEqualToString:@"Custom"]) {
          [specifiersToRemove addObject:specifier];
        } else if ([specifier.identifier isEqualToString:@"Use Custom User-Agent"]) {
          [specifiersToRemove addObject:specifier];
        }
      }
    }

    // Remove those specifiers.
    for (PSSpecifier *specifierToRemove in specifiersToRemove) {
      [specifiers removeObject:specifierToRemove];
    }
    _specifiers = [specifiers copy];
    [specifiers release];
  }

	return _specifiers;
}

// These methods are taken from http://iphonedevwiki.net/index.php/PreferenceBundles#Into_sandboxed.2Funsandboxed_processes_in_iOS_8
// We have to manually read/write preferences to the file to ensure consistency within the Tweak's code at runtime.
-(id) readPreferenceValue:(PSSpecifier*)specifier {
  id result;
  NSDictionary *exchangentSettings = [NSDictionary dictionaryWithContentsOfFile:nsPreferencesPath];
  NSString *key = specifier.properties[@"key"];
  if ([key isEqualToString:@"presetUserAgent"]) {
    // Dynamically construct the User Agent by appending the Device and iOS Version together.
    result = [NSString stringWithFormat:@"%@/%@", exchangentSettings[@"device"], exchangentSettings[@"iosVersion"]];
  } else if (!exchangentSettings[specifier.properties[@"key"]]) {
    // Preference doesn't have a value (unset), so fetch the default.
    result = specifier.properties[@"default"];
  } else {
    // Fetch the preference value
    result = exchangentSettings[specifier.properties[@"key"]];
  }

  // If Device or iOS Version changed, reload the User-Agent specifier to match the device/version.
  if ([key isEqualToString:@"device"] || [key isEqualToString:@"iosVersion"]) {
    [self reloadSpecifierID:@"User-Agent"];
  }

  return result;
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:nsPreferencesPath]];
  [defaults setObject:value forKey:specifier.properties[@"key"]];
  [defaults writeToFile:nsPreferencesPath atomically:YES];

  // Send Notification (via Darwin) if one is specified for the preference value.
  // This will notify the Tweak (.xm) that the preference value changed.
  CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
  if (toPost) {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
  }

  // Ahoy, thar be hacks afoot.
  // This might not be the right way to do it, but it works!
  // If "Use Custom User-Agent" is enabled/disabled, or if thw Tweak is enabled/disabled, then reload all specifiers.
  // This allows the filtering logic inside "specifiers()" to run and re-construct the preference page.
  if ([specifier.properties[@"key"] isEqualToString:@"useCustom"] || [specifier.properties[@"key"] isEqualToString:@"enabled"]) {
    shouldReload = YES;
    // TODO: Find a way to animate this.
    // See https://github.com/rpetrich/iphoneheaders/blob/master/Preferences/PSListController.h
    // Which contains some methods for removing *with animation*, like:
    // -(void)removeSpecifierID:(NSString*)specifierID animated:(BOOL)animated;
    [self reloadSpecifiers];
  }
}

-(void) GithubButtonAction {
  NSURL *ghUrl = [NSURL URLWithString:@"https://github.com/derv82/Exchangent"];
  [[UIApplication sharedApplication] openURL:ghUrl];
}

@end
