#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#define nsPreferencesPath @"/User/Library/Preferences/com.derv82.exchangentprefs.plist"

@interface ExchangentPrefsRootListController : PSListController {
}
@end

@implementation ExchangentPrefsRootListController
-(id) specifiers {
	if (!_specifiers) {
     NSMutableArray *specifiers = [[self loadSpecifiersFromPlistName:@"ExchangentPrefs" target:self] mutableCopy];
     _specifiers = [specifiers copy];
     [specifiers release];
	}

	return _specifiers;
}

-(id) readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *exchangentSettings = [NSDictionary dictionaryWithContentsOfFile:nsPreferencesPath];
    if (!exchangentSettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return exchangentSettings[specifier.properties[@"key"]];
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
}

@end
