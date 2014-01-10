//
//  HelpPopupViewController.h
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 12/5/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface HelpPopupViewController : UIViewController


+ (void)showHelpForCollapsedListOverView:(UIViewController *)callingViewController;
+ (void)showHelpForExpandedListOverView:(UIViewController *)callingViewController;
+ (void)showHelpForProcedureOverView:(UIViewController *)callingViewController;


@end
