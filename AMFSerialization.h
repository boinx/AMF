#import <Foundation/Foundation.h>



typedef NS_OPTIONS(NSUInteger, AMFReadingOptions) {
    AMFReadingOptionsAMF0 = (0UL << 0),
    AMFReadingOptionsAMF3 = (3UL << 0),
	AMFReadingOptionsSequence = (1UL << 2),
};

typedef NS_OPTIONS(NSUInteger, AMFWritingOptions) {
    AMFWritingOptionsAMF0 = (0UL << 0),
    AMFWritingOptionsAMF3 = (3UL << 0),
	AMFWritingOptionsSequence = (1UL << 2),
};


@interface AMFSerialization : NSCoder

+ (BOOL)isValidAMFObject:(id)object;

+ (NSData *)dataWithAMFObject:(id)object options:(AMFWritingOptions)options error:(NSError **)error;

+ (id)AMFObjectWithData:(NSData *)data options:(AMFReadingOptions)options error:(NSError **)error;

@end
