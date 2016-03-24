//
//  TableViewController.h
//  xmppTest
//
//  Created by jieaye on 16/3/22.
//  Copyright © 2016年 jieaye. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPManager.h"

@interface TableViewController : UITableViewController<XMPPRosterDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)NSMutableArray *dataArr;


@end
