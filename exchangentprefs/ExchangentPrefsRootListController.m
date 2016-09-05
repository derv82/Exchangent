#import <Preferences/PSListController.h>

@interface ExchangentPrefsRootListController : PSListController
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

/*
-(id) readPreferenceValue:(PSSpecifier*)specifier {
    NSDictionary *messagesTintSettings = [NSDictionary dictionaryWithContentsOfFile:messagesTintPath];
    if (!messagesTintSettings[specifier.properties[@"key"]]) {
        return specifier.properties[@"default"];
    }
    return messagesTintSettings[specifier.properties[@"key"]];
}

-(void) setPreferenceValue:(id)value specifier:(PSSpecifier*)specifier {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:messagesTintPath]];
    [defaults setObject:value forKey:specifier.properties[@"key"]];
    [defaults writeToFile:messagesTintPath atomically:YES];
    //  NSDictionary *messagesTintSettings = [NSDictionary dictionaryWithContentsOfFile:messagesTintPath];
    CFStringRef toPost = (CFStringRef)specifier.properties[@"PostNotification"];
    if(toPost) CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), toPost, NULL, NULL, YES);
    system("killall -9 MobileSMS");
}
*/

@end
