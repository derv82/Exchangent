#include "exchangentRootListController.h"

@implementation exchangentRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Exchangent" target:self] retain];
	}

	return _specifiers;
}

@end
