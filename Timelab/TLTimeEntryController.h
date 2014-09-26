/**
 *
 * TLTimeEntryController.h
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

#import "TLDateTextField.h"

@class TLClient;
@class TLTimeEntry;
@class TLDatePickerPopoverController;

@protocol TLTimeEntryControllerDelegate;

@interface TLTimeEntryController : NSWindowController <NSWindowDelegate, NSPopoverDelegate> {

@private
    
    __weak id <TLTimeEntryControllerDelegate> delegate;
    
    // timer for updating panel pages
    NSTimer *activeTimeEntryUpdateTimer;
    // ivar reference to our current "active" timeEntry.
    TLTimeEntry * activeTimeEntry;
    // ivar reference to the currently showing timeEntry.
    TLTimeEntry * showingEntry;
    
    // Contains NSMenuItem(s)
    NSMutableSet * clientsWithTimeEntries;
    
@public
    
    // All the outlets for the time entry panel
    __weak NSPanel *timeEntryPanel;
    __weak NSPopUpButton *projectOutlet;
    __weak NSPopUpButton *taskOutlet;
    __weak NSButton *timeEntryCreateOutlet;
    __weak NSButton *timeEntryRemoveOutlet;
    __weak NSButton *timerToggleOutlet;
    __weak NSTextField *timeDisplayOutlet;
    __weak TLDateTextField *dateDisplayOutlet;
    __weak NSButton *billableOutlet;
    __weak NSTextField *notesOutlet;
    __weak NSSegmentedControl *timeEntryControlOutlet;
    __weak NSButton *submitTimeEntryOutlet;

}

@property (weak, nonatomic) id <TLTimeEntryControllerDelegate> delegate;

@property (nonatomic, strong) NSMutableSet *clientsWithTimeEntries;
@property (nonatomic, strong) TLTimeEntry *activeTimeEntry;

@property (nonatomic, weak) IBOutlet NSPanel *timeEntryPanel;
@property (nonatomic, weak) IBOutlet NSPopUpButton *projectOutlet;
@property (nonatomic, weak) IBOutlet NSPopUpButton *taskOutlet;
@property (nonatomic, weak) IBOutlet NSButton *timeEntryCreateOutlet;
@property (nonatomic, weak) IBOutlet NSButton *timeEntryRemoveOutlet;
@property (nonatomic, weak) IBOutlet NSButton *timerToggleOutlet;
@property (nonatomic, weak) IBOutlet NSTextField *timeDisplayOutlet;
@property (nonatomic, weak) IBOutlet TLDateTextField *dateDisplayOutlet;
@property (nonatomic, weak) IBOutlet NSButton *billableOutlet;
@property (nonatomic, weak) IBOutlet NSTextField *notesOutlet;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *timeEntryControlOutlet;
@property (nonatomic, weak) IBOutlet NSButton *submitTimeEntryOutlet;

- (BOOL) loadTimeEntry:(TLTimeEntry *)timeEntry;
- (void) loadClientTimeEntries:(TLClient *)client;

/**
 * Quickly checks to see whether the given client has an active time entry.
 *
 * @param client A TSClient object to check.
 *
 * @return The active TSTimeEntry object if found.
 *         nil otherwise.
 */

- (TLTimeEntry *) clientHasActiveTimeEntry:(TLClient *)client;

/**
 * Create a new time entry for a client.
 *
 * Attempts to create a new time entry for the given TSClient object. An error object should be passed to this
 * method as it checks to ensure that every client has no more than the MAX_TIME_ENTRIES_PER_CLIENT allowed.
 *
 * @param client A TSClient object
 * @param error A NSError object which is used in checking that no more than 5 time entries per client are active.
 * @return TRUE if successfully created the time entry.
 *         FALSE otherwise.
 */
- (BOOL) createTimeEntry:(id)sender forClient:(TLClient *)client error:(NSError * __autoreleasing *)error;

/**
 * Remove a time entry from a client.
 *
 * Attempts to remove the given time entry from it's client.
 *
 * @param timeEntry A TSTimeEntry object.
 *
 * @return TRUE if successfully removed the time entry.
 *         FALSE otherwise.
 */
- (BOOL) removeTimeEntry:(TLTimeEntry *)timeEntry;

- (TLClient *) findClientWithTimeEntry:(TLTimeEntry *)timeEntry;

/**
 * Save the current state into the given time entry object.
 *
 * @param timeEntry A TSTimeEntry object to whom we're going to save state.
 *
 * return void
 */
- (void) saveTimeEntryState:(TLTimeEntry *)timeEntry;

// timer pause

- (void) setAllTimeEntries:(BOOL)status;

- (void) setButtonStates:(BOOL)state;

// action selector methods
- (IBAction) newTimeEntry:(id)sender;
- (IBAction) clickedTimeEntryRemoveOutlet:(id)sender;
- (IBAction) submitTimeEntry:(id)sender;
- (IBAction) editTimeEntries:(id)sender;
- (IBAction) closeTimeEntries:(id)sender;
- (IBAction) toggleTimer:(id)sender;
@end

@protocol TLTimeEntryControllerDelegate <NSObject>

- (void) lastTimeEntryRemovedForClient:(TLClient *)client;

@end