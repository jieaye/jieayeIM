//
//  ChatTableViewController.m
//  xmppTest
//
//  Created by jieaye on 16/3/22.
//  Copyright © 2016年 jieaye. All rights reserved.
//

#import "ChatTableViewController.h"
#import "XMPPMessageArchiving_Message_CoreDataObject.h"
typedef NS_ENUM(NSInteger,MessageTYpe){
    MessageTYpeSender,
    MessageTYpeReceive
};
@interface ChatTableViewController ()

@end

@implementation ChatTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBackgroundTaskIdentifier newTaskId = UIBackgroundTaskInvalid;
    newTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:NULL];
    self.dataArr = [[NSMutableArray alloc] init];
    [[XMPPManager sharedManager].xmppStream addDelegate:self delegateQueue:(dispatch_get_main_queue())];
    [[XMPPManager sharedManager].xmppMessageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self reloadMessages];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemEdit) target:self action:@selector(snderMess:)];
}

-(IBAction)snderMess:(id)sender{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"输入框" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex) {
        UITextField *text = [alertView textFieldAtIndex:0];
        XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
        [message addBody:text.text];
        [[XMPPManager sharedManager].xmppStream sendElement:message];
    }
}

//发送成功
-(void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message{
//    [self reloadMessages];
    [self addMessage:message type:(MessageTYpeSender)];
}

//- (void)viewWillDisappear:(BOOL)animated{
//    self.bageNum = 0;
//    //本地推送
//    UILocalNotification*notification = [[UILocalNotification alloc]init];
//    notification.applicationIconBadgeNumber = 0;
//}

//接收消息成功
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
//    [self reloadMessages];
//    NSLog(@"接收消息成功 == %@",message.body);
    dispatch_async(dispatch_get_main_queue(), ^{
        //本地推送
        UILocalNotification*notification = [[UILocalNotification alloc]init];
        NSDate * pushDate = [NSDate dateWithTimeIntervalSinceNow:10];
        if (notification) {
            notification.fireDate = pushDate;
            notification.timeZone = [NSTimeZone defaultTimeZone];
            notification.repeatInterval = kCFCalendarUnitDay;
            notification.soundName = UILocalNotificationDefaultSoundName;
            notification.alertBody = message.body;
            notification.applicationIconBadgeNumber = ++self.bageNum;
            //            NSDictionary*info = [NSDictionary dictionaryWithObject:@"test" forKey:@"name"];
            //            notification.userInfo = info;
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            
        }
    });
    [self addMessage:message type:(MessageTYpeReceive)];
}

-(void)addMessage:(XMPPMessage *)message type:(MessageTYpe)type{
//    NSLog(@"%@", message.fromStr);
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:[XMPPManager sharedManager].context];
    XMPPMessageArchiving_Message_CoreDataObject *dataObj = [[XMPPMessageArchiving_Message_CoreDataObject alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:[XMPPManager sharedManager].context];
    [dataObj message];
    dataObj.message = message ;
    if (type == MessageTYpeSender) {
        dataObj.bareJidStr = [XMPPManager sharedManager].xmppStream.myJID.bare;
    }else{
        dataObj.bareJidStr = message.fromStr;
    }
    
    dataObj.body = message.body;
    [self.dataArr addObject:dataObj];
    [self.tableView reloadData];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArr.count -1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
}


-(void)reloadMessages{
    NSManagedObjectContext *context = [XMPPManager sharedManager].context;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:context];
    [request setEntity:entityDescription];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ and streamBareJidStr == %@",self.friendJID.bare,[XMPPManager sharedManager].xmppStream.myJID.bare];
    NSSortDescriptor *sortDescriptor  = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    [request setPredicate:predicate];
    [request setSortDescriptors:@[sortDescriptor]];
    NSArray *fetchdArr = [context executeFetchRequest:request error:nil];
    if (fetchdArr.count > 0) {
        if (self.dataArr.count > 0) {
            [self.dataArr removeAllObjects];
        }
        [self.dataArr addObjectsFromArray:fetchdArr];
        [self.tableView reloadData];
    }
    
    
    if (self.dataArr.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataArr.count -1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:(UITableViewScrollPositionBottom) animated:YES];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.dataArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifierMess"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"reuseIdentifierMess"];
    }
    
    XMPPMessageArchiving_Message_CoreDataObject *message = [self.dataArr objectAtIndex:indexPath.row];
    cell.textLabel.text = message.body;
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
