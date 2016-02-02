//
//  UYEditorView.h
//  UYEditor
//
//  Created by Pan Xiao Ping on 15/8/25.
//  Copyright (c) 2015年 Cimu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIWebView+GUIFixes.h"

@class UYEditorView;
@protocol UYEditorViewDelegate <NSObject>
@optional
- (void)editorView:(UYEditorView *)editorView stylesForCurrentSelection:(NSArray *)styles;
- (void)editorViewDidLoaded:(UYEditorView *)editorView;
- (void)editorViewDidInput:(UYEditorView *)editorView;
@end

@interface UYEditorView : UIView <UIWebViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak)     id<UYEditorViewDelegate> delegate;
@property (nonatomic, readonly) UIWebView *webView;

- (void)runJavaScriptWhileLoaded:(NSString *)javaScript;
- (void)scrollToCaret;
@end
