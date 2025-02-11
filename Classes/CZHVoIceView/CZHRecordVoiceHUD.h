//
//  CZHRecordVoiceHUD.h
//  CZHRecordVoice
//
//  Created by 程召华 on 2018/9/3.
//  Copyright © 2018年 程召华. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CZHColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

typedef NS_ENUM(NSInteger, CZHRecordVoiceHUDType) {
    ///开始录制
    CZHRecordVoiceHUDTypeBeginRecord,
    ///正在录制
    CZHRecordVoiceHUDTypeRecording,
    ///松开取消
    CZHRecordVoiceHUDTypeReleaseToCancle,
    ///音频太短
    CZHRecordVoiceHUDTypeAudioTooShort,
    ///音频太长
    CZHRecordVoiceHUDTypeAudioTooLong,
    ///结束
    CZHRecordVoiceHUDTypeEndRecord,
};

@interface CZHRecordVoiceHUD : UIView

+ (instancetype)shareInstance;
///刷新视图
- (void)czh_showHUDWithType:(CZHRecordVoiceHUDType)type;
///时间太长自动发送
@property (nonatomic, copy) void (^longTimeHandler)(void);

- (void)showHUDWithType:(CZHRecordVoiceHUDType)type;

@property (nonatomic,assign,readonly) NSInteger seconds;
@end
