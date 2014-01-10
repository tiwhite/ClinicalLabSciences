//
//  HiddenPanelCell.m
//  ProceduresConsultTemplate
//
//  Created by tiwhite on 10/30/13.
//  Copyright (c) 2013 tiwhite. All rights reserved.
//


#import "HiddenPanelCell.h"


@interface HiddenPanelCell ()


@property (nonatomic, weak) IBOutlet UIView *mainPanel;
@property (nonatomic, weak) IBOutlet UIView *hiddenPanel;
@property (nonatomic, assign) BOOL isUserTogglingHiddenPanel;
@property (nonatomic, assign) CGPoint swipeStartPoint;
@property (nonatomic, assign) CFTimeInterval touchStartTime;

@property (nonatomic) UIDynamicAnimator *dynamicAnimator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *resistanceBehavior;

@property (nonatomic, assign) CGFloat attachmentSpringFrequency;
@property (nonatomic, assign) CGFloat attachmentSpringDamping;


@end


@implementation HiddenPanelCell


#pragma mark - Initialization


// ---------------------------------------------------------------------------------------------------------------------
- (void)awakeFromNib
{
	self.isUserTogglingHiddenPanel = NO;
	self.isHiddenPanelExposed = NO;
	
	[self initializeGestureRecognizers];
	[self initializeDynamicBehaviors];
	
	self.attachmentSpringFrequency = 5;
	self.attachmentSpringDamping = 0.65;
}


// ---------------------------------------------------------------------------------------------------------------------
// use swipe and pan gesture recognizers to trigger the exposure of the hidden panel
// use a tap gesture for cell interaction
- (void)initializeGestureRecognizers
{
	// swipes enable pan gesture to be used to drag panel
	UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																			action:@selector(handleLeftSwipeGesture:)];
	leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
	
	UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self
																			action:@selector(handleRightSwipeGesture:)];
	rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
	
	// pan gesture used to drag main panel to show/hide hidden panel
	UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
																			action:@selector(handlePanGesture:)];
	
	// tap gesture used for cell interaction
	UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
																			action:@selector(handleTapGesture:)];
	
	leftSwipeRecognizer.delegate = self;
	rightSwipeRecognizer.delegate = self;
	panRecognizer.delegate = self;
	tapRecognizer.delegate = self;
	
	[self addGestureRecognizer:leftSwipeRecognizer];
	[self addGestureRecognizer:rightSwipeRecognizer];
	[self addGestureRecognizer:panRecognizer];
	[self addGestureRecognizer:tapRecognizer];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)initializeDynamicBehaviors
{
	if (self.dynamicAnimator == nil) {
		UIDynamicAnimator *animator = [[UIDynamicAnimator alloc] initWithReferenceView:self];
		self.dynamicAnimator = animator;
	}
	
	UIDynamicItemBehavior *resistanceBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.mainPanel]];
	resistanceBehavior.resistance = 10;
	resistanceBehavior.angularResistance = 100;
	self.resistanceBehavior = resistanceBehavior;
}


#pragma mark - Rotation Code
// NOTE:  this code is not currently needed since only portrait is supported, but it will be needed if landscape mode is
//			added


// ---------------------------------------------------------------------------------------------------------------------
- (void)willRotate
{
	[self.dynamicAnimator removeAllBehaviors];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)didRotate
{
	self.isHiddenPanelExposed = NO;
	self.isUserTogglingHiddenPanel = NO;
}


#pragma mark - Handle Gestures


// ---------------------------------------------------------------------------------------------------------------------
- (void)handleLeftSwipeGesture:(UISwipeGestureRecognizer *)gestureRecognizer;
{
	[self enableHiddenPanelDrag];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)handleRightSwipeGesture:(UISwipeGestureRecognizer *)gestureRecognizer;
{
	// only acknowledge right swipe if panel is already open
	if (!self.isHiddenPanelExposed) {
		return;
	}
	
	[self.dynamicAnimator removeBehavior:self.resistanceBehavior];
	
	self.isUserTogglingHiddenPanel = YES;
	[self.dynamicAnimator addBehavior:self.attachmentBehavior];
	self.attachmentBehavior.frequency = 0;
	self.attachmentBehavior.damping = 0;
	
	[self.delegate hiddenPanelCell:self toggleScrolling:NO];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer
{
	[self setSelected:NO];
	
	// unless the user is actively dragging to expose/hide the hidden panel, we don't care about the pan gesture
	if (!self.isUserTogglingHiddenPanel) {
		// store location so when drag starts it will be smooth, but otherwise do nothing else
		self.swipeStartPoint = [gestureRecognizer locationInView:self];
		return;
	}
	
	// get the offset from the time the swipe gesture triggered until now
	CGPoint currentPoint = [gestureRecognizer locationInView:self];
	CGFloat delta = self.swipeStartPoint.x - currentPoint.x;
	
	// if the gesture started from the panel open position, need to account for the different starting points
	if (self.isHiddenPanelExposed) {
		delta += self.hiddenPanelWidth;
	}
	
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateChanged:
			// don't want panel to go beyond rightmost boundary
			if (delta < 0) {
				delta = 0;
			}
			// if user passes certain threshold, force hidden panel open
			if (delta > self.hiddenPanelMaxWidth) {
				[self exposeHiddenPanel];
			} else {
				self.attachmentBehavior.anchorPoint = CGPointMake(self.bounds.size.width / 2 - delta,
																  self.mainPanel.bounds.size.height / 2);
			}
			break;
		case UIGestureRecognizerStateEnded:
		case UIGestureRecognizerStateCancelled:
			[self finishFavDragWithOffset:delta andVelocity:[gestureRecognizer velocityInView:self].x];
			break;
		default:
			break;
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)handleTapGesture:(UITapGestureRecognizer *)gestureRecognizer
{
	if (!self.isHiddenPanelExposed) {
		[self flashSelected];	// because of the briefness of most taps, use a separate method to toggle selected and
								// unselected states
	} else {
		[self setSelected:NO];
	}
	[self.delegate hiddenPanelCellTapped:self];
}


#pragma mark - Other Touch Events
// Unfortunately, many of the gestures used by this class conflict with the standard "didSelectRowAtIndexPath" method.
// As a result, some manual detection of taps, etc is necessary


// ---------------------------------------------------------------------------------------------------------------------
// toggle the "selected" state of the cell.  App-specific subclasses should alter the appearance accordingly
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self setSelected:YES];
	self.touchStartTime = CACurrentMediaTime();
	[super touchesBegan:touches withEvent:event];
}


// ---------------------------------------------------------------------------------------------------------------------
// "long-press" should enable dragging, just like a swipe.  However, the long-press gesture conflicts with the pan
// gesture, so instead, simply keep track of touch duration and respond accordingly
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	if (self.isUserTogglingHiddenPanel) {
		return;
	}
	
	if (CACurrentMediaTime() - self.touchStartTime > 0.3f) {
		if (touches.count == 1) {
			for (UITouch *touch in touches) {
				self.swipeStartPoint = [touch locationInView:self];
			}
		}
		[self enableHiddenPanelDrag];
	}
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self setSelected:NO];
	[super touchesEnded:touches withEvent:event];
}


#pragma mark - Show/Hide Hidden Panel


// ---------------------------------------------------------------------------------------------------------------------
- (void)enableHiddenPanelDrag
{
	[self.dynamicAnimator removeBehavior:self.resistanceBehavior];
	[self.dynamicAnimator removeBehavior:self.attachmentBehavior];
	
	self.isUserTogglingHiddenPanel = YES;
	
	CGPoint mainPanelCenter = CGPointMake(self.mainPanel.bounds.size.width / 2, self.mainPanel.bounds.size.height / 2);
	if (self.isHiddenPanelExposed) {
		mainPanelCenter.x -= self.hiddenPanelWidth;
	}
	UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.mainPanel
																		 attachedToAnchor:mainPanelCenter];
	self.attachmentBehavior.frequency = 0;
	self.attachmentBehavior.damping = 0;
	self.attachmentBehavior = attachmentBehavior;
	[self.dynamicAnimator addBehavior:self.attachmentBehavior];
	
	// alert the tableview that the hidden panel is in the process of opening, and that scrolling is temporarily
	// prohibited
	[self.delegate hiddenPanelCell:self toggleScrolling:NO];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)exposeHiddenPanel
{
	// since animated opening is occuring, user is no longer in control of open/close process
	self.isUserTogglingHiddenPanel = NO;
	
	// add "spring" values to attachment behavior
	self.attachmentBehavior.frequency = self.attachmentSpringFrequency;
	self.attachmentBehavior.damping = self.attachmentSpringDamping;
	
	// add the resistance behavior to keep spring effect at reasonable speed
	[self.dynamicAnimator addBehavior:self.resistanceBehavior];
	
	// set the attachment behavior to the normal "open" point
	[self.attachmentBehavior setAnchorPoint:CGPointMake(self.bounds.size.width / 2 - self.hiddenPanelWidth,
														self.bounds.size.height / 2)];
	
	self.isHiddenPanelExposed = YES;
	
	// inform the tableview's controller that a cell has just opened, and also that scrolling is permitted again
	[self.delegate hiddenPanelCell:self toggleScrolling:YES];
	[self.delegate hiddenPanelCellOpened:self];
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)hideHiddenPanel
{
	// since animated closing is occuring, user is no longer in control of open/close process
	self.isUserTogglingHiddenPanel = NO;
	
	// add "spring" values to attachment behavior
	self.attachmentBehavior.frequency = self.attachmentSpringFrequency;
	self.attachmentBehavior.damping = self.attachmentSpringDamping;
	
	// add the resistance behavior to keep spring effect at reasonable speed
	[self.dynamicAnimator addBehavior:self.resistanceBehavior];
	
	// set the attachment behavior to the "closed" point
	[self.attachmentBehavior setAnchorPoint:CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2)];
	
	self.isHiddenPanelExposed = NO;
	
	// inform the tableview's controller that a cell has just closed, and also that scrolling is permitted again
	[self.delegate hiddenPanelCell:self toggleScrolling:YES];
	[self.delegate hiddenPanelCellClosed:self];
}


// ---------------------------------------------------------------------------------------------------------------------
// called when the user releases their finger while dragging.  Checks the finger location and drag speed to determine
// whether to open or close the hidden panel
- (void)finishFavDragWithOffset:(CGFloat)offset andVelocity:(CGFloat)velocity
{
	// dragging to the right (beyond minor nudge) = close
	if (velocity > 100) {
		[self hideHiddenPanel];
	// dragging to the left, or finger relatively still after dragging far enough to the left = open
	} else if (offset > self.hiddenPanelWidth * 0.55 || velocity < -300) {
		[self exposeHiddenPanel];
	// all other cases close
	} else {
		[self hideHiddenPanel];
	}
}


#pragma mark - Other


// ---------------------------------------------------------------------------------------------------------------------
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	if (!self.isUserTogglingHiddenPanel) {
		return YES;
	}
	return NO;
}


// ---------------------------------------------------------------------------------------------------------------------
- (void)flashSelected
{
	[self setSelected:YES];
	[self performSelector:@selector(setSelected:) withObject:NO afterDelay:0.25f];
}


@end
