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

#import "EaseUsersListViewController.h"

#import "UIViewController+HUD.h"
#import "EaseMessageViewController.h"

@interface EaseUsersListViewController ()

@property (strong, nonatomic) UISearchBar *searchBar;


@property (nonatomic, strong) UILabel *sectionTitleView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation EaseUsersListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sectionTitleView = ({
        UILabel *sectionTitleView = [[UILabel alloc] initWithFrame:CGRectMake((MainWidth-100)/2, (MainHeight-100)/2,100,100)];
        sectionTitleView.textAlignment = NSTextAlignmentCenter;
        sectionTitleView.font = [UIFont boldSystemFontOfSize:60];
        sectionTitleView.textColor = [UIColor blueColor];
        sectionTitleView.backgroundColor = [UIColor whiteColor];
        sectionTitleView.layer.cornerRadius = 6;
        sectionTitleView.layer.borderWidth = 1.f/[UIScreen mainScreen].scale;
        _sectionTitleView.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
        sectionTitleView;
    });
    [self.navigationController.view addSubview:self.sectionTitleView];
    self.sectionTitleView.hidden = YES;
    
    [self tableViewDidTriggerHeaderRefresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - setter

- (void)setShowSearchBar:(BOOL)showSearchBar
{
    if (_showSearchBar != showSearchBar) {
        _showSearchBar = showSearchBar;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
//    return 2;
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
//    if (section == 0) {
//        if ([_dataSource respondsToSelector:@selector(numberOfRowInUserListViewController:)]) {
//            return [_dataSource numberOfRowInUserListViewController:self];
//        }
//        return 0;
//    }
    return [[self.dataArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [EaseUserCell cellIdentifierWithModel:nil];
    EaseUserCell *cell = (EaseUserCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[EaseUserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    

        id<IUserModel> model = nil;
        if ([_dataSource respondsToSelector:@selector(userListViewController:userModelForIndexPath:)]) {
            model = [_dataSource userListViewController:self userModelForIndexPath:indexPath];
        }
        else {
           
            model = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//            model = [self.dataArray objectAtIndex:indexPath.row];
        }
        
        if (model) {

            cell.model = model;
        }
        
        return cell;

}




#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EaseUserCell cellHeightWithModel:nil];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id<IUserModel> model = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(userListViewController:userModelForIndexPath:)]) {
        model = [_dataSource userListViewController:self userModelForIndexPath:indexPath];
    }
    else {
//        model = [self.dataArray objectAtIndex:indexPath.row];
        model = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    }
    
    if (model) {
        if (_delegate && [_delegate respondsToSelector:@selector(userListViewController:didSelectUserModel:)]) {
            [_delegate userListViewController:self didSelectUserModel:model];
        } else {
            EaseMessageViewController *viewController = [[EaseMessageViewController alloc] initWithConversationChatter:model.buddy conversationType:EMConversationTypeChat];
            viewController.title = model.nickname;
            [self.navigationController pushViewController:viewController animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 22;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *contentView = [[UIView alloc]init];
    contentView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 22)];
    [label setBackgroundColor:[UIColor clearColor]];
    NSArray *array = [[DataManager sharedDataManager] IMUserTitle];
    [label setText:[array objectAtIndex:section]];
    [contentView addSubview:label];
    return contentView;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    
    return [[DataManager sharedDataManager] IMUserTitle];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    [self showSectionTitle:title];

    return index;
}


- (void)timerHandler:(NSTimer *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.3 animations:^{
            self.sectionTitleView.alpha = 0;
        } completion:^(BOOL finished) {
            self.sectionTitleView.hidden = YES;
        }];
    });
}

-(void)showSectionTitle:(NSString*)title{
    [self.sectionTitleView setText:title];
    self.sectionTitleView.hidden = NO;
    self.sectionTitleView.alpha = 1;
    [self.timer invalidate];
    self.timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerHandler:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
}

#pragma mark - data

- (void)tableViewDidTriggerHeaderRefresh
{
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        // 转发功能，应转发给好友，沈鼓APP，需转发给通讯录所有好友，即获取本地的所有通讯录好友
        
//        NSArray *buddyList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
        
        NSArray *buddyListData = [[DataManager sharedDataManager] IMUserlistSort];
//        NSArray *userlist = [[EMClient sharedClient].contactManager getContacts];
        if (!error) {
            NSMutableArray *contactsSource = [NSMutableArray arrayWithArray:buddyListData];
            NSMutableArray *tempDataArray = [NSMutableArray array];
            
            // remove the contact that is currently in the black list
            NSArray *blockList = [[EMClient sharedClient].contactManager getBlackList];
            
            for (int i = 0; i < buddyListData.count; i++) {
                
                NSArray *buddyList = buddyListData[i];
                
                NSMutableArray *tempModelArray = [NSMutableArray array];
                for (NSInteger j = 0; j < buddyList.count; j++) {
                    
                        NSDictionary *dic = buddyList[j];
                        
                        // NSString *buddy = [buddyList objectAtIndex:i];
                        NSString *buddy = dic[@"ImUserName"];
                        
                        if (![blockList containsObject:buddy]) {
                            [contactsSource addObject:buddy];
                            
                            id<IUserModel> model = nil;
                            if (weakself.dataSource && [weakself.dataSource respondsToSelector:@selector(userListViewController:modelForBuddy:)]) {
                                model = [weakself.dataSource userListViewController:self modelForBuddy:buddy];
                            }
                            else{
                                model = [[EaseUserModel alloc] initWithBuddy:buddy];
                                model.nickname = dic[@"cnName"];
                                model.avatarURLPath = dic[@"photo"];
                            }
                            
                            if(model){
                                [tempModelArray addObject:model];
                            }
                    }
                }
                
                [tempDataArray addObject:tempModelArray];
                
                
                
            }
            
            
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakself.dataArray removeAllObjects];
                    [weakself.dataArray addObjectsFromArray:tempDataArray];
                    [weakself.tableView reloadData];
                });
        }
        [weakself tableViewDidFinishTriggerHeader:YES reload:NO];
    });
}

- (void)dealloc
{
}

@end
