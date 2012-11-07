//
//  UMSocialUIController.h
//  SocialSDK
//
//  Created by yeahugo on 12-9-12.
//
//

#import <Foundation/Foundation.h>
#import "UMSocialDataService.h"
#import "UMSocialConfigDelegate.h"

/**
 `UMSocialControllerService`对象用到的一些回调方法，可以对出现的分享列表进行设置，或者得到一些完成事件的回调方法。
 */
@protocol UMSocialUIDelegate <NSObject>

@optional

/**
 关闭当前页面之后
 
 */
-(void)didCloseUIViewController;

/**
 当发送评论或者分享完成之后会重新请求获取评论数、分享数等，获取这些数据之后的回调方法
 
 @param response 返回`UMSocialResponseEntity`对象
 */
-(void)didFinishRefreshSocialData:(UMSocialResponseEntity *)response;

/**
 当授权完成，并且从服务器获取到账户信息之后的回调方法

 */
-(void)didFinishOauthAndGetAccount:(UMSocialResponseEntity *)response;

@end

/**
 用此类的方法可以得到分享的有关UI对象，例如分享列表、评论列表、分享编辑页、分享授权页、用户中心页面等。返回都是`UINavigationController`对象，建议把这个对象present到你要添加到的`UIViewController`上
 */

@class UMSUIHandler;
@interface UMSocialControllerService : NSObject
{
    UMSocialDataService *_socialDataService;
    UMSUIHandler *_socialUIHandler;
    UINavigationController *_currentNavigationController;
    UIViewController       *_currentViewController;
}

///---------------------------------------
/// @name 对象属性
///---------------------------------------

/**
 与`UMSocialControllerService`对象对应的`UMSocialData`对象，可以通过该对象设置分享内嵌文字、图片，获取分享数等属性
 */
@property (nonatomic, readonly) UMSocialData *soicalData;

/**
 用`UMSocialDataService`对象，可以调用发送微博、评论等数据级的方法
 */
@property (nonatomic, readonly) UMSocialDataService *socialDataService;

/**
 当前返回的`UINavigationController`对象
 */
@property (nonatomic, assign) UIViewController *currentViewController;

/**
 当前返回的`UIViewController`对象
 */
@property (nonatomic, assign) UINavigationController *currentNavigationController;


/**
 当前`<UMSocialUIDelegate>`对象,此对象可以获取到授权完成，关闭页面等状态，详情看`UMSocialUIDelegate`的定义
 */
@property (nonatomic, assign) id <UMSocialUIDelegate> soicalUIDelegate;

///---------------------------------------
/// @name 初始化方法和设置
///---------------------------------------

/**
 初始化一个`UMSocialControllerService`对象
 
 @param socialData `UMSocialData`对象
 
 @return 初始化对象
 */
- (id)initWithUMSocialData:(UMSocialData *)socialData;

/**
 设置实现了`<UMSocialConfigDelegate>`的对象，类方法，表示该对象对全部`UMSocialControllerService`对象起作用
 
 @param delegate 实现了`<UMSocialConfigDelegate>`的对象
 
 */
+ (void)setSocialConfigDelegate:(id <UMSocialConfigDelegate>)delegate;

///---------------------------------------
/// @name 获得评论列表、分享列表等UINavigationController
///---------------------------------------

/**
 分享列表页面，该列表出现的分享列表可以通过实现`UMSocialConfigDelegate`的方法来自定义
 
 @return `UINavigationController`对象
 */
- (UINavigationController *)getSocialShareListController;

/**
 评论列表页面，评论列表页面包括各评论详情、评论编辑
 
 @return `UINavigationController`对象
 */
- (UINavigationController *)getSocialCommentListController;

/**
 个人中心页面，该页面包括个人的各个微博授权信息
 
 @return `UINavigationController`对象
 */
- (UINavigationController *)getSocialAccountController;

/**
 分享编辑页面
 
 @param shareToType 要编辑的微博平台
 
 @return `UINavigationController`对象
 */
- (UINavigationController *)getSocialShareEditController:(UMSocialSnsType)shareToType;

/**
 授权页面，如果你要想得到授权完成之后的事件，你可以实现`UMSocialUIDelegate`里面的`-(void)didCloseUIViewController;`方法，当授权关闭页面会调用此方法。另外授权完成之后sdk会自动去取个人账户信息，你可以在回调函数里面去到刚刚授权的微博平台的账户信息。
 
 @param shareToType 要授权的微博平台
 
 @return `UINavigationController`对象
 */
- (UINavigationController *)getSocialOauthController:(UMSocialSnsType)shareToType;

@end


