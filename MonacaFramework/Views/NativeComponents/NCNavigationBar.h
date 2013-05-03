//
//  NCNavigationBar.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/28.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MFViewController.h"
#import "UIStyleProtocol.h"
#import "NCBackButton.h"

@interface NCNavigationBar : NSObject <UIStyleProtocol>
{
    MFViewController *_viewController;
    UINavigationBar *_navigationBar;
    NSMutableDictionary *_ncStyle;
    NSArray *_leftContainers;
    NSArray *_rightContainers;
    NSArray *_centerContainers;
    UIToolbar *_centerViewToolbar;
    NCContainer *_backButton;
}

- (id)initWithViewController:(MFViewController *)viewController;
- (void)applyUserInterface:(NSDictionary *)uidict;
- (void)createNavigationBar:(NSDictionary *)uidict;

@property (nonatomic, retain) MFViewController *viewController;

@end
