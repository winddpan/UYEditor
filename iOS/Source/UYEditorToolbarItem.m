//
//  UYEditorToolItem.m
//  UYEditor
//
//  Created by Pan Xiao Ping on 15/8/26.
//  Copyright (c) 2015年 Cimu. All rights reserved.
//

#import "UYEditorToolbarItem.h"

@implementation UYEditorToolbarItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.enableSelected = YES;
        self.selected = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (self.enableSelected) {
        _selected = selected;
        self.tintColor = self.selected ? nil : [UIColor lightGrayColor];
    }
}

- (void)setEnableSelected:(BOOL)enableSelected {
    _enableSelected = enableSelected;
    if (!enableSelected) {
        self.tintColor = nil;
    } else {
        self.tintColor = self.selected ? nil : [UIColor lightGrayColor];
    }
}

@end
