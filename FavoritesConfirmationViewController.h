//
//  FavoritesConfirmationViewController.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/25/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ToastViewController.h"


/*
	Display a confirmation to the user that a particular procedure has been added to or removed from the favorites.
*/


@interface FavoritesConfirmationViewController : ToastViewController


+ (void)showConfirmation:(BOOL)wasFavoriteAdded overView:(UIView *)callingView;


@end
