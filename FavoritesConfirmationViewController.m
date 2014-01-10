//
//  FavoritesConfirmationViewController.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/25/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "FavoritesConfirmationViewController.h"


@interface FavoritesConfirmationViewController ()

@property (nonatomic, weak) IBOutlet UILabel *dialogueLabel;
@property (nonatomic, weak) IBOutlet UIView *backgroundBoxView;
@property (nonatomic, weak) IBOutlet UIImageView *dialogueIcon;
@property (nonatomic, assign) BOOL wasFavoriteAdded;

@end


@implementation FavoritesConfirmationViewController


// ---------------------------------------------------------------------------------------------------------------------
+ (void)showConfirmation:(BOOL)wasFavoriteAdded overView:(UIView *)callingView
{
	FavoritesConfirmationViewController *confirmationView = [[FavoritesConfirmationViewController alloc] initWithNibName:@"FavoritesConfirmationViewController" bundle:[NSBundle mainBundle]];
	
	confirmationView.wasFavoriteAdded = wasFavoriteAdded;
	
	[confirmationView displayToastOverView:callingView
								   forTime:.75
						   allowTapToAbort:NO];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
	
	if (self.wasFavoriteAdded) {
		self.dialogueLabel.text = @"Added to Favorites";
		self.dialogueIcon.image = [UIImage imageNamed:@"popupIconAddFav"];
	} else {
		self.dialogueLabel.text = @"Removed from Favorites";
		self.dialogueIcon.image = [UIImage imageNamed:@"popupIconRemoveFav"];
	}
	
	self.backgroundBoxView.layer.cornerRadius = 10;
	self.backgroundBoxView.layer.masksToBounds = YES;
}


@end
