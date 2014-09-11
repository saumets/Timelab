/**
 *
 * TSClient.m
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

#import "TSClient.h"
#import "TSProject.h"

@implementation TSClient

@synthesize projectsMenu;
@synthesize clientName, companyId, projectsArray, timeEntries, clientTimeEntryMenuItem;

-(id) initWithAttributes:(NSNumber *)cId withName:(NSString *)name {
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [self setCompanyId:cId];
        [self setClientName:name];
        [self setProjectsArray:[[NSMutableArray alloc] init]];
        [self setTimeEntries:[[NSMutableArray alloc] init]];
        
        [self setProjectsMenu:[[NSMenu alloc] init]];
        
    }
    
    return self;
}

- (NSMutableArray *) tasksArray {

    static NSMutableArray *tasksArray = nil;
    if (tasksArray == nil) {
        tasksArray = [[NSMutableArray alloc] init];
    }
    return tasksArray;
}

- (NSMenu *) tasksMenu {
    static NSMenu *tasksMenu = nil;
    if (tasksMenu == nil) {
        tasksMenu = [[NSMenu alloc] init];
    }
    return tasksMenu;
}

-(TSTimeEntry *)getActiveTimeEntry:(id)sender {
   
    NSPredicate *aPredicate = [NSPredicate predicateWithFormat:@"active == %@", [NSNumber numberWithBool:YES]];
    NSArray *activeEntry = [timeEntries filteredArrayUsingPredicate:aPredicate];
    
    TSTimeEntry *timeEntry = (TSTimeEntry *)[activeEntry objectAtIndex:0];
    return timeEntry;
}

@end
