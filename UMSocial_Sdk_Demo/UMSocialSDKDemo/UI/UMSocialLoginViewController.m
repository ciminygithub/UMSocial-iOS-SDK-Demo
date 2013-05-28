//
//  UMSocialLoginViewController.m
//  SocialSDK
//
//  Created by yeahugo on 13-5-19.
//  Copyright (c) 2013年 Umeng. All rights reserved.
//

#import "UMSocialLoginViewController.h"
#import "UMSocial.h"

@interface UMSocialLoginViewController ()

@end

@implementation UMSocialLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _snsTableView.dataSource = self;
    _snsTableView.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    _snsTableView.frame = CGRectMake(_snsTableView.frame.origin.x, _snsTableView.frame.origin.y, _snsTableView.frame.size.width, 220);
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *UMSnsAccountCellIdentifier = @"UMSnsAccountCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UMSnsAccountCellIdentifier];
    
    NSDictionary *snsAccountDic = [UMSocialAccountManager socialAccountDictionary];
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:[UMSocialSnsPlatformManager getSnsPlatformStringFromIndex:indexPath.row]];
    
    UMSocialAccountEntity *accountEnitity = [snsAccountDic valueForKey:snsPlatform.platformName];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                       reuseIdentifier:UMSnsAccountCellIdentifier] ;
    }
    
    UISwitch *oauthSwitch = nil;
    if ([cell viewWithTag:snsPlatform.shareToType]) {
        oauthSwitch = (UISwitch *)[cell viewWithTag:snsPlatform.shareToType];
    }
    else{
        oauthSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 10, 40, 20)];
        
        oauthSwitch.tag = snsPlatform.shareToType;
        [cell addSubview:oauthSwitch];
    }
    oauthSwitch.center = CGPointMake(_snsTableView.bounds.size.width - 40, oauthSwitch.center.y);
    
    [oauthSwitch addTarget:self action:@selector(onSwitchOauth:) forControlEvents:UIControlEventValueChanged];
    
    NSString *showUserName = nil;
    
    //这里判断是否授权
    if ([UMSocialAccountManager isOauthWithPlatform:snsPlatform.platformName]) {
        [oauthSwitch setOn:YES];
        //这里获取到每个授权账户的昵称
        showUserName = accountEnitity.userName;
    }
    else {
        [oauthSwitch setOn:NO];
        showUserName = [NSString stringWithFormat:@"尚未授权"];
    }
    
    if ([showUserName isEqualToString:@""]) {
        cell.textLabel.text = @"已授权";
    }
    else{
        cell.textLabel.text = showUserName;
    }
    
    cell.imageView.image = [UIImage imageNamed:snsPlatform.smallImageName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)onSwitchOauth:(UISwitch *)switcher
{
    _changeSwitcher = switcher;
    
    if (switcher.isOn == YES) {
        [switcher setOn:NO];
        
        //此处调用授权的方法,你可以把下面的platformName 替换成 UMShareToSina,UMShareToTencent等
        NSString *platformName = [UMSocialSnsPlatformManager getSnsPlatformString:switcher.tag];
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:platformName];
        snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            
            //如果是授权到新浪微博，SSO之后如果想获取用户的昵称、头像等需要再次获取一次账户信息
            if ([platformName isEqualToString:UMShareToSina]) {
                [[UMSocialDataService defaultDataService] requestSocialAccountWithCompletion:^(UMSocialResponseEntity *accountResponse){
                    NSLog(@"SinaWeibo's user name is %@",[[[accountResponse.data objectForKey:@"accounts"] objectForKey:UMShareToSina] objectForKey:@"username"]);
                    [_snsTableView reloadData];
                }];
            }

            //这里可以获取到腾讯微博openid
            /*
            [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToTencent completion:^(UMSocialResponseEntity *respose){
                NSLog(@"get openid  response is %@",respose);
            }];
             */
             
            [_snsTableView reloadData];
        });
        
    }
    else {
        UIActionSheet *unOauthActionSheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"解除授权", nil];
        unOauthActionSheet.destructiveButtonIndex = 0;
        unOauthActionSheet.tag = switcher.tag;
        [unOauthActionSheet showInView:self.tabBarController.tabBar];
    }
}

#pragma UIActionSheet
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSString *platformType = [UMSocialSnsPlatformManager getSnsPlatformString:actionSheet.tag];
        [[UMSocialDataService defaultDataService] requestUnOauthWithType:platformType completion:^(UMSocialResponseEntity *response){
            if (response.responseType == UMSResponseGetAccount) {
                [_snsTableView reloadData];                
            }
        }];
    }
    else {//按取消
        [_changeSwitcher setOn:YES animated:YES];
    }
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _snsTableView.frame = CGRectMake(_snsTableView.frame.origin.x, _snsTableView.frame.origin.y, _snsTableView.frame.size.width, 220);
    [_snsTableView reloadData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
