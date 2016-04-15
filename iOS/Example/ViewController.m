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
    self.html = @"<img src=\"http://h.hiphotos.baidu.com/zhidao/pic/item/503d269759ee3d6d026568e240166d224f4ade7c.jpg\">\n<img src=\"http://h.hiphotos.baidu.com/zhidao/pic/item/503d269759ee3d6d026568e240166d224f4ade7c.jpg\">\n<img src=\"http://h.hiphotos.baidu.com/zhidao/pic/item/503d269759ee3d6d026568e240166d224f4ade7c.jpg\">\n<img src=\"http://h.hiphotos.baidu.com/zhidao/pic/item/503d269759ee3d6d026568e240166d224f4ade7c.jpg\">\n<img src=\"http://h.hiphotos.baidu.com/zhidao/pic/item/503d269759ee3d6d026568e240166d224f4ade7c.jpg\">";
    
    UIBarButtonItem *next = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(testSubNav)];
    self.navigationItem.rightBarButtonItem = next;
}

- (void)testSubNav {
    [[UYEditorViewController appearance] setFont:[UIFont fontWithName:@"AmericanTypewriter" size:30]];
    [[UYEditorViewController appearance] setToolbarTintColor:[UIColor blueColor]];
    [[UYEditorViewController appearance] setDisableImagePicker:YES];
    
    UYEditorViewController *new = [[UYEditorViewController alloc] init];
    //new.font = [UIFont fontWithName:@"AmericanTypewriter" size:30];
    new.placeholderColor = [[UIColor redColor] colorWithAlphaComponent:.5];
    new.placeholder = @"新的一页 New Page";
    new.textColor = [[UIColor greenColor] colorWithAlphaComponent:1.0];
    [self.navigationController pushViewController:new animated:YES];
    [new startEditing];
    
    NSLog(@"new:%@", new.webView);
}

@end
