//
//  SQStatusMenuItemView.h
//  Squash
//
//  Created by Michael Dippery on 10/29/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SQStatusMenuItemView : NSView
{
@private
    NSStatusItem *_statusItem;
    BOOL _isHighlighted;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem;
- (void)toggleHighlight;

@end
