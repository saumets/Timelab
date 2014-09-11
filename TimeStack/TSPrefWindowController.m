/**
 *
 * TSPrefWindowController.m
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

#import "TSPrefWindowController.h"
#import "AFURLSessionManager.h"

@interface TSPrefWindowController ()
// private methods
@end

@implementation TSPrefWindowController

@synthesize delegate, timestackAPIKey, timestackBaseURL,timestackAuthUsername, timestackAuthPassword;

- (id)init {
    self = [super initWithWindowNibName:@"Preferences"];
    if (self) {
        // Initialization code here.
        
        NSButton *closeButton = [[self window] standardWindowButton:NSWindowCloseButton];
        [closeButton setTarget:self];
        [closeButton setAction:@selector(closePreferences:)];
        
        [timestackBaseURL setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-baseurl"]];
        [timestackAPIKey setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-apikey"]];
        [timestackAuthUsername setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-authname"]];
        [timestackAuthPassword setStringValue:[[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-authpass"]];

    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void) savePreferences:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:[timestackBaseURL stringValue] forKey:@"timestack-baseurl"];
    [[NSUserDefaults standardUserDefaults] setObject:[timestackAPIKey stringValue] forKey:@"timestack-apikey"];
    [[NSUserDefaults standardUserDefaults] setObject:[timestackAuthUsername stringValue] forKey:@"timestack-authuser"];
    [[NSUserDefaults standardUserDefaults] setObject:[timestackAuthPassword stringValue] forKey:@"timestack-authpass"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.delegate testConnection:self];
}

- (void) closePreferences:(id)sender {
    [self close];
}
@end