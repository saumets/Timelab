//
//  TSDatePickerPopoverController.h
//  TimeStack
//
//  Created by Paul Saumets on 9/18/14.
//  Copyright (c) 2014 Design Lab Inc. All rights reserved.
//

@interface TSDatePickerPopoverController : NSViewController <NSPopoverDelegate>;

@property (readonly, strong) IBOutlet NSDatePicker *datePicker;

- (IBAction)showDatePickerRelativeToRect:(NSRect)rect inView:(NSView *)view completionHander:(void(^)(NSDate *selectedDate))completionHandler;

@end
