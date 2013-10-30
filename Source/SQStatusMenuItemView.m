//
//  SQStatusMenuItemView.m
//  Squash
//
//  Created by Michael Dippery on 10/29/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import "SQStatusMenuItemView.h"
#import "NSFileManager+Squash.h"
#import "SQApplication.h"


@implementation SQStatusMenuItemView

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    NSRect frame = NSMakeRect(0.0, 0.0, [statusItem length], [[NSStatusBar systemStatusBar] thickness]);
    if ((self = [super initWithFrame:frame])) {
        _statusItem = [statusItem retain];
        _isHighlighted = NO;
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
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

    [_statusItem drawStatusBarBackgroundInRect:rect withHighlight:_isHighlighted];

    NSImage *icon = [(SQApplication *) [NSApp delegate] statusMenuImage];
    NSSize iconSize = [icon size];
    CGFloat x = (rect.size.width - iconSize.width) / 2;
    CGFloat y = (rect.size.height - iconSize.height) / 2;
    NSPoint o = {x, y};
    [icon drawAtPoint:o fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
}

- (void)toggleHighlight
{
    _isHighlighted = !_isHighlighted;
    [self setNeedsDisplay:YES];
}

#pragma mark UI Responder

- (void)mouseDown:(NSEvent *)event
{
    [NSApp sendAction:@selector(togglePopover:) to:[NSApp delegate] from:self];
}

#pragma mark Drag Operations

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation op = [sender draggingSourceOperationMask];

    if ([[pboard types] containsObject:NSFilenamesPboardType] && (op & NSDragOperationCopy)) {
        if ((op & NSDragOperationCopy)) {
            return NSDragOperationCopy;
        } else if ((op & NSDragOperationLink)) {
            return NSDragOperationLink;
        }
    }
    return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSDragOperation op = [sender draggingSourceOperationMask];
    NSAssert([[pboard types] containsObject:NSFilenamesPboardType], @"Dragged item is not a file");
    NSAssert((op & NSDragOperationCopy) || (op & NSDragOperationLink), @"Drag operation is not copy or link");

    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    for (NSString *path in files) {
        if (![fm directoryExistsAtPath:path]) {
            NSLog(@"%@ does not exist or is not a directory", path);
            return NO;
        }
    }

    NSLog(@"Watching directories: %@", files);
    return YES;
}

@end
