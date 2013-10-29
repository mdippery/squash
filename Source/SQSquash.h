//
//  SQAppDelegate.h
//  Squash
//
//  Created by Michael Dippery on 10/29/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SQSquash : NSObject <NSApplicationDelegate>
{
@private
    NSStatusItem *_statusItem;
}

@property (assign) IBOutlet NSMenu *statusMenu;

- (IBAction)minifyJavaScript:(id)sender;

@end
