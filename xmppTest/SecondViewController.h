//
//  SecondViewController.h
//  xmppTest
//
//  Created by jieaye on 16/3/22.
//  Copyright © 2016年 jieaye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"
#import "XMPPManager.h"

@interface SecondViewController : UIViewController<XMPPStreamDelegate>

@property(nonatomic,strong)UITextField *textName;
@property(nonatomic,strong)UITextField *textPass;

@end

