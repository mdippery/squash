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

#import "SQNodePackageManager.h"

#import "SQNodePackageDownload.h"

#import "NSFileManager+Squash.h"


@interface SQNodePackageManager ()
- (BOOL)createPackageDirectory;
- (BOOL)packageIsInstalled:(NSString *)name;
- (NSString *)pathToExecutable:(NSString *)name forPackage:(NSString *)package;
@end


@implementation SQNodePackageManager

+ (SQNodePackageManager *)defaultManager
{
    static SQNodePackageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[super allocWithZone:nil] init];
    });
    return manager;
}

- (NSString *)nodeBinDirectory
{
    NSString *nodeBin = [[NSBundle mainBundle] pathForAuxiliaryExecutable:@"node"];
    return [nodeBin stringByDeletingLastPathComponent];
}

- (NSString *)nodePackageDirectory
{
    return [[[NSFileManager defaultManager] applicationSupportDirectory] stringByAppendingPathComponent:@"node"];
}

- (BOOL)createPackageDirectory
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *packageDir = [self nodePackageDirectory];
    if ([fm directoryExistsAtPath:packageDir]) return YES;
    return [fm createDirectoryAtPath:packageDir withIntermediateDirectories:NO attributes:nil error:NULL];
}

- (BOOL)packageIsInstalled:(NSString *)name
{
    NSString *packageDir = [self nodePackageDirectory];
    packageDir = [packageDir stringByAppendingPathComponent:name];
    return [[NSFileManager defaultManager] directoryExistsAtPath:packageDir];
}

- (BOOL)installNodePackage:(NSString *)name fromURL:(NSURL *)url
{
    if (![self createPackageDirectory]) return NO;

    if ([self packageIsInstalled:name]) return YES;

    NSString *destination = [[self nodePackageDirectory] stringByAppendingPathComponent:name];
    SQNodePackageDownload *download = [SQNodePackageDownload packageWithName:name destination:destination fromURL:url];
    return [download download];
}

- (NSString *)pathToExecutable:(NSString *)name forPackage:(NSString *)package
{
    NSString *dir = [self nodePackageDirectory];
    dir = [dir stringByAppendingPathComponent:package];
    dir = [dir stringByAppendingPathComponent:@"bin"];
    return [dir stringByAppendingPathComponent:name];
}

- (BOOL)launchExecutableFromPackage:(NSString *)package named:(NSString *)name
{
    return [self launchExecutableFromPackage:package named:name withArguments:nil];
}

- (BOOL)launchExecutableFromPackage:(NSString *)package named:(NSString *)name withArguments:(NSArray *)args
{
    NSString *lessc = [self pathToExecutable:name forPackage:package];
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:lessc];
    [task setArguments:args];

    NSString *binPath = [self nodeBinDirectory];
    NSDictionary *env = [NSDictionary dictionaryWithObject:binPath forKey:@"PATH"];
    [task setEnvironment:env];

    NSLog(@"Launching Node binary at path: %@ with env: %@ and args: %@", lessc, env, args);
    [task launch];
    [task waitUntilExit];
    BOOL success = [task terminationStatus] == 0;

    [task release];
    return success;
}

#pragma mark Singleton

+ (id)allocWithZone:(NSZone *)zone
{
    return [[self defaultManager] retain];
}

- (id)retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return UINT_MAX;
}

- (oneway void)release {}

- (id)autorelease
{
    return self;
}

@end
