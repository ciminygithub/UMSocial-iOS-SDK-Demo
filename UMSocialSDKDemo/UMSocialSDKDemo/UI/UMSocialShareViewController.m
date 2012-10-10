//
//  UMSocialShareViewController.m
//  SocialSDK
//
//  Created by jiahuan ye on 12-8-22.
//  Copyright (c) 2012年 umeng. All rights reserved.
//

#import "UMSocialShareViewController.h"
#import "UMStringMock.h"
#import <CoreLocation/CoreLocation.h>
#import "WXApi.h"

@interface UMSocialShareViewController ()

@end

@implementation UMSocialShareViewController

-(void)dealloc
{
    [_socialController release];
    [_actionSheet release];
    [_shareTableView release];
    [_imageView release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 100)];
        textLabel.numberOfLines = 4;
        textLabel.text = [UMStringMock commentMockString];
        [self.view addSubview:textLabel];
        [textLabel release];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,90 , 150, 120)];
        NSString *imageName = [NSString stringWithFormat:@"yinxing%d.jpg",rand()%4];
        _imageView.image = [UIImage imageNamed:imageName];
        [self.view addSubview:_imageView];
        
        UMSocialData *socialData = [[UMSocialData alloc] initWithIdentifier:@"another"];
        
        socialData.shareText = textLabel.text;
        socialData.shareImage = _imageView.image;
        
        _socialController = [[UMSocialControllerService alloc] initWithUMSocialData:socialData];
        [_socialController setUMSocialUIDelegate:self];
        [socialData release];
        _shareTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 190, 320, 250)];
        _shareTableView.dataSource = self;
        _shareTableView.delegate = self;
        [self.view addSubview:_shareTableView];
        
        _actionSheet = [[UIActionSheet alloc] initWithTitle:@"图文分享" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"新浪微博",@"腾讯微博",@"人人网",@"豆瓣",@"QQ空间",nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewWillDisappear:(BOOL)animated
{
    if ([_socialController.socialDataService.socialDataDelegate isEqual:self]) {
        [_socialController.socialDataService setUMSoicalDelegate:nil];
    }
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SocialShareCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        [cell autorelease];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text = @"分享列表";
    }
    if (indexPath.row == 1) {
        cell.textLabel.text = @"图文分享";
    }
    if (indexPath.row == 2) {
        cell.textLabel.text = @"直接发送微博";
    }
    
    return cell;    
}

#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.row > 0) {
        [_actionSheet setTitle:[tableView cellForRowAtIndexPath:indexPath].textLabel.text];
        [_actionSheet showInView:self.view];
        _actionSheet.delegate = self;
        UMShareAction shareAction  = indexPath.row;
        NSLog(@"tag is %d",_actionSheet.tag);
        _actionSheet.tag = shareAction; 
    }
    else{
         UINavigationController *shareListController = [_socialController getSocialShareListController];
        [self presentModalViewController:shareListController animated:YES];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"button index is %d",buttonIndex);
    UMShareToType shareToType = buttonIndex + UMShareToTypeSina;
    if (shareToType >= UMShareToTypeCount) {
        return;
    }
    if (actionSheet.tag == UMSharePostData) {
        [_socialController.socialDataService setUMSoicalDelegate:self];
        unsigned int dateInteger = [[NSDate date] timeIntervalSince1970];
        int random = rand_r(&dateInteger)%10;
        CLLocation *location = [[CLLocation alloc] initWithLatitude:28+random longitude:107+random];
        NSString *dateString = [[NSDate date] description];
        NSString *shareContent = [NSString stringWithFormat:@"%@ %@",[UMStringMock commentMockString],dateString];
        [_socialController.socialDataService postSNSWithType:shareToType usid:nil content:shareContent image:_imageView.image location:location];
        return;
    }
    
    else if(actionSheet.tag == UMShareEditPresent) {
        [_socialController.socialDataService setUMSoicalDelegate:nil];
        UINavigationController *shareEditController = [_socialController getSocialShareEditController:shareToType];
        [self presentModalViewController:shareEditController animated:YES];
    }
}

-(void)didFinishGetUMSocialDataResponse:(UMSocialResponseEntity *)response
{
    UIAlertView *alertView;
    if (response.responseType == UMSResponseShareToSNS) {
        if (response.responseCode == UMSResponseCodeSuccess) {
            alertView = [[UIAlertView alloc] initWithTitle:@"成功" message:@"发送成功" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
        }
        else {
            NSString *msg = response.message;
            alertView = [[UIAlertView alloc] initWithTitle:@"失败" message:msg delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
            
        }
        [alertView show];
        [alertView release];   
    }
}

#pragma mark - UMSocialUIDelegate

-(UITableViewCell *)customCellForShareListTableView
{
    UITableViewCell *weiXinCell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"weixinCell"] autorelease];
    weiXinCell.textLabel.text = @"微信分享";
    weiXinCell.imageView.image = [UIImage imageNamed:@"UMS_sms"];
    return weiXinCell;
}

-(void)didSelectShareListTableViewCell
{
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        SendMessageToWXReq* req = [[[SendMessageToWXReq alloc] init]autorelease];
        req.bText = YES;
        req.text = _socialController.soicalData.shareText;
        req.scene = WXSceneSession;
        
        [WXApi sendReq:req];
    }
    NSLog(@"分享到微信");
}
@end
