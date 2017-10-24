//
//  ListView.h
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/15.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBConnecter.h"
#import "AppDelegate.h"

//循環参照の回避
@class MakeSettingViewController;
//Delegateメソッド
@protocol ListViewDelegate <NSObject>

- (NSMutableArray *)saveCheckList:(NSMutableArray *) ownArr;
- (NSMutableArray *)deleteCheckList:(NSInteger)delID delIndexPath:(NSIndexPath *)delIndexPath tableNumber:(NSInteger)tableNumber selectInfoArr:(NSMutableArray *)selectInfoArr;

@end

@interface ListView : UIView <UITableViewDelegate, UITableViewDataSource>

//Delegateプロパティ
@property (nonatomic, weak) id<ListViewDelegate> delegate;

//tableViewの判定フラグ
@property (nonatomic, assign) NSInteger mTableNumber;
//遷移元のviewControllerを格納
@property (nonatomic, strong) MakeSettingViewController *mMakeSettingView;
//storyboardのインスタンスを保持
@property (nonatomic, strong) UIStoryboard *mStoryboard;
//storyboardのnavigationcontrollerを保持
@property (nonatomic, strong) UINavigationController *mNavigationController;

@property (weak, nonatomic) IBOutlet UITableView *mListTable;
@property (weak, nonatomic) IBOutlet UIButton *mNewMakeBtn;
//DB関連
@property (nonatomic, strong) DBConnecter *mDBConnecter;

//チェックが入っているかを管理するフラグ
@property (nonatomic, assign) BOOL mCheckFlg;
//選択された情報のidを格納
@property (nonatomic, assign) NSInteger mSelectID;
//選択された情報を格納するArr
@property (nonatomic, strong) NSMutableArray *mSelectInfoArr;
//rootViewの格納
@property (nonatomic, strong) UIViewController *mFrontView;

- (id) initWithList :(NSInteger)tableNumber MakeViewCon :(MakeSettingViewController *)MakeViewCon;
//- (id) initWithList :(MakeSettingViewController *)MakeViewCon;

//MakeSettingViewControllerに戻った時にこのクラスのテーブルをreloadするMethod
- (void)reloadTable;

@end
