//
//  ProceduresTableCell.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 10/25/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "HiddenPanelCell.h"


/*
	Subclass of HiddenPanelCell.  Contains the app-specific functionality (such as handling taps on the cell) as well
	as the cell's appearnce.
*/


@interface ProceduresTableCell : HiddenPanelCell


- (void)setTitle:(NSString *)title;
- (void)configureAppearance;


@end
