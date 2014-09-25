/**
 *
 * TLTimeTextField.m
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

#import "TLTimeTextField.h"
#import "TLTimeOverridePopoverController.h"

#define ICON_WIDTH 16.0f
#define ICON_HEIGHT 16.0f

@interface TLTimeTextField()
@property (strong) TLTimeOverridePopoverController *timeOverrideViewController;
- (void)performClick:(id)sender;
@end

@implementation TLTimeTextField

@synthesize timeOverrideViewController;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) awakeFromNib {
    NSRect buttonFrame = [self popoverButtonRectForBounds:[self bounds]];
    NSButton *showPopoverButton = [[NSButton alloc] initWithFrame:buttonFrame];
    
    NSImage *calImage = [NSImage imageNamed:@"clock"];
    if (calImage == nil) {
        NSLog(@"Failed to find clock image.");
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

- (void)performClick:(id)sender {
    
    if (![self timeOverrideViewController]) {
        timeOverrideViewController = [[TLTimeOverridePopoverController alloc] init];
        [timeOverrideViewController.timeOverride setStringValue:@""];
        [[timeOverrideViewController.timeOverride cell] setPlaceholderString:@"0.00"];
    }
    
    //[timeOverrideViewController.timeOverride setDelegate:self];

    if ([self stringValue]) {
        [timeOverrideViewController.timeOverride setStringValue:[self stringValue]];
    }
	
	[timeOverrideViewController showTimeOverrideRelativeToRect:[sender bounds] inView:sender completionHander:^(NSString *timeValue) {
        
        double hours = [timeValue doubleValue];
        if (hours > 0.00) {
            [self setStringValue:[NSString stringWithFormat:@"%.02lf",hours]];
        } else {
            [self setStringValue:@""];
        }
    }];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
