//
//  NSFileManager+Squash.m
//  Squash
//
//  Created by Michael Dippery on 10/30/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import "NSFileManager+Squash.h"


@implementation NSFileManager (Squash)

- (BOOL)directoryExistsAtPath:(NSString *)path
{
    BOOL exists = NO;
    BOOL isDirectory = NO;
    exists = [self fileExistsAtPath:path isDirectory:&isDirectory];
    return exists && isDirectory;
}

@end
