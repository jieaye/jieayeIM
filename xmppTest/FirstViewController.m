//
//  FirstViewController.m
//  xmppTest
//
//  Created by jieaye on 16/3/22.
//  Copyright © 2016年 jieaye. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "TableViewController.h"


@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     
    self.view.backgroundColor = [UIColor whiteColor];
    [[XMPPManager sharedManager].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    self.textName = [[UITextField alloc] initWithFrame:CGRectMake(5, 100, self.view.frame.size.width - 10, 35)];
    [self.textName setBorderStyle:UITextBorderStyleRoundedRect];
    self.textName.text = @"jieaye";
    self.textPass = [[UITextField alloc] initWithFrame:CGRectMake(5, 150, self.view.frame.size.width - 10, 35)];
    [self.textPass setBorderStyle:UITextBorderStyleRoundedRect];
    self.textPass.text = @"jieaye";
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"登录" forState:(UIControlStateNormal)];
    btn.frame = CGRectMake(5, 200, self.view.frame.size.width - 10, 35);
    [self.view addSubview:self.textName];
    [self.view addSubview:self.textPass];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnSelect:) forControlEvents:(UIControlEventTouchUpInside)];
    
    UIButton *btnReg = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btnReg setTitle:@"注册" forState:(UIControlStateNormal)];
    btnReg.frame = CGRectMake(5, 250, self.view.frame.size.width - 10, 35);
    [self.view addSubview:btnReg];
    [btnReg addTarget:self action:@selector(regReg:) forControlEvents:(UIControlEventTouchUpInside)];
}

-(void)btnSelect:(UIButton*)btn{
    [[XMPPManager sharedManager] loginXMPP:self.textName.text passWord:self.textPass.text];
}
-(void)regReg:(UIButton*)sender{
    [self.navigationController pushViewController:[[SecondViewController alloc] init] animated:YES];
}

//登录成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [[XMPPManager sharedManager].xmppStream sendElement:presence];
    NSLog(@"登录成功");
    [self.navigationController pushViewController:[[TableViewController alloc] init] animated:YES];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
