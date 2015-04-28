//
//  WLMenu.m
//  wakalet
//
//  Created by Sergey Ryazanov on 28.04.15.
//  Copyright (c) 2015 Jonathan Winger Lang. All rights reserved.
//

#import "WLMenu.h"

const NSInteger WLMenuQuitButtonTag = 159;

@interface WLMenu ()

@property (nonatomic, retain) NSMenuItem *quitItem;

@end

@implementation WLMenu

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.quitItem = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(terminate:) keyEquivalent:@""];
        _quitItem.tag = WLMenuQuitButtonTag;
        
        self.showQuitButton = YES;
    }
    return self;
}

#pragma mark - 


- (void)addItem:(NSMenuItem *)newItem
{
    [super addItem:newItem];
    [self updateQuitButton];
}

#pragma mark - Quit button

- (void)updateQuitButton
{
    [self removeQuitButton];
    [self addQuitButtonIfNeeded];
}

- (void)removeQuitButton
{
    NSInteger index = [self indexOfItem:_quitItem];
    if (index != -1 && index < self.numberOfItems) {
        [self removeItemAtIndex:index];
    }
}

- (void)addQuitButtonIfNeeded
{
    if (self.showQuitButton) {
        [self insertItem:_quitItem atIndex:self.numberOfItems];
    }
}

#pragma mark - Setters

- (void)setShowQuitButton:(BOOL)showQuitButton
{
    _showQuitButton = showQuitButton;
    [self updateQuitButton];
}

@end
