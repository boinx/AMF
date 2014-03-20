#import "AMFSerialization.h"

#import "AMF0Decoder.h"
#import "AMF0Encoder.h"

@implementation AMFSerialization

+ (BOOL)isValidAMFObject:(id)object
{
	if([object isKindOfClass:NSString.class])
	{
		return YES;
	}
	
	if([object isKindOfClass:NSNumber.class])
	{
		return YES;
	}
	
	if([object isKindOfClass:NSArray.class])
	{
		NSDictionary *array = object;
		for(id value in array)
		{
			if(![self isValidAMFObject:value])
			{
				return NO;
			}
		}
		return YES;
	}
	
	if([object isKindOfClass:NSDictionary.class])
	{
		NSDictionary *dictionary = object;
		for(id key in dictionary)
		{
			if(![key isKindOfClass:NSString.class])
			{
				return NO;
			}

			id value = [dictionary objectForKey:key];
			
			if(![self isValidAMFObject:value])
			{
				return NO;
			}
		}
		return YES;
	}
	
	return NO;
}

+ (NSData *)dataWithAMFObject:(id)object options:(AMFWritingOptions)options error:(NSError **)error
{
	id<AMFEncoder> encoder = nil;
	
	if(options & AMFWritingOptionsAMF3)
	{
		NSLog(@"TODO %s:%d", __FUNCTION__, __LINE__);
		return nil;
	}
	else
	{
		encoder = [AMF0Encoder encoder];
	}
	
	if(options & AMFWritingOptionsSequence)
	{
		if(![object isKindOfClass:NSArray.class])
		{
			NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
			return nil;
		}
		
		NSArray *objects = object;
		for(id object in objects)
		{
			if(![encoder encodeObject:object error:error])
			{
				NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
				return nil;
			}
		}
		
		return encoder.data;
	}
	else
	{
		if(![encoder encodeObject:object])
		{
			NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
			return nil;
		}
		
		return encoder.data;
	}
}

+ (id)AMFObjectWithData:(NSData *)data options:(AMFReadingOptions)options error:(NSError **)error
{
	id<AMFDecoder> decoder = nil;
	
	if(options & AMFWritingOptionsAMF3)
	{
		NSLog(@"TODO %s:%d", __FUNCTION__, __LINE__);
		return nil;
	}
	else
	{
		decoder = [AMF0Decoder decoderWithData:data];
	}
	
	if(decoder == nil)
	{
		NSLog(@"ERROR %s:%d", __FUNCTION__, __LINE__);
		return nil;
	}
	
	if(options & AMFReadingOptionsSequence)
	{
		NSMutableArray *objects = [NSMutableArray array];
		
		while(YES) {
			id object = [decoder decodeObjectWithError:error];
			if(object == nil)
			{
				break;
			}
			
			[objects addObject:object];
		}
		
		return objects.count > 0 ? [NSArray arrayWithArray:objects] : nil;
	}

	return [decoder decodeObjectWithError:error];
}

@end
