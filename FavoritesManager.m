//
//  FavoritesManager.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/15/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "FavoritesManager.h"
#import "UserDefaultsConsts.h"


@interface FavoritesManager ()

@property (nonatomic, strong) NSMutableSet *favoritesSet;

@end


@implementation FavoritesManager


// ---------------------------------------------------------------------------------------------------------------------
+ (FavoritesManager *)favoritesManagerInstance
{
	static FavoritesManager *sharedInstance = nil;
	static dispatch_once_t instanceToken;
	dispatch_once(&instanceToken, ^{
		sharedInstance = [[FavoritesManager alloc] init];
		[sharedInstance initializeFavoritesSet];
	});
	
	return sharedInstance;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)initializeFavoritesSet
{
	if (!self.favoritesSet) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		self.favoritesSet = [NSMutableSet setWithArray:[userDefaults objectForKey:kDefaultsFavoritesSet]];
		if (self.favoritesSet == nil) {
			self.favoritesSet = [[NSMutableSet alloc] init];
		}
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (BOOL)isProcedureAFavorite:(NSString *)procedureName
{
	if ([self.favoritesSet containsObject:procedureName]) {
		return YES;
	}
	
	return NO;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)addProcedureToFavorites:(NSString *)procedureName
{
	if (![self isProcedureAFavorite:procedureName])
	{
		[self.favoritesSet addObject:procedureName];
		
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:[self.favoritesSet allObjects] forKey:kDefaultsFavoritesSet];
		[userDefaults synchronize];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)removeProcedureFromFavorites:(NSString *)procedureName
{
	if ([self isProcedureAFavorite:procedureName])
	{
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[self.favoritesSet removeObject:procedureName];
		[userDefaults setObject:[self.favoritesSet allObjects] forKey:kDefaultsFavoritesSet];
		[userDefaults synchronize];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (NSMutableArray *)listOfFavorites
{
	NSMutableArray *favList = [[self.favoritesSet allObjects] mutableCopy];
	[favList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	
	return favList;
}


// ---------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfFavorites
{
	return self.favoritesSet.count;
}


// ---------------------------------------------------------------------------------------------------------------------
// the previous version of this app stored favorites differently.  They need to be migrated to the new system.
- (void)migrateOldFavorites
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray *oldFavorites = [[NSArray alloc] initWithArray:[userDefaults objectForKey:@"Favorites"]];
	
	for (NSDictionary *favorite in oldFavorites)
	{
		NSString *favName = [favorite objectForKey:@"Name"];
		[self addProcedureToFavorites:favName];
	}
	
	[userDefaults removeObjectForKey:@"Favorites"];
	[userDefaults synchronize];
}


@end
