#import <Foundation/Foundation.h>

@protocol AMFEncoder <NSObject>
@required

- (NSData *)data;

- (BOOL)encodeObject:(id)object;
- (BOOL)encodeObject:(id)object error:(NSError **)error;

@end
