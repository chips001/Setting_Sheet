//
//  SettingSheetData.h
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/08.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayoutData : NSObject

//セッティングシート情報
@property (nonatomic, assign) NSInteger id;           // id
@property (nonatomic, retain) NSString *venus_name;   // 会場名
@property (nonatomic, retain) NSString *live_date;      // ライブ日時
@property (nonatomic, retain) NSString *sheet_data;   // セッティングシート情報
@property (nonatomic, retain) NSDate *create_date;    // 登録日
@property (nonatomic, retain) NSDate *update_date;    // 更新日
@property (nonatomic, assign) BOOL delete_flag;       // 削除フラグ

@end
