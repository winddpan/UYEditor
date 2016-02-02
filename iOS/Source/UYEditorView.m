//
//  UYEditorView.m
//  UYEditor
//
//  Created by Pan Xiao Ping on 15/8/25.
//  Copyright (c) 2015年 Cimu. All rights reserved.
//

#import "UYEditorView.h"

#define UYEV_RUN_JS(format, ...)   [self.webView stringByEvaluatingJavaScriptFromString:([NSString stringWithFormat:format, ##__VA_ARGS__])]

@interface UYEditorView ()
@property (strong, nonatomic) NSMutableArray *javaScriptQueue;
@property (nonatomic) BOOL isWebViewLoaded;
@property (nonatomic) CGFloat lastEditorHeight;
@property (nonatomic) BOOL isAdjustingContentSize;
@property (strong, readwrite)  UIWebView *webView;
@property (nonatomic) BOOL isScrollIndicatorFlashing;
@property (nonatomic) BOOL shouldFlashScrollIndicator;
@end

@implementation UYEditorView

#pragma mark - Lifecycle

- (void)dealloc {
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize"];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
    CGFloat footerTop = UYEV_RUN_JS(@"$(editor_footer).position().top;").integerValue;
    CGFloat footerHeight = UYEV_RUN_JS(@"$(editor_footer).height();").integerValue;
    self.lastEditorHeight = footerTop + footerHeight;
    
    UIScrollView *scrollView = self.webView.scrollView;
    if (scrollView.contentSize.height != self.lastEditorHeight) {
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.webView.frame),  self.lastEditorHeight);
        
        if (!self.isScrollIndicatorFlashing && self.shouldFlashScrollIndicator) {
            self.isScrollIndicatorFlashing = YES;
            [self.webView.scrollView flashScrollIndicators];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isScrollIndicatorFlashing = NO;
            });
        }
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
- (void)scrollToCaret
{
    CGRect viewport = [self viewport];
    CGFloat fontSize = UYEV_RUN_JS(@"$('#editor_content').css('font-size')").doubleValue;
    CGFloat caretBottomOffset = UYEV_RUN_JS(@"uyeditor.getYCaretBottom();").integerValue;
    
    BOOL mustScroll = (caretBottomOffset < viewport.origin.y || caretBottomOffset > viewport.origin.y + CGRectGetHeight(viewport));
    if (mustScroll) {
        CGFloat necessaryHeight = viewport.size.height;
        CGFloat offsetY = caretBottomOffset -  necessaryHeight + ceil(fontSize/2.0 + 1);
        
        UIScrollView* scrollView = self.webView.scrollView;
        CGSize contentSize = scrollView.contentSize;
        if (offsetY > contentSize.height - necessaryHeight) {
            offsetY = contentSize.height - necessaryHeight;
        }
        offsetY = MAX(0, offsetY);
        
        CGRect targetRect = CGRectMake(0.0f,
                                       offsetY,
                                       CGRectGetWidth(viewport),
                                       necessaryHeight);
        [self.webView.scrollView scrollRectToVisible:targetRect animated:NO];
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
        self.shouldFlashScrollIndicator = YES;
        [self _adjustContentSizeAndMoveToCaret];
        self.shouldFlashScrollIndicator = NO;
        
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
    self.isWebViewLoaded = YES;
    [self.javaScriptQueue enumerateObjectsUsingBlock:^(NSString *javaScript, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.webView stringByEvaluatingJavaScriptFromString:javaScript];
    }];
    [self.javaScriptQueue removeAllObjects];
    
    [self refreshVisibleViewportAndContentSize];
    
    if ([self.delegate respondsToSelector:@selector(editorViewDidLoaded:)]) {
        [self.delegate editorViewDidLoaded:self];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.webView.scrollView && [keyPath isEqualToString:@"contentSize"]) {
        NSValue *newValue = change[NSKeyValueChangeNewKey];
        CGSize newSize = [newValue CGSizeValue];
        
        if (!self.isAdjustingContentSize) {
            [self _adjustContentSizeAndMoveToCaret];
        }
    }
}

- (void)_adjustContentSizeAndMoveToCaret {
    self.isAdjustingContentSize = YES;
    [self refreshVisibleViewportAndContentSize];
    [self scrollToCaret];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isAdjustingContentSize = NO;
    });
}

#pragma mark - run JS

- (void)runJavaScriptWhileLoaded:(NSString *)javaScript {
    if (self.isWebViewLoaded) {
        [self.webView stringByEvaluatingJavaScriptFromString:javaScript];
    } else {
        [self.javaScriptQueue addObject:javaScript];
    }
}

@end
