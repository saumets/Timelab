/**
 *
 * TSTimeEntry.m
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

#import "TSTimeEntry.h"

@implementation TSTimeEntry

@synthesize active = _active;

@synthesize lastStartTime;
@synthesize totalTime;

@synthesize client;
@synthesize selectedProject, selectedTask;
@synthesize projectId,taskId, billable;
@synthesize workDescription;

-(id)initWithClient:(TSClient *)clientObject {
    self = [super init];
    if (self) {
        // Initialization code here.
        
        [self setClient:clientObject];
        workDescription = [[NSString alloc] init];
    }
    
    return self;
}

// Custom getter and setters for active variable

-(void)setActive:(BOOL)a {
    
    if (a) {
        [self timeStart:self];
    } else {
        [self timePause:self];
    }
    
    _active = a;
}

-(BOOL)active {
    return _active;
}

-(void)timeStart:(id)sender {
    // should ONLY be calculated if the time entry is not active.
    if (![self active]) {
        self.lastStartTime = [ NSDate date ];
    }
}

-(void)timePause:(id)sender {
    // should ONLY be calculated if timer was active and we are now turning it off.
    if ([self active]) {
        self.totalTime = self.totalTime + [[NSDate date] timeIntervalSinceDate:self.lastStartTime];
    }
}

-(void)timeReset:(id)sender {
    totalTime = 0;
}

- (NSString *)updateTimeEntry:(id)sender {
    NSDate *currentTime = [NSDate date];
    NSTimeInterval timeInterval = [currentTime timeIntervalSinceDate:self.lastStartTime];
    
    timeInterval += totalTime;
    
    NSDate *timerDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0.0]];
    NSString *timeString = [dateFormatter stringFromDate:timerDate];
    return timeString;
}

@end
