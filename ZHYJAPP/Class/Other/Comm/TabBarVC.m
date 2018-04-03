//
//  TabBarVC.m
//  ZHYJAPP
//
//  Created by shuang wu on 16/9/28.
//  Copyright © 2016年 admin. All rights reserved.
//

#import "TabBarVC.h"
#import "ZHYJWebViewController.h"
#import "ContanctVC.h"
#import "MyVC.h"
#import "WorksVC.h"
#import "ChatViewController.h"
#import "UserProfileManager.h"
#import "ConversationListController.h"
#import "ContactListViewController.h"
#import "ChatDemoHelper.h"
#import "RedPacketChatViewController.h"
#import "MESBaseNavigationController.h"


//两次提示的默认间隔
static const CGFloat kDefaultPlaySoundInterval = 3.0;
static NSString *kMessageType = @"MessageType";
static NSString *kConversationChatter = @"ConversationChatter";
static NSString *kGroupName = @"GroupName";


@interface TabBarVC ()
{
    ConversationListController *_chatListVC;
    ContactListViewController *_contactsVC;
}


@property (strong, nonatomic) NSDate *lastPlaySoundDate;
@end

@implementation TabBarVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[UITabBar appearance] setBackgroundColor:[UIColor whiteColor]] ;
    
    [self createChild];
    
    
      //获取未读消息数，此时并没有把self注册为SDK的delegate，读取出的未读数是上次退出程序时的
    //    [self didUnreadMessagesCountChanged];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUntreatedApplyCount) name:@"setupUntreatedApplyCount" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupUnreadMessageCount) name:@"setupUnreadMessageCount" object:nil];
    
    
}


- (void)createChild{
    
    
    /**  邮件 */

    ZHYJWebViewController *statementVC = [[ZHYJWebViewController alloc] init];
    statementVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"邮件" image:[UIImage imageOriginalWithName:@"mail@3x"]selectedImage:[UIImage imageOriginalWithName:@"mailchoose@3x"]];
    MESBaseNavigationController *statementNV = [[MESBaseNavigationController alloc]initWithRootViewController:statementVC];
    
    /**  消息 */
    _chatListVC = [[ConversationListController alloc] init];
    _chatListVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"消息" image:[UIImage imageOriginalWithName:@"chat@3x"] selectedImage:[UIImage imageOriginalWithName:@"chatchoose@3x"]];
    MESBaseNavigationController *newsNav= [[MESBaseNavigationController alloc]initWithRootViewController:_chatListVC];
    
    

    
    /**  通讯录 */
    ContanctVC *contanctVC = [[ContanctVC alloc] init];
    contanctVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"通讯录" image:[UIImage imageOriginalWithName:@"contast@3x"] selectedImage:[UIImage imageOriginalWithName:@"contastchoose@3x"]];
    MESBaseNavigationController *contanctNV=[[MESBaseNavigationController alloc]initWithRootViewController:contanctVC];
    
    /**  应用 */
    WorksVC *workVC = [[WorksVC alloc] init];
    workVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"应用" image:[UIImage imageOriginalWithName:@"work@3x"] selectedImage:[UIImage imageOriginalWithName:@"workchoose@3x"]];
    MESBaseNavigationController *workNV=[[MESBaseNavigationController alloc]initWithRootViewController:workVC];
    
    
    /** 我的 */
    MyVC *settingVC = [[MyVC alloc] init];
    settingVC.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"我" image:[UIImage imageOriginalWithName:@"me@3x"] selectedImage:[UIImage imageOriginalWithName:@"mechoose@3x"]];
    MESBaseNavigationController *mysetNV = [[MESBaseNavigationController alloc]initWithRootViewController:settingVC];

    
    // 消息  邮件  应用  通讯录  我的
    
    self.viewControllers = @[newsNav,statementNV,workNV,contanctNV,mysetNV];

    
    self.selectedIndex = 2;
}

// 统计未读消息数
-(void)setupUnreadMessageCount
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSInteger unreadCount = 0;
    for (EMConversation *conversation in conversations) {
        unreadCount += conversation.unreadMessagesCount;
    }
    if (_chatListVC) {
        if (unreadCount > 0) {
            _chatListVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _chatListVC.tabBarItem.badgeValue = nil;
        }
    }
    
    UIApplication *application = [UIApplication sharedApplication];
    [application setApplicationIconBadgeNumber:unreadCount];
}

- (void)setupUntreatedApplyCount
{
    NSInteger unreadCount = [[[ApplyViewController shareController] dataSource] count];
    if (_contactsVC) {
        if (unreadCount > 0) {
            _contactsVC.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i",(int)unreadCount];
        }else{
            _contactsVC.tabBarItem.badgeValue = nil;
        }
    }
}

- (void)networkChanged:(EMConnectionState)connectionState
{
    _connectionState = connectionState;
    [_chatListVC networkChanged:connectionState];
}

- (void)playSoundAndVibration{
    NSTimeInterval timeInterval = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        //如果距离上次响铃和震动时间太短, 则跳过响铃
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
        return;
    }
    
    //保存最后一次响铃时间
    self.lastPlaySoundDate = [NSDate date];
    
    // 收到消息时，播放音频
    [[EMCDDeviceManager sharedInstance] playNewMessageSound];
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
}

- (void)showNotificationWithMessage:(EMMessage *)message
{
    EMPushOptions *options = [[EMClient sharedClient] pushOptions];
    //发送本地推送
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date]; //触发通知的时间
    
    if (options.displayStyle == EMPushDisplayStyleMessageSummary) {
        EMMessageBody *messageBody = message.body;
        NSString *messageStr = nil;
        switch (messageBody.type) {
            case EMMessageBodyTypeText:
            {
                messageStr = ((EMTextMessageBody *)messageBody).text;
            }
                break;
            case EMMessageBodyTypeImage:
            {
                messageStr = NSLocalizedString(@"message.image", @"Image");
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                messageStr = NSLocalizedString(@"message.location", @"Location");
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                messageStr = NSLocalizedString(@"message.voice", @"Voice");
            }
                break;
            case EMMessageBodyTypeVideo:{
                messageStr = NSLocalizedString(@"message.video", @"Video");
            }
                break;
            default:
                break;
        }
        
        do {
            NSString *title = [[UserProfileManager sharedInstance] getNickNameWithUsername:message.from];
            if (message.chatType == EMChatTypeGroupChat) {
                NSDictionary *ext = message.ext;
                if (ext && ext[kGroupMessageAtList]) {
                    id target = ext[kGroupMessageAtList];
                    if ([target isKindOfClass:[NSString class]]) {
                        if ([kGroupMessageAtAll compare:target options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                            notification.alertBody = [NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"group.atPushTitle", @" @ me in the group")];
                            break;
                        }
                    }
                    else if ([target isKindOfClass:[NSArray class]]) {
                        NSArray *atTargets = (NSArray*)target;
                        if ([atTargets containsObject:[EMClient sharedClient].currentUsername]) {
                            notification.alertBody = [NSString stringWithFormat:@"%@%@", title, NSLocalizedString(@"group.atPushTitle", @" @ me in the group")];
                            break;
                        }
                    }
                }
                NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
                for (EMGroup *group in groupArray) {
                    if ([group.groupId isEqualToString:message.conversationId]) {
                        title = [NSString stringWithFormat:@"%@(%@)", message.from, group.subject];
                        break;
                    }
                }
            }
            else if (message.chatType == EMChatTypeChatRoom)
            {
                NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
                NSMutableDictionary *chatrooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
                NSString *chatroomName = [chatrooms objectForKey:message.conversationId];
                if (chatroomName)
                {
                    title = [NSString stringWithFormat:@"%@(%@)", message.from, chatroomName];
                }
            }
            
            notification.alertBody = [NSString stringWithFormat:@"%@:%@", title, messageStr];
        } while (0);
    }
    else{
        notification.alertBody = NSLocalizedString(@"receiveMessage", @"you have a new message");
    }
    
#warning 去掉注释会显示[本地]开头, 方便在开发中区分是否为本地推送
    //notification.alertBody = [[NSString alloc] initWithFormat:@"[本地]%@", notification.alertBody];
    
    notification.alertAction = NSLocalizedString(@"open", @"Open");
    notification.timeZone = [NSTimeZone defaultTimeZone];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) {
        NSLog(@"skip ringing & vibration %@, %@", [NSDate date], self.lastPlaySoundDate);
    } else {
        notification.soundName = UILocalNotificationDefaultSoundName;
        self.lastPlaySoundDate = [NSDate date];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:[NSNumber numberWithInt:message.chatType] forKey:kMessageType];
    [userInfo setObject:message.conversationId forKey:kConversationChatter];
    notification.userInfo = userInfo;
    
    //发送通知
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
    UIApplication *application = [UIApplication sharedApplication];
        application.applicationIconBadgeNumber += 1;
}

#pragma mark - 自动登录回调

- (void)willAutoReconnect{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *showreconnect = [ud objectForKey:@"identifier_showreconnect_enable"];
    if (showreconnect && [showreconnect boolValue]) {
        [self hideHud];
        [self showHint:NSLocalizedString(@"reconnection.ongoing", @"reconnecting...")];
    }
}

- (void)didAutoReconnectFinishedWithError:(NSError *)error{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSNumber *showreconnect = [ud objectForKey:@"identifier_showreconnect_enable"];
    if (showreconnect && [showreconnect boolValue]) {
        [self hideHud];
        if (error) {
            [self showHint:NSLocalizedString(@"reconnection.fail", @"reconnection failure, later will continue to reconnection")];
        }else{
            [self showHint:NSLocalizedString(@"reconnection.success", @"reconnection successful！")];
        }
    }
}

#pragma mark - public

- (void)jumpToChatList
{
    if ([self.navigationController.topViewController isKindOfClass:[ChatViewController class]]) {
        //        ChatViewController *chatController = (ChatViewController *)self.navigationController.topViewController;
        //        [chatController hideImagePicker];
    }
    else if(_chatListVC)
    {
        [self.navigationController popToViewController:self animated:NO];
        [self setSelectedViewController:_chatListVC];
    }
}

- (EMConversationType)conversationTypeFromMessageType:(EMChatType)type
{
    EMConversationType conversatinType = EMConversationTypeChat;
    switch (type) {
        case EMChatTypeChat:
            conversatinType = EMConversationTypeChat;
            break;
        case EMChatTypeGroupChat:
            conversatinType = EMConversationTypeGroupChat;
            break;
        case EMChatTypeChatRoom:
            conversatinType = EMConversationTypeChatRoom;
            break;
        default:
            break;
    }
    return conversatinType;
}

- (void)didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    if (userInfo)
    {
        if ([self.navigationController.topViewController isKindOfClass:[ChatViewController class]]) {
            //            ChatViewController *chatController = (ChatViewController *)self.navigationController.topViewController;
            //            [chatController hideImagePicker];
        }
        
        NSArray *viewControllers = self.navigationController.viewControllers;
        [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if (obj != self)
            {
                if (![obj isKindOfClass:[ChatViewController class]])
                {
                    [self.navigationController popViewControllerAnimated:NO];
                }
                else
                {
                    
                    NSString *conversationChatter = userInfo[kConversationChatter];
                    if ([conversationChatter isEqualToString:@"call"])
                    {
                        self.callController = [[CallViewController alloc] initWithSession:self.callSession isCaller:NO status:@"call"];
                        self.callController.modalPresentationStyle = UIModalPresentationFullScreen;
                        [self presentViewController:self.callController animated:NO completion:nil];
                        
                    }
                    
                    ChatViewController *chatViewController = (ChatViewController *)obj;
                    if (![chatViewController.conversation.conversationId isEqualToString:conversationChatter])
                    {
                        [self.navigationController popViewControllerAnimated:NO];
                        EMChatType messageType = [userInfo[kMessageType] intValue];
#ifdef REDPACKET_AVALABLE
                        chatViewController = [[RedPacketChatViewController alloc]
#else
                                              chatViewController = [[ChatViewController alloc]
#endif
                                                                    initWithConversationChatter:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
                                              switch (messageType) {
                                                  case EMChatTypeChat:
                                                  {
                                                      NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
                                                      for (EMGroup *group in groupArray) {
                                                          if ([group.groupId isEqualToString:conversationChatter]) {
                                                              chatViewController.title = group.subject;
                                                              break;
                                                          }
                                                      }
                                                  }
                                                      break;
                                                  default:
                                                      chatViewController.title = conversationChatter;
                                                      break;
                                              }
                                              [self.navigationController pushViewController:chatViewController animated:NO];
                                              }
                                              *stop= YES;
                                              }
                                              }
                                              else
                                              {
                                                  ChatViewController *chatViewController = nil;
                                                  NSString *conversationChatter = userInfo[kConversationChatter];
                                                  EMChatType messageType = [userInfo[kMessageType] intValue];
#ifdef REDPACKET_AVALABLE
                                                  chatViewController = [[RedPacketChatViewController alloc]
#else
                                                                        chatViewController = [[ChatViewController alloc]
#endif
                                                                                              initWithConversationChatter:conversationChatter conversationType:[self conversationTypeFromMessageType:messageType]];
                                                                        switch (messageType) {
                                                                            case EMChatTypeGroupChat:
                                                                            {
                                                                                NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
                                                                                for (EMGroup *group in groupArray) {
                                                                                    if ([group.groupId isEqualToString:conversationChatter]) {
                                                                                        chatViewController.title = group.subject;
                                                                                        break;
                                                                                    }
                                                                                }
                                                                            }
                                                                                break;
                                                                            default:
                                                                                chatViewController.title = conversationChatter;
                                                                                break;
                                                                        }
                                                                        [self.navigationController pushViewController:chatViewController animated:NO];
                                                                        }
                                                                        }];
                                              }
                                              else if (_chatListVC)
                                              {
                                                  [self.navigationController popToViewController:self animated:NO];
                                                  [self setSelectedViewController:_chatListVC];
                                              }
                                              }





@end
