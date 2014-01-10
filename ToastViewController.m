//
//  ToastViewController.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/25/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "ToastViewController.h"


@interface ToastViewController ()

@end


@implementation ToastViewController


// ---------------------------------------------------------------------------------------------------------------------
- (void)displayToastOverView:(UIView *)callingView
					 forTime:(CGFloat)seconds
			 allowTapToAbort:(BOOL)allowTapToAbort
{
	self.view.alpha = 0;
	[callingView addSubview:self.view];
	[self fadeIn];
	[self performSelector:@selector(fadeOut) withObject:nil afterDelay:seconds];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)fadeIn
{
	[UIView animateWithDuration:0.15
					 animations:^{
						 self.view.alpha = 1;
					 }];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)fadeOut
{
	[UIView animateWithDuration:0.4
					 animations:^{
						 self.view.alpha = 0;
					 } completion:^(BOOL finished) {
						 [self dismissToast];
					 }];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)dismissToast
{
	[self.view removeFromSuperview];
	[self removeFromParentViewController];
}


@end
