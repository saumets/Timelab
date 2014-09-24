/**
 *
 * TLMainController.m
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

#import "AFURLSessionManager.h"

#import "TLMainController.h"

#import "TLClient.h"
#import "TLProject.h"
#import "TLTask.h"
#import "TLTimeEntry.h"

#define CLIENT_ACTIVE_START_OFFSET 5
#define PREFERENCES_MENUITEM_INDEX 1

@interface TLMainController (PrivateMethods)
- (void) rebuildClientMenuTree;
- (void) removeFromTimeEntryMenuTree:(TLClient *)client;
- (void) rebuildTimeEntryMenuTree;
@end

@implementation TLMainController

@synthesize validConnection;
@synthesize preferencesWindowController, timeEntryController;

@synthesize clientsArray;
//@synthesize tasksArray, tasksMenu;
@synthesize activeMenuItem;
@synthesize noTimeEntry;


- (id) initWithMenu:(NSMenu *)menu withClientIndex:(CGFloat)index {
    self = [super init];
    if (self) {
        // Initialization code here.
        
        // Reference to our root top-level NSMenu object.
        rootMenu = menu;
        
        // Reference to our NSMenu object where we'll attach the clients.
        clientSelectMenu = [[menu itemAtIndex:index] submenu];
        
        // Reference to our Preferences.. NSMenuItem
        NSMenuItem *preferencesItem = [rootMenu itemAtIndex:PREFERENCES_MENUITEM_INDEX];
        [preferencesItem setTarget:self];
        [preferencesItem setAction:@selector(openPreferences:)];
        
        // create our NO TIMES ENTRIES menu item. This is will be used and inserted into the status menu when
        // the user has no time entries active.
        
        noTimeEntry = [[NSMenuItem alloc] initWithTitle:@"No Time Entries" action:nil keyEquivalent:@""];
        [rootMenu insertItem:noTimeEntry atIndex:CLIENT_ACTIVE_START_OFFSET];
        
        // load our time entry controller and its windows for later user.
        // release when closed is disabled in the NIB for the panel since we're retaining it.
        if (!timeEntryController) {
            timeEntryController = [[TLTimeEntryController alloc] init];
            [timeEntryController setDelegate:self];
        }
        
        [self refreshTimelab];

    }
    return self;
}

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public Instance Methods
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (void) refreshTimelab {
    
    NSString *URL = [[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-baseurl"];
    NSString *apiKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-apikey"];

    NSString *authUser = [[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-authuser"];
    NSString *authPass = [[NSUserDefaults standardUserDefaults] stringForKey:@"timestack-authpass"];
    
    NSURL *baseURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@",URL]];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    
    [manager setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    
    [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:authUser password:authPass];
    
    // SEND REQUEST
    // NSURLRequest *projectsRequest = [NSURLRequest requestWithURL:projectsURL];
    
    [manager GET:[NSString stringWithFormat:@"%@?api_key=%@", @"projects", apiKey] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // process response object
        NSArray *projects = [NSArray arrayWithArray:[responseObject valueForKeyPath:@"records"]];
        [self refreshClientModels:projects];
        [self refreshProjectModels:projects];
        [self rebuildClientMenuTree];
        
        [manager GET:[NSString stringWithFormat:@"%@?api_key=%@", @"tasks", apiKey] parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            // process response object
            NSArray *tasks = [NSArray arrayWithArray:[responseObject valueForKeyPath:@"records"]];
            [self refreshTaskModels:tasks];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            // failure.
            NSAlert *errorAlert = [NSAlert alertWithError:error];
            [errorAlert runModal];
        }];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // process failure.
        NSAlert *errorAlert = [NSAlert alertWithError:error];
        [errorAlert runModal];
    }];
}

- (void) newTimeEntry:(id)sender {
    
    if ([sender isKindOfClass:[NSMenuItem class]]) {
        
        NSMenuItem *menuItem = (NSMenuItem *)sender;
        if ([[menuItem representedObject] isKindOfClass:[TLClient class]]) {
            
            TLClient *client = (TLClient *)[menuItem representedObject];
            
            NSError *error = nil;
            if (![timeEntryController createTimeEntry:self forClient:client error:&error]) {
                NSAlert *errorAlert = [NSAlert alertWithError:error];
                // The client has more than maximum allowed time entries currently. Is one of them active?
                TLTimeEntry *timeEntry = [timeEntryController clientHasActiveTimeEntry:client];
                
                // if one is active load that one up, otherwise load up the first time entry.
                if (timeEntry) {
                    [timeEntryController loadTimeEntry:timeEntry];
                } else {
                    [timeEntryController loadTimeEntry:[[client timeEntries] objectAtIndex:0]];
                }
                
                // show why they couldn't create a new time entry for this client.
                [errorAlert runModal];
            }

            [self rebuildTimeEntryMenuTree];
        }
    }
}

///////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private Instance Methods (Thanks to the LLVM 4.0 compiler allowing this)
#pragma mark -
///////////////////////////////////////////////////////////////////////////

- (void) refreshClientModels:(NSArray *)projects {

    // [self setClientsArray:[[NSMutableArray alloc] init]];
    [self setClientsArray:[NSMutableArray array]];
    
    for (NSDictionary *project in projects) {
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
    
        NSNumber * client_id = [f numberFromString:[project valueForKeyPath:@"client_id"]];
        NSString * client_name = [project valueForKeyPath:@"client_name"];
    
        // predicate logic filter to see if the client exists in memory already
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId == %@ AND clientName == %@",client_id, client_name];
        NSArray *filteredClientsArray = [clientsArray filteredArrayUsingPredicate:predicate];
        
        // does the client object not exist in our memory already? then add it.
        if (![filteredClientsArray count]) {
            TLClient *newClient = [[TLClient alloc] initWithAttributes:client_id withName:client_name];

            [clientsArray addObject:newClient];
        }
    }
}

- (void) refreshTaskModels:(NSArray *)tasks {
    
    // to refresh the task models we require at least a single client in the system.
    if ([clientsArray count]) {
    
        TLClient *client = [clientsArray objectAtIndex:0];
      
        [[client tasksArray] removeAllObjects];

        for (NSDictionary *task in tasks) {
            
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterNoStyle];
            
            NSNumber * taskId = [f numberFromString:[task valueForKeyPath:@"task_id"]];
            NSString * taskName = [task valueForKeyPath:@"task_name"];
            
            NSNumber * categoryId = [f numberFromString:[task valueForKeyPath:@"category_id"]];
            NSString * categoryName = [task valueForKeyPath:@"category_name"];
            
            BOOL taskStatus = [[task valueForKeyPath:@"is_active"] boolValue];
            
            TLTask *newTask = [[TLTask alloc] initWithAttributes:taskId withName:taskName categoryName: categoryName categoryId: categoryId andStatus:taskStatus];
            
            [[client tasksArray] addObject:newTask];
        }
        
        [[client tasksMenu] removeAllItems];
        
        for (TLTask *task in [client tasksArray]) {
            NSMenuItem *taskMenuItem = [[NSMenuItem alloc] initWithTitle:[task taskName] action:nil keyEquivalent:@""];
            [taskMenuItem setRepresentedObject:task];
            
            [[client tasksMenu] addItem:taskMenuItem];
        }
        
    }
}

- (void) refreshProjectModels:(NSArray *)projects {
    
    // reset the activeProjectsArray and empty it out. ARC takes care of this.
    // [self setProjectsActiveArray:[[NSMutableArray alloc] init]];
    // [self setProjectsInactiveArray:[[NSMutableArray alloc] init]];
    
    for (NSDictionary *project in projects) {

        
        NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        
        NSNumber * client_id = [f numberFromString:[project valueForKeyPath:@"client_id"]];

        NSNumber * projectId = [f numberFromString:[project valueForKeyPath:@"project_id"]];
        NSString * projectName = [project valueForKeyPath:@"project_name"];
        
        BOOL projectStatus = [[project valueForKeyPath:@"active"] boolValue];
        
        TLProject *newProject = [[TLProject alloc] initWithAttributes:projectId withTitle:projectName andStatus:projectStatus];
        
        if ([self addProjectToClient:newProject withClientId:client_id]) {
            continue;
        } else {
            NSLog(@"Error: Could not add project to client. Client not found!");
        }
        
     }
    
}

- (void) rebuildTimeEntryMenuTree {
    
    NSArray *items = [rootMenu itemArray];
    
    for ( NSMenuItem *menuItem in items) {
        if ( [[timeEntryController clientsWithTimeEntries] containsObject:menuItem] ) {
            [rootMenu removeItem:menuItem];
        }
    }
    
    NSSortDescriptor *alphaDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSArray *sortedItems = [[timeEntryController clientsWithTimeEntries] sortedArrayUsingDescriptors:[NSArray arrayWithObject:alphaDescriptor]];

    // ensure the No Time Entries item is not there.
    if (![sortedItems count]) {
        //[rootMenu addItem:noTimeEntry];
        [rootMenu insertItem:noTimeEntry atIndex:CLIENT_ACTIVE_START_OFFSET];
    } else {
        if ([[rootMenu itemArray] containsObject:noTimeEntry]){
            [rootMenu removeItem:noTimeEntry];
        }
    }
    
    for (int i = 0; i < [sortedItems count]; i++) {
        NSMenuItem *menuItem = (NSMenuItem *)sortedItems[i];
        [rootMenu insertItem:menuItem atIndex:(i+CLIENT_ACTIVE_START_OFFSET)];
    }
}

- (void) rebuildClientMenuTree {
    
    [clientSelectMenu removeAllItems];
    
    // refresh the new entry - clients menu
    for (TLClient *client in clientsArray) {
        NSMenuItem *newClientItem = [[NSMenuItem alloc] initWithTitle:[client clientName] action:@selector(newTimeEntry:) keyEquivalent:@""];
        // attach the TLClient object as the represented object for this NSMenuItem
        [newClientItem setTarget:self];
        [newClientItem setRepresentedObject:client];
        [clientSelectMenu addItem:newClientItem];
    }
}

- (BOOL) addProjectToClient:(TLProject *)project withClientId:(NSNumber *)clientId {
    
    // predicate logic filter to see if the client exists in memory already
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"companyId == %@",clientId];
    NSArray *filteredClientsArray = [clientsArray filteredArrayUsingPredicate:predicate];
    
    if ([filteredClientsArray count]) {
        // we found our client. assign it to the project model and add the project to the client project(s) array.
        TLClient *client = (TLClient *)[filteredClientsArray objectAtIndex:0];
        [project setProjectClient:client];
        [[client projectsArray] addObject:project];
        
        // TODO: Need to add configuration option for whether we include all projects or only active projects.
        if ([project projectStatus]) {
            NSMenuItem *projectMenuItem = [[NSMenuItem alloc] initWithTitle:[project projectTitle] action:nil keyEquivalent:@""];
            [projectMenuItem setRepresentedObject:project];
            [[client projectsMenu] addItem:projectMenuItem];
        }
    }
    
    return TRUE;
}

- (void) openPreferences:(id)sender {
    
    if (!preferencesWindowController) {
        preferencesWindowController = [[TLPrefWindowController alloc] init];
    }
    
    [NSApp activateIgnoringOtherApps:YES];
    [self.preferencesWindowController showWindow:self];
    [[self.preferencesWindowController window] makeKeyAndOrderFront:self];
}

#pragma mark -
#pragma mark TSTimeEntryController Delegate Implementation

- (void) lastTimeEntryRemovedForClient:(TLClient *)client {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title == %@",[client clientName]];
    NSSet *filteredClientSet = [[timeEntryController clientsWithTimeEntries] filteredSetUsingPredicate:predicate];
    
    if ([filteredClientSet count] ) {
        NSArray *allObjectsArray = [filteredClientSet allObjects];
        NSMenuItem *clientMenuItem = (NSMenuItem *)[allObjectsArray objectAtIndex:0];
        
        [[timeEntryController clientsWithTimeEntries] removeObject:clientMenuItem];
        [rootMenu removeItem:clientMenuItem];
    }

    if ([self respondsToSelector:@selector(rebuildTimeEntryMenuTree)]) {
        [self rebuildTimeEntryMenuTree];
    }
}

@end