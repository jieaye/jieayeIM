//
//  XMPPManager.h
//  xmppTest
//
//  Created by jieaye on 16/3/22.
//  Copyright © 2016年 jieaye. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPMessageArchiving.h"



typedef NS_ENUM(NSInteger,ConnToServerPurpose){
    ConnToServerPurposeLogin,
    ConnToServerPurposeRegister
};

@interface XMPPManager : NSObject<XMPPStreamDelegate,XMPPRosterDelegate,UIAlertViewDelegate>

@property(nonatomic,strong)XMPPStream *xmppStream;
@property(nonatomic,strong)NSString *passWord;
@property(nonatomic,assign)ConnToServerPurpose conn;
@property(nonatomic,strong)XMPPRoster *xmppRoster;
@property(nonatomic,strong)XMPPJID *fromJID;
@property(nonatomic,strong)XMPPMessageArchiving *xmppMessageArchiving;
@property(nonatomic,strong)NSManagedObjectContext *context;

+(XMPPManager*)sharedManager;

-(void)loginXMPP:(NSString*)userName passWord:(NSString*)passWord;
-(void)regXMPP:(NSString*)userName passWord:(NSString*)passWord;
@end
