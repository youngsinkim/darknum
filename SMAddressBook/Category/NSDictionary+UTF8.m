//
//  NSDictionary+UTF8.m
//  SMAddressBook
//
//  Created by 선옥 채 on 13. 9. 18..
//  Copyright (c) 2013년 sochae. All rights reserved.
//

#import "NSDictionary+UTF8.h"

@implementation NSDictionary (UTF8)

- (NSDictionary*)dictionaryByUTF8Encode
{
	NSMutableDictionary* encodeDict = [NSMutableDictionary dictionary];
	
	NSArray* keys = [self allKeys];
	
	for (NSString* key in keys) {
		NSObject* obj = [self objectForKey:key];
		
		if ([obj isKindOfClass:[NSMutableString class]]) {
			NSString* stringObj = (NSString*)obj;
			[encodeDict setValue:[stringObj stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:key];
		} else if ([obj isKindOfClass:[NSDictionary class]]) {
			[encodeDict setValue:[(NSDictionary*)obj dictionaryByUTF8Encode] forKey:key];
		} else {
			[encodeDict setValue:obj forKey:key];
		}
	}
	
	return encodeDict;
}


- (NSDictionary*)dictionaryByUTF8Decode
{
	NSMutableDictionary* decodeDict = [NSMutableDictionary dictionary];
	
	NSArray* keys = [self allKeys];
    
	for (NSString* key in keys) {
		NSObject* obj = [self objectForKey:key];
		
		if ([obj isKindOfClass:[NSMutableString class]]) {
			NSString* stringObj = (NSString*)obj;
			[decodeDict setValue:[stringObj stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forKey:key];
		} else if ([obj isKindOfClass:[NSDictionary class]]) {
			[decodeDict setValue:[(NSDictionary*)obj dictionaryByUTF8Decode] forKey:key];
		} else {
			[decodeDict setValue:obj forKey:key];
		}
	}
	
	return decodeDict;
}

@end
