//
//  TSLanguageManager.h
//
//  Created by Toni on 22/09/12.
//  Copyright (c) 2012 Toni Sala Echaurren. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <Foundation/Foundation.h>

// Supported languages.
// Add your specific supported languages here.
#define kLMDefaultLanguage  @"ko"
#define kLMEnglish          @"en"
#define kLMKorean           @"ko"
#define kLMSpanish          @"es"

//
#define LocalizedString(key, comment) [TSLanguageManager localizedString:key]

@interface TSLanguageManager : NSObject {
}

+(BOOL) isSupportedLanguage:(NSString*)language;
+(NSString*) localizedString:(NSString*) key;
+(void) setSelectedLanguage:(NSString*)language;
+(NSString*) selectedLanguage;

@end