//
//  ChatTableViewController.h
//  xmppTest
//
//  Created by jieaye on 16/3/22.
//  Copyright © 2016年 jieaye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPManager.h"
#import "XMPPFramework.h"

@interface ChatTableViewController : UITableViewController<XMPPStreamDelegate,UIAlertViewDelegate,XMPPMessageArchivingStorage>

@property(strong,nonatomic)XMPPJID *friendJID;
@property(strong,nonatomic)NSMutableArray *dataArr;
@property(assign,nonatomic)NSInteger bageNum;

@end
