//
//  CommonHeader.h
//  CCIRecordVoice
//
//  Created by LiTengFei on 2018/10/11.
//

#ifndef CommonHeader_h
#define CommonHeader_h

/**屏幕宽度*/
#define CZHScreenWidth ([UIScreen mainScreen].bounds.size.width)
/**屏幕高度*/
#define CZHScreenHeight ([UIScreen mainScreen].bounds.size.height)

/**宽度比例*/
#define CZH_ScaleWidth(__VA_ARGS__)  ([UIScreen mainScreen].bounds.size.width/375)*(__VA_ARGS__)

/**高度比例*/
#define CZH_ScaleHeight(__VA_ARGS__)  ([UIScreen mainScreen].bounds.size.height/667)*(__VA_ARGS__)

/**字体比例*/
#define CZH_ScaleFont(__VA_ARGS__)  ([UIScreen mainScreen].bounds.size.width/375)*(__VA_ARGS__)


/**yes:是iphoneX*/
#define CZHIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

    //状态栏高度
#define CZHStatusHeight [[UIApplication sharedApplication] statusBarFrame].size.height
/**导航栏高度*/
#define CZHNavigationBarHeight (CZHIsiPhoneX ? 88 : 64)

#define CZHTabbarHeight (CZHIsiPhoneX ? 83 : 49)
    //
#define CZHSafeAreaBottomHeight (CZHIsiPhoneX ? 34 : 0)

    ///weakSelf
#define CZHWeakSelf(type)  __weak typeof(type) weak##type = type;
#define CZHStrongSelf(type)  __strong typeof(type) type = weak##type;


/**全局字体*/
#define CZHGlobleFont(__VA_ARGS__)  (CZHGlobelNormalFont(__VA_ARGS__))
#define CZHGlobelBoldFont(__VA_ARGS__) ([UIFont boldSystemFontOfSize:CZH_ScaleFont(__VA_ARGS__)])
#define CZHGlobelNormalFont(__VA_ARGS__) ([UIFont systemFontOfSize:CZH_ScaleFont(__VA_ARGS__)])


#define CZHColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define CZHRGBColor(rgbValue, a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
    //#define BWJRGBColor(r, g, b, a)  [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define CZHRandomColor  [UIColor colorWithRed:(arc4random_uniform(256))/255.0 green:(arc4random_uniform(256))/255.0 blue:(arc4random_uniform(256))/255.0 alpha:1]

/**宏定义打印*/
#ifdef DEBUG // 处于开发阶段
    //#define MLLog(format, ...) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] )
#define CZHLog(...) printf("%s\n",[[NSString stringWithFormat:__VA_ARGS__]UTF8String]);
#else // 处于发布阶段
#define CZHLog(...)
#endif

#endif /* CommonHeader_h */
