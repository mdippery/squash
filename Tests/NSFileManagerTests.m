//
//  NSFileManagerTests.m
//  Squash
//
//  Created by Michael Dippery on 10/30/2013.
//  Copyright (c) 2013 Michael Dippery. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSFileManager+Squash.h"


@interface NSFileManagerTests : XCTestCase
{
@private
    NSString *basePath;
}
@end


@implementation NSFileManagerTests

- (void)setUp
{
    [super setUp];
    basePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents"];
}

- (void)testDirectoryExistsWhenDirectoryDoesNotExist
{
    NSString *testPath = [basePath stringByAppendingPathComponent:@"blah"];
    BOOL exists = [[NSFileManager defaultManager] directoryExistsAtPath:testPath];
    XCTAssertFalse(exists, @"%@ exists and is a directory", testPath);
}

- (void)testDirectoryExistsWhenDirectoryExists
{
    NSString *testPath = [basePath stringByAppendingPathComponent:@"MacOS"];
    BOOL exists = [[NSFileManager defaultManager] directoryExistsAtPath:testPath];
    XCTAssertTrue(exists, @"%@ does not exist or is not a directory", testPath);
}

- (void)testDirectoryExistsWhenFileDoesNotExist
{
    NSString *testPath = [basePath stringByAppendingPathComponent:@"blah.txt"];
    BOOL exists = [[NSFileManager defaultManager] directoryExistsAtPath:testPath];
    XCTAssertFalse(exists, @"%@ exists and is a directory", testPath);
}

- (void)testDirectoryExistsWhenFileExists
{
    NSString *testPath = [[NSBundle mainBundle] executablePath];
    BOOL exists = [[NSFileManager defaultManager] directoryExistsAtPath:testPath];
    XCTAssertFalse(exists, @"%@ exists and is a directory", testPath);
}

@end
