//
//  Util.h
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/07.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>
#import <UIKit/UIKit.h>

@class Util;
@protocol UtilDelegate <NSObject>

@end

@interface Util : NSObject

- (NSData *)AES256EncryptWithKey:(NSString *)key data:(NSData *)data;
- (NSData *)AES256DecryptWithKey:(NSString *)key data:(NSData *)data;
//画像をDBに格納する際にBase64エンコードする。
+ (NSString *)encodeToBase64String:(UIImage *)image;
//DBに格納してあるエンコードデータを画像にデコードする。
+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData;
//キーボードの完了ボタンの生成
+ (UIToolbar *)makeToolBar:(id)implementationClass;
//キャンセルボタン押下時の処理
+ (void)makeCancelAlert:(UIViewController *)viewCon;

@end
