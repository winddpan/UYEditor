//
//  UYEditorViewController.m
//  UYEditor
//
//  Created by Pan Xiao Ping on 15/8/25.
//  Copyright © 2015年 Cimu. All rights reserved.
//

#import "UYEditorViewController.h"
#import "UYEditorView.h"
#import "UYEditorToolbar.h"
#import "UYEditorToolbarItem.h"

#define UYEVC_JS(format, ...)   [self.editorView.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:format, ##__VA_ARGS__]]
static const CGFloat kToolbarHeight = 44.0;

@interface UYEditorViewController () <UYEditorViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (assign, nonatomic)  BOOL didWebViewLoaded;
@property (strong, nonatomic)  UYEditorView *editorView;
@property (strong, nonatomic)  UYEditorToolbar *toolbar;
@property (strong, nonatomic)  NSDictionary *commandMap;
@property (strong, nonatomic)  NSString *rawHTML;

@property (assign, nonatomic)  BOOL isDismissing;
@property (assign, nonatomic)  BOOL didAppear;
@end

@implementation UYEditorViewController
@synthesize html = _html, placeholder = _placeholder, editing = _editing;

- (void)viewWillDisappear:(BOOL)animated
{
    self.isDismissing = YES;
    self.didAppear = NO;
    _editing = [self hasFocus];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    self.isDismissing = NO;
    self.didAppear = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.didAppear = YES;
    [self tryFocusEditor];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _commandMap = @{// Javascript: document.execCommand(action, ...)
                    @(UYEditorToolbarBold) : @"bold",
                    @(UYEditorToolbarItalic) : @"italic",
                    @(UYEditorToolbarSubscript) : @"subscript",
                    @(UYEditorToolbarSuperscript) : @"superscript",
                    @(UYEditorToolbarStrikeThrough) : @"strikeThrough",
                    @(UYEditorToolbarUnderline) : @"underline",
                    @(UYEditorToolbarUnorderedList) : @"insertUnorderedList",
                    @(UYEditorToolbarOrderedList) : @"insertOrderedList",
                    // Selector: [self action]
                    @(UYEditorToolbarInsertImage) : @"insertImage",
                    @(UYEditorToolbarCamera) : @"insertCamearImage",
                    @(UYEditorToolbarHideKeyboard) : @"stopEditing",
                    };
    
    self.editable = YES;
    self.editorView.frame = self.view.bounds;
    self.editorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.editorView.delegate = self;
    [self.view addSubview:self.editorView];
    
    [self.toolbar.items enumerateObjectsUsingBlock:^(UYEditorToolbarItem *item, NSUInteger idx, BOOL *stop) {
        [item setTarget:self];
        [item setAction:@selector(triggleToolbarItemAction:)];
    }];
    self.editorView.webView.customInputAccessoryView = self.toolbar;
}

- (UYEditorView *)editorView {
    if (!_editorView) {
        _editorView = [[UYEditorView alloc] init];
    }
    return _editorView;
}

- (UYEditorToolbar *)toolbar {
    if (!_toolbar) {
        _toolbar = [[UYEditorToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), kToolbarHeight)];
    }
    return _toolbar;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)triggleToolbarItemAction:(UYEditorToolbarItem *)item {
    UYEditorToolbarItemIdentifer action = item.actionIdentifer;
    NSString *commond = [_commandMap objectForKey:@(action)];
    if ([self respondsToSelector:NSSelectorFromString(commond)]) {
        [self performSelector:NSSelectorFromString(commond)];
    } else {
        UYEVC_JS(@"uyeditor.command('%@')", commond);
    }
}
#pragma clang diagnostic pop

#pragma mark - javascript bridge

- (void)insertImage:(NSString *)url alt:(NSString *)alt {
    UYEVC_JS(@"uyeditor.insertImage(\"%@\", \"%@\")", url, alt);
}

- (BOOL)isPrepareForInsert {
    return UYEVC_JS(@"uyeditor.currentSelection").length > 0;
}

- (void)prepareForInsert {
    UYEVC_JS(@"uyeditor.backuprange()");
}

- (void)finishedInsert {
    UYEVC_JS(@"uyeditor.restorerange()");
}

#pragma mark - public funcs

- (void)runJavaScriptWhileLoaded:(NSString *)javaScript {
    [self.editorView runJavaScriptWhileLoaded:javaScript];
}

- (UIWebView *)webView {
    return self.editorView.webView;
}

- (BOOL)isHTMLUpdated {
    return ![self.rawHTML isEqualToString:self.html];
}

#pragma mark - propery setter/getter

- (NSString *)_addSlashes:(NSString *)html
{
    html = [html stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    html = [html stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    html = [html stringByReplacingOccurrencesOfString:@"\r"  withString:@"\\r"];
    html = [html stringByReplacingOccurrencesOfString:@"\n"  withString:@"\\n"];
    html = [html stringByReplacingOccurrencesOfString:@"'"  withString:@"\\'"];
    
    return html;
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = [placeholder copy];
    [self runJavaScriptWhileLoaded:[NSString stringWithFormat:@"uyeditor.setPlaceholder('%@')", _placeholder ?: @""]];
}

- (void)setEditable:(BOOL)editable {
    _editable = editable;
    [self runJavaScriptWhileLoaded:[NSString stringWithFormat:@"uyeditor.setEditable(%zd)", _editable]];
}

- (void)setHtml:(NSString *)html {
    if ([html rangeOfString:@"\\s*<p>.*</p>\\s*" options:NSRegularExpressionSearch].location == NSNotFound) {
        html = [NSString stringWithFormat:@"<p>%@</p>", html.length ? html : @"<br>"];
    }
    _html = [html copy];
    [self runJavaScriptWhileLoaded:[NSString stringWithFormat:@"uyeditor.setHTML('%@')", _html ? [self _addSlashes:_html] : @""]];
    
    if (self.didWebViewLoaded) {
        self.rawHTML = self.html;
    }
}

- (NSString *)html {
    return UYEVC_JS(@"uyeditor.getHTML()");
}

- (BOOL)hasFocus {
    return [UYEVC_JS(@"uyeditor.hasFocus();") isEqualToString:@"true"];
}

- (void)tryFocusEditor {
    if (self.editing && self.didWebViewLoaded && self.didAppear) {
        [self runJavaScriptWhileLoaded:@"uyeditor.focusEditor();"];
        [self.editorView scrollToCaret];
    }
}

- (void)startEditing {
    _editing = YES;
    [self tryFocusEditor];
}

- (void)stopEditing {
    _editing = NO;
    
    if (self.didWebViewLoaded && [self hasFocus]) {
        [self runJavaScriptWhileLoaded:@"uyeditor.blurEditor();"];
    }
}

- (void)setDisableImagePicker:(BOOL)disableImagePicker {
    _disableImagePicker = disableImagePicker;
    
    // ToolbarItem会重新生成，需要重新指定target selector
    self.toolbar.disableImagePicker = disableImagePicker;
    [self.toolbar.items enumerateObjectsUsingBlock:^(UYEditorToolbarItem *item, NSUInteger idx, BOOL *stop) {
        [item setTarget:self];
        [item setAction:@selector(triggleToolbarItemAction:)];
    }];
}

#pragma mark - ToolbarItem Actions

- (void)insertImage {
    [self prepareForInsert];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.view.backgroundColor = [UIColor whiteColor];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)insertCamearImage {
    [self prepareForInsert];
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.view.backgroundColor = [UIColor whiteColor];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    picker.allowsEditing = NO;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - ImagePicker delegate

- (void)addImageAssetToContent:(UIImage *)image
{
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    NSString *imageID = [[NSUUID UUID] UUIDString];
    NSString *path = [[NSTemporaryDirectory() stringByAppendingPathComponent:imageID] stringByAppendingString:@".jpg"];
    [data writeToFile:path atomically:YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self insertImage:[[NSURL fileURLWithPath:path] absoluteString] alt:@""];
    });
}

- (void)_dismissImagePicker:(UIImagePickerController *)picker withCompletion:(void (^)(void))completion {
    [picker dismissViewControllerAnimated:YES completion:completion];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController isKindOfClass:[UIImagePickerController class]]) {
        [viewController prefersStatusBarHidden];
        [viewController setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self _dismissImagePicker:picker withCompletion:^{
        [self finishedInsert];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage] ? : [info objectForKey:UIImagePickerControllerOriginalImage];
    [self addImageAssetToContent:image];
    [self _dismissImagePicker:picker withCompletion:nil];
}

#pragma mark -  editorView delegate

- (void)editorView:(UYEditorView *)editorView stylesForCurrentSelection:(NSArray *)styles {
    [self.toolbar.items enumerateObjectsUsingBlock:^(UYEditorToolbarItem *eItem, NSUInteger idx, BOOL *stop) {
        eItem.selected = NO;
    }];
    [styles enumerateObjectsUsingBlock:^(NSString *style, NSUInteger idx, BOOL *stop) {
        UYEditorToolbarItem *item = [self toolbarItemForStyle:style];
        item.selected = YES;
    }];
}

- (void)editorViewDidLoaded:(UYEditorView *)editorView {
    self.didWebViewLoaded = YES;
    self.rawHTML = self.html;
    [self tryFocusEditor];
    
    if ([self.delegate respondsToSelector:@selector(editorViewControllerDidLoaded:)]) {
        [self.delegate editorViewControllerDidLoaded:self];
    }
}

- (void)editorViewDidInput:(UYEditorView *)editorView {
    if ([self.delegate respondsToSelector:@selector(editorViewControllerDidInput:)]) {
        [self.delegate editorViewControllerDidInput:self];
    }
}

#pragma mark - Toolbar delegate

- (UYEditorToolbarItem *)toolbarItemForStyle:(NSString *)style {
    __block UYEditorToolbarItemIdentifer itemAction;
    __block UYEditorToolbarItem *item;
    [_commandMap enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *value, BOOL *stop) {
        if ([value isEqualToString:style]) {
            itemAction = [key integerValue];
            *stop = YES;
        }
    }];
    [self.toolbar.items enumerateObjectsUsingBlock:^(UYEditorToolbarItem *eItem, NSUInteger idx, BOOL *stop) {
        if (eItem.actionIdentifer == itemAction) {
            item = eItem;
            *stop = YES;
        }
    }];
    return item;
}

#pragma mark - FirstResponder

- (BOOL)canBecomeFirstResponder {
    return !self.isDismissing && _editing;
}

- (BOOL)canResignFirstResponder {
    return YES;
}

- (BOOL)isFirstResponder {
    return [self hasFocus];
}

- (BOOL)becomeFirstResponder {
    if (_editing) {
        [self startEditing];
        return YES;
    }
    return NO;
}

- (BOOL)resignFirstResponder {
    if (_editing) {
        [self stopEditing];
    }
    return YES;
}

@end
