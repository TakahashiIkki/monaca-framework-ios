//
//  NCManager.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 12/02/29.
//  Copyright (c) 2012年 ASIAL CORPORATION. All rights reserved.
//

#import "NCManager.h"
#import "MFUtility.h"

@implementation NCManager

- (id)init
{
    self = [super init];
    if (nil != self) {
        _components = [[NSMutableDictionary alloc] init];
        _noIDComponents = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id<UIStyleProtocol>)componentForID:(NSString *)cid
{
    return [_components objectForKey:cid];
}

- (void)setComponent:(id<UIStyleProtocol>)component forID:(NSString *)cid
{
    if (component == nil) {
        return;
    }

    if (cid == nil) {
        [_noIDComponents addObject:component];
        return;
    }
    
    if ([_components valueForKey:cid] != nil) {
        NSLog(NSLocalizedString(@"Duplicate id", nil), cid, [self componentForID:cid].type, [component type]);
        [_noIDComponents addObject:component];
        return;
    }
    
    [_components setValue:component forKey:cid];
}

- (void)removeAllComponents
{
    [_components removeAllObjects];
    [_noIDComponents removeAllObjects];
}

@end
