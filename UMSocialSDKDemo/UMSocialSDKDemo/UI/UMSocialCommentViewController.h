//
//  UMSocialCommentViewController.h
//  SocialSDK
//
//  Created by jiahuan ye on 12-9-1.
//  Copyright (c) 2012年 umeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMSocialControllerService.h"

@interface UMSocialCommentViewController : UIViewController
<
    UITableViewDelegate,
    UITableViewDataSource,
        UMSocialDataDelegate
>
{
    UITableView *_commentTableView;
    UMSocialControllerService *_socialController;
    UIImageView *_imageView;
}
@end
