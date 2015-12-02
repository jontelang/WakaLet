//
//  AppDelegate.m
//  WakaLet
//
//  Created by Jonathan Winger Lang on 13/01/13.
//  Copyright (c) 2013 Jonathan Winger Lang. All rights reserved.
//

#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "NSMenuItem+Equal.h"

@implementation AppDelegate

-(void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    // Insert code here to initialize your application
}

-(void)awakeFromNib{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setTitle:@"W"];
    //[statusItem setImage:[NSImage imageNamed:@"menubaricon.png"]];
    [statusItem setHighlightMode:YES];
    statusMenu = [[WLMenu alloc] init];
    [statusMenu setDelegate:self];
    [statusItem setMenu:statusMenu];
    [self checkAPIAndBuildMenu];
}

-(void)checkAPIAndBuildMenu{
    // Get the manually set API key
    NSString *api_key = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_key"];
    
    // If there is no key though, just show the add-API-key entry
    if( api_key == nil ){
        [self addItemInMenuIfNeeded:[[NSMenuItem alloc] initWithTitle:@"Set API key" action:@selector(openSetApi) keyEquivalent:@"a"]];
    }
    
    // If there is one, initiate the request
    else{
        // Get the current date, and 7 days back
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/YYYY"];
        NSString *todayDate = [formatter stringFromDate:[NSDate date]];
        NSString *someDaysAgoDate = [formatter stringFromDate:[[NSDate date] dateByAddingTimeInterval:3600*24*7*-1]];
        
        // Build the parameters for the string
        NSString *dataString = [NSString stringWithFormat:@"?start=%@&end=%@&api_key=%@",someDaysAgoDate,todayDate,api_key];
        
        // The general API url
        NSString *urlString = [@"https://wakatime.com/api/v1/users/current/summaries" stringByAppendingString:dataString];
        
        // Request the data
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
        
        // Let the user know we are refreshing
        [statusMenu removeAllItems];
        [self addItemInMenuIfNeeded:[[NSMenuItem alloc] initWithTitle:@"Refreshing.." action:nil keyEquivalent:@""]];
        
        // Record the date of the refresh/api get
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date]
                                                 forKey:@"refresh"];
        
        // Go go go
        //NSLog(@"Request: %@", request);
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[[NSOperationQueue alloc] init]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
            
            // Show possible errors
            if( connectionError != nil ){
                [self addItemInMenuIfNeeded:[[NSMenuItem alloc] initWithTitle:connectionError.localizedDescription
                                                               action:@selector(openSetApi)
                                                        keyEquivalent:@""]];
            }
            
            // Else just try to build the menu
            else{
                // The data
                NSError *err;
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&err];
                
                // If there is no error, build the wakalet
                if( err == nil ) {
                    [self performSelectorOnMainThread:@selector(buildMenuWithData:) withObject:dict waitUntilDone:NO];
                }
                
                // Otherwise let's show the error somehow
                else{
                    [self addItemInMenuIfNeeded:[[NSMenuItem alloc] initWithTitle:err.localizedDescription
                                                                   action:@selector(openSetApi)
                                                            keyEquivalent:@""]];
                }
            }
        }];
    }
}

-(void)addApiMenuWithTitle:(NSString *)title{
    dispatch_async(dispatch_get_main_queue(), ^{
        [statusMenu addItem:[[NSMenuItem alloc] initWithTitle:title action:@selector(openSetApi) keyEquivalent:@""]];
    });
}

-(void)openSetApi{
    NSString *old_apo_key = [[NSUserDefaults standardUserDefaults] valueForKey:@"api_key"];
    NSString *api_key = [self input:@"Enter your API key" defaultValue:old_apo_key==nil?@"":old_apo_key];
    
    if( api_key != nil ){
        [[NSUserDefaults standardUserDefaults] setValue:api_key forKey:@"api_key"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [self checkAPIAndBuildMenu];
}

-(NSString*)input:(NSString *)prompt defaultValue:(NSString*)defaultValue{
    NSAlert *alert = [NSAlert alertWithMessageText:prompt
                                     defaultButton:@"OK"
                                   alternateButton:@"Cancel"
                                       otherButton:nil
                         informativeTextWithFormat:@"You can find your API key at https://wakatime.com/settings#apikey"];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 400, 24)];
    [input setStringValue:defaultValue];
    [alert setAccessoryView:input];
    [alert setIcon:[NSImage imageNamed:@"waka.png"]];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    } else if (button == NSAlertAlternateReturn) {
        return nil;
    } else {
        NSAssert1(NO, @"Invalid input dialog button %lu", (long)button);
        return nil;
    }
}

-(void)menuWillOpen:(NSMenu *)menu{
    NSMenuItem* timeSinceRefreshItem = [menu itemWithTag:1337];
    timeSinceRefreshItem.title = [self getTimeSinceRefreshTitle];
}

-(void)buildMenuWithData:(NSDictionary*)dict{
    //NSLog(@"%@",dict);
    
    // Remove any existing menu
    [statusMenu removeAllItems];
    
    // This is a spacer object only
    NSMenuItem *spacer = [[NSMenuItem alloc] init];
    [spacer setView:[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 1, 7)]];
    [statusMenu addItem:spacer];
    
    // Let's find some data, reverse it to get it in the right order
    NSArray *dataObjArray = [[[dict valueForKey:@"data"] reverseObjectEnumerator] allObjects];
    
    // Build stuff
    for (int i = 0; i < [dataObjArray count]; i++) {
        
        // Get some data
        NSDictionary *dataObj = [dataObjArray objectAtIndex:i];
        NSDictionary *grandObj = [dataObj objectForKey:@"grand_total"];
        NSInteger *totalseconds = [[grandObj valueForKey:@"total_seconds"] integerValue];
        NSDictionary *rangeObj = [dataObj objectForKey:@"range"];
        NSString* date = [rangeObj valueForKey:@"date"];
        NSString* date_human = [rangeObj valueForKey:@"text"];
        NSString* grand_total_text = [grandObj valueForKey:@"text"];
        
        // Each item is clickable, we store the url to the date in it's tooltip
        NSMenuItem *dateItem = [[NSMenuItem alloc] initWithTitle:date_human
                                                          action:@selector(openUrlFromMenuItemTooltip:)
                                                   keyEquivalent:@""];
        dateItem.toolTip = [NSString stringWithFormat:@"http://www.wakatime.com/dashboard/day?date=%@",date];
        [statusMenu addItem:dateItem];
        
        // We only grab more data if there is data recorded
        if( totalseconds > 0 ){
            
            // Get stuff from the projects object
            NSArray *projectsObjArray = [dataObj objectForKey:@"projects"];
            for (int j = 0; j < [projectsObjArray count]; j++) {
                NSDictionary *projectObj = [projectsObjArray objectAtIndex:j];
                NSString *name  = [projectObj valueForKey:@"name"];
                NSString *time  = [projectObj valueForKey:@"digital"];
                name = [NSString stringWithFormat:@"  %@ (%@)", name, time];
                NSMenuItem *item = [[NSMenuItem alloc] init];
                item.enabled = NO;
                [item setTitle:name];
                [item setTag:i];
                [item setKeyEquivalent:@""];
                [item setAction:nil];
                [item setImage:nil];
                item.toolTip = [NSString stringWithFormat:@"Total for day: %@",grand_total_text];
                [statusMenu addItem:item];
            }
        }
        
        // Otherwise just show that there is no data for the date
        else{
            NSMenuItem *noDataItem = [[NSMenuItem alloc] initWithTitle:@"  No data" action:nil keyEquivalent:@""];
            noDataItem.enabled = NO;
            [statusMenu addItem:noDataItem];
        }
        
        //
        NSMenuItem *spacer = [[NSMenuItem alloc] init];
        [spacer setView:[[NSView alloc] initWithFrame:NSMakeRect(0, 0, 1, 7)]];
        [statusMenu addItem:spacer];
    }
    
    // Add verious other menu items
    [statusMenu addItem:[NSMenuItem separatorItem]];
    
    // Calculate the last refresh time
    NSMenuItem *timeSinceRefreshItem = [[NSMenuItem alloc] initWithTitle:[self getTimeSinceRefreshTitle]
                                                                  action:nil keyEquivalent:@""];
    timeSinceRefreshItem.enabled = NO;
    timeSinceRefreshItem.tag = 1337;
    [statusMenu addItem:timeSinceRefreshItem];
    
    // Add more various stuffs
    [self addItemInMenuIfNeeded:[[NSMenuItem alloc] initWithTitle:@"Refresh now" action:@selector(checkAPIAndBuildMenu) keyEquivalent:@"r"]];
    [self addItemInMenuIfNeeded:[[NSMenuItem alloc] initWithTitle:@"Dashboard" action:@selector(openWakaletDashboard) keyEquivalent:@"d"]];
    [self addItemInMenuIfNeeded:[[NSMenuItem alloc] initWithTitle:@"Set API key" action:@selector(openSetApi) keyEquivalent:@"a"]];

}

#pragma mark - 

-(BOOL)checkIsItemInMenu:(NSMenuItem *)checkItem{
    for (NSMenuItem *item in statusMenu.itemArray) {
        if ([item isSameWithMenuItem:checkItem]) {
            return YES;
        }
    }
    return NO;
}

-(void)addItemInMenuIfNeeded:(NSMenuItem *)menuItem{
    if (NO == [self checkIsItemInMenu:menuItem]) {
        [statusMenu addItem:menuItem];
    }
}


#pragma mark Clicky methods

-(void)openUrlFromMenuItemTooltip:(NSMenuItem*)menuItem{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:menuItem.toolTip]];
}

-(void)openWakaletDashboard{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://www.wakatime.com/dashboard"]];
}

-(NSString*)getTimeSinceRefreshTitle{
    NSDate *refreshDate = (NSDate*)[[NSUserDefaults standardUserDefaults] valueForKey:@"refresh"];
    int lastRefreshTimeStamp = (int)[refreshDate timeIntervalSince1970];
    int currentTimeStamp = (int)[[NSDate date] timeIntervalSince1970];
    int secondsAgo = currentTimeStamp - lastRefreshTimeStamp;
    if( secondsAgo < 60 ){
        if( secondsAgo == 1 ){
            return [NSString stringWithFormat:@"Last refresh: %i second ago",secondsAgo];
        }else{
            return [NSString stringWithFormat:@"Last refresh: %i seconds ago",secondsAgo];
        }
    }
    else if( secondsAgo < 3600 ){
        if( secondsAgo/60 == 1 ){
            return [NSString stringWithFormat:@"Last refresh: Around %i minute ago",secondsAgo/60];
        }else{
            return [NSString stringWithFormat:@"Last refresh: Around %i minutes ago",secondsAgo/60];
        }
    }
    else if( secondsAgo < 3600*24){
        if( secondsAgo/3600 == 1 ){
            return [NSString stringWithFormat:@"Last refresh: Around %i hour ago",secondsAgo/3600];
        }else{
            return [NSString stringWithFormat:@"Last refresh: Around %i hours ago",secondsAgo/3600];
        }
    }
    else{
        return [NSString stringWithFormat:@"Last refresh: A looong time ago"];
    }
}

@end
