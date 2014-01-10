//
//  NSDictionary-MutableDeepCopy.m
//  DentistryProConsult
//
//  Created by jrosamond on 3/4/10.
//  Copyright Medical College of Georgia 2010. All rights reserved.
//


#import "NSDictionary-MutableDeepCopy.h"


@implementation NSDictionary (MutableDeepCopy)


- (NSMutableDictionary *)mutableDeepCopy
{
	// Create a new mutable dictionary from the original dictionary.
	NSMutableDictionary *ret = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
	
	// Create an array to hold all of the keys.
	NSArray *keys = [self allKeys];
	
	// Loop through all of the keys in the original dictionary and make mutable copies of each array.
	for(id key in keys)
	{
		id oneValue = [self valueForKey:key];
		id oneCopy = nil;
		
		if ([oneValue respondsToSelector:@selector(mutableDeepCopy)]) {
			oneCopy = [oneValue mutableDeepCopy];
		} else if ([oneValue respondsToSelector:@selector(mutableCopy)]) {
			oneCopy = [oneValue mutableCopy];
		}
		if (oneCopy == nil) {
			oneCopy = [oneValue copy];
		}
		
		[ret setValue:oneCopy forKey:key];
	}
	
	return ret;
}

@end
