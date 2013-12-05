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

#import "SQNodePackageDownload.h"


@interface SQNodePackageDownload ()
- (BOOL)createDestinationDirectory;
- (BOOL)removeDestinationDirectory;
@end


@implementation SQNodePackageDownload

+ (SQNodePackageDownload *)packageWithName:(NSString *)name destination:(NSString *)destination fromURL:(NSURL *)downloadURL
{
    return [[[self alloc] initWithName:name destination:destination fromURL:downloadURL] autorelease];
}

- (id)initWithName:(NSString *)name destination:(NSString *)destination fromURL:(NSURL *)downloadURL
{
    if ((self = [super init])) {
        _name = [name copy];
        _destination = [destination copy];
        _downloadFilename = nil;
        _downloadURL = [downloadURL retain];
    }
    return self;
}

- (void)dealloc
{
    [_name release];
    [_destination release];
    [_downloadFilename release];
    [_downloadURL release];
    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ <name=%@, destination=%@, downloadURL=%@>", [self class], _name, _destination, _downloadURL];
}

- (BOOL)createDestinationDirectory
{
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:_destination withIntermediateDirectories:NO attributes:nil error:&error];
    if (!success) {
        NSLog(@"Could not create destination directory %@:\n%@", _destination, error);
        return NO;
    }
    return YES;
}

- (BOOL)removeDestinationDirectory
{
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:_destination error:&error];
    if (!success) {
        NSLog(@"Could not remove destination directory %@:\n%@", _destination, error);
        return NO;
    }
    return YES;
}

- (BOOL)download
{
    if (![self createDestinationDirectory]) {
        return NO;
    }

    NSURLRequest *request = [NSURLRequest requestWithURL:_downloadURL];
    NSURLDownload *download = [[NSURLDownload alloc] initWithRequest:request delegate:self];

    if (!download) {
        [self removeDestinationDirectory];
        return NO;
    }

    // TODO: Should communicate the asynchronous nature of this
    // operation to the caller, and let errors bubble up.

    [download release];
    return YES;
}

#pragma mark NSURLDownload Delegate

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    NSLog(@"Download failed\n%@", error);
    [self removeDestinationDirectory];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    NSLog(@"Download finished");
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
    NSString *ext = [filename pathExtension];
    NSString *base = [_name stringByAppendingPathExtension:ext];
    _downloadFilename = [[_destination stringByAppendingPathComponent:base] retain];
    [download setDestination:_downloadFilename allowOverwrite:YES];
}

@end
