//
//  MFUIChecker.m
//  MonacaFramework
//
//  Created by yasuhiro on 13/05/23.
//  Copyright (c) 2013年 ASIAL CORPORATION. All rights reserved.
//

#import "MFUIChecker.h"
#import "NativeComponents.h"

@interface RootNode : NSObject
+ (void)parse:(NSMutableDictionary *)dict;
@end

@interface ContainerNode : NSObject
+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position;
@end

@interface ToolBarNode : NSObject
+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position;
@end

@interface TabBarNode : NSObject
+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position;
@end

@interface ComponentNode : NSObject
+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position;
@end

@interface StyleNode : NSObject
+ (void)parse:(NSMutableDictionary *)dict withComponent:(NSString *)component;
@end

@interface IOSBarStyleNode : NSObject
+ (void)parse:(NSString *)style withComponent:(NSString *)component;
@end


@implementation MFUIChecker

+ (void)checkUI:(NSMutableDictionary *)uidict
{
    [RootNode parse:uidict];
}

+ (NSString *)dictionaryKeysToString:(NSDictionary *)dict
{
    NSEnumerator* enumerator = [dict keyEnumerator];
    NSString *string = @"[";
    id object = [enumerator nextObject];
    while (object) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"\"%@\"", object]];
        object = [enumerator nextObject];
        if (object)
            string = [string stringByAppendingString:@", "];
    }
    return [string stringByAppendingString:@"]"];
}

+ (NSString *)valueType:(id)object
{

    if ([NSStringFromClass([object class]) isEqualToString:@"__NSCFConstantString"] ||
        [NSStringFromClass([object class]) isEqualToString:@"__NSCFString"]) {
        NSString *str = object;
        NSRange range = [str rangeOfString:@"^#[0-9a-fA-F]{6}$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            return @"Color";
        }
        range = [str rangeOfString:@"^(true|false)$" options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            return @"Boolean";
        }
        return @"String";
    }
    if ([NSStringFromClass([object class]) isEqualToString:@"__NSCFArray"] ||
        [NSStringFromClass([object class]) isEqualToString:@"__NSArrayI"] ||
        [NSStringFromClass([object class]) isEqualToString:@"NSArray"] ) {
        return @"Array";
    }
    if ([NSStringFromClass([object class]) isEqualToString:@"__NSCFDictionary"]) {
        return @"Object";
    }
    if ([NSStringFromClass([object class]) isEqualToString:@"__NSCFNumber"]) {
        if (strcmp([object objCType], @encode(float)) == 0) {
            return @"Float";
        } else {
            return @"Integer";
        }
    }
    return nil;
}

@end

@implementation RootNode

+ (NSDictionary *)getValidDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:NSDictionary.class forKey:kNCPositionTop];
    [dict setValue:NSDictionary.class forKey:kNCPositionBottom];
    [dict setValue:NSDictionary.class forKey:kNCPositionMenu];
    return dict;
}

+ (void)parse:(NSMutableDictionary *)dict
{
    NSDictionary *validDict = [self getValidDictionary];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(NSLocalizedString(@"Key is not one of valid keys", nil), @"<root>", key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
    }
    NSMutableDictionary *Dict;
    if ((Dict = [dict objectForKey:kNCPositionTop])) {
        [ContainerNode parse:Dict withPosition:kNCPositionTop];
    }
    if ((Dict = [dict objectForKey:kNCPositionBottom])) {
        [ContainerNode parse:Dict withPosition:kNCPositionBottom];
    }
    if ((Dict = [dict objectForKey:kNCPositionMenu])) {
        //        [ContainerNode parse:Dict withPosition:kNCPositionMenu];
    }
}

@end

@implementation ContainerNode

+ (NSDictionary *)getValidDictionary:(NSString *)position
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:NSString.class forKey:kNCContainerToolbar];
    if ([position isEqualToString:kNCPositionTop]) {
        return dict;
    }
    if ([position isEqualToString:kNCPositionBottom]) {
        [dict setValue:NSString.class forKey:kNCContainerTabbar];
        return dict;
    }
    
    return nil;
}
+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position
{
    NSString *container = [dict objectForKey:kNCTypeContainer];
    if (container == nil) {
        NSLog(NSLocalizedString(@"Missing required key", nil), kNCTypeContainer, position);
        [dict removeAllObjects];
        return;
    }
    NSDictionary *validValue = [self getValidDictionary:position];
    if ([validValue objectForKey:container] == nil) {
        NSLog(NSLocalizedString(@"Value not in one of valid values", nil), position, container, [MFUIChecker dictionaryKeysToString:validValue]);
        [dict removeAllObjects];
        return;
    }
    
    if ([container isEqualToString:kNCContainerToolbar]) {
        [ToolBarNode parse:dict withPosition:position];
    }
    if ([container isEqualToString:kNCContainerTabbar]) {
        [TabBarNode parse:dict withPosition:position];
    }
}

@end

@implementation ToolBarNode

+ (NSDictionary *)getValidDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:NSString.class forKey:kNCTypeContainer];
    [dict setValue:NSDictionary.class forKey:kNCTypeStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeIOSStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeAndroidStyle];
    [dict setValue:NSString.class forKey:kNCTypeID];
    [dict setValue:NSArray.class forKey:kNCTypeLeft];
    [dict setValue:NSArray.class forKey:kNCTypeCenter];
    [dict setValue:NSArray.class forKey:kNCTypeRight];
    return dict;
}

+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position
{
    NSDictionary *validDict = [self getValidDictionary];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(NSLocalizedString(@"Key is not one of valid keys", nil), position, key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
        if (![[dict objectForKey:key] isKindOfClass:[validDict valueForKey:key]]) {
            NSLog(NSLocalizedString(@"Invalid value type", nil), position , key,
                   [MFUIChecker valueType:[validDict objectForKey:key]], [dict valueForKey:key]);
            [dict removeObjectForKey:key];
            continue;
        }
    }
    if ([dict objectForKey:kNCTypeStyle]) {
        [StyleNode parse:[dict objectForKey:kNCTypeStyle] withComponent:kNCContainerToolbar];
    }
    NSArray *array;
    if ((array = [dict objectForKey:kNCTypeLeft])) {
        for (NSMutableDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeLeft];
        }
    }
    if ((array = [dict objectForKey:kNCTypeCenter])) {
        for (NSMutableDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeCenter];
        }
    }
    if ((array = [dict objectForKey:kNCTypeRight])) {
        for (NSMutableDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeRight];
        }
    }
}

@end


@implementation TabBarNode

+ (NSDictionary *)getValidDictionary
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:NSString.class forKey:kNCTypeContainer];
    [dict setValue:NSDictionary.class forKey:kNCTypeStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeIOSStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeAndroidStyle];
    [dict setValue:NSString.class forKey:kNCTypeID];
    [dict setValue:NSArray.class forKey:kNCTypeItems];
    return dict;
}

+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position
{
    NSString *container = [dict objectForKey:kNCTypeItems];
    if (container == nil) {
        NSLog(NSLocalizedString(@"Missing required key", nil), kNCTypeItems, position);
    }
    NSDictionary *validDict = [self getValidDictionary];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(NSLocalizedString(@"Key is not one of valid keys", nil), position, key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
    }
    if ([dict objectForKey:kNCTypeStyle]) {
        [StyleNode parse:[dict objectForKey:kNCTypeStyle] withComponent:kNCContainerTabbar];
    }
    NSArray *array;
    if ((array = [dict objectForKey:kNCTypeRight])) {
        for (NSMutableDictionary *Dict in array) {
            [ComponentNode parse:Dict withPosition:kNCTypeItems];
        }
    }
}

@end

@implementation ComponentNode

+ (NSDictionary *)getValidDictionary:(NSString *)component
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:NSString.class forKey:kNCStyleComponent];
    [dict setValue:NSDictionary.class forKey:kNCTypeStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeIOSStyle];
    [dict setValue:NSDictionary.class forKey:kNCTypeAndroidStyle];
    [dict setValue:NSString.class forKey:kNCTypeID];
    [dict setValue:NSDictionary.class forKey:kNCTypeEvent];
    if ([component isEqualToString:kNCComponentButton]) {
        return dict;
    }
    if ([component isEqualToString:kNCComponentBackButton]) {
        return dict;
    }
    if ([component isEqualToString:kNCComponentLabel]) {
        [dict removeObjectForKey:kNCTypeEvent];
        return dict;
    }
    if ([component isEqualToString:kNCComponentSearchBox]) {
        return dict;
    }
    if ([component isEqualToString:kNCComponentSegment]) {
        return dict;
    }
    if ([component isEqualToString:kNCComponentTabbarItem]) {
        [dict removeObjectForKey:kNCTypeEvent];
        [dict setValue:NSString.class forKey:kNCTypeLink];
        return dict;
    }
    
    return  nil;
}

+ (void)parse:(NSMutableDictionary *)dict withPosition:(NSString *)position
{
    NSString *component = [dict objectForKey:kNCStyleComponent];
    if (component == nil) {
        NSLog(NSLocalizedString(@"Missing required key", nil), kNCStyleComponent, position);
        return;
    }
    NSDictionary *validDict = [self getValidDictionary:component];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(NSLocalizedString(@"Key is not one of valid keys", nil), component, key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
    }
    [StyleNode parse:[dict objectForKey:kNCTypeStyle] withComponent:component];
}
@end

@implementation StyleNode

+ (NSDictionary *)getValidDictionary:(NSString *)component
{
    if ([component isEqualToString:kNCContainerToolbar]) {
        return [NCNavigationBar defaultStyles];
    }
    if ([component isEqualToString:kNCContainerTabbar]) {
        return [MFTabBarController defaultStyles];
    }
    if ([component isEqualToString:kNCComponentButton]) {
        return [NCButton defaultStyles];
    }
    if ([component isEqualToString:kNCComponentBackButton]) {
        return [NCBackButton defaultStyles];
    }
    if ([component isEqualToString:kNCComponentLabel]) {
        return [NCLabel defaultStyles];
    }
    if ([component isEqualToString:kNCComponentSearchBox]) {
        return [NCSearchBox defaultStyles];
    }
    if ([component isEqualToString:kNCComponentSegment]) {
        return [NCSegment defaultStyles];
    }
    if ([component isEqualToString:kNCComponentTabbarItem]) {
        return [NCTabbarItem defaultStyles];
    }
    
    return  nil;
}

+ (void)parse:(NSMutableDictionary *)dict withComponent:(NSString *)component
{
    NSDictionary *validDict = [self getValidDictionary:component];
    NSEnumerator* enumerator = [[dict copy] keyEnumerator];
    id key;
    while (key = [enumerator nextObject]) {
        if ([validDict objectForKey:key] == nil) {
            NSLog(NSLocalizedString(@"Key is not one of valid keys", nil), component, key, [MFUIChecker dictionaryKeysToString:validDict]);
            continue;
        }
        if (![[MFUIChecker valueType:[dict objectForKey:key]] isEqualToString:[MFUIChecker valueType:[validDict valueForKey:key]]]) {
            if ([[MFUIChecker valueType:[dict objectForKey:key]] isEqualToString:@"Integer"] &&
                [[MFUIChecker valueType:[validDict valueForKey:key]] isEqualToString:@"Float"]) {
                continue;
            }
            NSLog(NSLocalizedString(@"Invalid value type", nil), component , key,
                  [MFUIChecker valueType:[validDict objectForKey:key]], [dict valueForKey:key]);
            [dict removeObjectForKey:key];
            continue;
        }
        if ([key isEqualToString:kNCStyleIOSBarStyle]) {
            [IOSBarStyleNode parse:[dict objectForKey:kNCStyleIOSBarStyle] withComponent:component];
        }
    }
}

@end

@implementation IOSBarStyleNode

+ (NSDictionary *)iosBarStyles
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [dict setValue:kNCTrue forKey:kNCBarStyleBlack];
    [dict setValue:kNCTrue forKey:kNCBarStyleBlackOpaque];
    [dict setValue:kNCTrue forKey:kNCBarStyleBlackTranslucent];
    [dict setValue:kNCTrue forKey:kNCBarStyleDefault];
    
    return dict;
}

+ (void)parse:(NSString *)style withComponent:(NSString *)component
{
    NSDictionary *validValue = [self iosBarStyles];
    if (![[validValue objectForKey:style] isEqualToString:kNCTrue]) {
        NSLog(NSLocalizedString(@"Value not in one of valid values", nil), component, style, [MFUIChecker dictionaryKeysToString:validValue]);
    }
}

@end
