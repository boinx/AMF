#import <Foundation/Foundation.h>

#import "AMFEncoder.h"


@interface AMF0Encoder : NSObject <AMFEncoder>

+ (instancetype)encoder;
+ (instancetype)encoderWithOutputStream:(NSOutputStream *)stream;

- (instancetype)initWithOutputStream:(NSOutputStream *)stream;

- (NSData *)data;

- (BOOL)encodeObject:(id)object;
- (BOOL)encodeObject:(id)object error:(NSError **)error;

@end
