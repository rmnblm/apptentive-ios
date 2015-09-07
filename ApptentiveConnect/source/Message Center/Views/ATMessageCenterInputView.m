//
//  ATMessageCenterInputView.m
//  ApptentiveConnect
//
//  Created by Frank Schmitt on 7/14/15.
//  Copyright (c) 2015 Apptentive, Inc. All rights reserved.
//

#import "ATMessageCenterInputView.h"

@interface ATMessageCenterInputView ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendBarLeadingToSuperview;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textViewTrailingToSuperview;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendBarBottomToTextView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *titleLabelToClearButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *clearButtonToSendButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonBaselines;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sendButtonVerticalCenter;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *clearButtonLeadingToSuperview;

@property (strong, nonatomic) NSArray *landscapeConstraints;
@property (strong, nonatomic) NSArray *portraitConstraints;

@property (strong, nonatomic) NSArray *landscapeSendBarConstraints;
@property (strong, nonatomic) NSArray *portraitSendBarConstraints;

@end

@implementation ATMessageCenterInputView

- (void)awakeFromNib {
	self.containerView.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor;
	self.sendBar.layer.borderColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:204.0/255.0 alpha:1.0].CGColor;
	
	self.containerView.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
	self.sendBar.layer.borderWidth = 1.0 / [UIScreen mainScreen].scale;
	
	NSDictionary *views = @{ @"sendBar": self.sendBar, @"messageView": self.messageView };
	self.portraitConstraints = @[ self.sendBarLeadingToSuperview, self.sendBarBottomToTextView, self.textViewTrailingToSuperview ];
	
	self.landscapeConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[messageView]-(0)-[sendBar]-(0)-|" options:NSLayoutFormatAlignAllTop | NSLayoutFormatAlignAllBottom metrics:nil views:views];
	
	self.portraitSendBarConstraints = @[ self.titleLabelToClearButton, self.clearButtonToSendButton, self.buttonBaselines, self.clearButtonLeadingToSuperview, self.sendButtonVerticalCenter ];
	
	self.landscapeSendBarConstraints = @[ [NSLayoutConstraint constraintWithItem:self.sendBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.clearButton attribute:NSLayoutAttributeTop multiplier:1.0 constant:-8.0], [NSLayoutConstraint constraintWithItem:self.sendBar attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.sendButton attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0] ];
}

- (void)setOrientation:(UIInterfaceOrientation)orientation {
	_orientation = orientation;
	[self updateConstraints];
}

- (void)updateConstraints {
	if (UIInterfaceOrientationIsLandscape(self.orientation)) {
		self.titleLabel.alpha = 0;
		
		[self.containerView removeConstraints:self.portraitConstraints];
		[self.containerView addConstraints:self.landscapeConstraints];
		
		[self.sendBar removeConstraints:self.portraitSendBarConstraints];
		[self.sendBar addConstraints:self.landscapeSendBarConstraints];
	} else {
		self.titleLabel.alpha = 1;
		
		[self.containerView removeConstraints:self.landscapeConstraints];
		[self.containerView addConstraints:self.portraitConstraints];

		[self.sendBar removeConstraints:self.landscapeSendBarConstraints];
		[self.sendBar addConstraints:self.portraitSendBarConstraints];
	}
	
	[super updateConstraints];
}

@end