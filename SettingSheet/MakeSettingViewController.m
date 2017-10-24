//
//  MakeSettingViewController.m
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/07.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import "MakeSettingViewController.h"
#import "TabBarController.h"
#import "DBConnecter.h"

//ページの枚数
const NSInteger PAGE_TOTAL = 3;
//UIPageControlの高さ
const NSInteger CONTROL_HEIGHT  = 50;


@interface MakeSettingViewController ()

//ステータスバーの高さを格納
@property (nonatomic, assign) NSInteger mStatusHeight;
//ナビゲーションバーの高さを格納
@property (nonatomic, assign) NSInteger mNavigationHeight;
//タブバーの高さを格納
@property (nonatomic, assign) NSInteger mTabHeight;
//PageControlの格納
@property (nonatomic, strong) UIPageControl *mPageControl;
//DB関連
@property (nonatomic, strong) DBConnecter *mDBConnecter;


//楽器画像格納用配列
@property (nonatomic, strong) NSMutableArray *mInstrumentPngArr;
//楽器view格納用配列
@property (nonatomic, strong) NSMutableArray *mInstrumentViewArr;
//土台となるScrollViewを格納
@property (nonatomic, strong) UIScrollView *mScrollView;
//生成されたListViewを格納
@property (nonatomic, strong) NSMutableArray *mListViewArr;
//ListViewで選択された値を受け取り格納しておくArr(check管理用)
@property (nonatomic, strong) NSMutableArray *mSelectInfoArr;
//ListViewで選択された値を受け取り格納しておくArr
@property (nonatomic, strong) NSMutableArray *mListViewSelectArr;

@end

@implementation MakeSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //プロパティの初期化
    self.mListViewArr = [[NSMutableArray alloc]init];
    self.mSelectInfoArr = [[NSMutableArray alloc]init];
    self.mListViewSelectArr = [[NSMutableArray alloc]init];
    self.mDBConnecter = [DBConnecter sharedManager];
    
    //StatusBar/NavigationBar/TabBarの高さを取得
    self.mStatusHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    self.mNavigationHeight = self.navigationController.navigationBar.frame.size.height;
    self.mTabHeight = self.tabBarController.tabBar.bounds.size.height;
    
    //画面のサイズを取得
    NSInteger viewWidth = self.view.bounds.size.width;
    NSInteger viewHeight = self.view.bounds.size.height;
    
    // UIScrollViewの生成
    NSInteger scrollOrignY = self.mStatusHeight + self.mNavigationHeight;
    NSInteger scrollHeight = viewHeight - (self.mStatusHeight + self.mNavigationHeight + self.mTabHeight + CONTROL_HEIGHT);
    CGRect scrollFrame = CGRectMake(self.view.bounds.origin.x, scrollOrignY, viewWidth, scrollHeight);
    self.mScrollView = [[UIScrollView alloc]initWithFrame:scrollFrame];
    
    // スクロールのインジケータを非表示にする
    self.mScrollView.showsHorizontalScrollIndicator = NO;
    self.mScrollView.showsVerticalScrollIndicator = NO;
    self.mScrollView.pagingEnabled = YES;
    self.mScrollView.userInteractionEnabled = YES;
    self.mScrollView.bounces = NO;
    self.mScrollView.delegate = self;
    
    // スクロールする範囲を設定
    NSInteger contentWidth = viewWidth * PAGE_TOTAL;
    
    // 縦にはスクロールしない為、heightは「0」を設定
    NSInteger contentHeight = 0;
    [self.mScrollView setContentSize: CGSizeMake(contentWidth, contentHeight)];
    self.mScrollView.backgroundColor = [UIColor grayColor];
    // スクロールビューを貼付ける
    [self.view addSubview:self.mScrollView];
    
    // ページコントロールの生成
    NSInteger controlOriginY = scrollHeight + self.mStatusHeight + self.mNavigationHeight;
    NSInteger controlWidth = self.view.bounds.size.width;
    self.mPageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(0, controlOriginY, controlWidth, CONTROL_HEIGHT)];
    self.mPageControl.backgroundColor = [UIColor blackColor];
    // pageControlのページ数を設定
    self.mPageControl.numberOfPages = PAGE_TOTAL;
    // 現在のページを設定
    self.mPageControl.currentPage = 0;
    self.mPageControl.userInteractionEnabled = NO;
    // ページコントロールを貼付ける
    [self.view addSubview:self.mPageControl];
    
    // スクロールビューに各画面の土台を生成
    NSInteger baseViewOriginY = - (self.mStatusHeight + self.mNavigationHeight);
    for (NSInteger i = 0; i < PAGE_TOTAL; i ++) {
        CGRect viewRect = CGRectMake(i * viewWidth, baseViewOriginY, viewWidth, scrollHeight);
        UIView *baseView = [[UIView alloc]initWithFrame:viewRect];
        [self.mScrollView addSubview: baseView];
        //リストの作成
        ListView *listView = [[ListView alloc]initWithList:i MakeViewCon:self];
        [baseView addSubview: listView];
        
        //ListViewでチェックされたCellはこちらで管理
        listView.delegate = self;
        NSLog(@"TableView_Tag = %ld",i);
        
        //生成したListViewを格納
        [self.mListViewArr addObject:listView];
    }
}


//選択したCellを格納するListViewのDelegateメソッド
- (NSMutableArray *) saveCheckList: (NSMutableArray *)ownArr{

    //比較のためにNSIntegerをNSNumberに変換
    NSNumber *newTableNumber = [ownArr objectAtIndex:0];
    NSLog(@"%@",newTableNumber);
    
    //選択されたテーブルの選択した情報をArrから削除
    if ([self.mSelectInfoArr count] > 0) {
        
        for (NSInteger i = 0; i < [self.mSelectInfoArr count]; i++) {
            NSMutableArray *delDateArr = [self.mSelectInfoArr objectAtIndex:i];
            NSNumber *delTableNumber = [delDateArr objectAtIndex:0];
            
            //Checkが外されたTableの情報を削除
            if ([newTableNumber isEqualToNumber: delTableNumber]) {
                [self.mSelectInfoArr removeObjectAtIndex:i];
            }
        }
        NSLog(@"管理用Arrの中身 = %@",self.mSelectInfoArr);
    }
    
    //cell管理用のArrに格納
    [self.mSelectInfoArr addObject:ownArr];
    NSLog(@"管理用Arrの中身 = %@",self.mSelectInfoArr);
    
    //cell管理用Arrの返却
    return self.mSelectInfoArr;
}

//deleteが押下された時にArrから選択されたものを削除してArrを更新
- (NSMutableArray *)deleteCheckList:(NSInteger)delID delIndexPath:(NSIndexPath *)delIndexPath tableNumber:(NSInteger)tableNumber selectInfoArr:(NSMutableArray *)selectInfoArr{
    
    self.mSelectInfoArr = selectInfoArr;
    NSLog(@"%@",self.mSelectInfoArr);
    NSLog(@"%ld",[self.mSelectInfoArr count]);
    
    //格納されてる情報の更新
//    if (rowCount > 0) {
        if ([self.mSelectInfoArr count] > 0) {
            
            for (NSInteger i = 0; i < [self.mSelectInfoArr count]; i++) {
                
                NSMutableArray *editInfoArr = [self.mSelectInfoArr objectAtIndex:i];
                //0:TableNumber 1:SelectID 2:indexPath(選択しているcellのナンバー)
                NSNumber *editIndexPath = [editInfoArr objectAtIndex:2];
                
                //比較の為にdelIDをNSNumberに変換
                NSNumber *delINdexPath = @(delIndexPath.row);
                
                NSComparisonResult result = [delINdexPath compare:editIndexPath];
                //delINdexNumがeditNumより小さい場合、editNumを-1
                if (result == NSOrderedAscending) {
                    NSInteger editIndexPathInt = [editIndexPath integerValue];
                    
                    NSIndexPath *correctionIndexPath = [NSIndexPath indexPathForRow:editIndexPathInt - 1 inSection:0];
                    [editInfoArr replaceObjectAtIndex:2 withObject:@(correctionIndexPath.row)];
                    [self.mSelectInfoArr replaceObjectAtIndex:i withObject:editInfoArr];
                    
                    NSLog(@"%@",self.mSelectInfoArr);
                    
                }
            }
        }
    
    if (tableNumber == 0) {
        [self.mDBConnecter deleteSettingSheetList:delID];
        
    }else if (tableNumber == 1){
        [self.mDBConnecter deleteArtistData:delID];
        
    }else if (tableNumber == 2){
        [self.mDBConnecter deleteVenueLiveData:delID];
    }
    
    NSLog(@"%@",self.mSelectInfoArr);
    
    return self.mSelectInfoArr;
}

//画面に戻ってきた直後にリロード
- (void)viewDidAppear:(BOOL)animated{
}

//スクロールビューがスワイプされたとき
- (void)scrollViewDidScroll:(UIScrollView *)_scrollView
{
    //fmod(x,y):x/yの余りを返す
    NSInteger pageWidth = self.mScrollView.frame.size.width;
    if ((NSInteger)fmod(self.mScrollView.contentOffset.x , pageWidth) == 0) {
        // ページコントロールに現在のページを設定
        self.mPageControl.currentPage = self.mScrollView.contentOffset.x / pageWidth;
    }
}

- (void) makeSettingSheetList{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
