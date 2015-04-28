//
//  AppDelegate.h
//  WakaLet
//
//  Created by Jonathan Winger Lang on 13/01/13.
//  Copyright (c) 2013 Jonathan Winger Lang. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WLMenu.h"

@interface AppDelegate : NSObject <NSApplicationDelegate,NSMenuDelegate>
{
    NSStatusItem *statusItem;
    WLMenu *statusMenu;
}
@end
