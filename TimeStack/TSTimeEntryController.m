/**
 *
 * TSTimeEntryController.m
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

#import "AFNetworking.h"
#import "TSTimeEntryController.h"
#import "TSTimeEntry.h"
#import "TSTask.h"
#import "TSProject.h"

#import "TSClient.h"

NSUInteger const MAX_TIME_ENTRIES_PER_CLIENT = 5;

@implementation TSTimeEntryController

@synthesize delegate;
@synthesize clientsWithTimeEntries, activeTimeEntry;
@synthesize timeEntryPanel, projectOutlet, taskOutlet, timeEntryCreateOutlet, timeEntryRemoveOutlet, timerToggleOutlet,timeDisplayOutlet, dateDisplayOutlet, billableOutlet, notesOutlet, timeEntryControlOutlet, submitTimeEntryOutlet;

- (id)init {
    self = [super initWithWindowNibName:@"TimeEntry"];
    if (self) {
        // Initialization code here.
        
        // allocate any data we need
        clientsWithTimeEntries = [[NSMutableSet alloc] init];

        // load our window
        [self window];

        [timeEntryPanel setDelegate:self];
        
        // Need to throw this onto a background run loop. Could be 1.0f but 0.5f ensures more accurate updates.
        activeTimeEntryUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f
                                                                      target:self
                                                                    selector:@selector(updateActiveTimeEntry:)
                                                                    userInfo:nil
                                                                     repeats:YES];
        
        // this should go on the load time entry page.
        [[NSRunLoop mainRunLoop] addTimer:activeTimeEntryUpdateTimer forMode:NSRunLoopCommonModes];
        
        NSButton *closeButton = [[self window] standardWindowButton:NSWindowCloseButton];
        [closeButton setTarget:self];
        [closeButton setAction:@selector(closeTimeEntries:)];
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)windowDidResignKey:(NSNotification *)notification {
    NSLog(@"Houston...we lost a panel.");
    [self saveTimeEntryState:showingEntry];
}

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Instance Methods
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (void) newTimeEntry:(id)sender {
    if ([sender isKindOfClass:[NSButton class]]) {
        
        TSClient *client = (TSClient *)[[sender cell] representedObject];
        
        NSError *error = nil;
        if (![self createTimeEntry:self forClient:client error:&error]) {
            NSAlert *errorAlert = [NSAlert alertWithError:error];
            [errorAlert runModal];
            return;
        }
    }
}

- (BOOL) removeTimeEntry:(TSTimeEntry *)timeEntry {
    
    TSClient *client = [self findClientWithTimeEntry:timeEntry];
    
    // straight basic removal from array.
    
    if ([[client timeEntries] count]) {
        
        [[client timeEntries] removeObject:timeEntry];
        
        if ([[client timeEntries] count]) {
            [self loadTimeEntry:[[client timeEntries] objectAtIndex:0]];
            return TRUE;
        } else {
            [[self window] close];
            [self.delegate lastTimeEntryRemovedForClient:client];
            return TRUE;
        }
    }

    return FALSE;
}

- (TSTimeEntry *) clientHasActiveTimeEntry:(TSClient *)client {
    for(TSTimeEntry *timeEntry in [client timeEntries]) {
        if ([timeEntry active]) {
            return timeEntry;
        }
    }
    return nil;
}

- (TSClient *) findClientWithTimeEntry:(TSTimeEntry *)timeEntry {

    for (NSMenuItem *clientMenuItem in [self clientsWithTimeEntries]) {
        
        TSClient *clientItem = (TSClient *)[clientMenuItem representedObject];
        
        if ([[clientItem timeEntries] containsObject:timeEntry]) {
            return clientItem;
        }
    }
    
    return nil;
}

- (BOOL) createTimeEntry:(id)sender forClient:(TSClient *)client error:(NSError * __autoreleasing *)error {
    
    if ([[client timeEntries] count] >= MAX_TIME_ENTRIES_PER_CLIENT) {
        NSDictionary *userInfo = @{
           NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to create new time entry.", nil),
           NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Only 5 time entires are allowed active per client.", nil),
           NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Submit an entry first before creating a new one?", nil)
        };
        
        *error = [NSError errorWithDomain:@"TimeStack"
                                             code:-1
                                         userInfo:userInfo];
        return FALSE;
    }
    
    // save the state of the currently showing time entry before creating a new one if we're currently showing an entry.
    if (showingEntry != nil) {
       [self saveTimeEntryState:showingEntry];
    }
    
    // set all existing timers to inactive state as we're creating a new one!
    [self setAllTimeEntries:FALSE];
    
    // Create the new Time Entry and attach it to the client
    TSTimeEntry *newTimeEntry = [[TSTimeEntry alloc] initWithClient:client];
    [newTimeEntry setActive:TRUE];
    [[client timeEntries] addObject:newTimeEntry];
    
    // Check to see if this client is in our clientsWithTimeEntries set, otherwise add it.
    // We use predicate logic filter to see if the NSMenuItem exists in the menu already.
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@",[client clientName]];
    NSSet *filteredClientSet = [[self clientsWithTimeEntries] filteredSetUsingPredicate:predicate];
    
    if ( ![filteredClientSet count] ) {
        
        NSMenuItem *newMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@",[client clientName]] action:@selector(editTimeEntries:)  keyEquivalent:@""];
        [newMenuItem setRepresentedObject:client];
        [newMenuItem setTarget:self];
        [newMenuItem setEnabled:TRUE];
        
        [[self clientsWithTimeEntries] addObject:newMenuItem];

    }
    
    [self loadTimeEntry:newTimeEntry];
    
    return TRUE;
}

- (void) editTimeEntries:(id)sender {
    TSClient *client = (TSClient *)[sender representedObject];
    [self loadClientTimeEntries:client];
}

- (void) closeTimeEntries:(id)sender {
    [self saveTimeEntryState:showingEntry];
    showingEntry = nil;
    [self close];
}

- (BOOL) loadTimeEntry:(TSTimeEntry *)timeEntry {
    
    // prep our reference pointer for finding our client.
    TSClient *client = [self findClientWithTimeEntry:timeEntry];
    NSInteger *timeEntryIndex;
    
    if (client == nil) {
        NSException *e = [NSException
                          exceptionWithName:@"ClientForTimeEntryNotFound"
                          reason:@"*** A client for this time entry could not be found!"
                          userInfo:nil];
        @throw e;
    }
    
    timeEntryIndex = [[client timeEntries] indexOfObject:timeEntry];
    NSInteger timeEntries = [[client timeEntries] count];
    
    // how many segments
    [timeEntryControlOutlet setSegmentCount:timeEntries];
    
    for(int i = 0; i < timeEntries; i++) {
        NSUInteger segmentLabel = (NSUInteger)i+1;
        [timeEntryControlOutlet setLabel:[NSString stringWithFormat:@"%li",  segmentLabel] forSegment:i];
        [timeEntryControlOutlet setWidth:36 forSegment:i];
    }
    
    [[timeEntryControlOutlet selectedCell] setRepresentedObject:[client timeEntries]];
    [timeEntryControlOutlet setSelectedSegment:timeEntryIndex];
    
    [timeEntryPanel setTitle:[client clientName]];
    
    // get all projects and tasks
    [projectOutlet setMenu:[client projectsMenu]];
    
    if ([[projectOutlet itemArray] containsObject:[timeEntry selectedProject]]) {
        [projectOutlet selectItem:[timeEntry selectedProject]];
    } else {
        [projectOutlet selectItemAtIndex:0];
    }

    [taskOutlet setMenu:[client tasksMenu]];
    
    if ([[taskOutlet itemArray] containsObject:[timeEntry selectedTask]]) {
        [taskOutlet selectItem:[timeEntry selectedTask]];
    } else {
        [taskOutlet selectItemAtIndex:0];
    }
    
    [timeEntryCreateOutlet setAction:@selector(newTimeEntry:)];
    [timeEntryCreateOutlet setTarget:self];
    [[timeEntryCreateOutlet cell] setRepresentedObject:client];
    
    //[timeEntryRemoveOutlet setAction:@selector(removeTimeEntry:)];
    //[timeEntryRemoveOutlet setTarget:self];
    //[[timeEntryRemoveOutlet cell] setRepresentedObject:timeEntry];
    
    if (timeEntries >= MAX_TIME_ENTRIES_PER_CLIENT) {
        [timeEntryCreateOutlet setEnabled:FALSE];
    } else {
        [timeEntryCreateOutlet setEnabled:TRUE];
    }
    
    
    
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:[timeEntry totalTime]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    
    // check if manual time entry exists for this entry.
    if (isnan([timeEntry manualTime])) {
        // manual entry does not exist - show our timer values
        if ([timeEntry active]) {
            [timerToggleOutlet setTitle:@"Pause"];
            activeTimeEntry = timeEntry;
            // [timeDisplayOutlet setStringValue:[timeEntry updateTimeEntry:self]];
            [[timeDisplayOutlet cell] setPlaceholderString:[timeEntry updateTimeEntry:self]];
        } else {
            [timerToggleOutlet setTitle:@"Start"];
            activeTimeEntry = nil;
            // [timeDisplayOutlet setStringValue:[dateFormatter stringFromDate:timerDate]];
            [[timeDisplayOutlet cell] setPlaceholderString:[dateFormatter stringFromDate:timerDate]];
        }
    } else {
        [timeDisplayOutlet setStringValue:[NSString stringWithFormat:@"%.02lf",[timeEntry manualTime]]];
    }

    
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    [dateDisplayOutlet setAlignment:NSRightTextAlignment];
    [[dateDisplayOutlet cell] setPlaceholderString:[dateFormatter stringFromDate:[timeEntry workDate]]];
    // [dateDisplayOutlet setStringValue:[dateFormatter stringFromDate:[timeEntry workDate]]];
    
    // START/PAUSE TIME BUTTON TOGGLE
    [[timerToggleOutlet cell] setRepresentedObject:timeEntry];
    [[submitTimeEntryOutlet cell] setRepresentedObject:timeEntry];
    
    [notesOutlet setStringValue:[timeEntry workDescription]];
    
    showingEntry = timeEntry;
    
    [NSApp activateIgnoringOtherApps:YES];
    [self showWindow:self];
    [[self window] makeKeyAndOrderFront:self];
    
    return TRUE;
}

- (void) loadClientTimeEntries:(TSClient *)client {
    TSTimeEntry *activeEntry = [self clientHasActiveTimeEntry:client];
    if (activeEntry) {
        [self loadTimeEntry:activeEntry];
    } else {
        [self loadTimeEntry:[[client timeEntries] objectAtIndex:0]];
    }
}

- (void) setAllTimeEntries:(BOOL)status {
    
    for (NSMenuItem *clientMenuItem in [self clientsWithTimeEntries]) {
        
        TSClient *client = (TSClient *)[clientMenuItem representedObject];
        
        for (TSTimeEntry *timeEntry in [client timeEntries]) {
            [timeEntry setActive:status];
        }
    }
}

- (void) saveTimeEntryState:(TSTimeEntry *)timeEntry {
    [timeEntry setSelectedProject:[projectOutlet selectedItem]];
    [timeEntry setSelectedTask:[taskOutlet selectedItem]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yy"];
    [timeEntry setWorkDate:[dateFormatter dateFromString:[[dateDisplayOutlet cell] placeholderString]]];
    
    if ([timeDisplayOutlet stringValue] && [[timeDisplayOutlet stringValue] length] > 0) {
        [timeEntry setManualTime:[timeDisplayOutlet doubleValue]];
    } else {
        [timeEntry setManualTime:NAN];
    }
    
    NSLog(@"Saving state.");
    
    [timeEntry setWorkDescription:[notesOutlet stringValue]];
    [timeEntry setBillable:[[NSNumber numberWithInteger:[billableOutlet state]] boolValue]];
}

- (IBAction)timeEntryControlSwitch:(id)sender {
    
    // save the state of the currently showingEntry
    [self saveTimeEntryState:showingEntry];
    
    NSInteger selectedEntry = [timeEntryControlOutlet selectedSegment];
    [timeEntryControlOutlet setSelectedSegment:selectedEntry];
    
    NSMutableArray *timeEntries = (NSMutableArray *)[[timeEntryControlOutlet selectedCell] representedObject];
    
    [self loadTimeEntry:(TSTimeEntry *)[timeEntries objectAtIndex:selectedEntry]];
}

- (IBAction)toggleTimer:(id)sender {
    
    TSTimeEntry *timeEntry = (TSTimeEntry *)[[sender cell] representedObject];
    
    if ([timeEntry active]) {
        [timeEntry setActive:FALSE];
        
        [timerToggleOutlet setTitle:@"Start"];
        activeTimeEntry = nil;
        
    } else {
        [timeEntry setActive:TRUE];
        
        [timerToggleOutlet setTitle:@"Pause"];
        activeTimeEntry = timeEntry;
    }
}

- (void) submitTimeEntry:(id)sender {
    
        [self saveTimeEntryState:showingEntry];
        [showingEntry setActive:FALSE];
    
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        
        TSProject *project = (TSProject *)[[showingEntry selectedProject] representedObject];
        TSTask *task = (TSTask *)[[showingEntry selectedTask] representedObject];

        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
    
        double hours = [showingEntry manualTime];
    
        if (isnan(hours)) {
           hours = ([showingEntry totalTime] / 3600);
        }
    
        parameters[@"project_id"] = [[project projectId] stringValue];
        parameters[@"date"] = [dateFormat stringFromDate:[showingEntry workDate]];
        parameters[@"hours"] = [NSString stringWithFormat:@"%.02lf", hours];
        parameters[@"billable"] = [NSNumber numberWithBool:[showingEntry billable]];
        parameters[@"task_id"] = [[task taskId] stringValue];
        parameters[@"notes"] = [showingEntry workDescription];
        
        
        NSString *URL = [[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-baseurl"];
        NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-apikey"];
    
        NSString *authUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-authuser"];
        NSString *authPass = [[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-authpass"];
    
        NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",URL]];
        
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        
        [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
        [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
        [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:authUser password:authPass];
    
        [manager POST:[NSString stringWithFormat:@"%@?api_key=%@", @"time", apiKey] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
            //
            NSLog(@"Post Success: %@",responseObject);
            
            [self removeTimeEntry:showingEntry];
            
        } failure:^(NSURLSessionDataTask *task, NSError *error) {

        }];
}

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBAction Selector Methods
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (void) clickedTimeEntryRemoveOutlet:(id)sender {
    [self removeTimeEntry:showingEntry];
}

/**
 * Update the rootMenu client list with all clients who have an active time entry open.
 *
 * @returns void
 */

- (void) updateActiveTimeEntry:(id)sender {
    if (activeTimeEntry != nil) {
      //[timeDisplayOutlet setStringValue:[activeTimeEntry updateTimeEntry:self]];
        [[timeDisplayOutlet cell] setPlaceholderString:[activeTimeEntry updateTimeEntry:self]];
    }
}

@end