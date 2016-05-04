//
//  UYEditorToolItem.m
//  UYEditor
//
//  Created by Pan Xiao Ping on 15/8/26.
//  Copyright (c) 2015年 Cimu. All rights reserved.
//

#import "UYEditorToolbarItem.h"

@implementation UYEditorToolbarItem

- (void)setToolbarImage:(UIImage *)toolbarImage {
    _toolbarImage = toolbarImage;
    [self _updateToolbarImage];
}

- (void)setToolbarColor:(UIColor *)toolbarColor {
    _toolbarColor = toolbarColor;
    [self _updateToolbarImage];
}

- (void)_updateToolbarImage {
    if (!_button) {
        _button = [[UIButton alloc] init];
        _button.adjustsImageWhenHighlighted = NO;
        self.customView = _button;
    }
    
    UIButton *button = self.customView;
    if (self.actionIdentifer == UYEditorToolbarInsertImage || self.actionIdentifer == UYEditorToolbarCamera || self.actionIdentifer == UYEditorToolbarHideKeyboard) {
        [button setImage:[self blendImage:self.toolbarImage withTintColor:self.toolbarColor] forState:UIControlStateNormal];
    } else {
        [button setImage:[self blendImage:self.toolbarImage withTintColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
        [button setImage:[self blendImage:self.toolbarImage withTintColor:self.toolbarColor] forState:UIControlStateSelected];
    }
}

- (UIImage *)blendImage:(UIImage *)image withTintColor:(UIColor *)tintColor
{
    if (!image) {
        return nil;
    }
    if (!tintColor) {
        return image;
    }
    
    CGBlendMode blendMode = kCGBlendModeDestinationIn;
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [image drawInRect:bounds blendMode:blendMode alpha:1.0f];
    
    if (blendMode != kCGBlendModeDestinationIn) {
        [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    }
    
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return tintedImage;
}
@end
