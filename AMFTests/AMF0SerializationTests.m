#import <XCTest/XCTest.h>

#import "AMF.h"


@interface AMF0SerializationTests : XCTestCase

@end


@implementation AMF0SerializationTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testDictionarySerialization
{
	NSDictionary *input = @{
		@"number": @(123.4),
		@"true": @YES,
		@"false": @NO,
		@"string": @"Some Text",
	};
	
	NSError *error = nil;

	NSData *data = [AMFSerialization dataWithAMFObject:input options:0 error:&error];
	XCTAssertTrue(data != nil, @"Error: %@", error);
	
	NSDictionary *output = [AMFSerialization AMFObjectWithData:data options:0 error:&error];
	XCTAssertTrue(output != nil, @"Error: %@", error);
	
	XCTAssertEqualObjects(input, output);
}

#if 0
- (void)testArraySerialization
{
	NSArray *input = @[
		@(123.4),
		@YES,
		@NO,
		@"Some Text",
	];
	
	NSError *error = nil;
	
	NSData *data = [AMFSerialization dataWithAMFObject:input options:0 error:&error];
	XCTAssertTrue(data != nil, @"Error: %@", error);
	
	NSArray *output = [AMFSerialization AMFObjectWithData:data options:0 error:&error];
	XCTAssertTrue(output != nil, @"Error: %@", error);
	
	XCTAssertEqualObjects(input, output);
}
#endif

- (void)testSequenceSerialization
{
	NSArray *input = @[
		@(123.4),
		@YES,
		@NO,
		@"Some Text",
	];
	
	NSError *error = nil;
	
	NSData *data = [AMFSerialization dataWithAMFObject:input options:AMFWritingOptionsSequence error:&error];
	XCTAssertTrue(data != nil, @"Error: %@", error);
	
	NSArray *output = [AMFSerialization AMFObjectWithData:data options:AMFReadingOptionsSequence error:&error];
	XCTAssertTrue(output != nil, @"Error: %@", error);
	
	XCTAssertEqualObjects(input, output);
}

@end
