#import "AMF0Encoder.h"

#import "AMF0.h"

@interface AMF0Encoder () <NSStreamDelegate>

@property (nonatomic, strong) NSOutputStream *stream;

@end


@implementation AMF0Encoder

+ (instancetype)encoder
{
	return [[self alloc] init];
}

+ (instancetype)encoderWithOutputStream:(NSOutputStream *)stream
{
	return [[self alloc] initWithOutputStream:stream];
}

- (instancetype)init
{
	NSOutputStream *stream = [[NSOutputStream alloc] initToMemory];
	
	return [self initWithOutputStream:stream];
}

- (instancetype)initWithOutputStream:(NSOutputStream *)stream
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
	NSOutputStream *stream = self.stream;
	[stream close];
}

- (NSData *)data
{
	return [self.stream propertyForKey:NSStreamDataWrittenToMemoryStreamKey];
}

- (BOOL)encodeObject:(id)object
{
	return [self encodeObject:object error:nil];
}

- (BOOL)encodeObject:(id)object error:(NSError **)error
{
	if([object isKindOfClass:NSNumber.class])
	{
		if(CFGetTypeID((__bridge CFTypeRef)object) == CFBooleanGetTypeID())
		{
			return [self encodeBool:object error:error];
		}
		else
		{
			return [self encodeNumber:object error:error];
		}
	}
	
	if([object isKindOfClass:NSString.class])
	{
		return [self encodeString:object error:error];
	}
	
	if([object isKindOfClass:NSDictionary.class])
	{
		return [self encodeDictionary:object error:error];
	}
	
	if([object isKindOfClass:NSNull.class])
	{
		return [self encodeNullWithError:error];
	}
	
	NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
	return NO;
}

- (BOOL)encodeNumber:(NSNumber *)number error:(NSError **)error
{
	if(![number isKindOfClass:NSNumber.class])
	{
		NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
		return NO;
	}
	
	const uint8_t type = AMF0TypeNumber;
	NSInteger length = [self.stream write:&type maxLength:sizeof(type)];
	if(length != sizeof(type))
	{
		NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
		return NO;
	}
	
	const double doubleValue = number.doubleValue;
	
	const uint64_t integerValue = OSSwapBigToHostInt64(*(uint64_t *)&doubleValue);
	
	length = [self.stream write:(uint8_t *)&integerValue maxLength:sizeof(integerValue)];
	if(length != sizeof(integerValue))
	{
		NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
		return NO;
	}
	
	return YES;
}

- (BOOL)encodeBool:(NSNumber *)number error:(NSError **)error
{
	if(![number isKindOfClass:NSNumber.class])
	{
		NSLog(@"%s:%d", __FUNCTION__, __LINE__);
		return NO;
	}
	
	const uint8_t type = AMF0TypeBoolean;
	NSInteger length = [self.stream write:&type maxLength:sizeof(type)];
	if(length != sizeof(type))
	{
		NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
		return NO;
	}

	const uint8_t value = number.boolValue ? 0x01 : 0x00;
	
	length = [self.stream write:&value maxLength:sizeof(value)];
	if(length != sizeof(value))
	{
		NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
		return NO;
	}
	
	return YES;
}

- (BOOL)encodeString:(NSString *)string error:(NSError **)error
{
	if(![string isKindOfClass:NSString.class])
	{
		NSLog(@"%s:%d", __FUNCTION__, __LINE__);
		return NO;
	}
	
	const NSUInteger stringLength = string.length;
	
	if(stringLength >= USHRT_MAX)
	{
		NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
		return NO;
	}
	else
	{
		const uint8_t type = AMF0TypeString;
		NSInteger length = [self.stream write:&type maxLength:sizeof(type)];
		if(length != sizeof(type))
		{
			NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
			return NO;
		}
		
		const uint16_t stringLength16 = OSSwapBigToHostInt16(stringLength);
		length = [self.stream write:(uint8_t *)&stringLength16 maxLength:sizeof(stringLength16)];
		
		if(length != sizeof(stringLength16))
		{
			NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
			return NO;
		}
		
		if(stringLength > 0)
		{
			NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
		
			length = [self.stream write:data.bytes maxLength:data.length];
			if(length != data.length)
			{
				NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
				return NO;
			}
		}
		
		return YES;
	}
}

- (BOOL)encodeDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
	if(![dictionary isKindOfClass:NSDictionary.class])
	{
		NSLog(@"%s:%d", __FUNCTION__, __LINE__);
		return NO;
	}
	
	NSNumber *typeKey = [dictionary objectForKey:AMF0TypeKey];
	
	if(typeKey.intValue == AMF0TypeECMAArray)
	{
		const uint8_t type = AMF0TypeECMAArray;
		NSInteger length = [self.stream write:&type maxLength:sizeof(type)];
		if(length != sizeof(type))
		{
			NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
			return NO;
		}
		
		const uint32_t count = OSSwapBigToHostInt32(dictionary.count);
		length = [self.stream write:(uint8_t *)&count maxLength:sizeof(count)];
		if(length != sizeof(count))
		{
			NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
			return NO;
		}
		
		for(NSString *key in dictionary)
		{
			if(![key isKindOfClass:NSString.class])
			{
				NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
				return NO;
			}
			
			if([key hasPrefix:AMF0KeyPrefix])
			{
				continue;
			}
			
			NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
			
			{
				const uint16_t keyLength = OSSwapBigToHostInt16(keyData.length);
				length = [self.stream write:(uint8_t *)&keyLength maxLength:sizeof(keyLength)];
				if(length != sizeof(keyLength))
				{
					NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
					return NO;
				}
			}
			
			length = [self.stream write:keyData.bytes maxLength:keyData.length];
			if(length != keyData.length)
			{
				NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
				return NO;
			}
			
			id object = [dictionary objectForKey:key];
			
			if(![self encodeObject:object error:error])
			{
				NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
				return NO;
			}
		}
		
		{
			const uint8_t type[3] = { 0x00, 0x00, AMF0TypeObjectEnd };
			NSInteger length = [self.stream write:type maxLength:sizeof(type)];
			if(length != sizeof(type))
			{
				NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
				return NO;
			}
		}
		
		return YES;
	}
	else
	{
		const uint8_t type = AMF0TypeObject;
		NSInteger length = [self.stream write:&type maxLength:sizeof(type)];
		if(length != sizeof(type))
		{
			NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
			return NO;
		}
		
		for(NSString *key in dictionary)
		{
			if(![key isKindOfClass:NSString.class])
			{
				NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
				return NO;
			}
			
			if([key hasPrefix:AMF0KeyPrefix])
			{
				continue;
			}

			NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
			
			{
				const uint16_t keyLength = OSSwapBigToHostInt16(keyData.length);
				length = [self.stream write:(uint8_t *)&keyLength maxLength:sizeof(keyLength)];
				if(length != sizeof(keyLength))
				{
					NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
					return NO;
				}
			}
			
			length = [self.stream write:keyData.bytes maxLength:keyData.length];
			if(length != keyData.length)
			{
				NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
				return NO;
			}
			
			id object = [dictionary objectForKey:key];
			
			if(![self encodeObject:object error:error])
			{
				NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
				return NO;
			}
		}
		
		{
			const uint8_t type[3] = { 0x00, 0x00, AMF0TypeObjectEnd };
			NSInteger length = [self.stream write:type maxLength:sizeof(type)];
			if(length != sizeof(type))
			{
				NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
				return NO;
			}
		}
		
		return YES;
	}
}

- (BOOL)encodeNullWithError:(NSError **)error
{
	const uint8_t type = AMF0TypeNull;
	NSInteger length = [self.stream write:&type maxLength:sizeof(type)];
	if(length != sizeof(type))
	{
		NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
		return NO;
	}
	
	return YES;
}

@end
