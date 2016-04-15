//
//  UYEditorToolItem.h
//  UYEditor
//
//  Created by Pan Xiao Ping on 15/8/26.
//  Copyright (c) 2015年 Cimu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    UYEditorToolbarDefault = 0,
    UYEditorToolbarBold,
    UYEditorToolbarItalic,
    UYEditorToolbarSubscript,
    UYEditorToolbarSuperscript,
    UYEditorToolbarStrikeThrough,
    UYEditorToolbarUnderline,
    UYEditorToolbarUnorderedList,
    UYEditorToolbarOrderedList,
    UYEditorToolbarInsertImage,
    UYEditorToolbarCamera,
    UYEditorToolbarHideKeyboard,
} UYEditorToolbarItemIdentifer;

@interface UYEditorToolbarItem : UIBarButtonItem
@property (nonatomic)   UYEditorToolbarItemIdentifer actionIdentifer;
@property (nonatomic)   BOOL selected;
@property (nonatomic)   BOOL enableSelected;
@property (strong, nonatomic)   UIColor *selectedColor;
@end
