//
//  UICheckBox.h
//  P2PCamera
//
//  Created by CHENCHAO on 13-11-7.
//  Copyright (c) 2013年 CHENCHAO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICheckBox : UIButton
{
    UIImageView*           boxImageView;
    UILabel*               titleLabel;
}

- (id)initWithFrame:(CGRect)frame withTitle:(NSString *)title;

@end
