//
//  ListView.m
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/15.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import "ListView.h"
#import "LayoutViewController.h"
#import "ArtistViewController.h"
#import "SetListViewController.h"
#import "MenuListView.h"

#import "DBConnecter.h"
#import "ArtistData.h"

//各CustomCellのimport
#import "SettingSheetEditCell.h"

//.hの@class MakeSettingViewControllerと記載してプロパティを定義しこちらでimport
//循環参照を回避
#import "MakeSettingViewController.h"


//セルの高さ
#define CUSTOM_CELL_HEIGHT 65
//CellのID
#define EDIT_CELL_IDENTIFIER @"SettingSheetEditCell"


@implementation ListView

// xibと紐付け
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UINib *nib = [UINib nibWithNibName:@"ListView" bundle:nil];
        self = [nib instantiateWithOwner:nil options:nil][0];
    }
    return self;
}

- (id) initWithList :(NSInteger)tableNumber MakeViewCon :(MakeSettingViewController *)MakeViewCon{

    if (self = [super init]) {
        
        //Main.storyboardのIDはinfo.plistのMainstoryboard file base name で確認可能
        if (self.mStoryboard == nil || self.mNavigationController == nil) {
            self.mStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.mNavigationController = [self.mStoryboard instantiateViewControllerWithIdentifier:@"MakeSettingNavigaion"];
        }
        
        //各プロパティの初期化
        self.mDBConnecter = [DBConnecter sharedManager];
        self.mSelectInfoArr = [[NSMutableArray alloc]init];
        self.mCheckFlg = NO;
        
        //最前面のView
        AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
        self.mFrontView = delegate.window.rootViewController;
        
        //CustomCellの登録
        [self.mListTable registerNib:[UINib nibWithNibName:@"SettingSheetEditCell" bundle:nil]
              forCellReuseIdentifier:EDIT_CELL_IDENTIFIER];
        
        //numberOfRowsInSection/cellForRowAtIndexPath/numberOfSectionsInTableViewはUITableViewDataSourceプロトコルに属することから「tableView.dataSource = self;」がないと、Delegateの受け手にならない(呼ばれない)。
        self.mListTable.delegate = self;
        self.mListTable.dataSource = self;
        
        self.mTableNumber = tableNumber;
        self.mMakeSettingView = MakeViewCon;
        [self makeListTable];
    }
    return self;
}

//作成済みのデータを表示
- (void) makeListTable{
    
    if (self.mTableNumber == 0) {
        [self.mNewMakeBtn setTitle:@"+ Make New StageLayout" forState:UIControlStateNormal];
    }else if (self.mTableNumber == 1){
        [self.mNewMakeBtn setTitle:@"+ Make New Artist Information" forState:UIControlStateNormal];
    }else if (self.mTableNumber == 2){
        [self.mNewMakeBtn setTitle:@"+ Make New Setlist" forState:UIControlStateNormal];
    }
}

- (IBAction)newMakeAction:(id)sender {
    
    if (self.mTableNumber == 0) {
        LayoutViewController *layoutView = [self.mStoryboard instantiateViewControllerWithIdentifier:@"LayoutViewController"];
        layoutView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;        
        [self.mMakeSettingView presentViewController:layoutView animated:YES completion:nil];
        
    }else if (self.mTableNumber == 1){
        ArtistViewController *artistView = [self.mStoryboard instantiateViewControllerWithIdentifier:@"ArtistViewController"];
        artistView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        //この画面に戻ってきた際にListViewをreloadさせる為に遷移先にインスタンスを渡す
        artistView.mArtistListView = self;
        
        [self.mMakeSettingView presentViewController:artistView animated:YES completion:nil];
        
    }else if (self.mTableNumber == 2){
        SetListViewController *setlistView = [self.mStoryboard instantiateViewControllerWithIdentifier:@"SetListViewController"];
        setlistView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        //この画面に戻ってきた際にListViewをreloadさせる為に遷移先にインスタンスを渡す
        setlistView.mArtistListView = self;
        
        [self.mMakeSettingView presentViewController:setlistView animated:YES completion:nil];
    }
}

//cellのタップで反応:セル描画直前の処理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //cellのチェック処理を行う
    [self cellCheck:indexPath];
//    
//    //選択したcellをチェック
//    SettingSheetEditCell *cell = [self.mListTable cellForRowAtIndexPath:indexPath];
//    
//    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
//        
//        //cellが選択されているcellと同じ場合
//        //cellの選択解除
//        [self.mListTable deselectRowAtIndexPath:indexPath animated:YES];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_off.png"];
//        cell.accessoryType = UITableViewCellAccessoryNone;
//        cell.mCellDeleteBtn.hidden = NO;
//        
//    }else{
//        
//        //cellが選択されたcellと異なる場合
//        //cellの選択解除
//        [self.mListTable deselectRowAtIndexPath:indexPath animated:YES];
//        
//        //一旦全てのセルの選択を解除
//        for (SettingSheetEditCell *cell in [self.mListTable visibleCells]) {
//            cell.accessoryType = UITableViewCellAccessoryNone;
//            cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_off.png"];
//            cell.accessoryType = UITableViewCellAccessoryNone;
//            cell.mCellDeleteBtn.hidden = NO;
//        }
//        
//        //選択したcellをチェック
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_on.png"];
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//        cell.mCellDeleteBtn.hidden = YES;
//        
//        //最終的に必要となる情報のidを格納
//        self.mSelectID = cell.mCellDeleteBtn.tag;
//        NSLog(@"%ld",self.mTableNumber);
//        NSLog(@"%ld",self.mSelectID);
//    }
//    
//    //必要な情報をArrに追加
//    NSMutableArray *ownArr = [[NSMutableArray alloc]init];
//    [ownArr addObject:@(self.mTableNumber)];
//    [ownArr addObject:@(self.mSelectID)];
//    [ownArr addObject:@(indexPath.row)];
//    
//    //保存は外部で行いcheckされたセルの情報を受け取る。
//    self.mSelectInfoArr = [self.delegate saveCheckList:ownArr];
//    NSLog(@"%@",self.mSelectInfoArr);
}

//cellのチェック処理を行う
- (void)cellCheck:(NSIndexPath *)indexPath{
    
    //選択したcellをチェック
    SettingSheetEditCell *cell = [self.mListTable cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        
        //cellが選択されているcellと同じ場合
        //cellの選択解除
        [self.mListTable deselectRowAtIndexPath:indexPath animated:YES];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_off.png"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mCellDeleteBtn.hidden = NO;
        
    }else{
        
        //cellが選択されたcellと異なる場合
        //cellの選択解除
        [self.mListTable deselectRowAtIndexPath:indexPath animated:YES];
        
        //一旦全てのセルの選択状態を解除
        for (SettingSheetEditCell *cell in [self.mListTable visibleCells]) {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_off.png"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.mCellDeleteBtn.hidden = NO;
        }
        
        //選択したcellをチェック
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_on.png"];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.mCellDeleteBtn.hidden = YES;
        
        //最終的に必要となる情報のidを格納
        self.mSelectID = cell.mCellDeleteBtn.tag;
        NSLog(@"%ld",self.mTableNumber);
        NSLog(@"%ld",self.mSelectID);
    }
    
    //必要な情報をArrに追加
    NSMutableArray *ownArr = [[NSMutableArray alloc]init];
    [ownArr addObject:@(self.mTableNumber)];
    [ownArr addObject:@(self.mSelectID)];
    [ownArr addObject:@(indexPath.row)];
    
    //保存は外部で行いcheckされたセルの情報を受け取る。
    self.mSelectInfoArr = [self.delegate saveCheckList:ownArr];
    NSLog(@"%@",self.mSelectInfoArr);

}


//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return CUSTOM_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSLog(@"%@",@"ロウの数呼ばれました");

    NSInteger rowCount = 0;
    
    if (self.mTableNumber == 0) {
        rowCount = [self.mDBConnecter getSettingLayoutDataCount];

    }else if (self.mTableNumber == 1){
        rowCount = [self.mDBConnecter getArtistDataCount];

    }else if (self.mTableNumber == 2){
        rowCount = [self.mDBConnecter getVenueNameDataCount];
    }
    
    if (rowCount == 0) {
        return 5;
    }else{
        NSLog(@"%ld",rowCount);
        return rowCount;
    }
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *cellIdentifier = EDIT_CELL_IDENTIFIER;
    SettingSheetEditCell *cell = [self.mListTable dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil){
        cell = [[SettingSheetEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (self.mTableNumber == 0) {
        //Layoutリスト
        cell.accessoryType = UITableViewCellAccessoryNone;
        //セル押下時ハイライトの無効化
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //NameLabelの生成:1
        cell.mCellEditMainLbl.font= [UIFont boldSystemFontOfSize:13];
        
        //InstrumentLabelの生成:2
        cell.mCellEditSubLbl.font= [UIFont boldSystemFontOfSize:13];
        
        //初回表示との分岐
        if ([self.mDBConnecter getArtistDataCount] == 0) {
            cell.mCellEditMainLbl.text = @"No artist name data";
            cell.mCellEditSubLbl.text = @"No artist create data";
            cell.mCellDeleteBtn.hidden = YES;
            cell.mCellDeleteBtn.enabled = NO;
            
            self.mListTable.allowsSelection = false;
        }else{
            NSMutableArray *artistListArr = [self.mDBConnecter getArtistData];
            
            if ([artistListArr count] > indexPath.row) {
                ArtistData *artistData = [artistListArr objectAtIndex:indexPath.row];
                cell.mCellEditMainLbl.text = artistData.artist_name;
                
                NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
                dateformat.dateFormat  = @"yyyy/MM/dd";
                NSString *dateStr = [dateformat stringFromDate:artistData.create_date];
                cell.mCellEditSubLbl.text = dateStr;
                
                cell.mCellDeleteBtn.hidden = NO;
                cell.mCellDeleteBtn.enabled = YES;
                //memberのidをdelボタンのタグとして保持
                cell.mCellDeleteBtn.tag = artistData.id;
                
                self.mListTable.allowsSelection = true;
            }
        }
        
    }else if (self.mTableNumber == 1){
        //Artistリスト
        cell.accessoryType = UITableViewCellAccessoryNone;
        //セル押下時ハイライトの無効化
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //NameLabelの生成:1
        cell.mCellEditMainLbl.font= [UIFont boldSystemFontOfSize:13];
        //InstrumentLabelの生成:2
        cell.mCellEditSubLbl.font= [UIFont boldSystemFontOfSize:13];
        
        //初回表示との分岐
        if ([self.mDBConnecter getArtistDataCount] == 0) {
            cell.mCellEditMainLbl.text = @"No artist name data";
            cell.mCellEditSubLbl.text = @"No artist create data";
            cell.mCellDeleteBtn.hidden = YES;
            cell.mCellDeleteBtn.enabled = NO;
            
            self.mListTable.allowsSelection = false;
        }else{
            NSMutableArray *artistListArr = [self.mDBConnecter getArtistData];

            if ([artistListArr count] > indexPath.row) {
                ArtistData *artistData = [artistListArr objectAtIndex:indexPath.row];
                cell.mCellEditMainLbl.text = artistData.artist_name;
                
                NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
                dateformat.dateFormat  = @"yyyy/MM/dd";
                NSString *dateStr = [dateformat stringFromDate:artistData.create_date];
                cell.mCellEditSubLbl.text = dateStr;
                
                cell.mCellDeleteBtn.hidden = NO;
                cell.mCellDeleteBtn.enabled = YES;
                //memberのidをdelボタンのタグとして保持
                cell.mCellDeleteBtn.tag = artistData.id;
                
                self.mListTable.allowsSelection = true;
            }
        }
        
    }else if (self.mTableNumber == 2){
        //Setlistリスト
        cell.accessoryType = UITableViewCellAccessoryNone;
        //セル押下時ハイライトの無効化
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //NameLabelの生成:1
        cell.mCellEditMainLbl.font= [UIFont boldSystemFontOfSize:13];
        //InstrumentLabelの生成:2
        cell.mCellEditSubLbl.font= [UIFont boldSystemFontOfSize:13];
        
        //初回表示との分岐
        if ([self.mDBConnecter getVenueNameList] == 0) {
            cell.mCellEditMainLbl.text = @"No venue name data";
            cell.mCellEditSubLbl.text = @"No live day data";
            cell.mCellDeleteBtn.hidden = YES;
            cell.mCellDeleteBtn.enabled = NO;
            
            self.mListTable.allowsSelection = false;
        }else{
            NSMutableArray *venueNameArr = [self.mDBConnecter getVenueNameList];
            
            if ([venueNameArr count] > indexPath.row) {
                VenueLiveData *venueNameData = [venueNameArr objectAtIndex:indexPath.row];
                cell.mCellEditMainLbl.text = venueNameData.venue_name;
                cell.mCellEditSubLbl.text = venueNameData.live_date;

                cell.mCellDeleteBtn.hidden = NO;
                cell.mCellDeleteBtn.enabled = YES;
                //memberのidをdelボタンのタグとして保持
                cell.mCellDeleteBtn.tag = venueNameData.id;
                
                self.mListTable.allowsSelection = true;
            }
        }
    }
    
    //Deleteボタンの生成:3
    [cell.mCellDeleteBtn addTarget:self action:@selector(deleteBtnAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [cell.mCellDeleteBtn setTitle:@"del" forState:UIControlStateNormal];
    
    if ([self.mSelectInfoArr count] > 0) {
        
        for (int i = 0; i < [self.mSelectInfoArr count] ; i++) {
            NSMutableArray *editArr = [self.mSelectInfoArr objectAtIndex:i];
            NSInteger saveTableInt = [[editArr objectAtIndex:0] integerValue];
            
            if (saveTableInt == self.mTableNumber) {
                //チェックされているセルを取り出す
                NSInteger editCheckCell = [[editArr objectAtIndex:2] integerValue];
                NSInteger indexPatnInt = indexPath.row;
                
                if (editCheckCell == indexPatnInt) {
                    cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_on.png"];
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    cell.mCellDeleteBtn.hidden = YES;
                    
                }else{
                    cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_off.png"];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.mCellDeleteBtn.hidden = NO;

                }
            }
        }
    }else{
        cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_off.png"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mCellDeleteBtn.hidden = NO;
    }
    
    return cell;
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event{
    NSLog(@"%@",self.mListTable);
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.mListTable];
    NSIndexPath *indexPath = [self.mListTable indexPathForRowAtPoint:point];
    NSLog(@"%ld",indexPath.row);
    return indexPath;
}

//Deleteボタン押下時のアクション
- (void)deleteBtnAction:(UIButton *)sender event:(UIEvent *)event{
    
    //押されたボタンのセルのインデックスを取得
    NSIndexPath *delIndexPath  = [self indexPathForControlEvent:event];
    //選択したcellをチェック
    SettingSheetEditCell *cell = [self.mListTable cellForRowAtIndexPath:delIndexPath];
    //削除する情報のIDを取得
    NSInteger delID = cell.mCellDeleteBtn.tag;
    NSLog(@"%ld",delID);
    
    //アラートコントローラーのインスタンスを生成
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Member Information!" message:@"Do you want to delete information?\nこの情報を削除してよろしいでしょうか？" preferredStyle:UIAlertControllerStyleAlert];
    // 左から順にボタンが配置
    [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
        //Cell管理用Arrの更新(checkしたcell以前のセルが削除された場合、checkしたcellを-1)
        //外部で保存してあるリストから選択されたIDを削除
        self.mSelectInfoArr = [self.delegate deleteCheckList:delID delIndexPath:delIndexPath tableNumber:self.mTableNumber selectInfoArr:self.mSelectInfoArr];
        
        [self.mListTable reloadData];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self.mFrontView presentViewController:alert animated:YES completion:nil];
}

//外部でreloadする際のMethod
- (void)reloadTable{
    [self.mListTable reloadData];
}


@end

