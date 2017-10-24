//
//  ArtistData.h
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/08.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ArtistData : NSObject

//アーティスト情報
@property (nonatomic, assign) NSInteger id;           // id
@property (nonatomic, retain) NSString *artist_name;  // アーティスト名
@property (nonatomic, retain) NSString *artist_kana;  // アーティスト名フリガナ
@property (nonatomic, retain) NSString *photo_data;   // アーティストイメージ
@property (nonatomic, retain) NSString *tel;          // 連絡先電話番号
@property (nonatomic, retain) NSString *e_mail;       // 連絡先メールアドレス
@property (nonatomic, retain) NSString *hp_url;       // ホームページURL
@property (nonatomic, retain) NSString *sns_account;  // SNSアカウント
@property (nonatomic, retain) NSDate *create_date;    // 登録日
@property (nonatomic, retain) NSDate *update_date;    // 更新日
@property (nonatomic, assign) BOOL delete_flag;       // 削除フラグ

@end
