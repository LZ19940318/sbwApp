/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "ConversationListController.h"

#import "ChatViewController.h"
#import "EMSearchBar.h"
#import "EMSearchDisplayController.h"
#import "RobotManager.h"
#import "RobotChatViewController.h"
#import "UserProfileManager.h"
#import "RealtimeSearchUtil.h"
#import "RedPacketChatViewController.h"
#import "ChatDemoHelper.h"
#import "NetworkManager.h"
#import "AFNetworking.h"
#import "DataManager.h"
#import "IMessageModel.h"
#import "ChineseString.h"
@implementation EMConversation (search)

//根据用户昵称,环信机器人名称,群名称进行搜索
- (NSString*)showName
{
    if (self.type == EMConversationTypeChat) {
        if ([[RobotManager sharedInstance] isRobotWithUsername:self.conversationId]) {
            return [[RobotManager sharedInstance] getRobotNickWithUsername:self.conversationId];
        }
        return [[UserProfileManager sharedInstance] getNickNameWithUsername:self.conversationId];
    } else if (self.type == EMConversationTypeGroupChat) {
        if ([self.ext objectForKey:@"subject"] || [self.ext objectForKey:@"isPublic"]) {
            return [self.ext objectForKey:@"subject"];
        }
    }
    return self.conversationId;
}

@end

@interface ConversationListController ()<EaseConversationListViewControllerDelegate, EaseConversationListViewControllerDataSource,UISearchDisplayDelegate, UISearchBarDelegate,EMChatManagerDelegate>
{
    NSMutableArray *dataS;
    NSString *nickName;
    NSString *nickImage;
    NSData *dataFromBase64Str;
    
}
@property (nonatomic, strong) UIView *networkStateView;
@property (nonatomic, strong) EMSearchBar           *searchBar;

@property (strong, nonatomic) EMSearchDisplayController *searchController;

@end

@implementation ConversationListController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.title = @"会话";
    //自定义标题视图
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0, 200, 44)];
    titleLabel.font = [UIFont boldSystemFontOfSize:18];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.text = @"消息";
    self.navigationItem.titleView = titleLabel;
    // Do any additional setup after loading the view.
    self.showRefreshHeader = YES;
    self.delegate = self;
    self.dataSource = self;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [self.view addSubview:self.searchBar];
    
    [self networkStateView];
    
    
    [self searchController];
    
   // NSLog(@"rr9999%@", [[DataManager sharedDataManager] IMUserlist]);

//    if ([[DataManager sharedDataManager] IMUserlistSort].count == 0) {
//        
//          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
//            [self sort];
//          });
//        
//        
//       
//    }else{
//        
//           if ([[DataManager sharedDataManager] IMUserlist].count > 0) {
//               
//               [self.tableView reloadData];
//               //        [SVProgressHUD dismiss];
//               [self refreshDataSource];
//               
//           }else{
//               
//               
//               [self createData];
//               [self sort];
//              
//               
//           }
//        [self.tableView reloadData];
//
//
//    }
//    

    


    
    //解析用的数组
    dataS = [NSMutableArray array];
//    self.tableView.frame = CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - self.searchBar.frame.size.height + 64);
    self.tableView.frame = CGRectMake(0, self.searchBar.frame.size.height, self.view.frame.size.width,MainHeight - self.searchBar.frame.size.height );
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //获取所有会话消息
//        NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
//        EMConversation * conversation = [[EMClient sharedClient].chatManager getConversation:@"2becbe024720abfb4825809f003c661f" type:EMConversationTypeChat createIfNotExist:YES];
//        NSLog(@"convesation == %@", conversation);
//    
//        [conversation loadMessagesStartFromId:nil count:99 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessage, EMError *aError){
//    
//            for (EMMessage *message in aMessage) {
//                EMMessageBody *msgBody = message.body;
//                EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
//                NSString *txt = textBody.text;
//                NSLog(@"普通文本消息==%@", txt);
//                NSString *sss = [txt stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                NSLog(@"uuuu%@", sss);
//                // cmd消息中的扩展属性
//                NSDictionary *ext = message.ext;
//                NSLog(@"cmd消息中的扩展属性是 -- %@",ext);
//            }
//        }];
    
    //        [self.conversation loadMessagesStartFromId:messageId count:(int)count searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
    
   
    
}


- (void)sort{
    
    [SVProgressHUD showProgress:3.0];
    
    NSArray *sortArrayData = [[DataManager sharedDataManager] IMUserlist];
    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithCapacity:sortArrayData.count];
    NSMutableArray *indexArray = [[NSMutableArray alloc]init];
    NSMutableArray *letterResultArr = [[NSMutableArray alloc]init];
    NSMutableArray *copyLetter = [[NSMutableArray alloc]init];
    for (int i = 0; i < sortArrayData.count; i++) {
        
        NSDictionary *dic = sortArrayData[i];
        [tempArray addObject:dic[@"cnName"]];
    }

    indexArray = [ChineseString IndexArray:tempArray];
    letterResultArr = [ChineseString LetterSortArray:tempArray];
    
    for (int i = 0; i < letterResultArr.count; i++) {
        NSMutableArray *array1 = letterResultArr[i];
        NSMutableArray *array2 = [NSMutableArray array];
       
        for (int j = 0; j< array1.count; j++) {
            for (int k = 0; k < sortArrayData.count; k++) {
                NSDictionary *dic = sortArrayData[k];
                if ([dic[@"cnName"] isEqualToString:array1[j]]) {
                    array2[j] = dic ;
                }
               
            }
            
        }
       
        copyLetter[i]=array2;
    }
    [[DataManager sharedDataManager] saveUserMessageListTitle:indexArray] ;
    [[DataManager sharedDataManager] saveUserMessageListSort:copyLetter];
    
    
    [SVProgressHUD dismiss];
    [self.tableView reloadData];
    //        [SVProgressHUD dismiss];
    [self refreshDataSource];
}

//更改状态栏字体为白色  (默认为黑色)
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}



    // 消息监听
- (void)didReceiveMessages:(NSArray *)aMessages
{
    [self refreshDataSource];
    [self refresh];
    
}

- (void)viewWillAppear:(BOOL)animated
{//出现这个页面显示tabbar
    [super viewWillAppear:animated];
    self.hidesBottomBarWhenPushed=NO;
    self.tabBarController.tabBar.hidden = NO;

    [self refreshDataSource];
    [self refresh];
    
   /*
    if ([[DataManager sharedDataManager] IMUserlistSort].count == 0) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
             [self sort];
            
        });
        
        
        
    }else{
        
        if ([[DataManager sharedDataManager] IMUserlist].count > 0) {
            
            [self.tableView reloadData];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [self sort];
            });

            //        [SVProgressHUD dismiss];
            [self refreshDataSource];
            
        }else{
            
            
            //[self createData];
            [self sort];
            
            
        }
        [self.tableView reloadData];
        
        
    }*/

    [self.tableView reloadData];

}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)removeEmptyConversationsFromDB
{
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    NSMutableArray *needRemoveConversations = [NSMutableArray array];
    for (EMConversation *conversation in conversations) {
        if (!conversation.latestMessage || (conversation.type == EMConversationTypeChatRoom )) {
            if (!needRemoveConversations) {
                needRemoveConversations = [[NSMutableArray alloc] initWithCapacity:0];
            }
            
            [needRemoveConversations addObject:conversation];
        }
    }
    
    if (needRemoveConversations && needRemoveConversations.count >= 1) {
        [[EMClient sharedClient].chatManager deleteConversations:needRemoveConversations isDeleteMessages:YES completion:nil];
    }
//    [self remove];

    [self.tableView reloadData];

}

#pragma mark - getter
- (UIView *)networkStateView
{
    if (_networkStateView == nil) {
        _networkStateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 44)];
        _networkStateView.backgroundColor = [UIColor colorWithRed:255 / 255.0 green:199 / 255.0 blue:199 / 255.0 alpha:0.5];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, (_networkStateView.frame.size.height - 20) / 2, 20, 20)];
        imageView.image = [UIImage imageNamed:@"messageSendFail"];
        [_networkStateView addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView.frame) + 5, 0, _networkStateView.frame.size.width - (CGRectGetMaxX(imageView.frame) + 15), _networkStateView.frame.size.height)];
        label.font = [UIFont systemFontOfSize:15.0];
        label.textColor = [UIColor grayColor];
        label.backgroundColor = [UIColor clearColor];
        label.text = NSLocalizedString(@"network.disconnection", @"Network disconnection");
        [_networkStateView addSubview:label];
    }
    
    return _networkStateView;
}

- (UISearchBar *)searchBar
{
    if (!_searchBar) {
        _searchBar = [[EMSearchBar alloc] initWithFrame: CGRectMake(0, 0, self.view.frame.size.width, 44)];
        _searchBar.delegate = self;
        _searchBar.placeholder = NSLocalizedString(@"search", @"Search");
        _searchBar.backgroundColor = [UIColor colorWithRed:0.747 green:0.756 blue:0.751 alpha:1.000];
    }
    
    return _searchBar;
}

- (EMSearchDisplayController *)searchController
{
    if (_searchController == nil) {
        
        _searchController = [[EMSearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
        _searchController.delegate = self;
        _searchController.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _searchController.searchResultsTableView.tableFooterView = [[UIView alloc] init];
        
            __weak ConversationListController *weakSelf = self;
        
        // 设置搜索框的cell的内容
        [_searchController setCellForRowAtIndexPathCompletion:^UITableViewCell *(UITableView *tableView, NSIndexPath *indexPath) {
            NSString *CellIdentifier = [EaseConversationCell cellIdentifierWithModel:nil];
            EaseConversationCell *cell = (EaseConversationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            // Configure the cell...
            if (cell == nil) {
                cell = [[EaseConversationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            id<IConversationModel> model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            cell.model = model;
            
            cell.detailLabel.attributedText = [weakSelf conversationListViewController:weakSelf latestMessageTitleForConversationModel:model];
            cell.timeLabel.text = [weakSelf conversationListViewController:weakSelf latestMessageTimeForConversationModel:model];
            return cell;
        }];
        
        
        // 设置搜索框的cell的高
        [_searchController setHeightForRowAtIndexPathCompletion:^CGFloat(UITableView *tableView, NSIndexPath *indexPath) {
            return [EaseConversationCell cellHeightWithModel:nil];
        }];
        
        
        // 选择搜索框的内容
        [_searchController setDidSelectRowAtIndexPathCompletion:^(UITableView *tableView, NSIndexPath *indexPath) {
            
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [weakSelf.searchController.searchBar endEditing:YES];
            id<IConversationModel> model = [weakSelf.searchController.resultsSource objectAtIndex:indexPath.row];
            
            EMConversation *conversation = model.conversation;
            ChatViewController *chatController;
            if ([[RobotManager sharedInstance] isRobotWithUsername:conversation.conversationId]) {
                chatController = [[RobotChatViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
                chatController.title = [[RobotManager sharedInstance] getRobotNickWithUsername:conversation.conversationId];
            }else {
#ifdef REDPACKET_AVALABLE
                chatController = [[RedPacketChatViewController alloc]
#else
                                  chatController = [[ChatViewController alloc]
#endif
                                                    initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
                                  chatController.title = [conversation showName];
                                  }
                                  [weakSelf.navigationController pushViewController:chatController animated:YES];
                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUnreadMessageCount" object:nil];
                                  [weakSelf.tableView reloadData];
        }];
    }
   
            
   return _searchController;
}
         
#pragma mark - EaseConversationListViewControllerDelegate
         
- (void)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
didSelectConversationModel:(id<IConversationModel>)conversationModel
{
        if (conversationModel) {
            
            EMConversation *conversation = conversationModel.conversation;
            NSLog(@"%@",conversation.conversationId);
            if (conversation) {
                
                if ([[RobotManager sharedInstance] isRobotWithUsername:conversation.conversationId]) {
                RobotChatViewController *chatController = [[RobotChatViewController alloc] initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
                chatController.title = [[RobotManager sharedInstance] getRobotNickWithUsername:conversation.conversationId];
                self.hidesBottomBarWhenPushed=YES;
                self.tabBarController.tabBar.hidden = YES;
                [self.navigationController setNavigationBarHidden:NO animated:YES];
                [self.navigationController pushViewController:chatController animated:YES];
                    
            } else {
                
#ifdef REDPACKET_AVALABLE
                    RedPacketChatViewController *chatController = [[RedPacketChatViewController alloc]
#else
                    ChatViewController *chatController = [[ChatViewController alloc]
#endif
                                                 initWithConversationChatter:conversation.conversationId conversationType:conversation.type];
                   chatController.title = conversationModel.title;
                   self.hidesBottomBarWhenPushed=YES;
                   self.tabBarController.tabBar.hidden = YES;
                   [self.navigationController setNavigationBarHidden:NO animated:YES];
                   [self.navigationController pushViewController:chatController animated:YES];
                }
        }
                                                                   
           [[NSNotificationCenter defaultCenter] postNotificationName:@"setupUnreadMessageCount" object:nil];
           [self.tableView reloadData];
  }
                   
}
           
#pragma mark - EaseConversationListViewControllerDataSource
                                                                       
- (id<IConversationModel>)conversationListViewController:(EaseConversationListViewController *)conversationListViewController modelForConversation:(EMConversation *)conversation
{
                            
                            
                           // EMMessage *lastMessage = [conversationModel.conversation latestMessage];
                            
        EaseConversationModel *model = [[EaseConversationModel alloc] initWithConversation:conversation];
//                            EMMessage *lastMessage = [model.conversation latestMessage];
//                            if(lastMessage == nil){
//                               
//                                return nil;
//                            }
                        
        UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:conversation.conversationId];
        profileEntity.imageUrl = [[NSString alloc] initWithData:dataFromBase64Str  encoding:NSUTF8StringEncoding];
    
    if (model.conversation.type == EMConversationTypeChat) {
        
        
        if ([[RobotManager sharedInstance] isRobotWithUsername:conversation.conversationId]) {
            model.title = [[RobotManager sharedInstance] getRobotNickWithUsername:conversation.conversationId];
            //            model.title = nick;
            UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:conversation.conversationId];
            profileEntity.imageUrl = [[NSString alloc] initWithData:dataFromBase64Str  encoding:NSUTF8StringEncoding];
        } else {
            UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:conversation.conversationId];
            if (profileEntity) {
                model.title = profileEntity.nickname == nil ? profileEntity.username : profileEntity.nickname;
                //                model.title = nick;
                model.avatarURLPath = [[NSString alloc] initWithData:dataFromBase64Str  encoding:NSUTF8StringEncoding];
                profileEntity.imageUrl = [[NSString alloc] initWithData:dataFromBase64Str  encoding:NSUTF8StringEncoding];
                NSLog(@"%@", profileEntity.imageUrl);
                model.avatarImage = [UIImage imageWithData:dataFromBase64Str];
            }
        }
        
    } else if (model.conversation.type == EMConversationTypeGroupChat) {
        
        NSString *imageName = @"groupPublicHeader";
        if (![conversation.ext objectForKey:@"subject"])
        {
            NSArray *groupArray = [[EMClient sharedClient].groupManager getJoinedGroups];
            for (EMGroup *group in groupArray) {
                if ([group.groupId isEqualToString:conversation.conversationId]) {
                    NSMutableDictionary *ext = [NSMutableDictionary dictionaryWithDictionary:conversation.ext];
                    [ext setObject:group.subject forKey:@"subject"];
                    [ext setObject:[NSNumber numberWithBool:group.isPublic] forKey:@"isPublic"];
                    conversation.ext = ext;
                    break;
                }
            }
        }
        
        NSDictionary *ext = conversation.ext;
        model.title = [ext objectForKey:@"subject"];
        imageName = [[ext objectForKey:@"isPublic"] boolValue] ? @"groupPublicHeader" : @"groupPrivateHeader";
        model.avatarImage = [UIImage imageNamed:imageName];
    }
    
    return model;
}
                                                                   
- (NSAttributedString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
latestMessageTitleForConversationModel:(id<IConversationModel>)conversationModel
                        {
                            NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@""];
                            EMMessage *lastMessage = [conversationModel.conversation latestMessage];
                            if (lastMessage) {
                                NSString *latestMessageTitle = @"";
                                EMMessageBody *messageBody = lastMessage.body;
                                switch (messageBody.type) {
                                    case EMMessageBodyTypeImage:{
                                        latestMessageTitle = NSLocalizedString(@"message.image1", @"[image]");
                                    } break;
                                    case EMMessageBodyTypeText:{
                                        // 表情映射。
                                        NSString *didReceiveText = [EaseConvertToCommonEmoticonsHelper
                                                                    convertToSystemEmoticons:((EMTextMessageBody *)messageBody).text];
                                        latestMessageTitle = didReceiveText;
                                        if ([lastMessage.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
                                            latestMessageTitle = @"[动画表情]";
                                        }
                                        if (lastMessage.ext != NULL) {
                                            latestMessageTitle = @"[待办提醒]";
                                        }
                                    } break;
                                    case EMMessageBodyTypeVoice:{
                                        latestMessageTitle = NSLocalizedString(@"message.voice1", @"[voice]");
                                    } break;
                                    case EMMessageBodyTypeLocation: {
                                        latestMessageTitle = NSLocalizedString(@"message.location1", @"[location]");
                                    } break;
                                    case EMMessageBodyTypeVideo: {
                                        latestMessageTitle = NSLocalizedString(@"message.video1", @"[video]");
                                    } break;
                                    case EMMessageBodyTypeFile: {
                                        latestMessageTitle = NSLocalizedString(@"message.file1", @"[file]");
                                    } break;
                                    default: {
                                    } break;
                                }
                                
                                if (lastMessage.direction == EMMessageDirectionReceive) {
                                    NSString *from = lastMessage.from;
                                    UserProfileEntity *profileEntity = [[UserProfileManager sharedInstance] getUserProfileByUsername:from];
                                    if (profileEntity) {
                                        from = profileEntity.nickname == nil ? profileEntity.username : profileEntity.nickname;
                                    }
                                    latestMessageTitle = [NSString stringWithFormat:@"%@", latestMessageTitle];
                                }
                                
                                NSDictionary *ext = conversationModel.conversation.ext;
                                if (ext && [ext[kHaveUnreadAtMessage] intValue] == kAtAllMessage) {
                                    latestMessageTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"group.atAll", nil), latestMessageTitle];
                                    attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
                                    [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:.0 blue:.0 alpha:0.5]} range:NSMakeRange(0, NSLocalizedString(@"group.atAll", nil).length)];
                                    
                                }
                                else if (ext && [ext[kHaveUnreadAtMessage] intValue] == kAtYouMessage) {
                                    latestMessageTitle = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"group.atMe", @"[Somebody @ me]"), latestMessageTitle];
                                    attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
                                    [attributedStr setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:1.0 green:.0 blue:.0 alpha:0.5]} range:NSMakeRange(0, NSLocalizedString(@"group.atMe", @"[Somebody @ me]").length)];
                                }
                                else {
                                    attributedStr = [[NSMutableAttributedString alloc] initWithString:latestMessageTitle];
                                }
                            }
                            
                            return attributedStr;
                        }
                                                                       
- (NSString *)conversationListViewController:(EaseConversationListViewController *)conversationListViewController
latestMessageTimeForConversationModel:(id<IConversationModel>)conversationModel
{
        NSString *latestMessageTime = @"";
        EMMessage *lastMessage = [conversationModel.conversation latestMessage];;
        if (lastMessage) {
            latestMessageTime = [NSDate formattedTimeFromTimeInterval:lastMessage.timestamp];
        }


        return latestMessageTime;
}
                                           
#pragma mark - UISearchBarDelegate
                                                                       
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    
    return YES;
}
                                                                   
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    __weak typeof(self) weakSelf = self;
    [[RealtimeSearchUtil currentUtil] realtimeSearchWithSource:self.dataArray searchText:(NSString *)searchText collationStringSelector:@selector(title) resultBlock:^(NSArray *results) {
        if (results) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.searchController.resultsSource removeAllObjects];
                [weakSelf.searchController.resultsSource addObjectsFromArray:results];
                [weakSelf.searchController.searchResultsTableView reloadData];
            });
        }
    }];
}
                                                                   
                                                                       
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}
                                                                   
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}
                                                                   
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    searchBar.text = @"";
    [[RealtimeSearchUtil currentUtil] realtimeSearchStop];
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO animated:YES];
}
                                                                   
#pragma mark - public
                                                                       
-(void)refresh
{
    
        [self tableViewDidTriggerHeaderRefresh];

        [self refreshAndSortView];
}

-(void)refreshDataSource
{

        [self tableViewDidTriggerHeaderRefresh];

        [self removeEmptyConversationsFromDB];

}

- (void)isConnect:(BOOL)isConnect{
   if (!isConnect) {
       self.tableView.tableHeaderView = _networkStateView;
   }
   else{
       self.tableView.tableHeaderView = nil;
   }
   
}
                                           
- (void)networkChanged:(EMConnectionState)connectionState
{
    if (connectionState == EMConnectionDisconnected) {
        self.tableView.tableHeaderView = _networkStateView;
    }
    else{
        self.tableView.tableHeaderView = nil;
    }
}
                                               
@end
