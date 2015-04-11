//
//  AppDelegate.h
//  WakaLet
//
//  Created by Jonathan Winger Lang on 13/01/13.
//  Copyright (c) 2013 Jonathan Winger Lang. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate,NSMenuDelegate>
{
    NSStatusItem *statusItem;
    NSMenu *statusMenu;
}
@end
