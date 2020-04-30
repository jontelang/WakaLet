//
//  NSMenuItem+Equal.h
//  wakalet
//
//  Created by Sergey Ryazanov on 06.05.15.
//  Copyright (c) 2015 Jonathan Winger Lang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSMenuItem (Equal)

- (BOOL)isSameWithMenuItem:(NSMenuItem *)checkItem;

@end
