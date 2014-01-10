//
//  FavoritesCell.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/19/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "FavoritesTableCell.h"
#import "UIColor+AppDefinedColors.h"


@interface FavoritesTableCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *deletionBackgroundView;
@property (nonatomic, weak) IBOutlet UIImageView *deletionButtonIcon;
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UIView *dividerView;

@end


@implementation FavoritesTableCell


// ---------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
	[super awakeFromNib];
	self.hiddenPanelWidth = 240;
	self.hiddenPanelMaxWidth = 300;
}



// ---------------------------------------------------------------------------------------------------------------------
- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
	// if the hidden panel is open, need to decide whether the user tapped the cell or the hidden part and respond
	// accordingly
	if (self.isHiddenPanelExposed)
	{
		CGRect hiddenRect = CGRectMake(self.bounds.size.width - self.hiddenPanelWidth, 0,
									   self.hiddenPanelWidth, self.bounds.size.height);
		if (CGRectContainsPoint(hiddenRect, [gestureRecognizer locationInView:self])) {
			[self deleteFavoritesCell];
		}
		[self hideHiddenPanel];
		[self setSelected:NO];
		// otherwise just use the standard default behavior
	} else {
		[super handleTapGesture:gestureRecognizer];
	}
}


#pragma mark - Set Appearance


// ---------------------------------------------------------------------------------------------------------------------
- (void)configureAppearance
{
	self.deletionBackgroundView.backgroundColor = [UIColor appRemoveFromFavoritesColor];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)deleteFavoritesCell
{
	[self.delegate favoritesCellDeleteFavorite:self];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)setSelected:(BOOL)selected
{
	if (selected) {
		self.bgView.backgroundColor = [UIColor appCellHighlightedColor];
		self.deletionButtonIcon.highlighted = YES;
	} else {
		self.bgView.backgroundColor = [UIColor appCellColor];
		self.deletionButtonIcon.highlighted = NO;
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)setTitle:(NSString *)title
{
	self.titleLabel.text = title;
}


@end
