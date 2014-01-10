//
//  RootViewController.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 10/31/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "RootViewController.h"
#import "ProceduresTableViewController.h"
#import "NavMenuViewController.h"
#import "UIColor+AppDefinedColors.h"


@interface RootViewController ()


// UIContainerViews
@property (nonatomic, weak) IBOutlet UIView *contentContainer;
@property (nonatomic, weak) IBOutlet UIView *menuContainer;
@property (nonatomic, weak) IBOutlet UIView *contentWrapper;

@property (nonatomic, weak) NavMenuViewController *menuVC;	// used to load the correct content views
@property (nonatomic, weak) UIViewController *currentContentVC;
@property (nonatomic, weak) UIViewController *replacementContentVC;

@property (nonatomic, assign) NSInteger contentOffset;				// x value of the content view when menu is open
@property (nonatomic, assign) NSInteger menuOffset;					// x value of the menu view when the menu is closed

// UIKitDynamics
@property (nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) UIAttachmentBehavior *contentAttachment;
@property (nonatomic, strong) UIAttachmentBehavior *menuAttachment;
@property (nonatomic, strong) UIDynamicItemBehavior *resistanceBehavior; // used to dampen any springy effects
@property (nonatomic, assign) CGFloat attachmentSpringFrequency;		// used to create spring effects (0 otherwise)
@property (nonatomic, assign) CGFloat attachmentSpringDamping;			// used to create spring effects (0 otherwise)

// Other
@property (nonatomic, assign) CGFloat dragStartPosition;
@property (nonatomic, weak) IBOutlet UIView *menuClosingView;	// an invisible view only present when menu is showing
																// contains the gesture recognizers needed to close menu

@end


@implementation RootViewController


#pragma mark - Initialization


// ---------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.contentOffset = self.view.bounds.size.width - self.menuClosingView.frame.size.width;
	self.menuOffset = -self.view.bounds.size.width / 4;
	self.menuClosingView.hidden = YES;
	
	[[UINavigationBar appearance] setBarTintColor:[UIColor appNavBarColor]];
	
	[self initializeDynamicBehaviors];
	[self.menuAttachment setAnchorPoint:CGPointMake(self.view.bounds.size.width / 2 + self.menuOffset,
													self.view.bounds.size.height / 2)];
	[self.contentAttachment setAnchorPoint:CGPointMake(self.view.bounds.size.width / 2,
													   self.view.bounds.size.height / 2)];
	
	self.attachmentSpringFrequency = 3;
	self.attachmentSpringDamping = 0.75;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if ([segue.identifier isEqualToString:@"SegueEmbedProceduresList"]) {
		UINavigationController *destinationNavController = (UINavigationController *)segue.destinationViewController;
		if (!self.currentContentVC) {
			self.currentContentVC = destinationNavController;
		}
		[self connectContentVCToRootVC];
	} else if ([segue.identifier isEqualToString:@"SegueEmbedNavigationMenu"]) {
		NavMenuViewController *navigationMenu = (NavMenuViewController *)segue.destinationViewController;
		navigationMenu.rootViewController = self;
		self.menuVC = navigationMenu;
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)connectContentVCToRootVC
{
	if ([self.currentContentVC respondsToSelector:@selector(setRootViewController:)]) {
		[self.currentContentVC performSelector:@selector(setRootViewController:) withObject:self];
	} else if ([((UINavigationController *)self.currentContentVC).topViewController
				respondsToSelector:@selector(setRootViewController:)])
	{
		[((UINavigationController *)self.currentContentVC).topViewController
			performSelector:@selector(setRootViewController:) withObject:self];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)initializeDynamicBehaviors
{
	if (self.dynamicAnimator == nil) {
		UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
		self.dynamicAnimator = animator;
	}
	
	// content attachment behavior
	self.contentAttachment = [[UIAttachmentBehavior alloc] initWithItem:self.contentWrapper
																		attachedToAnchor:self.contentWrapper.center];
	self.contentAttachment.frequency = 0;
	self.contentAttachment.damping = 0;
	
	// menu attachment behavior
	self.menuAttachment = [[UIAttachmentBehavior alloc] initWithItem:self.menuContainer
																	 attachedToAnchor:self.menuContainer.center];
	self.menuAttachment.frequency = 0;
	self.menuAttachment.damping = 0;
	
	// resistance behavior
	self.resistanceBehavior = [[UIDynamicItemBehavior alloc]
												 initWithItems:@[self.contentWrapper, self.menuContainer]];
	self.resistanceBehavior.resistance = 5;
	self.resistanceBehavior.angularResistance = 100;
	
	// add the behaviors
	[self.dynamicAnimator addBehavior:self.contentAttachment];
	[self.dynamicAnimator addBehavior:self.menuAttachment];
}


#pragma mark - Rotation Code
// UIKitDynamics can conflict with Autolayout Constraints during rotation.  Disable Dynamics while rotation occurs
// NOTE: rotation is disabled for most of the app due to some of the views experiencing conflicts when using auto-layout
//		this should be fixed as soon as a solution is found


// ---------------------------------------------------------------------------------------------------------------------
// for now, only support portrait
- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration
{
	[self.dynamicAnimator removeAllBehaviors];
	self.menuClosingView.hidden = YES;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	self.contentOffset = self.view.bounds.size.width - 30;
	self.menuOffset = -self.view.bounds.size.width / 5;
	[self initializeDynamicBehaviors];
	[self.menuAttachment setAnchorPoint:CGPointMake(self.view.bounds.size.width / 2 + self.menuOffset,
													self.view.bounds.size.height / 2)];
}


#pragma mark - Load Other Content Views


// ---------------------------------------------------------------------------------------------------------------------
- (void)loadNewContentView:(UIViewController *)newViewController
{
	// insert the new view into the content container
	[self addChildViewController:newViewController];
	[newViewController didMoveToParentViewController:self];
	newViewController.view.frame = self.contentContainer.bounds;
	self.replacementContentVC = newViewController;
	[self.contentContainer insertSubview:newViewController.view atIndex:0];
	
	// use a fast cross-fade to make the new view visible
	newViewController.view.alpha = 0;
	[UIView animateWithDuration:0.2
					 animations:^{
						 self.replacementContentVC.view.alpha = 1;
						 self.currentContentVC.view.alpha = 0;
					 } completion:^(BOOL finished) {
						 // once the animation is finished, remove the old view and perform any necessary initialization
						 // on the new one
						 [self.currentContentVC.view removeFromSuperview];
						 [self.currentContentVC removeFromParentViewController];
						 self.currentContentVC = self.replacementContentVC;
						 [self connectContentVCToRootVC];
						 [self hideMenu:nil];
					 }];
}


#pragma mark - Open/Close Menu


// ---------------------------------------------------------------------------------------------------------------------
- (void)revealMenu
{
	[self.menuVC refreshFavorites];
	
	// add the resistance behavior to keep spring effect at reasonable speed
	[self.dynamicAnimator addBehavior:self.resistanceBehavior];
	
	// add "spring" values to attachment behaviors
	self.contentAttachment.frequency = self.attachmentSpringFrequency;
	self.contentAttachment.damping = self.attachmentSpringDamping;
	self.menuAttachment.frequency = self.attachmentSpringFrequency;
	self.menuAttachment.damping = self.attachmentSpringDamping;
	
	// set the attachment behavior anchors to the normal "open" points
	[self.contentAttachment setAnchorPoint:CGPointMake(self.view.bounds.size.width / 2 + self.contentOffset,
													   self.view.bounds.size.height / 2)];
	[self.menuAttachment setAnchorPoint:CGPointMake(self.view.bounds.size.width / 2,
													self.view.bounds.size.height / 2)];
	
	self.menuClosingView.hidden = NO;
}


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)hideMenu:(id)sender
{
	// add the resistance behavior to keep spring effect at reasonable speed
	[self.dynamicAnimator addBehavior:self.resistanceBehavior];
	
	// add "spring" values to attachment behavior
	self.contentAttachment.frequency = self.attachmentSpringFrequency;
	self.contentAttachment.damping = self.attachmentSpringDamping;
	self.menuAttachment.frequency = self.attachmentSpringFrequency;
	self.menuAttachment.damping = self.attachmentSpringDamping;
	
	// set the attachment behavior anchors to the normal "closed" points
	[self.contentAttachment setAnchorPoint:CGPointMake((self.view.bounds.size.width / 2) - 1,
													   self.view.bounds.size.height / 2)];
	[self.menuAttachment setAnchorPoint:CGPointMake(self.view.bounds.size.width / 2 + self.menuOffset,
													self.view.bounds.size.height / 2)];
	
	self.menuClosingView.hidden = YES;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)dragMenuToPoint:(CGPoint)targetPoint;
{
	// we only really care about the horizontal point
	NSInteger xOffset = targetPoint.x;
	
	// set the "starting" position if it hasn't been set yet
	if (self.dragStartPosition == 0) {
		self.dragStartPosition = xOffset;
		[self.dynamicAnimator removeBehavior:self.resistanceBehavior];
		self.contentAttachment.frequency = 0;
		self.contentAttachment.damping = 0;
		self.menuAttachment.frequency = 0;
		self.menuAttachment.damping = 0;
		
		[self.menuVC refreshFavorites];
		return;
	}
	
	// get the delta - the reason for doing this rather than using the offset directly is to avoid any "jumps" when the
	// dragging first starts
	CGFloat delta = xOffset - self.dragStartPosition;
	
	// make sure the delta stays within the bounds of the view
	if (delta < 0) {
		delta = 0;
	}
	
	// move the content container
	[self.contentAttachment setAnchorPoint:CGPointMake(self.view.bounds.size.width / 2 + delta,
													   self.view.bounds.size.height / 2)];
	
	// now move the menu container - it should move as a percentage of the content's movement
	CGFloat percentToMove = (delta / (self.view.bounds.size.width - self.menuClosingView.frame.size.width));
	CGFloat menuDelta = percentToMove * -self.menuOffset;
	[self.menuAttachment setAnchorPoint:CGPointMake(self.view.bounds.size.width / 2 + self.menuOffset + menuDelta,
													self.view.bounds.size.height / 2)];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)releaseMenuAtPoint:(CGPoint)point withVelocity:(CGPoint)velocity;
{
	// we only care about the horizontal dragging
	NSInteger xOffset = point.x;
	NSInteger xVelocity = velocity.x;
	
	// use the current "state" to make one outcome (open vs close) more likely than the other
	// if already open, nudge towards close.  If closed, nudge towards open
	if (self.menuClosingView.hidden) {	// menu currently closed
		xVelocity += 100;
		xOffset += (self.view.bounds.size.width * 0.05);
	} else {	// menu currently open
		xVelocity -= 100;
		xOffset -= (self.view.bounds.size.width * 0.05);
	}
	
	// first check velocity - if moving quickly, regardless of position, open or close the menu
	if (xVelocity > 200) {
		[self revealMenu];
	} else if (xVelocity < -200) {
		[self hideMenu:nil];
		
	// if the velocity is small, use the position to determine whether to open or close
	} else {
		if (xOffset >= (self.view.bounds.size.width / 2)) {
			[self revealMenu];
		} else {
			[self hideMenu:nil];
		}
	}
	
	self.dragStartPosition = 0;
}


// ---------------------------------------------------------------------------------------------------------------------
- (IBAction)handleCloseMenuDrag:(UIPanGestureRecognizer *)gestureRecognizer
{
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:;
			// trick the drag function into thinking the drag started on the left, rather than the right
			// this allows us to use the same code for closing the menu as for opening
			[self dragMenuToPoint:[gestureRecognizer locationInView:self.menuClosingView]];
			break;
		case UIGestureRecognizerStateChanged:
			[self dragMenuToPoint:[gestureRecognizer locationInView:self.view]];
			break;
		case UIGestureRecognizerStateCancelled:
		case UIGestureRecognizerStateEnded: {
			CGPoint touchPoint = [gestureRecognizer locationInView:self.view];
			CGPoint touchVelocity = [gestureRecognizer velocityInView:self.view];
			[self releaseMenuAtPoint:touchPoint withVelocity:touchVelocity];
		}
			break;
		default:
			break;
	}
}


@end
