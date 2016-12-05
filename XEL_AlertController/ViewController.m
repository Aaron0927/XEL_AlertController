//
//  ViewController.m
//  XEL_AlertController
//
//  Created by leijin on 16/12/1.
//  Copyright © 2016年 xel. All rights reserved.
//

#import "ViewController.h"
#import "XEL_AlertView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 100, 50)];
    [button setTitle:@"alert" forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor greenColor]];
    [button addTarget:self action:@selector(alert) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(200, 20, 100, 50)];
    [button1 setTitle:@"alert1" forState:UIControlStateNormal];
    [button1 setBackgroundColor:[UIColor greenColor]];
    [button1 addTarget:self action:@selector(alert1) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button1];
    
}


- (void)alert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"titletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitle当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突." message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
//    [alert addAction:[UIAlertAction actionWithTitle:@"Destructive" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//        
//    }]];
//    
    [alert addAction:[UIAlertAction actionWithTitle:@"sure" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
//    [alert addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//        
//    }]];
    
    
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)alert1 {
    XEL_AlertView *alert = [XEL_AlertView xel_alertControllerWithTitle:@"titletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitletitle当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突.当一个view上面既有UITapGestureRecognizer 又有其他view的点击响应事件的时候,这时候就可能造成冲突." message:@"message" preferredStyle:XEL_AlertControllerStyleActionSheet];
    
    [alert xel_addAction:[XEL_AlertAction xel_actionWithTitle:@"cancel" style:XEL_AlertActionStyleCancel handler:^(XEL_AlertAction *action) {
        
    }]];
    
    [alert xel_addAction:[XEL_AlertAction xel_actionWithTitle:@"sure" style:XEL_AlertActionStyleDefault handler:^(XEL_AlertAction *action) {
        NSLog(@"dosomething");
    }]];
    
    
    [alert showInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
