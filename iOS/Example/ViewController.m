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
    [self becomeFirstResponder];
}

@end
