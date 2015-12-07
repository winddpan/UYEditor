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
}

@property (readonly, strong) NSArray *items;
@end
