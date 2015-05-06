//
//  NSMenuItem+Equal.m
//  wakalet
//
//  Created by Sergey Ryazanov on 06.05.15.
//  Copyright (c) 2015 Jonathan Winger Lang. All rights reserved.
//

#import "NSMenuItem+Equal.h"

@implementation NSMenuItem (Equal)

- (BOOL)isSameWithMenuItem:(NSMenuItem *)checkItem
{
    if ([self.title isEqualToString:checkItem.title]
        && [NSStringFromSelector(self.action) isEqualToString:NSStringFromSelector(checkItem.action)]
        && [self.keyEquivalent isEqualToString:checkItem.keyEquivalent])
    {
        return YES;
    }
    return NO;
}

@end
