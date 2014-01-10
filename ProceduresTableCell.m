//
//  ProceduresTableCell.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 10/25/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "ProceduresTableCell.h"
#import "UIColor+AppDefinedColors.h"
#import "FavoritesManager.h"

@interface ProceduresTableCell ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *favBackgroundView;
@property (nonatomic, weak) IBOutlet UIImageView *favAddIcon;
@property (nonatomic, weak) IBOutlet UIImageView *favRemoveIcon;
@property (nonatomic, weak) IBOutlet UILabel *favButtonLabel;
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UIView *dividerView;
@property (nonatomic, weak) IBOutlet UIImageView *favoritesIndicator;

@end


@implementation ProceduresTableCell


#pragma mark - Initialization


// ---------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
	[super awakeFromNib];
	self.hiddenPanelWidth = 240;
	self.hiddenPanelMaxWidth = 300;
}


#pragma mark - Gesture Recognizers


// ---------------------------------------------------------------------------------------------------------------------
- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
	// if the hidden panel is open, need to decide whether the user tapped the cell or the hidden part and respond
	// accordingly
	if (self.isHiddenPanelExposed)
	{
		CGRect hiddenRect = CGRectMake(self.bounds.size.width - self.hiddenPanelWidth, 0,
									   self.hiddenPanelWidth, self.bounds.size.height);
		if (CGRectContainsPoint(hiddenRect, [gestureRecognizer locationInView:self]))
		{
			FavoritesManager *favoritesManager = [FavoritesManager favoritesManagerInstance];
			if ([favoritesManager isProcedureAFavorite:self.titleLabel.text]) {
				[favoritesManager removeProcedureFromFavorites:self.titleLabel.text];
			} else {
				[favoritesManager addProcedureToFavorites:self.titleLabel.text];
			}
			[self toggleFavoriteStatus];
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
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)toggleFavoriteStatus
{
	BOOL isAFavorite = [[FavoritesManager favoritesManagerInstance] isProcedureAFavorite:self.titleLabel.text];
	self.favoritesIndicator.hidden = !isAFavorite;
	self.favAddIcon.highlighted = isAFavorite;
	if (isAFavorite) {
		self.favBackgroundView.backgroundColor = [UIColor appRemoveFromFavoritesColor];
		self.favButtonLabel.text = @"REMOVE FROM FAVORITES";
		self.favAddIcon.hidden = YES;
		self.favRemoveIcon.hidden = NO;
	} else {
		self.favBackgroundView.backgroundColor = [UIColor appAddToFavoritesColor];
		self.favButtonLabel.text = @"ADD TO FAVORITES";
		self.favAddIcon.hidden = NO;
		self.favRemoveIcon.hidden = YES;
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)setSelected:(BOOL)selected
{
	if (selected) {
		self.bgView.backgroundColor = [UIColor appCellHighlightedColor];
		self.favAddIcon.highlighted = YES;
		self.favRemoveIcon.highlighted = YES;
	} else {
		self.bgView.backgroundColor = [UIColor appCellColor];
		self.favAddIcon.highlighted = NO;
		self.favRemoveIcon.highlighted = NO;
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)setTitle:(NSString *)title
{
	self.titleLabel.text = title;
	[self toggleFavoriteStatus];
}


@end
