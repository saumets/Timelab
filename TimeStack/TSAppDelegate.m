/**
 *
 * TSAppDelegate.m
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

#import "TSAppDelegate.h"
#import "TSPrefWindowController.h"
#import "TSMainController.h"
#import "TSTimeEntryController.h"

#define TIMELAB_MENUITEM_INDEX 3

@implementation TSAppDelegate

@synthesize statusItem;
@synthesize statusItemView;

@synthesize statusMenu;
@synthesize timeMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // set up our NSUserDefaults if this is first run.
    NSURL *timestackDefaultsFile = [[NSBundle mainBundle] URLForResource:@"timestackDefaults" withExtension:@"plist"];
    NSDictionary *appDefaults = [NSDictionary dictionaryWithContentsOfURL:timestackDefaultsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    // setup custom view that implements mouseDown: and rightMouseDown:
    self.statusItemView = [[TSStatusItemView alloc] init];
    self.statusItemView.image = [NSImage imageNamed:@"designlab_icon.png"];
    self.statusItemView.target = self;
    self.statusItemView.action = @selector(mainAction);
    self.statusItemView.rightAction = @selector(rightMenu);
    
    // set menu delegate
    [self.timeMenu setDelegate:self];
    [self.statusMenu setDelegate:self];
    
    // use the custom view in the status bar item
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [statusItem setView:self.statusItemView];
    
    if (!timelabMainController) {
        timelabMainController= [[TSMainController alloc] initWithMenu:statusMenu withClientIndex:TIMELAB_MENUITEM_INDEX];
    }
    
}

- (void) applicationWillTerminate:(NSNotification *)notification {
    NSLog(@"Application is terminating.");
}

- (void) dealloc {
    NSLog(@"Deallocating TSMainController.");
    timelabMainController = nil;
}

// menu delegate method to unhighlight the custom status bar item view
- (void)menuDidClose:(NSMenu *)menu{
    [self.statusItemView setHighlightState:NO];
}

-(void) mainAction {
    // check if we are showing the highlighted state of the custom status item view
    if(self.statusItemView.clicked){
        // show the right click menu
        [self.statusItem popUpStatusItemMenu:self.statusMenu];
    }
}

-(void) rightMenu {
    if(self.statusItemView.clicked){
        // show the right click menu
        [self.statusItem popUpStatusItemMenu:self.timeMenu];
    }
}

#pragma mark -
#pragma mark IBAction Selectors

- (void) openAboutTimeStack:(id)sender {
    
   [aboutTimeStack makeKeyAndOrderFront:self];
}

@end
