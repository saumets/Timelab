/**
 *
 * TSTimeOverridePopoverController.m
 * TimeStack
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

#import "TSTimeOverridePopoverController.h"

@interface TSTimeOverridePopoverController ()
@property (copy) void(^completionHandler)(NSString *timeValue);
@end

@implementation TSTimeOverridePopoverController

@synthesize overrideLabel, hoursLabel, timeOverride;
@synthesize timeOverridePopOver;
@synthesize completionHandler = _completionHandler;

- (id) init {
    self = [super init];
    if (self) {
        self.view = [[NSView alloc] initWithFrame:NSMakeRect(0.0, 0.0, 215.0f, 144.0f)];
        
        if (![self overrideLabel]) {
            overrideLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(18.0f, 47.0f, 179.0f, 84.0f)];
            [overrideLabel setBezeled:FALSE];
            [overrideLabel setDrawsBackground:FALSE];
            [overrideLabel setEditable:FALSE];
            [overrideLabel setSelectable:FALSE];
            [overrideLabel setFont:[NSFont systemFontOfSize:11.0f]];
            [overrideLabel setStringValue:@"You have chosen manual time entry. Please enter the number of hours worked in decimal format (e.g. 1.5). An example of 20 minutes would convert to 0.32 hrs."];
            [self.view addSubview:overrideLabel];
        }
        
        if (![self hoursLabel]) {
            hoursLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(58.0f, 22.0f, 81.0f, 17.0f)];
            [hoursLabel setBezeled:FALSE];
            [hoursLabel setDrawsBackground:FALSE];
            [hoursLabel setEditable:FALSE];
            [hoursLabel setSelectable:FALSE];
            [hoursLabel setStringValue:@"Total Hours:"];
            [self.view addSubview:hoursLabel];
        }
        
        if (![self timeOverride]) {
            
            timeOverride = [[NSTextField alloc] initWithFrame:NSMakeRect(145.0f, 20.0f, 50.0f, 22.0f)];
            //[datePicker setDatePickerStyle:NSClockAndCalendarDatePickerStyle];
            //[datePicker setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
            //[datePicker setBezeled:FALSE];
            [timeOverride setTarget:self];
            [timeOverride setAction:@selector(timeOveride:)];
            
            [self.view addSubview:timeOverride];
        }
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)showTimeOverrideRelativeToRect:(NSRect)rect inView:(NSView *)view completionHander:(void(^)(NSString *timeValue))completionHandler {
    
	_completionHandler = completionHandler;
    
	if (![self timeOverridePopOver]) {
        timeOverridePopOver = [[NSPopover alloc] init];
    }
    
	timeOverridePopOver.delegate = self;
	timeOverridePopOver.contentViewController = self;
	timeOverridePopOver.behavior = NSPopoverBehaviorTransient;
	[timeOverridePopOver showRelativeToRect:rect ofView:view preferredEdge:NSMaxYEdge];
}

- (void)popoverWillClose:(NSNotification *)notification {
	_completionHandler([timeOverride stringValue]);
}

- (void)timeOveride:(id)sender {
	_completionHandler([timeOverride stringValue]);
    [timeOverridePopOver performClose:self];
}

@end
