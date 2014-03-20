#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, AMF0Type) {
	AMF0TypeNumber = 0x00,
	AMF0TypeBoolean = 0x01,
	AMF0TypeString = 0x02,
	AMF0TypeObject = 0x03,
	AMF0TypeNull = 0x05,
	AMF0TypeECMAArray = 0x08,
	AMF0TypeObjectEnd = 0x09,
	AMF0TypeStrictArray = 0x0a,
	AMF0TypeDate = 0x0b,
	AMF0TypeLongString = 0x0c,
	AMF0TypeXMLDocument = 0xf0,
	AMF0TypeTypedObject = 0x10,
	AMF0TypeSwitchToAMF3 = 0x11,
};

extern NSString * const AMF0TypeKey;

extern NSString * const AMF0KeyPrefix;
