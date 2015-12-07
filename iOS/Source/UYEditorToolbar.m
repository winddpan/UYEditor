//
//  CSEditorToobar.m
//  ZSSRichTextEditor
//
//  Created by Pan Xiao Ping on 15/5/11.
//  Copyright (c) 2015年 Cimu. All rights reserved.
//

#import "UYEditorToolbar.h"

static const CGFloat UYEditorToolbarItemSize = 35.0;
static const CGFloat UYEditorToolbarItemSizeiPad = 44.0;

@implementation UYEditorToolbar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        toolBarScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? self.frame.size.width : self.frame.size.width - 44, self.frame.size.height)];
        toolBarScroll.backgroundColor = [UIColor clearColor];
        toolBarScroll.showsHorizontalScrollIndicator = NO;
        toolBarScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        // Toolbar with icons
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        toolbar.backgroundColor = [UIColor clearColor];
        [toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [toolBarScroll addSubview:toolbar];
        
        // Background Toolbar
        UIToolbar *backgroundToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 44)];
        backgroundToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:backgroundToolbar];
        [self addSubview:toolBarScroll];

        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            [self buildiPadItems];
        } else {
            [self buildiPhoneItems];
        }
        
        toolBarScroll.contentSize = CGSizeMake(toolbar.frame.size.width, self.frame.size.height);
    }
    return self;
}

- (void)buildiPadItems {
    
    NSInteger FlexibleSpace = -1;
    NSInteger FixedSpace = -2;
    NSArray *itemIdef = @[@(FlexibleSpace),
                          @(UYEditorToolbarInsertImage),
                          @(UYEditorToolbarCamera),
                          @(FixedSpace),
                          @(UYEditorToolbarBold),
                          @(UYEditorToolbarItalic),
                          @(UYEditorToolbarStrikeThrough),
                          @(UYEditorToolbarUnderline),
                          @(FixedSpace),
                          @(UYEditorToolbarUnorderedList),
                          @(UYEditorToolbarOrderedList),
                          @(FlexibleSpace),
                          ];
    NSArray *itemImgs = @[@"kb_image",
                          @"kb_camera",
                          @"kb_bold",
                          @"kb_italic",
                          @"kb_strikethrough",
                          @"kb_underline",
                          @"kb_unorderedlist",
                          @"kb_orderedlist",
                          ];
    
    NSMutableArray *toolbarItems = [NSMutableArray array];
    NSMutableArray *imageStack = [[NSMutableArray alloc] initWithArray:itemImgs];
    
    [itemIdef enumerateObjectsUsingBlock:^(NSNumber *identifier, NSUInteger idx, BOOL *stop) {
        NSInteger idef = [identifier integerValue];
        UYEditorToolbarItem *item;

        if (idef == FlexibleSpace) {
            item = [[UYEditorToolbarItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        } else if (idef == FixedSpace) {
            item = [[UYEditorToolbarItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            item.width = 40;
        } else {
            UIImage *image = [UIImage imageNamed:[imageStack firstObject]];
            
            item = [[UYEditorToolbarItem alloc] init];
            item.actionIdentifer = idef;
            item.image = image;
            item.width = UYEditorToolbarItemSizeiPad;
            item.enableSelected = idx > 2;
            
            if (imageStack.count) {
                [imageStack removeObjectAtIndex:0];
            }
        }
        [toolbarItems addObject:item];
    }];
    [toolbar setItems:toolbarItems animated:NO];
    _items = toolbarItems;
}

- (void)buildiPhoneItems {
    NSInteger FlexibleSpace = -1;
    NSInteger FixedSpace = -2;
    NSArray *itemIdef = @[@(FlexibleSpace),
                          @(UYEditorToolbarInsertImage),
                          @(UYEditorToolbarCamera),
                          @(FixedSpace),
                          @(UYEditorToolbarBold),
                          @(UYEditorToolbarItalic),
                          @(UYEditorToolbarStrikeThrough),
                          @(UYEditorToolbarUnderline),
                          @(FixedSpace),
                          @(UYEditorToolbarUnorderedList),
                          @(UYEditorToolbarOrderedList),
                          @(FlexibleSpace),
                          ];
    NSArray *itemImgs = @[@"kb_image",
                          @"kb_camera",
                          @"kb_bold",
                          @"kb_italic",
                          @"kb_strikethrough",
                          @"kb_underline",
                          @"kb_unorderedlist",
                          @"kb_orderedlist",
                          ];
    
    NSMutableArray *toolbarItems = [NSMutableArray array];
    NSMutableArray *imageStack = [[NSMutableArray alloc] initWithArray:itemImgs];
    [itemIdef enumerateObjectsUsingBlock:^(NSNumber *identifier, NSUInteger idx, BOOL *stop) {
        NSInteger idef = [identifier integerValue];
        UYEditorToolbarItem *item;
        
        if (idef == FlexibleSpace) {
            item = [[UYEditorToolbarItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        } else if (idef == FixedSpace) {
            item = [[UYEditorToolbarItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            item.width = 10;
        } else {
            UIImage *image = [UIImage imageNamed:[imageStack firstObject]];
            
            item = [[UYEditorToolbarItem alloc] init];
            item.actionIdentifer = idef;
            item.image = image;
            item.width = UYEditorToolbarItemSize;
            item.enableSelected = idx > 2;
            
            if (imageStack.count) {
                [imageStack removeObjectAtIndex:0];
            }
        }
        [toolbarItems addObject:item];
    }];
    [toolbar setItems:toolbarItems animated:NO];
    
    // Toolbar holder used to crop and position toolbar
    UIView *toolbarCropper = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width-44, 0, 44, 44)];
    toolbarCropper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    toolbarCropper.clipsToBounds = YES;

    // Use a toolbar so that we can tint
    UIToolbar *keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(-7, 0, 44, 44)];
    keyboardToolbar.backgroundColor = [UIColor clearColor];
    [keyboardToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    [toolbarCropper addSubview:keyboardToolbar];

    UYEditorToolbarItem *keyboardItem = [[UYEditorToolbarItem alloc] initWithImage:[UIImage imageNamed:@"kb_dismiss"] style:UIBarButtonItemStylePlain target:nil action:nil];
    keyboardItem.actionIdentifer = UYEditorToolbarHideKeyboard;
    keyboardItem.enableSelected = NO;
    keyboardToolbar.items = @[keyboardItem];
    [self addSubview:toolbarCropper];

    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.6f, 44)];
    line.backgroundColor = [UIColor lightGrayColor];
    line.alpha = 0.7f;
    [toolbarCropper addSubview:line];

    [toolbarItems addObject:keyboardItem];
    _items = [toolbarItems copy];

    UIView *first = toolbar.subviews.firstObject;
    UIView *last = toolbar.subviews.lastObject;
    CGRect toolbarFrame = toolbar.frame;
    toolbarFrame.size.width = CGRectGetMaxX(last.frame) + CGRectGetMinX(first.frame) + 30;
    toolbar.frame = toolbarFrame;
}

@end
