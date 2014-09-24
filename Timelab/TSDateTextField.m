/**
 *
 * TSDateTextField.m
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

#import "TSDateTextField.h"
#import "TSDatePickerPopoverController.h"

#define ICON_WIDTH 16.0f
#define ICON_HEIGHT 16.0f

@interface TSDateTextField()
@property (strong) TSDatePickerPopoverController *datePickerViewController;
- (void)performClick:(id)sender;
@end;

@implementation TSDateTextField

@synthesize datePickerViewController;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        NSButton *showPopoverButton = [[NSButton alloc] initWithFrame:NSZeroRect];
        showPopoverButton.buttonType = NSMomentaryChangeButton;
        showPopoverButton.bezelStyle = NSInlineBezelStyle;
        showPopoverButton.bordered = NO;
        showPopoverButton.imagePosition = NSImageOnly;

        [showPopoverButton setImage:[NSImage imageNamed:@"calendar.png"]];
        [showPopoverButton.cell setHighlightsBy:NSContentsCellMask];
        
        [self addSubview:showPopoverButton];
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code here.
    
    NSRect buttonFrame = [self popoverButtonRectForBounds:[self bounds]];
    NSButton *showPopoverButton = [[NSButton alloc] initWithFrame:buttonFrame];
    
    NSImage *calImage = [NSImage imageNamed:@"calendar"];
    if (calImage == nil) {
        NSLog(@"Failed to find calendar image.");
    }
    
    showPopoverButton.buttonType = NSMomentaryChangeButton;
    showPopoverButton.bezelStyle = NSInlineBezelStyle;
    showPopoverButton.bordered = NO;
    showPopoverButton.imagePosition = NSImageOnly;
    
    [showPopoverButton setImage:calImage];
    [showPopoverButton.cell setHighlightsBy:NSContentsCellMask];
    
    [showPopoverButton setTarget:self];
    [showPopoverButton setAction:@selector(performClick:)];
    
    [self addSubview:showPopoverButton];
    
}

- (NSRect) popoverButtonRectForBounds:(NSRect) rect;
{
    
    NSRect popoverButtonFrame = NSZeroRect;
    
    popoverButtonFrame.origin.x += rect.size.width-(ICON_WIDTH)-8.0f;
    popoverButtonFrame.origin.y += 3.0f;
    popoverButtonFrame.size.width = ICON_WIDTH;
    popoverButtonFrame.size.height = ICON_HEIGHT;

	return popoverButtonFrame;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)performClick:(id)sender {
    
    if (![self datePickerViewController]) {
        datePickerViewController = [[TSDatePickerPopoverController alloc] init];
        [datePickerViewController.datePicker setDateValue:[NSDate date]];
    }

    [datePickerViewController.datePicker setDelegate:self];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM/dd/yyyy"];
    [datePickerViewController.datePicker setDateValue:[dateFormat dateFromString:[self stringValue]]];
	
	[datePickerViewController showDatePickerRelativeToRect:[sender bounds] inView:sender completionHander:^(NSDate *selectedDate) {
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM/dd/YY"];
        //[format setDateStyle:NSDateFormatterLongStyle];
        //[self setStringValue:[format stringFromDate:selectedDate]];
        [[self cell] setPlaceholderString:[format stringFromDate:selectedDate]];
    }];
 }

/*
- (void) mouseDown:(NSEvent *)theEvent {
    NSLog(@"Clicked Date TextField!");
}
*/

@end
