//
//  FavoritesCell.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/19/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "HiddenPanelCell.h"
@protocol FavoritesCellDelegate;


/*
	Subclass of HiddenPanelCell.  Contains the app-specific functionality (such as handling taps on the cell) as well
	as the cell's appearnce.
*/


@interface FavoritesTableCell : HiddenPanelCell


@property (nonatomic, weak) id <HiddenPanelCellDelegate, FavoritesCellDelegate> delegate;


- (void)setTitle:(NSString *)title;
- (void)configureAppearance;


@end


// define the protocol required to use this class
@protocol FavoritesCellDelegate <HiddenPanelCellDelegate>

- (void)favoritesCellDeleteFavorite:(FavoritesTableCell *)favoritesCell;

@end