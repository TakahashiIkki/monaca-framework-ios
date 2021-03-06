//
//  NCTitleView.m
//  MonacaFramework
//
//  Created by Nakagawa Hiroki on 11/12/22.
//  Copyright (c) 2011年 ASIAL CORPORATION. All rights reserved.
//

#import "NCTitleView.h"
#import "MFDelegate.h"
#import "MFDevice.h"
#import "MFUtility.h"
#import "MFViewManager.h"
#import "UILabel+Resize.h"

@implementation NCTitleView

@synthesize type = _type;

static const CGFloat kSizeOfTitleFont             = 14.0f;
static const CGFloat kSizeOfSubtitleFont          = 11.0f;
static const CGFloat kSizeOfLandscapeTitleFont    = 18.0f;
static const CGFloat kSizeOfPortraitTitleFont     = 19.0f;

- (id)init {
    self = [super init];
    
    if (self) {

        _title = [[UILabel alloc] init];
        _subtitle = [[UILabel alloc] init];
        _type = kNCStyleTitle;
        _titleImageView = [[UIImageView alloc] init];

        [_title setBackgroundColor:[UIColor clearColor]];
        _title.textAlignment = UITextAlignmentCenter;
        [_title setFont:[UIFont boldSystemFontOfSize:kSizeOfTitleFont]];
        [_title setTextColor:[UIColor whiteColor]];
#ifdef XCODE5
        // iOS7では影はつけない
        if ([MFDevice iOSVersionMajor] <= 6) {
            _title.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        }
#else
            _title.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
#endif
        [_subtitle setBackgroundColor:[UIColor clearColor]];
        _subtitle.textAlignment = UITextAlignmentCenter;
        [_subtitle setFont:[UIFont boldSystemFontOfSize:kSizeOfTitleFont]];
        [_subtitle setTextColor:[UIColor whiteColor]];

#ifdef XCODE5
        // iOS7では影はつけない
        if ([MFDevice iOSVersionMajor] <= 6) {
            _subtitle.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        }
#else
            _subtitle.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
#endif
        [self addSubview:_title];
        [self addSubview:_subtitle];
        [self addSubview:_titleImageView];
        _ncStyle = [[NCStyle alloc] initWithComponent:kNCContainerToolbar];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self sizeToFit];
}

- (void)sizeToFit
{
    [_title sizeToFit];
    [_subtitle sizeToFit];
    
    if (![[self retrieveUIStyle:kNCStyleTitleImage] isEqualToString:kNCUndefined]) {
        [_titleImageView setHidden:NO];
        [_title setHidden:YES];
        [_subtitle setHidden:YES];
        _titleImageView.frame = CGRectMake(-_titleImageView.image.size.width/2.0f, -_titleImageView.image.size.height/2.0f,
                                           _titleImageView.image.size.width, _titleImageView.image.size.height);
        [_titleImageView sizeToFit];
    } else {
        [_title setHidden:NO];
        [_subtitle setHidden:NO];
        [_titleImageView setHidden:YES];
    }
    if (UIInterfaceOrientationIsLandscape([MFUtility currentInterfaceOrientation])) {
        _title.font = [UIFont boldSystemFontOfSize:kSizeOfLandscapeTitleFont * [[self retrieveUIStyle:kNCStyleTitleFontScale] floatValue]];
        _title.frame = [_title resizedFrameWithPoint:CGPointMake(0, 0)];
        [_title setCenter:CGPointMake(self.frame.size.width/2.0f, self.frame.size.height/2.0f)];
        [_subtitle setHidden:YES];
    } else {
        if (![[self retrieveUIStyle:kNCStyleSubtitle] isEqual:kNCUndefined]) {
            _title.font = [UIFont boldSystemFontOfSize:kSizeOfTitleFont * [[self retrieveUIStyle:kNCStyleTitleFontScale] floatValue]];
            _subtitle.font = [UIFont systemFontOfSize:kSizeOfSubtitleFont * [[self retrieveUIStyle:kNCStyleSubtitleFontScale] floatValue]];
            _title.frame = [_title resizedFrameWithPoint:CGPointMake(0, 0)];
            _subtitle.frame = [_subtitle resizedFrameWithPoint:CGPointMake(0, 0)];
            _title.center = CGPointMake(0, -8);
            _subtitle.center = CGPointMake(0, 10);
        } else {
            _title.font = [UIFont boldSystemFontOfSize:kSizeOfPortraitTitleFont * [[self retrieveUIStyle:kNCStyleTitleFontScale] floatValue]];
            _title.frame = [_title resizedFrameWithPoint:CGPointMake(0, 0)];
            _title.center = CGPointMake(0, self.frame.size.height/2.0f);
            [_subtitle setHidden:YES];
        }
    }
    _title.frame = CGRectIntegral(_title.frame);
    _subtitle.frame = CGRectIntegral(_subtitle.frame);
    
}

#pragma mark - UIStyleProtocol

- (void)updateUIStyle:(id)value forKey:(NSString *)key
{
    if (value == [NSNull null]) {
        value = kNCUndefined;
    }
    if ([NSStringFromClass([[_ncStyle.styles valueForKey:key] class]) isEqualToString:@"__NSCFBoolean"]) {
        if (isFalse(value)) {
            value = kNCFalse;
        } else {
            value = kNCTrue;
        }
    }
    
    if ([key isEqualToString:kNCStyleTitle]) {
        value = [NSString stringWithFormat:@"%@", value];
        if ([value isEqualToString:kNCUndefined]) {
            [_title setText:@" "];
        } else {
            [_title setText:value];
        }
    }
    if ([key isEqualToString:kNCStyleSubtitle]) {
        value = [NSString stringWithFormat:@"%@", value];
        if ([value isEqualToString:kNCUndefined]) {
            [_subtitle setText:@" "];
        } else {
            [_subtitle setText:value];
        }
    }
    if ([key isEqualToString:kNCStyleTitleColor]) {
        [_title setTextColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleSubtitleColor]) {
        [_subtitle setTextColor:hexToUIColor(removeSharpPrefix(value), 1)];
    }
    if ([key isEqualToString:kNCStyleTitleFontScale]) {
        if (UIInterfaceOrientationIsLandscape([MFUtility currentInterfaceOrientation])) {
            [_title setFont:[UIFont boldSystemFontOfSize:kSizeOfLandscapeTitleFont * [value floatValue]]];
        } else {
            if (![[self retrieveUIStyle:kNCStyleSubtitle] isEqual:kNCUndefined]) {
                [_title setFont:[UIFont boldSystemFontOfSize:kSizeOfTitleFont * [value floatValue]]];
            } else {
                [_title setFont:[UIFont boldSystemFontOfSize:kSizeOfPortraitTitleFont * [value floatValue]]];
            }
        }
    }
    if ([key isEqualToString:kNCStyleSubtitleFontScale]) {
        [_subtitle setFont:[UIFont boldSystemFontOfSize:kSizeOfSubtitleFont * [value floatValue]]];
    }
    if ([key isEqualToString:kNCStyleTitleImage]) {
        NSString *imagePath = [[MFViewManager currentWWWFolderName] stringByAppendingPathComponent:value];
        _titleImageView.image = [UIImage imageWithContentsOfFile:imagePath];
        _titleImageView.contentMode = UIViewContentModeCenter;
    }
    
    [_ncStyle updateStyle:value forKey:key];
    // 必ずupdateしてから実行
    [self sizeToFit];
}

- (id)retrieveUIStyle:(NSString *)key
{
    if ([key isEqualToString:@"title"] || [key isEqualToString:@"subTitle"]) {
        return [NSString stringWithFormat:@"%@", [_ncStyle retrieveStyle:key]];
    } else {
        return [_ncStyle retrieveStyle:key];
    }
}

@end
