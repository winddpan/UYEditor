//
//  UYEditorView.m
//  UYEditor
//
//  Created by Pan Xiao Ping on 15/8/25.
//  Copyright (c) 2015年 Cimu. All rights reserved.
//

#import "UYEditorView.h"

#define UYEV_JS(format, ...)   [self.webView stringByEvaluatingJavaScriptFromString:([NSString stringWithFormat:format, ##__VA_ARGS__])]

@interface UYEditorView ()
@property (strong, nonatomic) NSMutableArray *javaScriptQueue;
@property (nonatomic) BOOL isWebViewLoaded;
@property (nonatomic) BOOL isFirstResponder;
@property (nonatomic) CGFloat lastEditorHeight;
@property (strong, readwrite)  UIWebView *webView;
@end

@implementation UYEditorView
@synthesize html = _html, placeholder = _placeholder;

#pragma mark - Lifecycle

- (void)dealloc {
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.editable = YES;
        self.isWebViewLoaded = NO;
        self.javaScriptQueue = [[NSMutableArray alloc] init];
        
        self.webView = [[UIWebView alloc] init];
        self.webView.frame = self.bounds;
        self.webView.delegate = self;
        self.webView.scalesPageToFit = YES;
        self.webView.multipleTouchEnabled = NO;
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
        self.webView.backgroundColor = [UIColor whiteColor];
        self.webView.opaque = NO;
        self.webView.scrollView.bounces = NO;
        self.webView.usesGUIFixes = YES;
        self.webView.keyboardDisplayRequiresUserAction = NO;
        self.webView.scrollView.bounces = YES;
        [self addSubview:self.webView];
        [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
        
        NSURL *editorURL = [[NSBundle mainBundle] URLForResource:@"uyeditor" withExtension:@"html"];
        [self.webView loadRequest:[NSURLRequest requestWithURL:editorURL]];
    }
    return self;
}

#pragma mark - private funcs

- (void)refreshVisibleViewportAndContentSize
{
    CGFloat footerTop = UYEV_JS(@"$(editor_footer).position().top;").integerValue;
    CGFloat footerHeight = UYEV_JS(@"$(editor_footer).height();").integerValue;
    self.lastEditorHeight = footerTop + footerHeight;
    
    UIScrollView *scrollView = self.webView.scrollView;
    if (scrollView.contentSize.height != self.lastEditorHeight) {
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.webView.frame),  self.lastEditorHeight);
    }
}

- (CGRect)viewport
{
    UIScrollView* scrollView = self.webView.scrollView;
    CGRect viewport;
    viewport.origin = scrollView.contentOffset;
    viewport.size = scrollView.bounds.size;
    viewport.size.height -= (scrollView.contentInset.top + scrollView.contentInset.bottom);
    viewport.size.width -= (scrollView.contentInset.left + scrollView.contentInset.right);
    return viewport;
}

/**
 *  @brief      Scrolls to a position where the caret is visible. This uses the values stored in caretYOffest and lineHeight properties.
 *  @param      animated    If the scrolling shoud be animated  The offset to show.
 */
- (void)scrollToCaretAnimated:(BOOL)animated
{
    CGRect viewport = [self viewport];
    CGFloat caretYOffset = UYEV_JS(@"uyeditor.getYCaretInfo().top;").integerValue +
                           UYEV_JS(@"uyeditor.getYCaretInfo().height;").integerValue;
    
    CGFloat footerTop = UYEV_JS(@"$(editor_footer).position().top;").integerValue;
    CGFloat footerHeight = UYEV_JS(@"$(editor_footer).height();").integerValue;
    CGFloat paddingBottom = footerTop + footerHeight;
    
    CGFloat offsetBottom = caretYOffset + paddingBottom;
    BOOL mustScroll = (caretYOffset < viewport.origin.y || offsetBottom > viewport.origin.y + CGRectGetHeight(viewport));
    if (mustScroll) {
        CGFloat necessaryHeight = viewport.size.height / 2;
        caretYOffset = MIN(caretYOffset, self.webView.scrollView.contentSize.height - necessaryHeight);
        CGRect targetRect = CGRectMake(0.0f,
                                       caretYOffset,
                                       CGRectGetWidth(viewport),
                                       necessaryHeight);
        [self.webView.scrollView scrollRectToVisible:targetRect animated:animated];
    }
}

- (void)handleCallBackURL:(NSString *)url
{
    if ([url hasPrefix:@"debug://"]) {
        NSLog(@"%@", url);
    } else if ([url hasPrefix:@"selection"]) {
        //[self scrollToCaretAnimated:YES];
    } else if ([url hasPrefix:@"contentheight://"]) {
        [self refreshVisibleViewportAndContentSize];
    } else if ([url hasPrefix:@"input://"]) {
        [self scrollToCaretAnimated:NO];
        if ([self.delegate respondsToSelector:@selector(editorViewDidInput:)]) {
            [self.delegate editorViewDidInput:self];
        }
    } else if ([url hasPrefix:@"styles://"]) {
        if ([self.delegate respondsToSelector:@selector(editorView:stylesForCurrentSelection:)]) {
            NSString *styles = [url stringByReplacingOccurrencesOfString:@"styles://" withString:@""];
            [self.delegate editorView:self stylesForCurrentSelection:[styles componentsSeparatedByString:@","]];
        }
    }
}

- (void)focusEditor {
    UYEV_JS(@"uyeditor.focusEditor();");
}

- (void)blurEditor {
    UYEV_JS(@"uyeditor.blurEditor();");
}

#pragma mark - UIWebView Delegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType != UIWebViewNavigationTypeLinkClicked) {
        NSString *url = [[request URL] absoluteString];
        [self handleCallBackURL:url];
        return YES;
    }
    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.javaScriptQueue enumerateObjectsUsingBlock:^(NSString *javaScript, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.webView stringByEvaluatingJavaScriptFromString:javaScript];
    }];
    [self.javaScriptQueue removeAllObjects];
    self.isWebViewLoaded = YES;

    [self refreshVisibleViewportAndContentSize];
    
    if ([self.delegate respondsToSelector:@selector(editorViewDidLoaded:)]) {
        [self.delegate editorViewDidLoaded:self];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([self isFirstResponder]) {
            [self focusEditor];
        }
    });
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.webView.scrollView && [keyPath isEqualToString:@"contentSize"]) {
        NSValue *newValue = change[NSKeyValueChangeNewKey];
        CGSize newSize = [newValue CGSizeValue];
        
        if (newSize.height != self.lastEditorHeight) {
            self.webView.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame), self.lastEditorHeight);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self refreshVisibleViewportAndContentSize];
                [self scrollToCaretAnimated:NO];
            });
        }
    }
}

#pragma mark - run JS

- (void)runJavaScript:(NSString *)javaScript {
    if (self.isWebViewLoaded) {
        [self.webView stringByEvaluatingJavaScriptFromString:javaScript];
    } else {
        [self.javaScriptQueue addObject:javaScript];
    }
}

#pragma mark - propery setter/getter

- (NSString *)addSlashes:(NSString *)html
{
    html = [html stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    html = [html stringByReplacingOccurrencesOfString:@"'"  withString:@"\\'"];

    return html;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    [self runJavaScript:[NSString stringWithFormat:@"uyeditor.setPlaceholder('%@')", _placeholder ?: @""]];
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    [self runJavaScript:[NSString stringWithFormat:@"uyeditor.setEditable(%zd)", _editable]];
}

- (void)setHtml:(NSString *)html {
    if ([html rangeOfString:@"\\s*<p>.*</p>\\s*" options:NSRegularExpressionSearch].location == NSNotFound) {
        html = [NSString stringWithFormat:@"<p>%@</p>", html.length ? html : @"<br>"];
    }
    _html = html;
    [self runJavaScript:[NSString stringWithFormat:@"uyeditor.setHTML('%@')", _html ? [self addSlashes:_html] : @""]];
}

- (BOOL)isEditing {
    return [UYEV_JS(@"uyeditor.hasFocus();") isEqualToString:@"true"];
}

- (NSString *)html {
    return UYEV_JS(@"uyeditor.getHTML()");
}

#pragma mark - FirstResponder

- (BOOL)canBecomeFirstResponder {
    return self.editable;
}

- (BOOL)canResignFirstResponder {
    return _isFirstResponder;
}

- (BOOL)isFirstResponder {
    return _isFirstResponder;
}

- (BOOL)becomeFirstResponder {
    if (self.isWebViewLoaded) {
        [self focusEditor];
    }
    if ([self canBecomeFirstResponder]) {
        _isFirstResponder = YES;
        return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder {
    [self blurEditor];
    if (_isFirstResponder) {
        _isFirstResponder = NO;
        return YES;
    }
    return NO;
}

@end