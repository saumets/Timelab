/**
 *
 * TLClient.h
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

@class TLTimeEntry;

@interface TLClient : NSObject {

@private
    NSNumber *companyId;
    NSString *clientName;
    
    // used for the TimeStack menu.
    NSMenu *projectsMenu;
    NSMutableArray *projectsArray;
    
    NSMutableArray *timeEntries;
    
    NSMenuItem *clientTimeEntryMenuItem;
}

@property (nonatomic, strong) NSNumber *companyId;
@property (nonatomic, strong) NSString *clientName;

@property (nonatomic, strong) NSMenu *projectsMenu;
@property (nonatomic, strong) NSMutableArray *projectsArray;

@property (nonatomic, strong) NSMutableArray *timeEntries;

// NSMenuItem which holds this clients TimeEntryMenuItem
@property (nonatomic, strong) NSMenuItem *clientTimeEntryMenuItem;

-(id) initWithAttributes:(NSNumber *)cId withName:(NSString *)name;
/**
 * Our tasks array of task NSTask objects which returns a static array.
 *
 * GENIUS:
 * http://stackoverflow.com/questions/3871515/how-to-create-a-static-nsmutablearray-in-a-class-in-objective-c
 *
 */
- (NSMutableArray *) tasksArray;
- (NSMenu *) tasksMenu;

-(TLTimeEntry *)getActiveTimeEntry:(id)sender;

@end
