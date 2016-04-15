//
//  UYEditorViewController.h
//  UYEditor
//
//  Created by Pan Xiao Ping on 15/8/25.
//  Copyright © 2015年 Cimu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZAppearance.h"

@class UYEditorViewController;
@protocol UYEditorViewControllerDelegate <NSObject>
@optional
- (void)editorViewControllerDidLoaded:(UYEditorViewController *)viewController;
- (void)editorViewControllerDidInput:(UYEditorViewController *)viewController;
@end

@interface UYEditorViewController : UIViewController <MZAppearance>

@property (weak)    id<UYEditorViewControllerDelegate> delegate;
@property (nonatomic, readonly) UIWebView *webView;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, readonly, getter=isEditing) BOOL editing;

@property (nonatomic, assign) BOOL disableImagePicker MZ_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *toolbarTintColor MZ_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIFont *font MZ_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *textColor MZ_APPEARANCE_SELECTOR;
@property (nonatomic, copy) UIColor *placeholderColor MZ_APPEARANCE_SELECTOR;

@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *html;

- (void)startEditing;
- (void)stopEditing;

- (BOOL)isHTMLUpdated;
- (void)runJavaScriptWhileLoaded:(NSString *)javaScript;

@end
