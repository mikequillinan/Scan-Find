//
//  NSString+HTMLEntities.h
//  WinesToDo
//
//  Created by Michael Quillinan on 2/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTMLEntities)

- (NSString *)stringByDecodingHTMLEntities;

@end
