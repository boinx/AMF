#import <Foundation/Foundation.h>

#import "AMFDecoder.h"


@interface AMF0Decoder : NSObject <AMFDecoder>

+ (instancetype)decoderWithData:(NSData *)data;
+ (instancetype)decoderWithStream:(NSInputStream *)stream;

- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithStream:(NSInputStream *)stream;

- (id)decodeObject;
- (id)decodeObjectWithError:(NSError **)error;

@end
