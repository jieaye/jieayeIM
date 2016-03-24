//
//  SecondViewController.m
//  xmppTest
//
//  Created by jieaye on 16/3/22.
//  Copyright © 2016年 jieaye. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[XMPPManager sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.view.backgroundColor = [UIColor whiteColor];
    self.textName = [[UITextField alloc] initWithFrame:CGRectMake(5, 100, self.view.frame.size.width - 10, 35)];
    [self.textName setBorderStyle:UITextBorderStyleRoundedRect];
    self.textPass = [[UITextField alloc] initWithFrame:CGRectMake(5, 150, self.view.frame.size.width - 10, 35)];
    [self.textPass setBorderStyle:UITextBorderStyleRoundedRect];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"注册" forState:(UIControlStateNormal)];
    btn.frame = CGRectMake(5, 200, self.view.frame.size.width - 10, 35);
    [self.view addSubview:self.textName];
    [self.view addSubview:self.textPass];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnReg) forControlEvents:(UIControlEventTouchUpInside)];
}

-(void)btnReg{
    [[XMPPManager sharedManager] regXMPP:self.textName.text passWord:self.textPass.text];
}

-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
