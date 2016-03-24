//
//  XMPPManager.m
//  xmppTest
//
//  Created by jieaye on 16/3/22.
//  Copyright © 2016年 jieaye. All rights reserved.
//

#import "XMPPManager.h"
#import "XMPPMessageArchivingCoreDataStorage.h"


@implementation XMPPManager

+(XMPPManager*)sharedManager{
    static XMPPManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPManager alloc] init];
    });
    return manager;
}

-(instancetype)init{
    if (self=[super init]) {
        self.xmppStream = [[XMPPStream alloc] init];
        self.xmppStream.hostName = kHostName;
        self.xmppStream.hostPort = kHostPort;
        [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        XMPPRosterCoreDataStorage *coreData = [XMPPRosterCoreDataStorage sharedInstance];
        self.xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:coreData dispatchQueue:dispatch_get_main_queue()];
        [self.xmppRoster activate:self.xmppStream];
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        XMPPMessageArchivingCoreDataStorage *messageData = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        self.xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:messageData dispatchQueue:dispatch_get_main_queue()];
        [self.xmppMessageArchiving activate:self.xmppStream];
        
        self.context = [messageData mainThreadManagedObjectContext];
    }
    return self;
}

//登录
-(void)loginXMPP:(NSString*)userName passWord:(NSString*)passWord{
    self.conn = ConnToServerPurposeLogin;
    self.passWord = passWord;
    [self connectToServerWithuserName:userName];
}

//注册
-(void)regXMPP:(NSString*)userName passWord:(NSString*)passWord{
    self.conn = ConnToServerPurposeRegister;
    self.passWord = passWord;
    [self connectToServerWithuserName:userName];
}

//连接服务器
-(void)connectToServerWithuserName:(NSString*)userName{
    XMPPJID *jid = [XMPPJID jidWithUser:userName domain:kDmin resource:kResource];
    self.xmppStream.myJID = jid;
    if ([self.xmppStream isConnected] || [self.xmppStream isConnecting]) {
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
        [self.xmppStream sendElement:presence];
//        断开连接
        [self.xmppStream disconnect];
    }
    NSError *error = NULL;
    [self.xmppStream connectWithTimeout:-1 error:&error];
    if (error != NULL) {
        NSLog(@"连接失败！");
    }
}

//连接超时
-(void)xmppStreamConnectDidTimeout:(XMPPStream*)sender{
     NSLog(@"timeout");
}

//连接成功
-(void)xmppStreamDidConnect:(XMPPStream*)sender{
    NSLog(@"连接成功！");
    if (self.conn == ConnToServerPurposeLogin) {
    [self.xmppStream authenticateWithPassword:self.passWord error:nil];
    }else{
    [self.xmppStream registerWithPassword:self.passWord error:nil];
    }
    
    

}




- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
      NSLog(@"验证失败！");
}

- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
     NSLog(@"reg失败！");
}


//获取好友


-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence{
    self.fromJID = presence.from;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"好友请求" message:presence.from.user delegate:self cancelButtonTitle:@"拒绝" otherButtonTitles:@"同意", nil];
    [alert show];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
//            拒绝
            [self.xmppRoster rejectPresenceSubscriptionRequestFrom:self.fromJID];
            break;
        case 1:
//            同意
            [self.xmppRoster acceptPresenceSubscriptionRequestFrom:self.fromJID andAddToRoster:YES];
            break;
        default:
            break;
    }
}








@end
