//
//  MonacaNavigationController.h
//  MonacaFramework
//
//  Created by air on 12/06/28.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFViewController.h"

@interface MFNavigationController : UINavigationController<UINavigationControllerDelegate>{

}

- (MFViewController *)currentMonacaViewControllerOrNil;
- (MFViewController *)lastMonacaViewController;
- (MFTabBarController *)lastMonacaTabBarController;

@end
