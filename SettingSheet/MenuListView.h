//
//  MenuListView.h
//  misha
//
//  Created by 一木　英希 on 2016/03/08.
//  Copyright © 2016年 clincs. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "DBConnecter.h"
#import "Util.h"

@protocol MenuListViewDelegate <NSObject>

-(void)transitionPost:(NSInteger)transitionTag;

@end

@interface MenuListView : UIView <UITableViewDataSource,UITableViewDelegate,UtilDelegate>{
}

//@property (nonatomic, weak)id<MenuListViewDelegate> delegate;
//@property (nonatomic) NSInteger mTransitionTag;
//@property (nonatomic,retain) UIButton* mCooperationActionBtn;
//@property (nonatomic) BOOL mFacebookFlg;
//@property (nonatomic) BOOL mTwitterFlg;

@property (nonatomic, strong)DBConnecter *mDBConnecter;
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (weak, nonatomic) IBOutlet UILabel *mNameLbl;
@property (weak, nonatomic) IBOutlet UITextField *mNameField;
@property (weak, nonatomic) IBOutlet UILabel *mInstrumentLbl;
@property (weak, nonatomic) IBOutlet UIButton *mAddMemberBtn;
@property (weak, nonatomic) IBOutlet UITextField *mInstrumentField;
@property (weak, nonatomic) IBOutlet UILabel *mInfoLbl;

//初回表示との分岐の為にRowの数を保持
@property (nonatomic, assign) NSInteger mRowCount;

//編集完了時の名前/楽器名を保持
@property (nonatomic, strong) NSString *mName;
@property (nonatomic, strong) NSString *mInstrument;

//Checkの入ったindex保持用Arr;
@property (nonatomic, strong) NSMutableArray *mCheckIndexArr;
//追加したメンバーの情報の格納用Arr
@property (nonatomic, strong) NSMutableArray *mArtistMemberArr;
//最前面の画面を格納
@property (nonatomic, strong) UIViewController *mModalView;

//初期化メソッド
- (id)initWithFrame:(CGRect)frame modalView:(UIViewController *)modalView;

@end
