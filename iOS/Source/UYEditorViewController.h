//
//  UYEditorViewController.h
//  UYEditor
//
//  Created by Pan Xiao Ping on 15/8/25.
//  Copyright © 2015年 Cimu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UYEditorViewController;
@protocol UYEditorViewControllerDelegate <NSObject>
@optional
- (void)editorViewControllerDidLoaded:(UYEditorViewController *)viewController;
- (void)editorViewControllerDidInput:(UYEditorViewController *)viewController;
@end

@interface UYEditorViewController : UIViewController

@property (weak)    id<UYEditorViewControllerDelegate> delegate;
@property (nonatomic, readonly)     UIWebView *webView;
@property (nonatomic, readonly)     BOOL isEditing;
@property (nonatomic, readwrite)    BOOL editable;
@property (nonatomic, readwrite)    NSString *placeholder;
@property (nonatomic, readwrite)    NSString *html;
@property (nonatomic, assign)       BOOL disableImagePicker;

- (BOOL)isHTMLUpdated;
- (void)runJavaScript:(NSString *)javaScript;

@end
