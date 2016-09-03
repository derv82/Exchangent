#include <substrate.h>

%hook DATaskManager

-(id)userAgent {
	%log; id r = %orig; HBLogDebug(@" = %@", r);

	id newAgent = @"iPhone8C2/1307.36";
	NSLog(@"ASTaskManager.userAgent overriding to: %@", newAgent);
	return newAgent;
} 

%end

