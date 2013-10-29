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
}

@property (nonatomic, assign, getter=isHighlighted) BOOL highlighted;

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@end
