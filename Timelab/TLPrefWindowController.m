/**
 *
 * TLPrefWindowController.m
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

#import "TLPrefWindowController.h"
#import "AFURLSessionManager.h"

@interface TLPrefWindowController ()
// private methods
@end

@implementation TLPrefWindowController

@synthesize timelabAPIKey, timelabBaseURL,timelabAuthUsername, timelabAuthPassword;

- (id)init {
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        // Initialization code here.
        
        NSButton *closeButton = [[self window] standardWindowButton:NSWindowCloseButton];
        [closeButton setTarget:self];
        [closeButton setAction:@selector(closePreferences:)];
        
        [timelabBaseURL setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"timelab-baseurl"]];
        [timelabAPIKey setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"timelab-apikey"]];
        [timelabAuthUsername setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"timelab-authuser"]];
        [timelabAuthPassword setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"timelab-authpass"]];

    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) savePreferences:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[timelabBaseURL stringValue] forKey:@"timelab-baseurl"];
    [[NSUserDefaults standardUserDefaults] setObject:[timelabAPIKey stringValue] forKey:@"timelab-apikey"];
    [[NSUserDefaults standardUserDefaults] setObject:[timelabAuthUsername stringValue] forKey:@"timelab-authuser"];
    [[NSUserDefaults standardUserDefaults] setObject:[timelabAuthPassword stringValue] forKey:@"timelab-authpass"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) closePreferences:(id)sender {
    [self close];
}
@end