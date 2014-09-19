/**
 *
 * TSTimeEntry.h
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

@class TSClient;

@interface TSTimeEntry : NSObject {

@public
    // we might not need this here since we keep TLTimeEntry objects within the Client class.
    TSClient * client;
    
@private
    
    BOOL active;
    
    NSDate *lastStartTime;
    NSTimeInterval totalTime;
    
    // reference pointers to hold the current NSMenuItem used for these objects. The representedObject
    // attached to the menuitem is the corresponding TSProject and TSTask
    NSMenuItem *selectedProject;
    NSMenuItem *selectedTask;
    
    NSNumber * projectId;
    NSNumber * taskId;
    BOOL billable;
    NSDate * workDate;
    NSString * workDescription;
    
}

@property (nonatomic, assign) BOOL active;

@property (nonatomic, retain) NSDate * lastStartTime;
@property (nonatomic) NSTimeInterval totalTime;

@property (nonatomic, strong) NSMenuItem * selectedProject;
@property (nonatomic, strong) NSMenuItem * selectedTask;
@property (nonatomic, strong) TSClient * client;
@property (nonatomic, strong) NSNumber * projectId;
@property (nonatomic, strong) NSNumber * taskId;
@property (nonatomic, assign) BOOL billable;
@property (nonatomic, strong) NSDate *workDate;
@property (nonatomic, strong) NSString * workDescription;

-(id) initWithClient:(TSClient *) clientObject;
-(void) timeStart:(id) sender;
-(void) timePause:(id) sender;
-(void) timeReset:(id) sender;
-(NSString *) updateTimeEntry:(id) sender;

@end
