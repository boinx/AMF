#import <Foundation/Foundation.h>

typedef NS_ENUM(uint8_t, AMF3Type) {
	AMF3TypeUndefined = 0x00,
	AMF3TypeNull = 0x01,
	AMF3TypeFalse = 0x02,
	AMF3TypeTrue = 0x03,
	AMF3TypeInteger = 0x04,
	AMF3TypeDouble = 0x05,
	AMF3TypeString = 0x06,
	AMF3TypeXML = 0x07,
	AMF3TypeDate = 0x08,
	AMF3TypeArray = 0x09,
	AMF3TypeObject = 0x0A,
	AMF3TypeXMLEnd = 0x0B,
	AMF3TypeData = 0x0C,
};
