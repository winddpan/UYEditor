//
//  CSEditorToobar.h
//  UYEditor
//
//  Created by Pan Xiao Ping on 15/5/11.
//  Copyright (c) 2015年 Cimu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UYEditorToolbarItem.h"

@interface UYEditorToolbar : UIView
{
@private
    UIScrollView *toolBarScroll;
    UIToolbar *toolbar;
    UIToolbar *keyboardToolbar;
    CGFloat _toolbarWidth;
}
@property (nonatomic, assign)          BOOL disableImagePicker;
@property (nonatomic, copy, nonnull)   UIColor *tintColor;
@property (readonly, strong, nonnull)  NSArray<UYEditorToolbarItem *> *items;
@property (nullable, nonatomic)        SEL action;    // default is NULL
@property (nullable, nonatomic,weak)   id  target;    // default is nil
@end
