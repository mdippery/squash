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
#import "SQStatusMenuItemView.h"

#import "NSFileManager+Squash.h"

#import <dispatch/dispatch.h>


@interface SQApplication ()
- (void)activateStatusMenu;
- (void)installSass;
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

- (void)installSass
{
    NSFileManager *fm = [NSFileManager defaultManager];

    NSString *gemDir = [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"gems"];
    NSString *sassBin = [[gemDir stringByAppendingPathComponent:@"bin"] stringByAppendingPathComponent:@"sass"];

    if ([fm fileExistsAtPath:sassBin]) {
        NSLog(@"Sass is already installed at %@", gemDir);
        return;
    }

    NSLog(@"%@ does not exist, installing", sassBin);

    NSError *error;
    if (![fm directoryExistsAtPath:gemDir]) {
        BOOL success = [fm createDirectoryAtPath:gemDir withIntermediateDirectories:NO attributes:nil error:&error];
        if (!success) {
            NSLog(@"Could not create directory: %@\n%@", gemDir, error);
            return;
        }
    }

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/gem"];

    NSDictionary *env = [NSDictionary dictionaryWithObject:gemDir forKey:@"GEM_HOME"];
    [task setEnvironment:env];

    NSArray *args = [NSArray arrayWithObjects:@"install", @"--version", @"3.2.12", @"sass", nil];
    [task setArguments:args];

    [task launch];
    [task waitUntilExit];
    // TODO: Check return value

    [task release];
    NSLog(@"Installed sass into %@", gemDir);
}

- (IBAction)processSass:(id)sender
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [self installSass];
#if 0
        NSBundle *bundle = [NSBundle mainBundle];

        NSTask *task = [[NSTask alloc] init];
        [task setLaunchPath:@"/usr/bin/ruby"];

        NSString *gemDir = [bundle pathForResource:@"gems" ofType:@""];
        NSDictionary *env = [NSDictionary dictionaryWithObject:gemDir forKey:@"GEM_HOME"];
        [task setEnvironment:env];

        NSString *sassBin = [[gemDir stringByAppendingPathComponent:@"bin"] stringByAppendingPathComponent:@"sass"];
        NSString *scssPath = [bundle pathForResource:@"scss-test" ofType:@"scss"];
        NSString *cssPath = @"/tmp/scss-test.css";
        NSArray *args = [NSArray arrayWithObjects:sassBin, scssPath, cssPath, nil];
        [task setArguments:args];

        [task launch];

        NSUserNotification *note = [[NSUserNotification alloc] init];
        note.title = @"SASS Processed";
        note.informativeText = @"SASS file has been processed.";
        [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:note];

        [note release];
        [task release];
#endif
    });
}

@end
