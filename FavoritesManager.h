//
//  FavoritesManager.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/15/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <Foundation/Foundation.h>


/*
	Class for controlling the addition, removal, and lookup of procedures in the user's favorites list.  Favorites
	are stored as an array in NSUserDefaults.
*/


@interface FavoritesManager : NSObject


+ (FavoritesManager *)favoritesManagerInstance;

- (BOOL)isProcedureAFavorite:(NSString *)procedureName;
- (void)addProcedureToFavorites:(NSString *)procedureName;
- (void)removeProcedureFromFavorites:(NSString *)procedureName;
- (NSMutableArray *)listOfFavorites;
- (NSInteger)numberOfFavorites;
- (void)migrateOldFavorites;

@end
