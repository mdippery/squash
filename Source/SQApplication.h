//
//  SQAppDelegate.h
//  Squash
//
//  Created by Michael Dippery on 10/29/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SQApplication : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate>
{
@private
    NSStatusItem *_statusItem;
    BOOL _isVisible;
}

@property (assign) IBOutlet NSPopover *contentPopover;
@property (readonly) NSImage *statusMenuImage;

- (IBAction)togglePopover:(id)sender;
- (IBAction)minifyJavaScript:(id)sender;

@end
