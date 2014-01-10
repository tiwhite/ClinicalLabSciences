//
//  UIColor+AppDefinedColors.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/4/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>


/*
	Category adding additional predefined colors to UIColor.  Rather than describing the colors (red, blue, etc), the
	colors are labeled according to their roles.  This way the color definitions can be easily modified without causing
	confusion.
*/


@interface UIColor (AppDefinedColors)


+ (UIColor *)appNavBarColor;
+ (UIColor *)appSearchBarColor;
+ (UIColor *)appSearchBarButtonTextColor;
+ (UIColor *)appCellColor;
+ (UIColor *)appCellHighlightedColor;
+ (UIColor *)appAddToFavoritesColor;
+ (UIColor *)appRemoveFromFavoritesColor;


@end
