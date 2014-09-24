/**
 *
 * TLDatePickerPopoverController.m
 * Timelab
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2014 Paul Saumets
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 **/

#import "TLDatePickerPopoverController.h"

@interface TLDatePickerPopoverController ()
@property (copy) void(^completionHandler)(NSDate *selectedDate);
@end

@implementation TLDatePickerPopoverController

@synthesize datePicker;
@synthesize dateSelectPopOver;
@synthesize completionHandler = _completionHandler;


- (id) init {
    self = [super init];
    if (self) {
        self.view = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 139.0f, 148.0f)];
        if (![self datePicker]) {
            datePicker = [[NSDatePicker alloc] initWithFrame:NSMakeRect(0.0, 0.0, 139.0f, 148.0f)];
            [datePicker setDatePickerStyle:NSClockAndCalendarDatePickerStyle];
            [datePicker setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
            [datePicker setBezeled:FALSE];
            [datePicker setTarget:self];
            [datePicker setAction:@selector(dateChanged:)];
            
            [datePicker setTimeZone:[NSTimeZone localTimeZone]];
            
            [self.view addSubview:datePicker];
        }
    }
    
    return self;
}

- (IBAction)showDatePickerRelativeToRect:(NSRect)rect inView:(NSView *)view completionHander:(void(^)(NSDate *selectedDate))completionHandler {
    
	_completionHandler = completionHandler;
    
	if (![self dateSelectPopOver]) {
        dateSelectPopOver = [[NSPopover alloc] init];
    }
    
	dateSelectPopOver.delegate = self;
	dateSelectPopOver.contentViewController = self;
	dateSelectPopOver.behavior = NSPopoverBehaviorTransient;
	[dateSelectPopOver showRelativeToRect:rect ofView:view preferredEdge:NSMaxYEdge];
}

- (void)popoverWillClose:(NSNotification *)notification {
	_completionHandler([datePicker dateValue]);
}

- (void)dateChanged:(id)sender {
	_completionHandler([datePicker dateValue]);
}

@end
