#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#define nsPreferencesPath @"/User/Library/Preferences/com.derv82.exchangentprefs.plist"

@interface ExchangentPrefsRootListController : PSListController {
  BOOL shouldReload;
}
@end

@implementation ExchangentPrefsRootListController
-(id) specifiers {
  if (shouldReload) {
    shouldReload = NO;
    [_specifiers release];
    _specifiers = nil;
  }
	if (!_specifiers) {
     NSMutableArray *specifiers = [[self loadSpecifiersFromPlistName:@"ExchangentPrefs" target:self] mutableCopy];
     NSDictionary *exchangentSettings = [NSDictionary dictionaryWithContentsOfFile:nsPreferencesPath];
     id _tempValue;
     
     _tempValue = [exchangentSettings objectForKey:@"enabled"];
     BOOL isTweakEnabled = _tempValue ? [_tempValue boolValue] : NO;

     _tempValue = [exchangentSettings objectForKey:@"useCustom"];
     BOOL isCustomEnabled = _tempValue ? [_tempValue boolValue] : NO;

     NSMutableArray *specifiersToRemove = [[NSMutableArray alloc] init];
     for (PSSpecifier *specifier in specifiers) {
       NSLog(@"Specifier identifier: %@", specifier.identifier);
       if (isCustomEnabled || !isTweakEnabled) {
         if ([specifier.identifier isEqualToString:@"User-Agent for Device and Version"]) {
           [specifiersToRemove addObject:specifier];
         } else if ([specifier.identifier isEqualToString:@"Preset Versions"]) {
           [specifiersToRemove addObject:specifier];
         } else if ([specifier.identifier isEqualToString:@"Device"]) {
           [specifiersToRemove addObject:specifier];
         } else if ([specifier.identifier isEqualToString:@"iOS Version"]) {
           [specifiersToRemove addObject:specifier];
         } else if ([specifier.identifier isEqualToString:@"Preset User-Agent"]) {
           [specifiersToRemove addObject:specifier];
         }
       }
       if (!isCustomEnabled || !isTweakEnabled) {
         if ([specifier.identifier isEqualToString:@"User-Agent:"]) {
           [specifiersToRemove addObject:specifier];
         }
       }
       if (!isTweakEnabled) {
         if ([specifier.identifier isEqualToString:@"Custom"]) {
           [specifiersToRemove addObject:specifier];
         } else if ([specifier.identifier isEqualToString:@"Use Custom User-Agent"]) {
           [specifiersToRemove addObject:specifier];
         }
       }
     }

     NSLog(@"Specifiers to remove: %@", specifiersToRemove);
     for (PSSpecifier *specifierToRemove in specifiersToRemove) {
       [specifiers removeObject:specifierToRemove];
     }
     _specifiers = [specifiers copy];
     [specifiers release];
	}

	return _specifiers;
}

-(id) readPreferenceValue:(PSSpecifier*)specifier {
  id result;
  NSDictionary *exchangentSettings = [NSDictionary dictionaryWithContentsOfFile:nsPreferencesPath];
  NSString *key = specifier.properties[@"key"];
  if ([key isEqualToString:@"presetUserAgent"]) {
    result = [NSString stringWithFormat:@"%@/%@", exchangentSettings[@"device"], exchangentSettings[@"iosVersion"]];
  } else if (!exchangentSettings[specifier.properties[@"key"]]) {
    result = specifier.properties[@"default"];
  } else {
    result = exchangentSettings[specifier.properties[@"key"]];
  }

  if ([key isEqualToString:@"device"] || [key isEqualToString:@"iosVersion"]) {
    [self reloadSpecifierID:@"Preset User-Agent"];
  }
  return result;
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
  NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
  [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:nsPreferencesPath]];
  [defaults setObject:value forKey:specifier.properties[@"key"]];
  [defaults writeToFile:nsPreferencesPath atomically:YES];
  CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
  if (toPost) {
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
  }
  if ([specifier.properties[@"key"] isEqualToString:@"useCustom"] || [specifier.properties[@"key"] isEqualToString:@"enabled"]) {
    NSLog(@"Reloading specifiers");
    shouldReload = YES;
    [self reloadSpecifiers];
  }
}

@end
