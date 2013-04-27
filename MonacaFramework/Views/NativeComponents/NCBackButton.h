//
//  NCBackButton.h
//  MonacaFramework
//
//  Created by Yasuhiro Mitsuno on 2013/04/27.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIStyleProtocol.h"

@interface NCBackButton : UIBarButtonItem <UIStyleProtocol> {
    UIButton *_backButton;
    NSString* _position;
    NSMutableDictionary *_ncStyle;
}

- (void)applyUserInterface:(NSDictionary *)uidict;
- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;

@end
