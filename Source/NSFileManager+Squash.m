/*
 * Squash
 * Copyright 2013 Michael Dippery <michael@monkey-robot.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "NSFileManager+Squash.h"


@implementation NSFileManager (Squash)

- (BOOL)directoryExistsAtPath:(NSString *)path
{
    BOOL exists = NO;
    BOOL isDirectory = NO;
    exists = [self fileExistsAtPath:path isDirectory:&isDirectory];
    return exists && isDirectory;
}

- (NSString *)applicationSupportDirectory
{
    NSString *executableName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleExecutable"];
    NSArray *parts = [NSArray arrayWithObject:executableName];
    NSError *error;
    NSString *path = [self findOrCreateDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appendPathComponents:parts error:&error];
    if (error) {
        NSAssert(path == nil, @"Error creating directory but path is not nil");
        NSLog(@"Could not create application support directory (%@):\n%@", executableName, error);
        return nil;
    }
    return path;
}

- (NSString *)findOrCreateDirectory:(NSSearchPathDirectory)searchPathDirectory
                           inDomain:(NSSearchPathDomainMask)domainMask
               appendPathComponents:(NSArray *)pathComponents
                              error:(NSError **)error
{
    NSFileManager *fm = [NSFileManager defaultManager];

    NSArray *urls = [fm URLsForDirectory:searchPathDirectory inDomains:domainMask];
    if ([urls count] == 0) {
        if (error) {
            // TODO: Define the domain string _somewhere_
            // TODO: Pass back useful error information in info dictionary
            NSError *e = [NSError errorWithDomain:@"com.monkey-robot.Squash.ErrorDomain" code:NSFileReadUnknownError userInfo:nil];
            *error = e;
        }
        return nil;
    }

    NSString *path = [[urls objectAtIndex:0] path];
    if (pathComponents) {
        for (NSString *part in pathComponents) {
            path = [path stringByAppendingPathComponent:part];
        }
    }

    NSError *e;
    BOOL success = [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&e];
    if (!success) {
        if (error) {
            *error = e;
        }
        return nil;
    }

    if (error) {
        *error = nil;
    }

    return path;
}

@end
