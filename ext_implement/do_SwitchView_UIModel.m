//
//  do_SwitchView_Model.m
//  DoExt_UI
//
//  Created by @userName on @time.
//  Copyright (c) 2015年 DoExt. All rights reserved.
//

#import "do_SwitchView_UIModel.h"
#import "doProperty.h"

@implementation do_SwitchView_UIModel

#pragma mark - 注册属性（--属性定义--）
-(void)OnInit
{
    [super OnInit];    
    //属性声明
	[self RegistProperty:[[doProperty alloc]init:@"checke                                                                                                                                                                                                                                                               d" :Bool :@"false" :NO]];
    [self RegistProperty:[[doProperty alloc]init:@"shape" :String :@"circle":NO]];
    [self RegistProperty:[[doProperty alloc]init:@"colors" :String :@"00FF00,888888,FFFFFF":NO]];
}
@end

