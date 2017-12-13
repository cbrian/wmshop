//
//  NSString+SCExtensions.m
//  SamClub
//
//  Created by Brian Cao on 12/12/17.
//  Copyright © 2017 Brian Cao. All rights reserved.
//

#import "NSString+SCExtensions.h"

@implementation NSString (SCExtensions)

+(NSString *) filter_ASCIISet_String: (NSString *) anyString
{
    return [[anyString componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithRange:NSMakeRange(0, 128)].invertedSet] componentsJoinedByString:@""];
}

@end
