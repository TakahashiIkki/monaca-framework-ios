//
//  MFViewManager.m
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/06/02.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFViewManager.h"
#import "MFUtility.h"

@implementation MFViewManager

static NSString *_wwwFolderName;

+ (void)setCurrentWWWFolderName:(NSString *)wwwFolderName;
{
    _wwwFolderName = wwwFolderName;
}

+ (NSString *)currentWWWFolderName;
{
    return _wwwFolderName;
}

+ (MFViewController *)currentViewController;
{
    id viewController = [MFUtility getAppDelegate].monacaNavigationController.topViewController;
    if ([viewController isKindOfClass:MFTabBarController.class]) {
        return (MFViewController *)[(MFNavigationController *)[(MFTabBarController *)viewController selectedViewController] topViewController];
    } else {
        return viewController;
    }
}

/*
 * 404 page
 */
+ (void)show404PageWithWebView:(UIWebView *)webView path:(NSString *)aPath {
    NSLog(@"Page not found (as warning):%@", [MFUtility getWWWShortPath:aPath]);
    NSString *pathFor404 = [[NSBundle mainBundle] pathForResource:@"404/index" ofType:@"html"];
    NSString *html = [NSString stringWithContentsOfFile:pathFor404 encoding:NSUTF8StringEncoding error:nil];
    
    html = [html stringByReplacingOccurrencesOfString:@"%%%urlPlaceHolder%%%" withString:[MFUtility getWWWShortPath:aPath]];
    [webView loadHTMLString:html baseURL:[NSURL fileURLWithPath:pathFor404]];
}


+ (id)topViewController
{
    id viewController = [MFUtility getAppDelegate].monacaNavigationController.topViewController;
    return viewController;
}

+ (BOOL)isTabbarControllerTop
{
    if ([[self topViewController] isKindOfClass:[MFTabBarController class]]) {
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)isViewControllerTop
{
    if ([[self topViewController] isKindOfClass:[MFViewController class]]) {
        return YES;
    } else {
        return NO;
    }
}

@end
