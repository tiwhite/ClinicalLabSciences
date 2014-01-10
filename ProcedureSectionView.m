//
//  ProcedureView.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 11/6/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "ProcedureSectionView.h"


@interface ProcedureSectionView ()

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIView *titleBackgroundView;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIView *dividerView;
@property (nonatomic, weak) IBOutlet UIImageView *disclosureIndicator;

@end


@implementation ProcedureSectionView


#pragma mark - Initialization


// ---------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
	[self configureAppearance];
	[self initializeGestureRecognizers];
}


#pragma mark - Set Appearance


// ---------------------------------------------------------------------------------------------------------------------
- (void)configureAppearance
{
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)setTitle:(NSString *)title
{
	self.titleLabel.text = title;
}


#pragma mark - Gesture Recognizers


// ---------------------------------------------------------------------------------------------------------------------
- (void)initializeGestureRecognizers
{
	UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																			   action:@selector(handleTapGesture:)];
	[self.titleBackgroundView addGestureRecognizer:tapGestureRecognizer];
	
	
	UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
																				action:@selector(handlePanGesture:)];
	[self.titleBackgroundView addGestureRecognizer:panGestureRecognizer];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture
{
	[self.delegate procedureSection:self handleTapGesture:tapGesture];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
	[self.delegate procedureSection:self handlePanGesture:panGesture];
}


#pragma mark - Other


// ---------------------------------------------------------------------------------------------------------------------
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
												 navigationType:(UIWebViewNavigationType)navigationType
{
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		[[UIApplication sharedApplication] openURL:[request URL]];
		return NO;
	}
	return YES;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)adjustAppearanceForExpansion:(BOOL)isSectionOpen
{
	if (isSectionOpen) {
		self.disclosureIndicator.image = [UIImage imageNamed:@"iconHeaderArrow_down"];
	} else {
		self.disclosureIndicator.image = [UIImage imageNamed:@"iconHeaderArrow_right"];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)loadWebPage:(NSString *)webPagePath
{
	NSString *urlAddress = [[NSBundle mainBundle] pathForResource:webPagePath ofType:@"html"];
	NSURL *url = [NSURL fileURLWithPath:urlAddress];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:requestObj];
}


@end
