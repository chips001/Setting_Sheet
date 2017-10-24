//
//  Util.m
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/07.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import "Util.h"
#import <CommonCrypto/CommonCryptor.h>

//Toolbarの高さ
const NSInteger TOOLBAR_HEIGHT = 44;

@implementation Util

/**
 @brief dataを暗号化する。
 
 @par 概要
 指定されたkey(AESKeyとして定義)でdataをAES256暗号化する。
 
 @par 処理
 1. cryptStatusにAES暗号化アルゴリズムのステータスを格納する。
 2. cryptStatusに関し、全ての暗号化ステータスにエラーがなければ、暗号化したデータをreturnする。
 3. エラーがあればnilをreturnする。
 
 @param key 暗号化のkey
 @param data 暗号化対象のデータ
 @return 暗号化したデータ
 
 */
- (NSData *)AES256EncryptWithKey:(NSString *)key data:(NSData *)data {
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer      = malloc(bufferSize);
    
    size_t numBytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES256, NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize, &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    free(buffer);
    return nil;
}

/**
 @brief dataを復号する。
 
 @par 概要
 指定されたkey(AESKeyとして定義)でdataをAES256復号化する。
 
 @par 処理
 1. cryptStatusにAES復号化アルゴリズムのステータスを格納する。
 2. cryptStatusに関し、全ての復号化ステータスにエラーがなければ、復号化したデータをreturnする。
 3. エラーがあればnilをreturnする。
 
 @param key 暗号化のkey
 @param data 復号対象のデータ
 @return 復号化したデータ
 */
- (NSData *)AES256DecryptWithKey:(NSString *)key data:(NSData *)data {
    char keyPtr[kCCKeySizeAES256 + 1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer      = malloc(bufferSize);
    
    size_t numBytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCKeySizeAES256, NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize, &numBytesDecrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    free(buffer);
    return nil;
}

+ (UIToolbar *)makeToolBar:(id)implementationClass{
    
    NSInteger toolBarWidth = [[UIScreen mainScreen] bounds].size.width;
    
    //完了ボタンの生成
    //implementationClass:使用するクラスを引数にして生成
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, toolBarWidth, TOOLBAR_HEIGHT)];
    toolBar.barStyle = UIBarStyleBlack;
    [toolBar sizeToFit];
    // 「完了」ボタンを右端に配置したいためフレキシブルなスペースを作成する。
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    UIBarButtonItem *compBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:implementationClass action:@selector(closeKeyboard:)];
    NSArray *toolBarItems = [NSArray arrayWithObjects:spacer, compBtn, nil];
    [toolBar setItems:toolBarItems animated:YES];
    
    return toolBar;
}

-(void)closeKeyboard:(id)sender{
    [sender resignFirstResponder];
}

//画像をDBに格納する際にBase64エンコードする。
+ (NSString *)encodeToBase64String:(UIImage *)image {
    NSData * data = [UIImagePNGRepresentation(image) base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return [NSString stringWithUTF8String:[data bytes]];
}

//DBに格納してあるエンコードデータを画像にデコードする。
+ (UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}

+ (void)makeCancelAlert:(UIViewController *)viewCon{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Caution!" message:@"The data being edited will not be saved, is it OK?\n編集中のデータは保存されません。\nよろしいですか？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        //Alertを閉じて前の画面に戻る
        [alert dismissViewControllerAnimated:YES completion:nil];
        [viewCon dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    [viewCon presentViewController:alert animated:YES completion:nil];
}

@end
