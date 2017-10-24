//
//  DBConnecter.m
//  hacoboon
//
//  Created by 一木　英希 on 2017/01/07.
//  Copyright © 2017年 一木 英希. All rights reserved.
//
#import "DBConnecter.h"

@interface DBConnecter ()

//DBファイルへのパス
@property (nonatomic, retain) NSString *dbPath;

@end

//DBのKEY
NSString *const AESkey = @"AES256Key";
//DBインスタンス格納用
static id sharedManagerInstance = nil;

@implementation DBConnecter

//DB接続用の共通インスタンスを生成し、returnする。
+ (id)sharedManager {
    if (sharedManagerInstance == nil) {
        sharedManagerInstance = [[self alloc] init];
        [sharedManagerInstance setUpDB];
    }
    return sharedManagerInstance;
}

//DBのシングルトンを保持する。
- (id)copyWithZone:(NSZone *)zone {
    // シングルトン状態を保持するため何もせず self を返す
    return self;
}

//DBの初期化を行う。
- (void)makeDB {
    //DBの初期化
    if (self.fmDB == nil) {
        NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentPath = [path objectAtIndex:0];
        self.dbPath = [documentPath stringByAppendingPathComponent:@"settingsheet.sqlite"];
        self.fmDB = [FMDatabase databaseWithPath:self.dbPath];
    }
}

//DBのテーブルを生成する。
- (void)setUpDB {
    //テーブルの生成
    [self makeDB];
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.dbPath]) {
        return;
    } else {
        [self.fmDB open];

        //テーブルの生成
        //セッティングシート情報テーブル
        NSString *createTable1 = @"CREATE TABLE setting_sheet_data (id integer PRIMARY KEY AUTOINCREMENT, venus_name none, live_date none, sheet_data none, create_date numeric, update_date numeric, delete_flag BOOL);";
        [self.fmDB executeUpdate:createTable1];

        //アーティスト情報テーブル
        NSString *createTable2 = @"CREATE TABLE artist_data (id integer PRIMARY KEY AUTOINCREMENT, artist_name none,artist_kana none, photo_data none, tel none, e_mail none, hp_url none, sns_account none, create_date numeric, update_date numeric, delete_flag BOOL);";
        [self.fmDB executeUpdate:createTable2];
        
        //メンバー情報テーブル
        NSString *createTable3 = @"CREATE TABLE member_data (id integer PRIMARY KEY AUTOINCREMENT, name none, instrument none, create_date numeric, update_date numeric, delete_flag BOOL);";
        [self.fmDB executeUpdate:createTable3];

        //セットリスト情報テーブル
        NSString *createTable4 = @"CREATE TABLE set_list_data (id integer PRIMARY KEY AUTOINCREMENT, song_name none, features none, create_date numeric, update_date numeric, delete_flag BOOL);";
        [self.fmDB executeUpdate:createTable4];
        
        //会場名情報テーブル
        NSString *createTable5 = @"CREATE TABLE venue_live_data (id integer PRIMARY KEY AUTOINCREMENT, venue_name none, live_date none, create_date numeric, update_date numeric, delete_flag BOOL);";
        [self.fmDB executeUpdate:createTable5];
        
        //会場名とセットリストの関係情報テーブル
        NSString *createTable6 = @"CREATE TABLE set_relation_data (id integer PRIMARY KEY AUTOINCREMENT, venue_id integer, set_list_id integer, create_date numeric, update_date numeric, delete_flag BOOL);";
        [self.fmDB executeUpdate:createTable6];

        [self.fmDB close];
    }
    return;
}

//count--------------------------------------------------------------------------------------------

//登録されているレイアウトの数を返す。
- (NSInteger)getSettingLayoutDataCount {
    //ご依頼主情報の有無のチェック
    NSInteger recordCount = 0;
    [self makeDB];
    [self.fmDB open];
    NSString *countSql   = @"SELECT COUNT(*) AS COUNT FROM setting_sheet_data;";
    FMResultSet *results = [self.fmDB executeQuery:countSql];
    
    while ([results next]) {
        recordCount = [results longForColumn:@"COUNT"];
    }
    [self.fmDB close];
    return recordCount;
}

//登録されているアーティスト情報の数を返す。
- (NSInteger)getArtistDataCount {
    //ご依頼主情報の有無のチェック
    NSInteger recordCount = 0;
    [self makeDB];
    [self.fmDB open];
    NSString *countSql   = @"SELECT COUNT(*) AS COUNT FROM artist_data;";
    FMResultSet *results = [self.fmDB executeQuery:countSql];

    while ([results next]) {
        recordCount = [results longForColumn:@"COUNT"];
    }
    [self.fmDB close];
    return recordCount;
}

//登録されているメンバー情報の数を返す。
- (NSInteger)getMemberDataCount {
    //ご依頼主情報の有無のチェック
    NSInteger recordCount = 0;
    [self makeDB];
    [self.fmDB open];
    NSString *countSql   = @"SELECT COUNT(*) AS COUNT FROM member_data;";
    FMResultSet *results = [self.fmDB executeQuery:countSql];
    
    while ([results next]) {
        recordCount = [results longForColumn:@"COUNT"];
    }
    [self.fmDB close];
    return recordCount;
}

//登録されている曲の数を返す。
- (NSInteger)getSetListDataCount {
    //ご依頼主情報の有無のチェック
    NSInteger recordCount = 0;
    [self makeDB];
    [self.fmDB open];
    NSString *countSql   = @"SELECT COUNT(*) AS COUNT FROM set_list_data;";
    FMResultSet *results = [self.fmDB executeQuery:countSql];
    
    while ([results next]) {
        recordCount = [results longForColumn:@"COUNT"];
    }
    [self.fmDB close];
    return recordCount;
}

//登録されている会場数を返す。
- (NSInteger)getVenueNameDataCount {
    //ご依頼主情報の有無のチェック
    NSInteger recordCount = 0;
    [self makeDB];
    [self.fmDB open];
    NSString *countSql   = @"SELECT COUNT(*) AS COUNT FROM venue_live_data;";
    FMResultSet *results = [self.fmDB executeQuery:countSql];
    
    while ([results next]) {
        recordCount = [results longForColumn:@"COUNT"];
    }
    [self.fmDB close];
    return recordCount;
}

//引数に付与した会場idに紐ずく曲数を返す。
- (NSInteger)getSetRelationCount: (NSInteger)venueID {
    //ご依頼主情報の有無のチェック
    NSInteger recordCount = 0;
    [self makeDB];
    [self.fmDB open];
    NSString *countSql   = @"SELECT COUNT(venue_id = ? or null) AS COUNT FROM set_relation_data;";
    FMResultSet *results = [self.fmDB executeQuery:countSql, [NSNumber numberWithInteger:venueID]];
    
    while ([results next]) {
        recordCount = [results longForColumn:@"COUNT"];
    }
    [self.fmDB close];
    return recordCount;
}

//encrypt/decrypt-------------------------------------------------------------------------------------

//DBに保存するデータの配列に対し、暗号化メソッドを適用する。
- (NSMutableArray *)encrypt:(NSMutableArray *)valueArr {
    //暗号化した配列を返却
    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
    Util *util = [[Util alloc] init];
    for (int i = 0; i < [valueArr count]; i++) {
        NSString *valueStr = [valueArr objectAtIndex:i];
        NSData *valueData = [valueStr dataUsingEncoding:NSUTF8StringEncoding];
        NSData *value = [util AES256EncryptWithKey:AESkey data:valueData];
        [resultArr addObject:value];
    }
    return resultArr;
}

//DBに暗号化して保存されたデータを取り出す際、復号化メソッドを適用する。
- (NSString *)decrypt:(NSData *)value {
    //暗号化されたデータを複合
    Util *util = [[Util alloc] init];
    NSData *valueData = [util AES256DecryptWithKey:AESkey data:value];
    NSString *resultvalue = [[NSString alloc] initWithData:valueData encoding:NSUTF8StringEncoding];
    NSLog(@"result:%@", resultvalue);
    return resultvalue;
}

//insert-----------------------------------------------------------------------------------------------

//DBにデータを格納する
//- (void)inputCompletionInsertDB:(LayoutData *)settingSheetData setArtistDataInstance:(ArtistData *)artistData setMemberDataInstance:(MemberData *)memberData setSetListDataInstance:(SetListData *)setListData {
//    
//    //新規登録
//    [self makeDB];
//    [self.fmDB open];
//
//    //セッティングシート情報の格納
//    NSMutableArray *settingSheetValueArr  = [[NSMutableArray alloc] init];
//    NSMutableArray *settingSheetResultArr = [[NSMutableArray alloc] init];
//    //会場名
//    [settingSheetValueArr addObject:settingSheetData.venus_name];
////    //ライブ日時
////    [settingSheetValueArr addObject:settingSheetData.live_date];
//    //セッティングシート情報
//    [settingSheetValueArr addObject:settingSheetData.sheet_data];
//    //データの暗号化
//    settingSheetResultArr = [self encrypt:settingSheetValueArr];
//    NSString *insertData1 = @"INSERT INTO setting_sheet_data (venus_name, live_date, sheet_data, create_date, update_date, delete_flag) VALUES (?, ?, ?, ?, ?, ?);";
//    [self.fmDB executeUpdate:insertData1, [settingSheetResultArr objectAtIndex:0], [settingSheetResultArr objectAtIndex:1], [settingSheetResultArr objectAtIndex:2], [NSDate date], [NSDate date], @0];
//    
//    
//    //アーティスト情報の格納
////    NSInteger updataFlg = 0; //[self getGuestClientDataCount];
////    NSString *countSql   = @"SELECT COUNT(*) AS COUNT FROM artist_data;";
////    FMResultSet *results = [self.fmDB executeQuery:countSql];
////    while ([results next]) {
////        updataFlg = [results longForColumn:@"COUNT"];
////    }
//    NSMutableArray *artistValueArr = [[NSMutableArray alloc]init];
//    NSMutableArray *artistResultArr = [[NSMutableArray alloc]init];
//    //アーティスト名
//    [artistValueArr addObject:artistData.artist_name];
//    //アーティスト名フリガナ
//    [artistValueArr addObject:artistData.artist_kana];
//    //アーティストイメージ
//    [artistValueArr addObject:artistData.photo_data];
//    //連絡先電話番号
//    [artistValueArr addObject:artistData.tel];
//    //連絡先メールアドレス
//    [artistValueArr addObject:artistData.e_mail];
//    //ホームページURL
//    [artistValueArr addObject:artistData.hp_url];
//    //SNSアカウント
//    [artistValueArr addObject:artistData.sns_account];
//    //データの暗号化
//    artistResultArr = [self encrypt:artistValueArr];
////    if (updataFlg == 0) {
//        //新規登録
//        NSString *insertData2 = @"INSERT INTO artist_data (artist_name, artist_kana, photo_data, tel, e_mail, hp_url, sns_account, create_date, update_date, delete_flag) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
//        [self.fmDB executeUpdate:insertData2, [artistResultArr objectAtIndex:0],[artistResultArr objectAtIndex:1], [artistResultArr objectAtIndex:2], [artistResultArr objectAtIndex:3], [artistResultArr objectAtIndex:4], [artistResultArr objectAtIndex:5], [artistResultArr objectAtIndex:6], [artistResultArr objectAtIndex:7], [artistResultArr objectAtIndex:8], [artistResultArr objectAtIndex:9], [NSDate date], [NSDate date], @0];
////    } else {
////        //更新
////        NSString *updateData = @"UPDATE artist_data SET artist_name =?, photo_data =?, tel =?, e_mail =?, hp_url =?, sns_account =?, update_date =?, delete_flag =? where id = ?;";
////        [self.fmDB executeUpdate:updateData, [artistResultArr objectAtIndex:0], [artistResultArr objectAtIndex:1], [artistResultArr objectAtIndex:2], [artistResultArr objectAtIndex:3], [artistResultArr objectAtIndex:4], [artistResultArr objectAtIndex:5], [artistResultArr objectAtIndex:6], [artistResultArr objectAtIndex:7], [artistResultArr objectAtIndex:8], [NSDate date], @0, @(updataFlg)];
////    }
//
//
//    //メンバー情報の格納
//    NSMutableArray *memberValueArr  = [[NSMutableArray alloc] init];
//    NSMutableArray *memberResultArr = [[NSMutableArray alloc] init];
//    //メンバー名
//    [memberValueArr addObject:memberData.name];
//    //楽器
//    [memberValueArr addObject:memberData.instrument];
//    //データの暗号化
//    memberResultArr = [self encrypt:memberValueArr];
//    NSString *insertData3 = @"INSERT INTO member_data (name, instrument, create_date, update_date, delete_flag) VALUES (?, ?, ?, ?, ?);";
//    [self.fmDB executeUpdate:insertData3, [memberResultArr objectAtIndex:0], [memberResultArr objectAtIndex:1], [NSDate date], [NSDate date], @0];
//    
//    
//    //曲情報の格納
//    NSMutableArray *setListValueArr  = [[NSMutableArray alloc] init];
//    NSMutableArray *setListResultArr = [[NSMutableArray alloc] init];
//    //曲名
//    [setListValueArr addObject:setListData.song_name];
//    //曲の特長
//    [setListValueArr addObject:setListData.features];
//    //データの暗号化
//    setListResultArr = [self encrypt:setListValueArr];
//    NSString *insertData4 = @"INSERT INTO set_list_data (song_name, features, create_date, update_date, delete_flag) VALUES (?, ?, ?, ?, ?);";
//    [self.fmDB executeUpdate:insertData4, [setListResultArr objectAtIndex:0], [setListResultArr objectAtIndex:1], [NSDate date], [NSDate date], @0];
//
//    [self.fmDB close];
//}

- (void)insertLayoutData:(LayoutData *)layoutData{
    //新規登録
    [self makeDB];
    [self.fmDB open];
    
    //レイアウト情報の格納
    NSMutableArray *layoutDataValueArr  = [[NSMutableArray alloc] init];
    NSMutableArray *layoutDataResultArr = [[NSMutableArray alloc] init];
    //会場名
    [layoutDataValueArr addObject:layoutData.venus_name];
    //ライブ日時
    [layoutDataValueArr addObject:layoutData.live_date];
    //セッティングシート情報
    [layoutDataValueArr addObject:layoutData.sheet_data];
    //データの暗号化
    layoutDataResultArr = [self encrypt:layoutDataValueArr];
    NSString *insertData1 = @"INSERT INTO setting_sheet_data (venus_name, live_date, sheet_data, create_date, update_date, delete_flag) VALUES (?, ?, ?, ?, ?, ?);";
    [self.fmDB executeUpdate:insertData1, [layoutDataResultArr objectAtIndex:0], [layoutDataResultArr objectAtIndex:1], [layoutDataResultArr objectAtIndex:2], [NSDate date], [NSDate date], @0];
    
    [self.fmDB close];
}

//アーティスト情報をDBに格納
- (void)insertArtistData:(ArtistData *)artistData {
    //新規登録
    [self makeDB];
    [self.fmDB open];
    
    //アーティスト情報の格納
    //    NSInteger updataFlg = 0; //[self getGuestClientDataCount];
    //    NSString *countSql   = @"SELECT COUNT(*) AS COUNT FROM artist_data;";
    //    FMResultSet *results = [self.fmDB executeQuery:countSql];
    //    while ([results next]) {
    //        updataFlg = [results longForColumn:@"COUNT"];
    //    }
    NSMutableArray *artistValueArr = [[NSMutableArray alloc]init];
    NSMutableArray *artistResultArr = [[NSMutableArray alloc]init];
    //アーティスト名(必須)
    [artistValueArr addObject:artistData.artist_name];
    //アーティスト名フリガナ(必須)
    [artistValueArr addObject:artistData.artist_kana];
    //アーティストイメージ
    [artistValueArr addObject:artistData.photo_data];
    //連絡先電話番号(必須)
    [artistValueArr addObject:artistData.tel];
    //連絡先メールアドレス(必須)
    [artistValueArr addObject:artistData.e_mail];
    //ホームページURL
    [artistValueArr addObject:artistData.hp_url];
    //SNSアカウント
    [artistValueArr addObject:artistData.sns_account];
    //データの暗号化
    artistResultArr = [self encrypt:artistValueArr];
    
    NSLog(@"%@",[artistValueArr objectAtIndex:0]);
    //    if (updataFlg == 0) {
    //新規登録
    NSString *insertData2 = @"INSERT INTO artist_data (artist_name, artist_kana, photo_data, tel, e_mail, hp_url, sns_account, create_date, update_date, delete_flag) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);";
    [self.fmDB executeUpdate:insertData2, [artistResultArr objectAtIndex:0],[artistResultArr objectAtIndex:1], [artistResultArr objectAtIndex:2], [artistResultArr objectAtIndex:3], [artistResultArr objectAtIndex:4], [artistResultArr objectAtIndex:5], [artistResultArr objectAtIndex:6], [NSDate date], [NSDate date], @0];
    //    } else {
    //        //更新
    //        NSString *updateData = @"UPDATE artist_data SET artist_name =?, photo_data =?, tel =?, e_mail =?, hp_url =?, sns_account =?, update_date =?, delete_flag =? where id = ?;";
    //        [self.fmDB executeUpdate:updateData, [artistResultArr objectAtIndex:0], [artistResultArr objectAtIndex:1], [artistResultArr objectAtIndex:2], [artistResultArr objectAtIndex:3], [artistResultArr objectAtIndex:4], [artistResultArr objectAtIndex:5], [artistResultArr objectAtIndex:6], [artistResultArr objectAtIndex:7], [artistResultArr objectAtIndex:8], [NSDate date], @0, @(updataFlg)];
    //    }
    [self.fmDB close];
}

//メンバー情報をDBに格納
- (void)insertMemberData:(MemberData *)memberData {
    //新規登録
    [self makeDB];
    [self.fmDB open];
    
    //メンバー情報の格納
    NSMutableArray *memberValueArr  = [[NSMutableArray alloc] init];
    NSMutableArray *memberResultArr = [[NSMutableArray alloc] init];
    //メンバー名
    [memberValueArr addObject:memberData.name];
    //楽器
    [memberValueArr addObject:memberData.instrument];
    
    //データの暗号化
    memberResultArr = [self encrypt:memberValueArr];
    NSString *insertData3 = @"INSERT INTO member_data (name, instrument, create_date, update_date, delete_flag) VALUES (?, ?, ?, ?, ?);";
    [self.fmDB executeUpdate:insertData3, [memberResultArr objectAtIndex:0], [memberResultArr objectAtIndex:1], [NSDate date], [NSDate date], @0];
    
    [self.fmDB close];
}

//曲情報をDBに格納
- (void)insertSongData:(SetListData *)setListData {
    //新規登録
    [self makeDB];
    [self.fmDB open];
    
    //メンバー情報の格納
    NSMutableArray *songValueArr  = [[NSMutableArray alloc] init];
    NSMutableArray *songResultArr = [[NSMutableArray alloc] init];
    //メンバー名
    [songValueArr addObject:setListData.song_name];
    //楽器
    [songValueArr addObject:setListData.features];
    
    //データの暗号化
    songResultArr = [self encrypt:songValueArr];
    NSString *insertData4 = @"INSERT INTO set_list_data (song_name, features, create_date, update_date, delete_flag) VALUES (?, ?, ?, ?, ?);";
    [self.fmDB executeUpdate:insertData4, [songResultArr objectAtIndex:0], [songResultArr objectAtIndex:1], [NSDate date], [NSDate date], @0];
    
    [self.fmDB close];
}

- (NSInteger)insertVenueData:(VenueLiveData *)venueLiveData {
    //新規登録
    [self makeDB];
    [self.fmDB open];
    
    //メンバー情報の格納
    NSMutableArray *venueValueArr  = [[NSMutableArray alloc] init];
    NSMutableArray *venueResultArr = [[NSMutableArray alloc] init];
    //メンバー名
    [venueValueArr addObject:venueLiveData.venue_name];
    //楽器
    [venueValueArr addObject:venueLiveData.live_date];
    
    //データの暗号化
    venueResultArr = [self encrypt:venueValueArr];
    NSString *insertData5 = @"INSERT INTO venue_live_data (venue_name, live_date, create_date, update_date, delete_flag) VALUES (?, ?, ?, ?, ?);";
    [self.fmDB executeUpdate:insertData5, [venueResultArr objectAtIndex:0], [venueResultArr objectAtIndex:1], [NSDate date], [NSDate date], @0];
    
    //追加したレコードのIDを取得
    NSInteger maxId = 0;
    NSString *maxSql   = @"SELECT MAX(id) AS id FROM venue_live_data;";
    FMResultSet *results = [self.fmDB executeQuery:maxSql];
    
    while ([results next]) {
        maxId = [results longForColumn:@"id"];
    }
    [self.fmDB close];
    return maxId;
}

//会場名とセットリストの関係情報をDBに格納
- (void)insertRelationData:(SetRelationData *)setRelationData {
    //新規登録
    [self makeDB];
    [self.fmDB open];
    
    //メンバー情報の格納
    NSMutableArray *relationValueArr  = [[NSMutableArray alloc] init];
    //会場ID
    [relationValueArr addObject:@(setRelationData.venue_id)];
    //曲ID
    [relationValueArr addObject:@(setRelationData.set_list_id)];
    
    //ただのIDである為、暗号化は行わない(暗号化メソッドはNSStringにしか対応しない為、NSNumberを渡すと落ちる)
    NSString *insertData6 = @"INSERT INTO set_relation_data (venue_id, set_list_id, create_date, update_date, delete_flag) VALUES (?, ?, ?, ?, ?);";
    [self.fmDB executeUpdate:insertData6, [relationValueArr objectAtIndex:0], [relationValueArr objectAtIndex:1], [NSDate date], [NSDate date], @0];
    [self.fmDB close];
}

//select-----------------------------------------------------------------------------------------------

//セッティングシート一覧をDBから取得する。
- (NSMutableArray *)getSettingSheetList {
    //セッティングシート一覧の取得
    //レコードごとにArrayに格納
    NSMutableArray *settingSheetDataArr = [[NSMutableArray alloc] init];

    NSString *select = @"SELECT * FROM setting_sheet_data ORDER BY id DESC;";

    [self makeDB];
    [self.fmDB open];

    FMResultSet *rs = [self.fmDB executeQuery:select];
    while ([rs next]) {
        LayoutData *layoutData = [[LayoutData alloc] init];
        //id
        layoutData.id = [rs longForColumn:@"id"];
        //会場名
        NSData *venusName = [rs dataForColumn:@"venus_name"];
        layoutData.venus_name = [self decrypt:venusName];
        //ライブ日時
        NSData *liveDay = [rs dataForColumn:@"live_date"];
        layoutData.live_date = [self decrypt:liveDay];
        //セッティングシート情報
        NSData *layoutShreetData = [rs dataForColumn:@"sheet_data"];
        layoutData.sheet_data = [self decrypt:layoutShreetData];
        //登録日
        layoutData.create_date = [rs dateForColumn:@"create_date"];
        //更新日
        layoutData.update_date = [rs dateForColumn:@"update_date"];
        //削除フラグ
        layoutData.delete_flag = [rs boolForColumn:@"delete_flag"];
        
        [settingSheetDataArr addObject:layoutData];
    }
    [self.fmDB close];
    return settingSheetDataArr;
}

//アーティスト情報をDBから取得する。
- (NSMutableArray *)getArtistData {
    //アーティスト情報の取得
    //レコードごとにArrayに格納
    NSMutableArray *artistDataArr = [[NSMutableArray alloc] init];
    
    NSString *select = @"SELECT * FROM artist_data ORDER BY id DESC;";
    
    [self makeDB];
    [self.fmDB open];
    
    FMResultSet *rs = [self.fmDB executeQuery:select];
    while ([rs next]) {
        ArtistData *artistData = [[ArtistData alloc] init];
        //id
        artistData.id = [rs longForColumn:@"id"];
        //アーティスト名
        NSData *artistName = [rs dataForColumn:@"artist_name"];
        artistData.artist_name = [self decrypt:artistName];
        //アーティスト名フリガナ
        NSData *artistKana = [rs dataForColumn:@"artist_kana"];
        artistData.artist_kana = [self decrypt:artistKana];
        //アーティストイメージ
        NSData *photoData = [rs dataForColumn:@"photo_data"];
        artistData.photo_data = [self decrypt:photoData];
        //連絡先電話番号
        NSData *tel = [rs dataForColumn:@"tel"];
        artistData.tel = [self decrypt:tel];
        //連絡先メールアドレス
        NSData *eMail = [rs dataForColumn:@"e_mail"];
        artistData.e_mail = [self decrypt:eMail];
        //ホームページURL
        NSData *hpUrl = [rs dataForColumn:@"hp_url"];
        artistData.hp_url = [self decrypt:hpUrl];
        //SNSアカウント
        NSData *snsAccount = [rs dataForColumn:@"sns_account"];
        artistData.sns_account = [self decrypt:snsAccount];
        //登録日
        artistData.create_date = [rs dateForColumn:@"create_date"];
        //更新日
        artistData.update_date = [rs dateForColumn:@"update_date"];
        //削除フラグ
        artistData.delete_flag = [rs boolForColumn:@"delete_flag"];
        
        [artistDataArr addObject:artistData];
    }
    [self.fmDB close];
    return artistDataArr;
}

//メンバー一覧情報をDBから取得する。
- (NSMutableArray *)getMemberList {
    //メンバー一覧情報の取得
    //レコードごとにArrayに格納
    NSMutableArray *memberListArr = [[NSMutableArray alloc] init];
    
    NSString *select = @"SELECT * FROM member_data ORDER BY id DESC;";
    
    [self makeDB];
    [self.fmDB open];
    
    FMResultSet *rs = [self.fmDB executeQuery:select];
    while ([rs next]) {
        MemberData *memberData = [[MemberData alloc] init];
        //id
        memberData.id = [rs longForColumn:@"id"];
        //メンバー名
        NSData *name = [rs dataForColumn:@"name"];
        memberData.name = [self decrypt:name];
        //楽器
        NSData *instrument = [rs dataForColumn:@"instrument"];
        memberData.instrument = [self decrypt:instrument];
        //登録日
        memberData.create_date = [rs dateForColumn:@"create_date"];
        //更新日
        memberData.update_date = [rs dateForColumn:@"update_date"];
        //削除フラグ
        memberData.delete_flag = [rs boolForColumn:@"delete_flag"];
        
        [memberListArr addObject:memberData];
    }
    [self.fmDB close];
    return memberListArr;
}

//セットリスト一覧情報をDBから取得する。
- (NSMutableArray *)getSetList {
    //曲一覧情報の取得
    //レコードごとにArrayに格納
    NSMutableArray *setListArr = [[NSMutableArray alloc] init];
    
    NSString *select = @"SELECT * FROM set_list_data ORDER BY id DESC;";
    
    [self makeDB];
    [self.fmDB open];
    
    FMResultSet *rs = [self.fmDB executeQuery:select];
    while ([rs next]) {
        SetListData *setListData = [[SetListData alloc] init];
        //id
        setListData.id = [rs longForColumn:@"id"];
        //曲名
        NSData *songName = [rs dataForColumn:@"song_name"];
        setListData.song_name = [self decrypt:songName];
        //楽器
        NSData *features = [rs dataForColumn:@"features"];
        setListData.features = [self decrypt:features];
        //登録日
        setListData.create_date = [rs dateForColumn:@"create_date"];
        //更新日
        setListData.update_date = [rs dateForColumn:@"update_date"];
        //削除フラグ
        setListData.delete_flag = [rs boolForColumn:@"delete_flag"];
        
        [setListArr addObject:setListData];
    }
    [self.fmDB close];
    return setListArr;
}

//会場名一覧情報をDBから取得する。
- (NSMutableArray *)getVenueNameList {
    //曲一覧情報の取得
    //レコードごとにArrayに格納
    NSMutableArray *venueNameListArr = [[NSMutableArray alloc] init];
    
    NSString *select = @"SELECT * FROM venue_live_data ORDER BY id DESC;";
    
    [self makeDB];
    [self.fmDB open];
    
    FMResultSet *rs = [self.fmDB executeQuery:select];
    while ([rs next]) {
        VenueLiveData *venueLiveData = [[VenueLiveData alloc] init];
        //id
        venueLiveData.id = [rs longForColumn:@"id"];
        //会場名
        NSData *venueName = [rs dataForColumn:@"venue_name"];
        venueLiveData.venue_name = [self decrypt:venueName];
        //ライブ日時
        NSData *liveDay = [rs dataForColumn:@"live_date"];
        venueLiveData.live_date = [self decrypt:liveDay];
        //登録日
        venueLiveData.create_date = [rs dateForColumn:@"create_date"];
        //更新日
        venueLiveData.update_date = [rs dateForColumn:@"update_date"];
        //削除フラグ
        venueLiveData.delete_flag = [rs boolForColumn:@"delete_flag"];
        
        [venueNameListArr addObject:venueLiveData];
    }
    [self.fmDB close];
    return venueNameListArr;
}

//delete-----------------------------------------------------------------------------------------------

//選択されたセッティングシートの情報を削除する。
- (void)deleteSettingSheetList:(NSInteger)id {
    //セッティングシートの削除
    //delete文の作成
    NSString *delete = [[NSString alloc] initWithFormat:@"DELETE from setting_sheet_data where id= ?"];

    [self makeDB];
    [self.fmDB open];
    [self.fmDB executeUpdate:delete, [NSNumber numberWithInteger:id]];
    [self.fmDB close];
}

//選択されたアーティストの情報を削除する。
- (void)deleteArtistData:(NSInteger)id {
    //メンバー情報の削除
    //delete文の作成
    NSString *delete = [[NSString alloc] initWithFormat:@"DELETE from artist_data where id= ?"];
    
    [self makeDB];
    [self.fmDB open];
    [self.fmDB executeUpdate:delete, [NSNumber numberWithInteger:id]];
    [self.fmDB close];
}

//選択されたメンバーの情報を削除する。
- (void)deleteMemberData:(NSInteger)id {
    //メンバー情報の削除
    //delete文の作成
    NSString *delete = [[NSString alloc] initWithFormat:@"DELETE from member_data where id= ?"];
    
    [self makeDB];
    [self.fmDB open];
    [self.fmDB executeUpdate:delete, [NSNumber numberWithInteger:id]];
    [self.fmDB close];
}

//選択された曲の情報を削除する。
- (void)deleteSetList:(NSInteger)id {
    //曲の削除
    //delete文の作成
    NSString *delete = [[NSString alloc] initWithFormat:@"DELETE from set_list_data where id= ?"];
    
    [self makeDB];
    [self.fmDB open];
    [self.fmDB executeUpdate:delete, [NSNumber numberWithInteger:id]];
    [self.fmDB close];
}

//選択された会場の情報とそれに紐づくSetListのデータを削除する。
- (void)deleteVenueLiveData:(NSInteger)id {
    //ライブ会場とそれに紐づく情報の削除(曲情報は消さない)
    //delete文の作成
    NSString *deleteVenueData = [[NSString alloc] initWithFormat:@"DELETE from venue_live_data where id= ?"];
    NSString *deleteRelationData = [[NSString alloc] initWithFormat:@"DELETE from set_relation_data where venue_id= ?"];

    [self makeDB];
    [self.fmDB open];
    [self.fmDB executeUpdate:deleteVenueData, [NSNumber numberWithInteger:id]];
    [self.fmDB executeUpdate:deleteRelationData, [NSNumber numberWithInteger:id]];
    [self.fmDB close];
}

////セッティングシート暗号化用のArrayを作成し、encryptメソッドを適用する。
//- (NSMutableArray *)settingEncrypt:(SettingSheetData *)settingSheetData {
//    NSMutableArray *valueArr = [[NSMutableArray alloc] init];
//    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
//
//    //会場名
//    [valueArr addObject:settingSheetData.venus_name];
//    //ライブ日時
//    [valueArr addObject:settingSheetData.live_date];
//    //セッティングシート情報
//    [valueArr addObject:settingSheetData.sheet_data];
//
//    resultArr = [self encrypt:valueArr];
//    return resultArr;
//}
//
////アーティスト情報暗号化用のArrayを作成し、encryptメソッドを適用する。
//- (NSMutableArray *)artistEncrypt:(ArtistData *)artistData {
//    NSMutableArray *valueArr = [[NSMutableArray alloc] init];
//    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
//
//    //アーティスト名
//    [valueArr addObject:artistData.artist_name];
//    //アーティストイメージ
//    [valueArr addObject:artistData.photo_data];
//    //連絡先電話番号
//    [valueArr addObject:artistData.tel];
//    //連絡先メールアドレス
//    [valueArr addObject:artistData.e_mail];
//    //ホームページURL
//    [valueArr addObject:artistData.hp_url];
//    //SNSアカウント
//    [valueArr addObject:artistData.sns_account];
//
//    resultArr = [self encrypt:valueArr];
//    return resultArr;
//}
//
////メンバー情報暗号化用のArrayを作成し、encryptメソッドを適用する。
//- (NSMutableArray *)memberEncrypt:(MemberData *)memberData {
//    NSMutableArray *valueArr = [[NSMutableArray alloc] init];
//    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
//
//    //メンバー名
//    [valueArr addObject:memberData.name];
//    //楽器
//    [valueArr addObject:memberData.instrument];
//
//    resultArr = [self encrypt:valueArr];
//    return resultArr;
//}
//
////曲情報暗号化用のArrayを作成し、encryptメソッドを適用する。
//- (NSMutableArray *)setListEncrypt:(SetListData *)setListData {
//    NSMutableArray *valueArr  = [[NSMutableArray alloc] init];
//    NSMutableArray *resultArr = [[NSMutableArray alloc] init];
//
//    //曲名
//    [valueArr addObject:setListData.song_name];
//    //曲の特長
//    [valueArr addObject:setListData.features];
//
//    resultArr = [self encrypt:valueArr];
//    return resultArr;
//}

@end
