//
//  ViewController.m
//  UYEditor
//
//  Created by Pan Xiao Ping on 15/8/25.
//  Copyright (c) 2015年 Cimu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"wv:%@", self.webView);
    self.placeholder = @"输入你的内容";
    self.html = @"<img src=\"http://h.hiphotos.baidu.com/zhidao/pic/item/503d269759ee3d6d026568e240166d224f4ade7c.jpg\">";
//    [self becomeFirstResponder];
    
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(testSubNav)];
    self.navigationItem.rightBarButtonItem = next;
    
    self.disableImagePicker = NO;
}

- (void)testSubNav {
    UYEditorViewController *new = [[UYEditorViewController alloc] init];
    new.placeholder = @"新的一页";
    [self.navigationController pushViewController:new animated:YES];
    [new startEditing];
    
    NSLog(@"new:%@", new.webView);
}

@end
