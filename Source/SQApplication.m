/*
 * Squash
 * Copyright 2013 Michael Dippery <michael@monkey-robot.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "SQApplication.h"

#import "SQGemManager.h"
#import "SQNodePackageManager.h"
#import "SQStatusMenuItemView.h"

#import <dispatch/dispatch.h>


@interface SQApplication ()
- (void)activateStatusMenu;
@end


@implementation SQApplication

- (void)awakeFromNib
{
    _isVisible = NO;
    [self activateStatusMenu];
}

- (void)dealloc
{
    [_statusItem release];
    [super dealloc];
}

- (void)activateStatusMenu
{
    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    _statusItem = [[bar statusItemWithLength:NSSquareStatusItemLength] retain];
    NSView *view = [[[SQStatusMenuItemView alloc] initWithStatusItem:_statusItem] autorelease];
    [_statusItem setView:view];
}

- (NSImage *)statusMenuImage
{
    return [NSImage imageNamed:@"StatusIcon.png"];
}

#pragma mark NSApp Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}

#pragma mark NSUserNotificationCenter Delegate

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    return YES;
}

#pragma mark UI Actions

- (IBAction)togglePopover:(id)sender
{
    SQStatusMenuItemView *view = (SQStatusMenuItemView *) [_statusItem view];
    _isVisible = !_isVisible;
    [view toggleHighlight];
    if (_isVisible) {
        [[self contentPopover] showRelativeToRect:[view bounds] ofView:view preferredEdge:NSMaxYEdge];
    } else {
        [[self contentPopover] close];
    }
}

- (IBAction)minifyJavaScript:(id)sender
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *jsminPath = [bundle pathForAuxiliaryExecutable:@"jsmin"];
        NSString *jsData = [bundle pathForResource:@"jsmin-test" ofType:@"js"];
        jsData = [NSString stringWithContentsOfFile:jsData encoding:NSUTF8StringEncoding error:NULL];

        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:jsminPath];

        NSPipe *writePipe = [NSPipe pipe];
        NSFileHandle *writeHandle = [writePipe fileHandleForWriting];

        NSPipe *readPipe = [NSPipe pipe];
        NSFileHandle *readHandle = [readPipe fileHandleForReading];

        [task setStandardInput:writePipe];
        [task setStandardOutput:readPipe];

        [task launch];

        [writeHandle writeData:[jsData dataUsingEncoding:NSUTF8StringEncoding]];
        [writeHandle closeFile];

        NSData *data = [readHandle readDataToEndOfFile];

        NSString *miniJS = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

        NSUserNotification *note = [[NSUserNotification alloc] init];
        note.title = @"JavaScript Minified";
        note.informativeText = @"JavaScript file has been minified.";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:note];

        [note release];
        [miniJS release];
        [task release];
    });
}

- (IBAction)processSass:(id)sender
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        BOOL success = [[SQGemManager defaultManager] installGemWithName:@"sass" version:@"3.2.12"];
        if (!success) {
            NSLog(@"Could not install Sass");
            return;
        }

        NSBundle *bundle = [NSBundle mainBundle];

        NSString *scssPath = [bundle pathForResource:@"scss-test" ofType:@"scss"];
        NSString *cssPath = @"/tmp/scss-test.css";
        NSArray *args = [NSArray arrayWithObjects:scssPath, cssPath, nil];

        success = [[SQGemManager defaultManager] launchGemExecutableNamed:@"sass" withArguments:args];
        if (!success) {
            NSLog(@"Could not launch Sass");
            return;
        }

        NSUserNotification *note = [[NSUserNotification alloc] init];
        note.title = @"SASS Processed";
        note.informativeText = @"SASS file has been processed.";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:note];

        [note release];
    });
}

- (IBAction)processLess:(id)sender
{
    NSURL *lessURL = [NSURL URLWithString:@"https://github.com/less/less.js/tarball/master"];
    BOOL success = [[SQNodePackageManager defaultManager] installNodePackage:@"less" fromURL:lessURL];
    NSLog(@"Downloaded Less: %@", success ? @"YES" : @"NO");
}

@end
