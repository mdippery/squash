//
//  SQAppDelegate.m
//  Squash
//
//  Created by Michael Dippery on 10/29/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import "SQSquash.h"


@interface SQSquash ()
- (void)activateStatusMenu;
- (NSImage *)statusMenuImage;
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
    [_statusItem setImage:[self statusMenuImage]];
    [_statusItem setHighlightMode:YES];
    [_statusItem setMenu:[self statusMenu]];
}

- (NSImage *)statusMenuImage
{
    return [NSImage imageNamed:@"StatusIcon.png"];
}

#pragma mark NSApp Delegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
}

#pragma mark UI Actions

- (IBAction)minifyJavaScript:(id)sender
{
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

    [miniJS release];
    [task release];
}

@end
