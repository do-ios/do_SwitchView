//
//  do_SwitchView_View.h
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "do_SwitchView_IView.h"
#import "do_SwitchView_UIModel.h"
#import "doIUIModuleView.h"

@interface do_SwitchView_UIView : UIControl<do_SwitchView_IView, doIUIModuleView>
//可根据具体实现替换UIView
{
@private
    __weak do_SwitchView_UIModel *_model;
}
@property(nonatomic, strong) UIColor *onTintColor;
@property(nonatomic, strong) UIColor *tintColor;
@property(nonatomic, strong) UIColor *thumbTintColor;
@property (nonatomic, assign)BOOL defaultColors;
@property(nonatomic, strong) UIImage *onImage;
@property(nonatomic, strong) UIImage *offImage;

@end
