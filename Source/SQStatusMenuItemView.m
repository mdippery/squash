//
//  SQStatusMenuItemView.m
//  Squash
//
//  Created by Michael Dippery on 10/29/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import "SQStatusMenuItemView.h"
#import "SQSquash.h"


@implementation SQStatusMenuItemView

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        _menuIsOpen = NO;
    }
    return self;
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    NSImage *icon = [(SQSquash *) [NSApp delegate] statusMenuImage];
    NSSize iconSize = [icon size];
    CGFloat x = (rect.size.width - iconSize.width) / 2;
    CGFloat y = (rect.size.height - iconSize.height) / 2;
    NSPoint o = {x, y};
    [icon drawAtPoint:o fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

- (void)mouseDown:(NSEvent *)event
{
    _menuIsOpen = !_menuIsOpen;
    NSLog(@"Menu is: %@", _menuIsOpen ? @"OPEN" : @"CLOSED");
}

- (void)mouseUp:(NSEvent *)event
{
    NSLog(@"Menu is: %@", _menuIsOpen ? @"OPEN" : @"CLOSED");
}

@end
