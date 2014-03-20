#import <Foundation/Foundation.h>

@protocol AMFDecoder <NSObject>
@required

- (id)decodeObject;
- (id)decodeObjectWithError:(NSError **)error;

@end
