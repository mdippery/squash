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
}

- (NSImage *)statusMenuImage
{
    return [NSImage imageNamed:@"StatusIcon.png"];
}

#pragma mark NSApp delegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
}

@end
