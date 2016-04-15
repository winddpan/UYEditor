//
//  CSEditorToobar.m
//  ZSSRichTextEditor
//
//  Created by Pan Xiao Ping on 15/5/11.
//  Copyright (c) 2015年 Cimu. All rights reserved.
//

#import "UYEditorToolbar.h"

static const CGFloat UYEditorToolbarItemSizeIPhone = 35.0;
static const CGFloat UYEditorToolbarItemSizeIPad = 44.0;
static const CGFloat UYEditorToolbarItemSpacingIPhone = 10.0;
static const CGFloat UYEditorToolbarItemSpacingIPad = 40.0;
static const CGFloat UYEditorToolbarKeyboardItemWidth = 44.0;

@implementation UYEditorToolbar

- (BOOL)isPad {
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Background Toolbar
        UIToolbar *backgroundToolbar = [[UIToolbar alloc] initWithFrame:self.bounds];
        backgroundToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:backgroundToolbar];
        
        toolBarScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [self isPad] ? self.frame.size.width : self.frame.size.width - UYEditorToolbarKeyboardItemWidth, self.frame.size.height)];
        toolBarScroll.backgroundColor = [UIColor clearColor];
        toolBarScroll.showsHorizontalScrollIndicator = NO;
        toolBarScroll.showsVerticalScrollIndicator = NO;
        toolBarScroll.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:toolBarScroll];
        
        // Toolbar with icons
        toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        toolbar.backgroundColor = [UIColor clearColor];
        [toolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [toolBarScroll addSubview:toolbar];
        
        // Toolbar holder used to crop and position toolbar
        UIView *toolbarCropper = [[UIView alloc] initWithFrame:CGRectMake(toolBarScroll.frame.size.width, 0, UYEditorToolbarKeyboardItemWidth, self.frame.size.height)];
        toolbarCropper.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        toolbarCropper.clipsToBounds = YES;
        [self addSubview:toolbarCropper];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0.5f, toolbarCropper.frame.size.height)];
        line.backgroundColor = [UIColor lightGrayColor];
        line.alpha = 0.7f;
        [toolbarCropper addSubview:line];
        
        // Use a toolbar so that we can tint
        keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(-7, 0, UYEditorToolbarKeyboardItemWidth, toolbarCropper.frame.size.height)];
        keyboardToolbar.backgroundColor = [UIColor clearColor];
        [keyboardToolbar setBackgroundImage:[UIImage new] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
        [toolbarCropper addSubview:keyboardToolbar];
        
        [self buildToolbarItems];
    }
    return self;
}

- (void)setDisableImagePicker:(BOOL)disableImagePicker {
    _disableImagePicker = disableImagePicker;
    [self buildToolbarItems];
}

- (void)setTintColor:(UIColor *)tintColor {
    _tintColor = tintColor;
    
    [_items enumerateObjectsUsingBlock:^(UYEditorToolbarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.selectedColor = tintColor;
    }];
}

- (void)buildToolbarItems {
    NSInteger FlexibleSpace = -1;
    NSInteger FixedSpace = -2;
    NSArray *itemIdef = @[@(FlexibleSpace),
                          @(UYEditorToolbarInsertImage),
                          @(UYEditorToolbarCamera),
                          //@(FixedSpace),
                          @(UYEditorToolbarBold),
                          @(UYEditorToolbarItalic),
                          @(UYEditorToolbarStrikeThrough),
                          @(UYEditorToolbarUnderline),
                          //@(FixedSpace),
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
        
        if (idef == FlexibleSpace) {
            UYEditorToolbarItem *item = [[UYEditorToolbarItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
            [toolbarItems addObject:item];
        } else if (idef == FixedSpace) {
            UYEditorToolbarItem *item = [[UYEditorToolbarItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
            item.width =  [self isPad] ? UYEditorToolbarItemSpacingIPad : UYEditorToolbarItemSpacingIPhone;
            [toolbarItems addObject:item];
        } else {
            BOOL isImagePicker = idef == UYEditorToolbarInsertImage || idef == UYEditorToolbarCamera;
            if (!isImagePicker || !self.disableImagePicker) {
                UIImage *image = [UIImage imageNamed:[imageStack firstObject]];
                UYEditorToolbarItem *item = [[UYEditorToolbarItem alloc] init];
                item.actionIdentifer = idef;
                item.image = image;
                item.width = [self isPad] ? UYEditorToolbarItemSizeIPad : UYEditorToolbarItemSizeIPhone;
                item.enableSelected = !isImagePicker;
                [toolbarItems addObject:item];
            }
            if (imageStack.count) {
                [imageStack removeObjectAtIndex:0];
            }
        }
    }];
    [toolbar setItems:toolbarItems animated:NO];
    
    UYEditorToolbarItem *keyboardItem = [[UYEditorToolbarItem alloc] initWithImage:[UIImage imageNamed:@"kb_dismiss"] style:UIBarButtonItemStylePlain target:nil action:nil];
    keyboardItem.actionIdentifer = UYEditorToolbarHideKeyboard;
    keyboardItem.enableSelected = NO;
    keyboardToolbar.items = @[keyboardItem];
    
    _items = [[toolbarItems copy] arrayByAddingObject:keyboardItem];
    
    CGRect toolbarFrame = toolbar.frame;
    toolbarFrame.size.width = 2000;
    [toolbar setNeedsLayout];
    [toolbar layoutIfNeeded];
    
    __block CGFloat left = MAXFLOAT;
    __block CGFloat right = 0;
    [toolbar.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:NSClassFromString(@"UIToolbarButton")]) {
            left = MIN(left, CGRectGetMinX(obj.frame));
            right = MAX(right, CGRectGetMaxX(obj.frame));
        }
    }];
    _toolbarWidth = right - left + ([self isPad] ? UYEditorToolbarItemSizeIPad : UYEditorToolbarItemSizeIPhone);
    
    if (self.tintColor) {
        [_items enumerateObjectsUsingBlock:^(UYEditorToolbarItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.selectedColor = self.tintColor;
        }];
    }
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect toolbarFrame = toolbar.frame;
    toolbarFrame.size.width = MAX(_toolbarWidth, toolBarScroll.frame.size.width);
    toolbar.frame = toolbarFrame;    
    toolBarScroll.contentSize = CGSizeMake(toolbar.frame.size.width, toolBarScroll.contentSize.height);
}

@end
