#include "exchangentRootListController.h"

@implementation exchangentRootListController

- (NSArray *)specifiers {
	if (!_specifiers) {
     NSMutableArray *specifiers = [[self loadSpecifiersFromPlistName:@"Exchangent" target:self] mutableCopy];
     _specifiers = [specifiers copy];
     [specifiers release];
	}

	return _specifiers;
}

@end
