 //
//  UMSocialSnsViewController.m
//  SocialSDK
//
//  Created by yeahugo on 13-5-19.
//  Copyright (c) 2013年 Umeng. All rights reserved.
//

#import "UMSocialSnsViewController.h"

#import "UMSocialLoginViewController.h"
#import "UMSocialBarViewController.h"

#import "AppDelegate.h"
#import "UMSocial.h"

#import "UMSocialScreenShoter.h"

#import <MediaPlayer/MediaPlayer.h>

@interface UMSocialSnsViewController ()

@end

@implementation UMSocialSnsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

//下面可以设置根据点击不同的分享平台，设置不同的分享文字
/*
-(void)didSelectSocialPlatform:(NSString *)platformName withSocialData:(UMSocialData *)socialData
{
    if ([platformName isEqualToString:UMShareToSina]) {
        socialData.shareText = @"分享到新浪微博";
    }
    else{
        socialData.shareText = @"分享内嵌文字";
    }
}
*/

-(void)didCloseUIViewController:(UMSViewControllerType)fromViewControllerType
{
    NSLog(@"didClose is %d",fromViewControllerType);
}

//下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"didFinishGetUMSocialDataInViewController with response is %@",response);
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

-(UMSocialShakeConfig)didShakeWithShakeConfig
{
    return UMSocialShakeConfigDefault;
}

-(void)didCloseShakeView
{
    NSLog(@"didCloseShakeView");
}

-(void)didFinishShareInShakeView:(UMSocialResponseEntity *)response
{
    NSLog(@"finish share with response is %@",response);
}

/*
 注意分享到新浪微博我们使用新浪微博SSO授权，你需要在xcode工程设置url scheme，并重写AppDelegate中的`- (BOOL)application openURL sourceApplication`方法，详细见文档。否则不能跳转回来原来的app。
 */
-(IBAction)showShareList1:(id)sender
{
    NSString *shareText = @"友盟社会化组件可以让移动应用快速具备社会化分享、登录、评论、喜欢等功能，并提供实时、全面的社会化数据统计分析服务。 http://www.umeng.com/social";             //分享内嵌文字
    UIImage *shareImage = [UIImage imageNamed:@"UMS_social_demo"];          //分享内嵌图片

//    [UMSocialData defaultData].extConfig.sinaData.shareText = @"分享到新浪微博内容";
//    [UMSocialData defaultData].extConfig.sinaData.shareImage = [UIImage imageNamed:@"icon"];
//    [UMSocialData defaultData].extConfig.tencentData.shareText = @"分享到腾讯微博内容";
//    [UMSocialData defaultData].extConfig.wechatSessionData.shareText = @"分享到微信好友微博内容";
//    [UMSocialData defaultData].extConfig.wechatTimelineData.shareText = @"分享到微信朋友圈内容";
//    [UMSocialData defaultData].extConfig.qqData.shareText = @"分享到QQ内容";
    
    //如果得到分享完成回调，需要传递delegate参数
//    [[UMSocialData defaultData].urlResource setResourceType:UMSocialUrlResourceTypeMusic url:@"http://mr3.douban.com/201312051131/7617787a152d19143e63d9ac39662348/view/song/small/p149167.mp3"];
    [UMSocialSnsService presentSnsIconSheetView:self appKey:UmengAppkey shareText:nil shareImage:nil shareToSnsNames:nil delegate:self];
}

-(IBAction)setShakeSns:(id)sender
{
    NSString *shareText = @"友盟社会化组件可以让移动应用快速具备社会化分享、登录、评论、喜欢等功能，并提供实时、全面的社会化数据统计分析服务。 http://www.umeng.com/social";             //分享内嵌文字
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"IMG_0840" ofType:@"MOV"];
//    NSURL *url = [NSURL fileURLWithPath:path];
//    MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:url];
//    player.view.frame = self.view.frame;
//    [self.view addSubview:player.view];
//    [player play];
//    
    [UMSocialShakeService setShakeToShareWithTypes:nil
                                         shareText:shareText
                                      screenShoter:[UMSocialScreenShoterDefault screenShoter]
                                  inViewController:self
                                          delegate:self];

//    UMSocialShareEditView *shakeEditView = [[UMSocialShareEditView alloc] initWithSnsTypes:@[UMShareToSina,UMShareToTencent,UMShareToQzone,UMShareToQQ,UMShareToWechatSession,UMShareToWechatTimeline] controller:self];
//    shakeEditView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
//    [self.view addSubview:shakeEditView];
}

/*
 自定义分享样式，可以自己构造分享列表页面
 
 */
-(IBAction)showShareList3:(id)sender
{    
    UIActionSheet * editActionSheet = [[UIActionSheet alloc] initWithTitle:@"图文分享" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    for (NSString *snsName in [UMSocialSnsPlatformManager sharedInstance].allSnsValuesArray) {
        UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName];
        [editActionSheet addButtonWithTitle:snsPlatform.displayName];
    }
    [editActionSheet addButtonWithTitle:@"取消"];
    editActionSheet.cancelButtonIndex = editActionSheet.numberOfButtons - 1;
    [editActionSheet showFromTabBar:self.tabBarController.tabBar];
    editActionSheet.delegate = self;
}


/*
 在自定义分享样式中，根据点击不同的点击来处理不同的的动作
 
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex + 1 >= actionSheet.numberOfButtons ) {
        return;
    }
//    //分享内嵌文字
//    [UMSocialData defaultData].shareText = @"友盟社会化组件可以让移动应用快速具备社会化分享、登录、评论、喜欢等功能，并提供实时、全面的社会化数据统计分析服务。";
//    //分享内嵌图片
//    [UMSocialData defaultData].shareImage = [UIImage imageNamed:@"UMS_social_demo"];
    
    [[UMSocialControllerService defaultControllerService] setShareText:@"分享内嵌文字" shareImage:[UIImage imageNamed:@"UMS_social_demo"] socialUIDelegate:self];
    
     //分享编辑页面的接口,snsName可以换成你想要的任意平台，例如UMShareToSina,UMShareToWechatTimeline
    NSString *snsName = [[UMSocialSnsPlatformManager sharedInstance].allSnsValuesArray objectAtIndex:buttonIndex];
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName];
    snsPlatform.snsClickHandler(self,[UMSocialControllerService defaultControllerService],YES);    
}

- (void)viewDidLoad
{
    _shareButton1.center = CGPointMake(self.tabBarController.view.bounds.size.width/2, _shareButton1.center.y);
    _shareButton2.center = CGPointMake(self.tabBarController.view.bounds.size.width/2, _shareButton2.center.y);
     _shareButton3.center = CGPointMake(self.tabBarController.view.bounds.size.width/2, _shareButton3.center.y);
    
    [super viewDidLoad];
    self.title = @"分享";
    self.tabBarItem.image = [UIImage imageNamed:@"UMS_share"];
}


-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    /*
     如果要弹出的分享列表支持不同方向，需要在这里设置一下重新布局
     如果当前UIViewController有UINavigationController,则用self.navigationController.view，否则用self.view
     */
    UIView * iconActionSheet = [self.tabBarController.view viewWithTag:kTagSocialIconActionSheet];
    [iconActionSheet setNeedsDisplay];
    UIView * shakeView = [self.tabBarController.view viewWithTag:kTagSocialShakeView];
    [shakeView setNeedsDisplay];
}


-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _shareButton1.center = CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/5);
    _shareButton2.center = CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/5 *2);
    _shareButton3.center = CGPointMake(self.view.frame.size.width/2,self.view.frame.size.height/5 *3);
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
