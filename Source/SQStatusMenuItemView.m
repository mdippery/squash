//
//  SQStatusMenuItemView.m
//  Squash
//
//  Created by Michael Dippery on 10/29/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import "SQStatusMenuItemView.h"
#import "SQApplication.h"


@implementation SQStatusMenuItemView

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    NSRect frame = NSMakeRect(0.0, 0.0, [statusItem length], [[NSStatusBar systemStatusBar] thickness]);
    if ((self = [super initWithFrame:frame])) {
        _statusItem = [statusItem retain];
    }
    return self;
}

- (void)dealloc
{
    [_statusItem release];
    [super dealloc];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];

    [_statusItem drawStatusBarBackgroundInRect:rect withHighlight:self.isHighlighted];

    NSImage *icon = [(SQApplication *) [NSApp delegate] statusMenuImage];
    NSSize iconSize = [icon size];
    CGFloat x = (rect.size.width - iconSize.width) / 2;
    CGFloat y = (rect.size.height - iconSize.height) / 2;
    NSPoint o = {x, y};
    [icon drawAtPoint:o fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

- (void)mouseDown:(NSEvent *)event
{
    self.highlighted = !self.isHighlighted;
    [self setNeedsDisplay:YES];
    NSLog(@"Menu is: %@", self.isHighlighted ? @"OPEN" : @"CLOSED");
}

- (void)mouseUp:(NSEvent *)event
{
    NSLog(@"Menu is: %@", self.isHighlighted ? @"OPEN" : @"CLOSED");
}

@end
