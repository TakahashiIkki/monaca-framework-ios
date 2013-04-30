//
//  MonacaTransitPlugin.m
//  MonacaFramework
//
//  Created by air on 12/06/28.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>

#import "MFTransitPlugin.h"
#import "MFDelegate.h"
#import "MFViewController.h"
#import "MFTabBarController.h"
#import "MFNavigationController.h"
#import "MFUtility.h"

#define kMonacaTransitPluginJsReactivate @"window.onReactivate"
#define kMonacaTransitPluginOptionUrl @"url"
#define kMonacaTransitPluginOptionBg  @"bg"

@implementation MFTransitPlugin

#pragma mark - private methods

- (MFDelegate *)monacaDelegate
{
    return (MFDelegate *)self.appDelegate;
}

- (MFNavigationController *)monacaNavigationController
{
    return self.monacaDelegate.monacaNavigationController;
}

- (MFViewController *)lastMonacaViewController
{
    return self.monacaNavigationController.lastMonacaViewController;
}

- (NSURLRequest *)createRequest:(NSString *)urlString withQuery:(NSString *)query
{
    NSURL *url;
    if ([self.commandDelegate pathForResource:urlString]){
        url = [NSURL fileURLWithPath:[self.commandDelegate pathForResource:urlString]];
        if ([[query class] isSubclassOfClass:[NSString class]]) {
            url = [NSURL URLWithString:[url.absoluteString stringByAppendingFormat:@"?%@", query]];
        }
    }else {
        url = [NSURL URLWithString:[@"monaca404:///www/" stringByAppendingPathComponent:urlString]];
    }
    return [NSURLRequest requestWithURL:url];
}

// @see [MonacaDelegate application: didFinishLaunchingWithOptions:]
- (void)setupViewController:(MFViewController *)viewController options:(NSDictionary *)options
{
    viewController.monacaPluginOptions = options;
    [MFUtility setupMonacaViewController:viewController];
}

+ (void)setBgColor:(MFViewController *)viewController color:(UIColor *)color
{
    viewController.cdvViewController.webView.backgroundColor = [UIColor clearColor];
    viewController.cdvViewController.webView.opaque = NO;

    UIScrollView *scrollView = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 5.0f) {
        for (UIView *subview in [viewController.cdvViewController.webView subviews]) {
            if ([[subview.class description] isEqualToString:@"UIScrollView"]) {
                scrollView = (UIScrollView *)subview;
            }
        }
    } else {
        scrollView = (UIScrollView *)[viewController.cdvViewController.webView scrollView];
    }

    if (scrollView) {
        scrollView.opaque = NO;
        scrollView.backgroundColor = [UIColor clearColor];
        // Remove shadow
        for (UIView *subview in [scrollView subviews]) {
            if([subview isKindOfClass:[UIImageView class]]){
                subview.hidden = YES;
            }
        }
    }

    viewController.view.opaque = YES;
    viewController.view.backgroundColor = color;
}

#pragma mark - public methods

#pragma mark - MonacaViewController actions

+ (void)viewDidLoad:(MFViewController *)viewController
{
    // @todo MonacaViewController内部にて実行すべき事柄
    if(![viewController isKindOfClass:[MFViewController class]]) {
        return;
    }

    if (viewController.monacaPluginOptions) {
        NSString *bgName = [viewController.monacaPluginOptions objectForKey:kMonacaTransitPluginOptionBg];
        if (bgName) {
            NSURL *appWWWURL = [[MFUtility getAppDelegate] getBaseURL];
            NSString *bgPath = [appWWWURL.path stringByAppendingFormat:@"/%@", bgName];
            UIImage *bgImage = [UIImage imageWithContentsOfFile:bgPath];
            if (bgImage) {
                [[self class] setBgColor:viewController color:[UIColor colorWithPatternImage:bgImage]];
            }
        }
    }
}

+ (void)webViewDidFinishLoad:(UIWebView*)theWebView viewController:(MFViewController *)viewController
{
    if (!viewController.monacaPluginOptions || ![viewController.monacaPluginOptions objectForKey:kMonacaTransitPluginOptionBg]) {
        theWebView.backgroundColor = [UIColor blackColor];
    }
}

- (NSString *)getRelativePathTo:(NSString *)filePath {
    NSString *currentDirectory = [self.lastMonacaViewController.cdvViewController.webView.request.URL URLByDeletingLastPathComponent].filePathURL.path;
    NSString *urlString = [currentDirectory stringByAppendingPathComponent:filePath];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[urlString componentsSeparatedByString:@"www/"]];
    if (array.count > 0) {
        [array removeObjectAtIndex:0];
    }
    return [[array valueForKey:@"description"] componentsJoinedByString:@""];
}

#pragma mark - plugins methods

- (void)push:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *urlString = [arguments objectAtIndex:1];
    if (![self isValidOptions:options] || ![self isValidString:urlString]) {
        return;
    }

    NSString *relativeUrlString = [self getRelativePathTo:urlString];
    NSString *query = [self getQueryFromPluginArguments:arguments urlString:relativeUrlString];
    NSString *urlStringWithoutQuery = [[relativeUrlString componentsSeparatedByString:@"?"] objectAtIndex:0];

    MFViewController *viewController = [[MFViewController alloc] initWithFileName:urlStringWithoutQuery];
    MFNavigationController *nav = [self monacaNavigationController];
    
    [viewController.cdvViewController.webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
    [self setupViewController:viewController options:options];
    
    BOOL isAnimated = YES;
    id animationParam = [options objectForKey:@"animation"];
    
    if ([animationParam isKindOfClass:NSNumber.class]) {
        NSNumber *animationNumber = (NSNumber*)animationNumber;
        // case for {animation : false}
        if (!animationNumber) {
            isAnimated = NO;
        }
    }
    
    [nav pushViewController:viewController animated:isAnimated];
}

- (void)slideRight:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *urlString = [arguments objectAtIndex:1];
    if (![self isValidOptions:options] || ![self isValidString:urlString]) {
        return;
    }
    
    NSString *relativeUrlString = [self getRelativePathTo:urlString];
    NSString *query = [self getQueryFromPluginArguments:arguments urlString:relativeUrlString];
    NSString *urlStringWithoutQuery = [[relativeUrlString componentsSeparatedByString:@"?"] objectAtIndex:0];

    MFViewController *viewController = [[MFViewController alloc] initWithFileName:urlStringWithoutQuery];
    MFNavigationController *nav = [self monacaNavigationController];
    
    [viewController.cdvViewController.webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
    [self setupViewController:viewController options:options];
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromLeft;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    
    [nav.view.layer addAnimation:transition forKey:kCATransition];
    [nav pushViewController:viewController animated:NO];
}

- (void)pop:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    BOOL isAnimated = YES;
    id animationParam = [options objectForKey:@"animation"];
    if ([animationParam isKindOfClass:NSNumber.class]) {
        NSNumber *animationNumber = (NSNumber*)animationNumber;
        // case for {animation : false}
        if (!animationNumber) {
            isAnimated = NO;
        }
    }
    
    [(MFViewController*)[self.monacaNavigationController popViewControllerAnimated:isAnimated] destroy];
    
    NSString *command =[NSString stringWithFormat:@"%@ && %@();",
                        kMonacaTransitPluginJsReactivate,
                        kMonacaTransitPluginJsReactivate];
    [self writeJavascript:command monacaViewController:self.monacaNavigationController.currentMonacaViewControllerOrNil];
}

- (void)modal:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *urlString = [arguments objectAtIndex:1];
    if (![self isValidOptions:options] || ![self isValidString:urlString]) {
        return;
    }

    NSString *relativeUrlString = [self getRelativePathTo:urlString];
    NSString *query = [self getQueryFromPluginArguments:arguments urlString:relativeUrlString];
    NSString *urlStringWithoutQuery = [[relativeUrlString componentsSeparatedByString:@"?"] objectAtIndex:0];
    
    MFViewController *viewController = [[MFViewController alloc] initWithFileName:urlStringWithoutQuery];
    [viewController.cdvViewController.webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];

    [self setupViewController:viewController options:options];

    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromTop;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];

    MFNavigationController *nav = [self monacaNavigationController];
    [nav.view.layer addAnimation:transition forKey:kCATransition];
    [nav pushViewController:viewController animated:NO];
}

- (void)dismiss:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{

    CATransition *transition = [CATransition animation];
    transition.duration = 0.4f;
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];

    MFNavigationController *nav = [self monacaNavigationController];
    [nav.view.layer addAnimation:transition forKey:kCATransition];
    [(MFViewController*)[nav popViewControllerAnimated:NO] destroy];

    NSString *command =[NSString stringWithFormat:@"%@ && %@();", kMonacaTransitPluginJsReactivate, kMonacaTransitPluginJsReactivate];
    [self writeJavascript:command monacaViewController:self.monacaNavigationController.currentMonacaViewControllerOrNil];
}


- (void)home:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *fileName = [options objectForKey:kMonacaTransitPluginOptionUrl];

    [self popToHomeViewController:YES];

    if (fileName) {
        [self.webView loadRequest:[self createRequest:fileName withQuery:nil]];
    }
    
    NSString *command =[NSString stringWithFormat:@"%@ && %@();", kMonacaTransitPluginJsReactivate, kMonacaTransitPluginJsReactivate];
    [self writeJavascript:command monacaViewController:self.monacaNavigationController.currentMonacaViewControllerOrNil];
}

- (void)popToHomeViewController:(BOOL)isAnimated
{
    NSArray *viewControllers = [[self monacaNavigationController] popToRootViewControllerAnimated:isAnimated];
    
    for (MFViewController *vc in viewControllers) {
        [vc destroy];
    }
}

- (void)browse:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *urlString = [arguments objectAtIndex:1];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (void)link:(NSMutableArray*)arguments withDict:(NSMutableDictionary*)options
{
    NSString *urlString = [self getRelativePathTo:[arguments objectAtIndex:1]];
    NSString *query = [self getQueryFromPluginArguments:arguments urlString:urlString];
    NSString *urlStringWithoutQuery = [[urlString componentsSeparatedByString:@"?"] objectAtIndex:0];
    
    [self.lastMonacaViewController.cdvViewController.webView loadRequest:[self createRequest:urlStringWithoutQuery withQuery:query]];
}

- (NSString *) buildQuery:(NSDictionary *)jsonQueryParams urlString:(NSString *)urlString
{
    NSString *query = @"";
    NSArray *array = [urlString componentsSeparatedByString:@"?"];
    if (array.count > 1) {
        query = [array objectAtIndex:1];
    }
    
    if (jsonQueryParams.count > 0) {
        NSMutableArray *queryParams = [NSMutableArray array];
        for (NSString *key in jsonQueryParams) {
            NSString *encodedKey = [MFUtility urlEncode:key];
            NSString *encodedValue = nil;
            if ([[jsonQueryParams objectForKey:key] isEqual:[NSNull null]]){
                [queryParams addObject:[NSString stringWithFormat:@"%@", encodedKey]];
            }else {
                encodedValue = [MFUtility urlEncode:[jsonQueryParams objectForKey:key]];
                [queryParams addObject:[NSString stringWithFormat:@"%@=%@", encodedKey, encodedValue]];
            }
        }
        if([query isEqualToString:@""]){
            query = [[[queryParams reverseObjectEnumerator] allObjects] componentsJoinedByString:@"&"];
        }else{
            query = [NSString stringWithFormat:@"%@&%@",query,[[[queryParams reverseObjectEnumerator] allObjects] componentsJoinedByString:@"&"]];
        }
    }
    return [query isEqualToString:@""]?nil:query;
}

- (NSString *) getQueryFromPluginArguments:(NSMutableArray *)arguments urlString:(NSString *)aUrlString{
    NSString *query = nil;
    if (arguments.count > 2 && ![[arguments objectAtIndex:2] isEqual:[NSNull null]]){
        query = [self buildQuery:[arguments objectAtIndex:2] urlString:aUrlString];
    }
    return query;
}

- (BOOL)isValidString:(NSString *)urlString {
    if (urlString.length > 512) {
        NSLog(@"[error] MonacaTransitException::Too long path length:%@", urlString);
        return NO;
    }
    return YES;
}

- (BOOL)isValidOptions:(NSDictionary *)options {
    for (NSString *key in options) {
        NSObject *option = [options objectForKey:key];
        
        if ([option isKindOfClass:NSString.class] && ((NSString *)option).length > 512) {
            NSLog(@"[error] MonacaTransitException::Too long option length:%@, %@", key, [options objectForKey:key]);
            return NO;
        }
    }
    return YES;
}

- (NSString*) writeJavascript:(NSString*)javascript monacaViewController:(MFViewController*)monacaViewController
{
    return [monacaViewController.cdvViewController.webView stringByEvaluatingJavaScriptFromString:javascript];
}

@end
