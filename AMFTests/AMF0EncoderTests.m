#import <XCTest/XCTest.h>

#import "AMF0.h"
#import "AMF0Encoder.h"


@interface AMF0EncoderTests : XCTestCase

@end


@implementation AMF0EncoderTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testAMF0Number
{
	const double value = 123.0;
	
	AMF0Encoder *encoder = [AMF0Encoder encoder];
	
	NSError *error = nil;
	XCTAssertTrue([encoder encodeObject:@(value) error:&error], @"Error: %@", error);
	
	NSData *data = [encoder data];
	
	uint8_t bytes[9];
	bytes[0] = AMF0TypeNumber;
	*(uint64_t *)&(bytes[1]) = OSSwapHostToBigInt64(*(uint64_t *)&value);
	
	XCTAssertEqual(data.length, sizeof(bytes));
	XCTAssertTrue(memcmp(data.bytes, bytes, sizeof(bytes)) == 0);
}

- (void)testAMF0BooleanFalse
{
	const BOOL value = NO;
	
	AMF0Encoder *encoder = [AMF0Encoder encoder];
	
	NSError *error = nil;
	XCTAssertTrue([encoder encodeObject:@(value) error:&error], @"Error: %@", error);
	
	NSData *data = [encoder data];
	
	uint8_t bytes[2];
	bytes[0] = AMF0TypeBoolean;
	bytes[1] = value ? 0x1 : 0x0;
	
	XCTAssertEqual(data.length, sizeof(bytes));
	XCTAssertTrue(memcmp(data.bytes, bytes, sizeof(bytes)) == 0);
}

- (void)testAMF0BooleanTrue
{
	const BOOL value = YES;
	
	AMF0Encoder *encoder = [AMF0Encoder encoder];
	
	NSError *error = nil;
	XCTAssertTrue([encoder encodeObject:@(value) error:&error], @"Error: %@", error);
	
	NSData *data = [encoder data];
	
	uint8_t bytes[2];
	bytes[0] = AMF0TypeBoolean;
	bytes[1] = value ? 0x1 : 0x0;
	
	XCTAssertEqual(data.length, sizeof(bytes));
	XCTAssertTrue(memcmp(data.bytes, bytes, sizeof(bytes)) == 0);
}

- (void)testAMF0String
{
	const NSString *value = @"String";
	
	AMF0Encoder *encoder = [AMF0Encoder encoder];
	
	NSError *error = nil;
	XCTAssertTrue([encoder encodeObject:value error:&error], @"Error: %@", error);
	
	NSData *data = [encoder data];
	
	uint8_t bytes[9];
	bytes[0] = AMF0TypeString;
	*(uint16_t *)&bytes[1] = OSSwapHostToBigInt16(value.length);
	memcpy(&bytes[3], value.UTF8String, value.length);

	XCTAssertEqual(data.length, sizeof(bytes));
	XCTAssertTrue(memcmp(data.bytes, bytes, sizeof(bytes)) == 0);
}

@end
