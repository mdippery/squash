//
//  SQAppDelegate.m
//  Squash
//
//  Created by Michael Dippery on 10/29/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import "SQSquash.h"

#import <dispatch/dispatch.h>
#import "SQStatusMenuItemView.h"


@interface SQSquash ()
- (void)activateStatusMenu;
@end


@implementation SQSquash

- (void)awakeFromNib
{
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
    [_statusItem setMenu:[self statusMenu]];
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

@end
