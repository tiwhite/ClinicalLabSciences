//
//  UIColor+AppDefinedColors.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/4/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "UIColor+AppDefinedColors.h"


@implementation UIColor (AppDefinedColors)


#pragma mark - Bars


// ---------------------------------------------------------------------------------------------------------------------
+ (UIColor *)appNavBarColor
{
	return [UIColor colorWithRed:44/255.0f green:104/255.0f blue:192/255.0f alpha:1];
}


// ---------------------------------------------------------------------------------------------------------------------
+ (UIColor *)appSearchBarColor
{
	return [UIColor colorWithRed:22/255.0f green:84/255.0f blue:171/255.0f alpha:1];
}


// ---------------------------------------------------------------------------------------------------------------------
+ (UIColor *)appSearchBarButtonTextColor
{
	return [UIColor whiteColor];
}


#pragma mark - Table Cells


// ---------------------------------------------------------------------------------------------------------------------
+ (UIColor *)appCellColor
{
	return [UIColor colorWithRed:1 green:1 blue:1 alpha:1];
}


// ---------------------------------------------------------------------------------------------------------------------
+ (UIColor *)appCellHighlightedColor
{
	return [UIColor colorWithRed:230/255.0f green:230/255.0f blue:230/255.0f alpha:1];
}


#pragma mark - Other


// ---------------------------------------------------------------------------------------------------------------------
+ (UIColor *)appAddToFavoritesColor
{
	return [UIColor colorWithRed:44/255.0f green:192/255.0f blue:114/255.0f alpha:1];
}


// ---------------------------------------------------------------------------------------------------------------------
+ (UIColor *)appRemoveFromFavoritesColor
{
	return [UIColor colorWithRed:206/255.0f green:126/255.0f blue:126/255.0f alpha:1];
}


@end
