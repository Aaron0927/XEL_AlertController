//
//  XEL_AlertViewController.m
//  XEL_AlertController
//
//  Created by leijin on 16/12/1.
//  Copyright © 2016年 xel. All rights reserved.
//

#import "XEL_AlertViewController.h"

@interface XEL_AlertViewController ()

@end

@implementation XEL_AlertViewController

@synthesize title;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)xel_addTextFieldWithConfigutationHanler:(void (^)(UITextField *))configurationHandler {
    
}

- (void)xel_addAction:(XEL_AlertAction *)action {
    
}

+ (instancetype)xel_alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(XEL_AlertActionStyle)preferredStyle {
    return [[self alloc] init];
}

@end


@implementation XEL_AlertAction

+ (instancetype)xel_actionWithTitle:(NSString *)title style:(XEL_AlertActionStyle)style handler:(void (^)(XEL_AlertAction *))handler {
    return [[self alloc] init];
}

- (id)copyWithZone:(NSZone *)zone {
    return nil;
}

@end