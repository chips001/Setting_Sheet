//
//  SetRelationData.h
//  SettingSheet
//
//  Created by 一木 英希 on 2017/02/23.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SetRelationData : NSObject

@property (nonatomic, assign) NSInteger id;           // id
@property (nonatomic, assign) NSInteger venue_id;    // 会場名id
@property (nonatomic, assign) NSInteger set_list_id; // 曲のid
@property (nonatomic, retain) NSDate *create_date;    // 登録日
@property (nonatomic, retain) NSDate *update_date;    // 更新日
@property (nonatomic, assign) BOOL delete_flag;       // 削除フラグ

@end
