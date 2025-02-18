//
//  CZHRecordTool.m
//  CZHRecordVoice
//
//  Created by 程召华 on 2018/9/3.
//  Copyright © 2018年 程召华. All rights reserved.
//
#define ALPHA 0.05f                 // 音频振幅调解相对值 (越小振幅就越高)
#import "CZHRecordTool.h"
#import <AVFoundation/AVFoundation.h>

@interface CZHRecordTool ()

@property (nonatomic, strong) AVAudioRecorder *audioRecorder;

@end


@implementation CZHRecordTool

+ (instancetype)shareInstance {
    static CZHRecordTool *_shareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[CZHRecordTool alloc] init];
    });
    return _shareInstance;
}

- (BOOL)initAudioRecorder
{
    // 0. 设置录音会话
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    // 1. 确定录音存放的位置
    NSURL *url = [NSURL URLWithString:self.recordPath];
    
    // 2. 设置录音参数
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    // 设置编码格式
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey: AVFormatIDKey];
    // 采样率
    [recordSettings setValue :[NSNumber numberWithFloat:8000] forKey: AVSampleRateKey];
    // 通道数
    [recordSettings setValue :[NSNumber numberWithInt:1] forKey: AVNumberOfChannelsKey];
    //线性采样位数  8、16、24、32
    [recordSettings setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    //录音的质量
    [recordSettings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
    
    // 3. 创建录音对象
    NSError *error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:url settings:recordSettings error:&error];
    _audioRecorder.meteringEnabled = YES;
    if (error) {
        return NO;
    }
    return YES;
}

- (void)czh_beginRecordWithRecordPath:(NSString *)recordPath {
    NSLog(@"------%@",recordPath);
    _isRecording = YES;
    _recordPath = recordPath;
    //    NSLog(@"创建中...");
    if (self.delegate && [self.delegate respondsToSelector:@selector(czh_prepareToRecording)]) {
        [self.delegate czh_prepareToRecording];
    }
    if (![self initAudioRecorder]) { // 初始化录音机
        NSLog(@"录音机创建失败...");
        if (self.delegate && [self.delegate respondsToSelector:@selector(czh_recordingFailed:)]) {
            [self.delegate czh_recordingFailed:@"录音器创建失败"];
        }
        return;
    };
    //    NSLog(@"创建完成...");
    [self micPhonePermissions:^(BOOL ishave) {
        if (ishave) {
            [self czh_startRecording];
        }else {
            [self showPermissionsAlert];
            //            NSLog(@"麦克风未开启权限");
        }
    }];
}

- (void)czh_startRecording {
    //    NSLog(@"startRecording...");
    if (!_isRecording) {
        return;
    }
    //    NSLog(@"初始化...");
    if (![self.audioRecorder prepareToRecord]) {
        NSLog(@"初始化录音机失败");
        if (self.delegate && [self.delegate respondsToSelector:@selector(czh_recordingFailed:)]) {
            [self.delegate czh_recordingFailed:@"录音器初始化失败"];
        }
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(czh_recording)]) {
        [self.delegate czh_recording];
    }
    [self.audioRecorder record];
    
    
}



- (void)czh_endRecord {
    _isRecording = NO;
    [self.audioRecorder stop];
}

- (void)czh_pauseRecord {
    [self.audioRecorder pause];
}

- (void)czh_deleteRecord {
    _isRecording = NO;
    [self.audioRecorder stop];
    [self.audioRecorder deleteRecording];
}

- (float)czh_updateLevels {
    [self.audioRecorder updateMeters];
    
    double aveChannel = pow(10, (ALPHA * [self.audioRecorder averagePowerForChannel:0]));
    if (aveChannel < 0) {
        aveChannel =0 ;
    }
    else if (aveChannel > 1){
        aveChannel = 1;
    }
    
    return aveChannel;
    
}

// 判断麦克风权限
- (void)micPhonePermissions:(void (^)(BOOL ishave))block  {
    __block BOOL ret = NO;
    AVAudioSession *avSession = [AVAudioSession sharedInstance];
    if ([avSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [avSession requestRecordPermission:^(BOOL available) {
            if (available) ret = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block(ret);
            });
        }];
    }
}

- (void)showPermissionsAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法录音" message:@"请在“设置-隐私-麦克风”中允许访问麦克风。" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}



@end
