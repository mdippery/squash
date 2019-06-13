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

#import "Pitch.h"


@interface SQNodePackageDownload ()
- (BOOL)createDestinationDirectory;
- (BOOL)removeDestinationDirectory;
- (void)untarPackage;
- (void)cleanupPackage;
- (void)replaceDestinationWithContentsOfDirectoryAtPath:(NSString *)path;
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

- (void)untarPackage
{
    NSError *error;
    TARFile *tar = [TARFile fileWithContentsOfFile:_downloadFilename];
    BOOL success = [tar extractToDirectory:_destination error:&error];
    if (!success) {
        NSLog(@"Could not untar %@ into %@: %@", _downloadFilename, _destination, error);
    }
    [self cleanupPackage];
}

- (void)cleanupPackage
{
    NSFileManager *fm = [NSFileManager defaultManager];

    // Remove pax_global_header file if one exists -- it's
    // just a global header file that we don't actually need.
    NSString *paxPath = [_destination stringByAppendingPathComponent:@"pax_global_header"];
    if ([fm fileExistsAtPath:paxPath isDirectory:NULL]) {
        [fm removeItemAtPath:paxPath error:NULL];
    }

    // Move the contents of the downloaded directory to the
    // destination directory.
    NSArray *paths = [fm contentsOfDirectoryAtPath:_destination error:NULL];
    for (NSString *path in paths) {
        path = [_destination stringByAppendingPathComponent:path];
        BOOL isDir = NO;
        if ([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
            NSLog(@"Found subdirectory: %@", path);
            [self replaceDestinationWithContentsOfDirectoryAtPath:path];
        }
    }
}

- (void)replaceDestinationWithContentsOfDirectoryAtPath:(NSString *)path
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *dirname = [_destination stringByDeletingLastPathComponent];
    dirname = [dirname stringByAppendingPathComponent:[path lastPathComponent]];

    NSError *error;
    BOOL success;

    success = [fm moveItemAtPath:path toPath:dirname error:&error];
    if (!success) {
        NSLog(@"Could not replace package: %@", error);
        return;
    }

    success = [fm removeItemAtPath:_destination error:&error];
    if (!success) {
        NSLog(@"Could not delete %@: %@", _destination, error);
        return;
    }

    success = [fm moveItemAtPath:dirname toPath:_destination error:&error];
    if (!success) {
        NSLog(@"Could not move package from %@ to %@: %@", dirname, _destination, error);
        return;
    }
}

#pragma mark NSURLDownload Delegate

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    NSLog(@"Download failed\n%@", error);
    [self removeDestinationDirectory];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    // After downloading, we need to untar the package.
    // This is a bit of a hack -- in the specific case
    // of less (which this class is used for), the
    // package is distributed as a tarball. THIS WON'T
    // WORK IN THE GENERAL CASE.
    [self untarPackage];
}

- (void)download:(NSURLDownload *)download decideDestinationWithSuggestedFilename:(NSString *)filename
{
    NSString *ext = [filename pathExtension];
    NSString *base = [_name stringByAppendingPathExtension:ext];
    _downloadFilename = [[_destination stringByAppendingPathComponent:base] retain];
    [download setDestination:_downloadFilename allowOverwrite:YES];
}

@end
