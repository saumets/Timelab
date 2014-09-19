//
//  TSDateTextField.m
//  TimeStack
//
//  Created by Paul Saumets on 9/18/14.
//  Copyright (c) 2014 Design Lab Inc. All rights reserved.
//

#import "TSDateTextField.h"

#define ICON_WIDTH 16.0f
#define ICON_HEIGHT 16.0f

@implementation TSDateTextField

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
        //showPopoverButton.image = [NSImage imageNamed:@"calendar.png"];
        [showPopoverButton.cell setHighlightsBy:NSContentsCellMask];
        
        [self addSubview:showPopoverButton];
        NSLog(@"Added subview");
        //[self addSubview:showPopoverButton positioned:NSWindowAbove relativeTo:self];
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code here.
    //NSButton *showPopoverButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    
    NSRect buttonFrame = NSMakeRect(0.0f, 0.0f, 16.0f, 16.0f);
    
    NSButton *showPopoverButton = [[NSButton alloc] initWithFrame:buttonFrame];
    
    NSImage *calImage = [NSImage imageNamed:@"calendar.png"];
    if (calImage == nil) {
        NSLog(@"Failed to find calendar image.");
    }
    
    showPopoverButton.buttonType = NSMomentaryChangeButton;
    showPopoverButton.bezelStyle = NSInlineBezelStyle;
    showPopoverButton.bordered = YES;
    showPopoverButton.imagePosition = NSImageOnly;
    
    [showPopoverButton setImage:calImage];
    [showPopoverButton.cell setHighlightsBy:NSContentsCellMask];
    
    //[showPopoverButton drawInteriorWithFrame:buttonFrame inView:self];
    
    [self addSubview:showPopoverButton];
    NSLog(@"Added subview AWAKE");
 
}

- (NSRect) popoverButtonRectForBounds:(NSRect) rect;
{
	//rect.origin.x+=rect.size.width-(_searchButtonCell?(ICON_WIDTH+4.0):4.0);
	//rect.size.width=_cancelButtonCell?ICON_WIDTH:0.0;
	return rect;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void) mouseDown:(NSEvent *)theEvent {
    NSLog(@"Clicked Date TextField!");
}

@end
