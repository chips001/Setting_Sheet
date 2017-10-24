//
//  DBConnecter.h
//  hacoboon
//
//  Created by 一木　英希 on 2017/01/07.
//  Copyright © 2017年 一木 英希. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Util.h"
#import "FMDatabase.h"
#import "LayoutData.h"
#import "ArtistData.h"
#import "MemberData.h"
#import "SetListData.h"
#import "VenueLiveData.h"
#import "SetRelationData.h"

@interface DBConnecter : NSObject

//FMDBのインスタンス
@property (nonatomic, retain) FMDatabase *fmDB;

+ (id)sharedManager;
- (void)setUpDB;

//新規登録
//- (void)inputCompletionInsertDB:(LayoutData *)settingSheetData setArtistDataInstance:(ArtistData *)artistData setMemberDataInstance:(MemberData *)memberData setSetListDataInstance:(SetListData *)setListData;

//レイアウト情報を格納
- (void)insertLayoutData:(LayoutData *)layoutData;
//アーティスト情報を格納
- (void)insertArtistData:(ArtistData *)artistData;
//メンバー情報を格納
- (void)insertMemberData:(MemberData *)memberData;
//曲情報をDBに格納
- (void)insertSongData:(SetListData *)setListData;
//会場名、ライブ日時をDBに格納し、格納したデータのIDを返す
- (NSInteger)insertVenueData:(VenueLiveData *)venueLiveData;
//会場名とセットリストの関係情報をDBに格納
- (void)insertRelationData:(SetRelationData *)setRelationData;

//セッティングシートのレイアウト情報の有無
- (NSInteger)getSettingLayoutDataCount;
//アーティスト情報の有無
- (NSInteger)getArtistDataCount;
//メンバーの数取得
- (NSInteger)getMemberDataCount;
//曲の数取得
- (NSInteger)getSetListDataCount;
//登録されている会場数を返す。
- (NSInteger)getVenueNameDataCount;
//引数に付与した会場idに紐ずく曲数を返す。
- (NSInteger)getSetRelationCount: (NSInteger)venueID;

//セッティングシート一覧の取得
- (NSMutableArray *)getSettingSheetList;
//アーティスト情報を取得する。
- (NSMutableArray *)getArtistData;
//メンバー一覧情報を取得する。
- (NSMutableArray *)getMemberList;
//セットリスト一覧情報をDBから取得する。
- (NSMutableArray *)getSetList;
//会場名一覧情報をDBから取得する。
- (NSMutableArray *)getVenueNameList;

//選択されたセッティングシートの情報を削除する。
- (void)deleteSettingSheetList:(NSInteger)id;
//選択されたアーティストの情報を削除する。
- (void)deleteArtistData:(NSInteger)id;
//選択されたメンバーの情報を削除する。
- (void)deleteMemberData:(NSInteger)id;
//選択された曲の情報を削除する。
- (void)deleteSetList:(NSInteger)id;
//選択された会場の情報とそれに紐づくSetListのデータを削除する。
- (void)deleteVenueLiveData:(NSInteger)id;

@end
