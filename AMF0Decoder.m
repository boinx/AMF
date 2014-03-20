#import "AMF0Decoder.h"

#import "AMF0.h"

@interface AMF0EndOfObjectMarker : NSObject

+ (instancetype)endOfObjectMarker;

@end

@implementation AMF0EndOfObjectMarker

+ (instancetype)endOfObjectMarker
{
	static AMF0EndOfObjectMarker *marker = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		marker = [[AMF0EndOfObjectMarker alloc] init];
	});
	
	return marker;
}

@end


@interface AMF0Decoder () <NSStreamDelegate>

@property (nonatomic, strong) NSInputStream *stream;

@end


@implementation AMF0Decoder

+ (instancetype)decoderWithData:(NSData *)data
{
	return [[self alloc] initWithData:data];
}

+ (instancetype)decoderWithStream:(NSInputStream *)stream
{
	return [[self alloc] initWithStream:stream];
}

- (instancetype)initWithData:(NSData *)data
{
	if(data == nil)
	{
		return nil;
	}
	
	NSInputStream *stream = [[NSInputStream alloc] initWithData:data];
	
	return [self initWithStream:stream];
}

- (instancetype)initWithStream:(NSInputStream *)stream
{
	self = [super init];
	if(self != nil)
	{
		if(stream.streamStatus == NSStreamStatusNotOpen)
		{
			[stream open];
		}
		
		self.stream = stream;
	}
	return self;
}

- (void)dealloc
{
	NSInputStream *stream = self.stream;
	[stream close];
}

- (id)decodeObject
{
	return [self decodeObjectWithError:nil];
}

- (id)decodeObjectWithError:(NSError **)error
{
	int type = [self decodeTypeWithError:error];
	if(type < 0)
	{
		NSLog(@"%s:%d", __FUNCTION__, __LINE__);
		return nil;
	}
	
	switch(type)
	{
		case AMF0TypeNumber:
			return [self decodeNumberWithError:error];
			
		case AMF0TypeBoolean:
			return [self decodeBooleanWithError:error];
			
		case AMF0TypeString:
			return [self decodeStringWithError:error];
			
		case AMF0TypeObject:
			return [self decodeAMFObjectWithError:error];
			
		case AMF0TypeECMAArray:
			return [self decodeECMAArrayWithError:error];
			
		case AMF0TypeObjectEnd:
			return [AMF0EndOfObjectMarker endOfObjectMarker];
	}
	
	NSLog(@"%s:%d unhandled type:%02x", __FUNCTION__, __LINE__, type);
	return nil;
}

- (int)decodeTypeWithError:(NSError **)error
{
	uint8_t type = 0;
	NSInteger length = [self.stream read:&type maxLength:sizeof(type)];
	
	if(length != sizeof(type))
	{
		NSLog(@"%s:%d", __FUNCTION__, __LINE__);
		return -1;
	}

	return type;
}

- (NSNumber *)decodeNumberWithError:(NSError **)error
{
	uint64_t integerValue = 0;
	NSInteger length = [self.stream read:(uint8_t *)&integerValue maxLength:sizeof(integerValue)];
	
	if(length != sizeof(integerValue))
	{
		NSLog(@"%s:%d", __FUNCTION__, __LINE__);
		return nil;
	}
	
	integerValue = OSSwapBigToHostConstInt64(integerValue);

	const double doubleValue = *(double *)&integerValue;
	
	return [NSNumber numberWithDouble:doubleValue];
}

- (NSNumber *)decodeBooleanWithError:(NSError **)error
{
	uint8_t value = 0;
	NSInteger length = [self.stream read:(uint8_t *)&value maxLength:sizeof(value)];
	
	if(length != sizeof(value))
	{
		NSLog(@"%s:%d", __FUNCTION__, __LINE__);
		return nil;
	}
	
	return [NSNumber numberWithBool:value != 0 ? YES : NO];
}

- (NSString *)decodeStringWithError:(NSError **)error
{
	uint16_t stringLength = 0;
	NSInteger length = [self.stream read:(uint8_t *)&stringLength maxLength:sizeof(stringLength)];
	
	if(length != sizeof(stringLength))
	{
		NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
		return nil;
	}
	
	stringLength = OSSwapBigToHostConstInt16(stringLength);
	
	NSMutableData *data = [NSMutableData dataWithLength:stringLength];
	
	length = [self.stream read:(uint8_t *)data.mutableBytes maxLength:stringLength];
	if(length != stringLength)
	{
		NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
		return nil;
	}
	
	return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (NSDictionary *)decodeAMFObjectWithError:(NSError **)error
{
	@autoreleasepool
	{
		NSMutableDictionary *objects = [NSMutableDictionary dictionary];
		
		while(YES)
		{
			id key = [self decodeStringWithError:error];
			if(key == nil)
			{
				return nil;
			}
			
			id value = [self decodeObjectWithError:error];
			if(value == nil)
			{
				return nil;
			}
			
			if([value isKindOfClass:AMF0EndOfObjectMarker.class])
			{
				break;
			}
			
			[objects setObject:value forKey:key];
		}

		return [NSDictionary dictionaryWithDictionary:objects];
	}
}

- (NSDictionary *)decodeECMAArrayWithError:(NSError **)error
{
	uint32_t count = 0;
	NSInteger length = [self.stream read:(uint8_t *)&count maxLength:sizeof(count)];
	
	if(length != sizeof(count))
	{
		NSLog(@"%s:%d", __FUNCTION__, __LINE__);
		return nil;
	}
	
	count = OSSwapBigToHostConstInt32(count);
	
	@autoreleasepool
	{
		NSMutableDictionary *objects = [NSMutableDictionary dictionaryWithCapacity:count];

		for(uint32_t index = 0; index < count; ++index)
		{
			id key = [self decodeStringWithError:error];
			if(key == nil)
			{
				NSLog(@"%s:%d", __FUNCTION__, __LINE__);
				return nil;
			}
			
			id value = [self decodeObjectWithError:error];
			if(value == nil)
			{
				NSLog(@"%s:%d", __FUNCTION__, __LINE__);
				return nil;
			}
			
			[objects setObject:value forKey:key];
		}
		
		NSString *key = [self decodeStringWithError:error];
		if(key == nil)
		{
			NSLog(@"%s:%d", __FUNCTION__, __LINE__);
			return nil;
		}
		
		int type = [self decodeTypeWithError:error];
		if(type != AMF0TypeObjectEnd)
		{
			NSLog(@"%s:%d", __FUNCTION__, __LINE__);
			return nil;
		}
		
		return [NSDictionary dictionaryWithDictionary:objects];
	}
}

#pragma mark - NSStreamDelegate

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
	NSLog(@"%@ %d", stream, (int)eventCode);
}

@end
