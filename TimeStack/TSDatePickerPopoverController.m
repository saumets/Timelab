//
//  TSDatePickerPopoverController.m
//  TimeStack
//
//  Created by Paul Saumets on 9/18/14.
//  Copyright (c) 2014 Design Lab Inc. All rights reserved.
//

#import "TSDatePickerPopoverController.h"

@interface TSDatePickerPopoverController ()
@property (strong) IBOutlet NSPopover *popover;
@property (copy) void(^completionHandler)(NSDate *selectedDate);
@end

@implementation TSDatePickerPopoverController

@synthesize datePicker;
@synthesize popover;
@synthesize completionHandler = _completionHandler;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        NSLog(@"init popover controller.");
    }
    return self;
}

- (IBAction)showDatePickerRelativeToRect:(NSRect)rect inView:(NSView *)view completionHander:(void(^)(NSDate *selectedDate))completionHandler {
    
	_completionHandler = completionHandler;
    
	popover = [[NSPopover alloc] init];
	popover.delegate = self;
	popover.contentViewController = self;
	popover.behavior = NSPopoverBehaviorTransient;
	[popover showRelativeToRect:rect ofView:view preferredEdge:NSMaxXEdge];
}

@end
