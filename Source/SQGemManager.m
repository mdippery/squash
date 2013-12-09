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

#import "SQGemManager.h"
#import "NSFileManager+Squash.h"


@interface SQGemManager ()
- (BOOL)createGemDirectory;
- (BOOL)gemIsInstalled:(NSString *)gem version:(NSString *)version;
@end


@implementation SQGemManager

+ (id)manager
{
    return [[[self alloc] init] autorelease];
}

- (NSString *)gemDirectory
{
    return [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"gems"];
}

- (BOOL)createGemDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *gemDir = [self gemDirectory];
    if ([fm directoryExistsAtPath:gemDir]) return YES;
    return [fm createDirectoryAtPath:gemDir withIntermediateDirectories:NO attributes:nil error:NULL];
}

- (BOOL)gemIsInstalled:(NSString *)gem version:(NSString *)version
{
    NSString *gemName = [NSString stringWithFormat:@"%@-%@", gem, version];
    NSString *gemDir = [self gemDirectory];
    gemDir = [gemDir stringByAppendingPathComponent:@"gems"];
    gemDir = [gemDir stringByAppendingPathComponent:gemName];
    return [[NSFileManager defaultManager] directoryExistsAtPath:gemDir];
}

- (BOOL)installGemWithName:(NSString *)gem version:(NSString *)version
{
    // TODO: Allow "version" to be nil so latest is installed
    NSParameterAssert(gem);
    NSParameterAssert(version);

    if (![self createGemDirectory]) return NO;

    if ([self gemIsInstalled:gem version:version]) return YES;

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/gem"];

    NSDictionary *env = [NSDictionary dictionaryWithObject:[self gemDirectory] forKey:@"GEM_HOME"];
    [task setEnvironment:env];

    NSArray *args = [NSArray arrayWithObjects:@"install", @"--version", version, gem, nil];
    [task setArguments:args];

    [task launch];
    [task waitUntilExit];
    BOOL success = [task terminationStatus] == 0;

    [task release];
    return success;
}

- (BOOL)launchGemExecutableNamed:(NSString *)name
{
    return [self launchGemExecutableNamed:name withArguments:nil];
}

- (BOOL)launchGemExecutableNamed:(NSString *)name withArguments:(NSArray *)args
{
    NSString *launchPath = [[[self gemDirectory] stringByAppendingPathComponent:@"bin"] stringByAppendingPathComponent:name];

    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:launchPath];
    [task setArguments:args];

    NSString *gemDir = [self gemDirectory];
    NSDictionary *env = [NSDictionary dictionaryWithObject:gemDir forKey:@"GEM_HOME"];
    [task setEnvironment:env];

    NSLog(@"Launch Gem binary at path: %@ with args: %@", launchPath, args);
    [task launch];
    [task waitUntilExit];
    BOOL success = [task terminationStatus] == 0;

    [task release];
    return success;
}

@end
