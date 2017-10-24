//
//  SetListViewController.m
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/17.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import "SetListViewController.h"
#import "Util.h"
#import "TrackOrderCell.h"
#import "DBConnecter.h"
#import "SetListData.h"
#import "VenueLiveData.h"
#import "SetRelationData.h"

//CellのID
#define TRUCK_ORDER_CELL_IDENTIFIER @"TrackOrderCell"
//セルの高さ
#define CELL_HEIGHT 65
//#000000(R0G0B0)：テーブル背景
#define TABLE_BACK_SMOKE    [[UIColor alloc]initWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8]
//テキストの色(ゴールド)
#define TEXT_COLOR [[UIColor alloc]initWithRed:231.0/255.0 green:189.0/255.0 blue:44.0/255.0 alpha:1.0]

@interface SetListViewController ()

@property (weak, nonatomic) IBOutlet UITextField *mSongNameField;
@property (weak, nonatomic) IBOutlet UITextField *mFeatureField;
@property (weak, nonatomic) IBOutlet UITextField *mVenueNameField;
@property (weak, nonatomic) IBOutlet UITextField *mLiveDayField;
@property (weak, nonatomic) IBOutlet UITableView *mSongListTable;
@property (weak, nonatomic) IBOutlet UIButton *mRegistrationBtn;

//DB関連
@property (nonatomic, strong) DBConnecter *mDBConnecter;

@property (nonatomic, strong) NSDate *mLiveDate;
@property (nonatomic, strong) UIDatePicker *mDatePicker;
@property (nonatomic, strong) NSDateFormatter *mDateFormatter;

//曲の選択順を付与するinteger
@property (nonatomic, assign) NSInteger mTrackCount;
//選択した曲順を格納するArr
@property (nonatomic, strong) NSMutableArray *mTrackArr;


@end

@implementation SetListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //CustomCellの登録
    [self.mSongListTable registerNib:[UINib nibWithNibName:@"TrackOrderCell" bundle:nil]
          forCellReuseIdentifier:TRUCK_ORDER_CELL_IDENTIFIER];
    
    self.mDBConnecter = [DBConnecter sharedManager];
    self.mTrackArr = [[NSMutableArray alloc]init];
    UIToolbar *toolBar = [Util makeToolBar:self];
    self.mSongListTable.delegate = self;
    self.mSongListTable.dataSource = self;
    self.mSongListTable.backgroundColor = TABLE_BACK_SMOKE;
    self.mTrackCount = 1;
    
    // ToolbarをTextViewのinputAccessoryViewに設定
    self.mSongNameField.inputAccessoryView = toolBar;
    self.mFeatureField.inputAccessoryView = toolBar;
    self.mVenueNameField.inputAccessoryView = toolBar;
    
    //mLiveFieldの値の編集
    self.mDatePicker = [[UIDatePicker alloc]init];
    [self.mDatePicker setDatePickerMode:UIDatePickerModeDate];
    
    self.mDateFormatter = [[NSDateFormatter alloc] init];
    [self.mDateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    self.mLiveDayField.inputView = self.mDatePicker;
    self.mLiveDayField.inputAccessoryView = toolBar;
}

//ライブ日時の編集が完了したら結果をmLiveDayFieldに表示
//-(void)updateTextField: (UIDatePicker*)sender {
////    UIDatePicker *datePicker = sender;
////    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
////    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
////    NSString *dateStr = [self.mDateFormatter stringFromDate:datePicker.date];
//    NSString *dateStr = [self.mDateFormatter stringFromDate:self.mDatePicker.date];
//    self.mLiveDayField.text = dateStr;
//}

//キーボードを閉じる(閉じるボタンTap)
-(void)closeKeyboard:(id)sender{
    NSString *dateStr = [self.mDateFormatter stringFromDate:self.mDatePicker.date];
    self.mLiveDayField.text = dateStr;
    
    [self.mSongNameField resignFirstResponder];
    [self.mFeatureField resignFirstResponder];
    [self.mVenueNameField resignFirstResponder];
    [self.mLiveDayField resignFirstResponder];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//「曲を登録する」ボタン押下時のAction
- (IBAction)mRegistrationBtnAction:(id)sender {
    
    if (self.mSongNameField.text.length == 0 || self.mFeatureField.text.length == 0) {
        UIAlertController *incompAlert = [UIAlertController alertControllerWithTitle:@"Caution!" message:@"Please enter「Song Name」and「Features/Remarks」.\n「曲名」と「曲の特長/備考」を入力してください。" preferredStyle:UIAlertControllerStyleAlert];
        [incompAlert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //アラートを閉じる
            [incompAlert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:incompAlert animated:YES completion:nil];
    }else{
        
        //必須入力項目記入済みの場合
        NSString *artistCompStr = [NSString stringWithFormat:@"Do you want to save this information?\nこの情報を保存しますか？\nSong Name:%@\nFeatures/Remarks:%@\n", self.mSongNameField.text, self.mFeatureField.text];
        
        UIAlertController *compAlert = [UIAlertController alertControllerWithTitle:@"Confirmation!" message:artistCompStr preferredStyle:UIAlertControllerStyleAlert];
        [compAlert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            //曲の情報を格納。
            SetListData *setListData = [[SetListData alloc]init];
            setListData.song_name = self.mSongNameField.text;
            setListData.features = self.mFeatureField.text;
            [self.mDBConnecter insertSongData:setListData];

            //アラートを閉じて前の画面に戻る
            [compAlert dismissViewControllerAnimated:YES completion:nil];
            
            //ListViewに入力したデータを反映する為にreload
            [self.mSongListTable reloadData];
        }]];
        
        [compAlert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //アラートを閉じる
            [compAlert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:compAlert animated:YES completion:nil];
    }
}

- (IBAction)cancelBtnAction:(id)sender {
    [Util makeCancelAlert:self];
}

- (IBAction)mSaveBtnAction:(id)sender {
    
    if (self.mVenueNameField.text.length == 0 || self.mLiveDayField.text.length == 0) {
        //必須入力項目未記入の場合
        UIAlertController *incompAlert = [UIAlertController alertControllerWithTitle:@"Caution!" message:@"Please enter the「Venue Name」and「Live Day」 in.\n「会場名」と「ライブ日時」を入力して下さい。" preferredStyle:UIAlertControllerStyleAlert];
        [incompAlert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //アラートを閉じる
            [incompAlert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:incompAlert animated:YES completion:nil];
        
    }else{
        //曲が選択されていない場合。
        if ([self.mTrackArr count] == 0) {
            UIAlertController *noTrackAlert = [UIAlertController alertControllerWithTitle:@"Caution!" message:@"Please select a song.\n曲を選択して下さい。" preferredStyle:UIAlertControllerStyleAlert];
            [noTrackAlert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //アラートを閉じる
                [noTrackAlert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:noTrackAlert animated:YES completion:nil];
            
        }else{
            
            NSInteger songCount = [self.mTrackArr count];
            
            NSString *artistCompStr = [NSString stringWithFormat:@"Do you want to save this information?\nこの情報を保存しますか？\n\nVenue Name:%@\nLive Day:%@\nNumber of songs:%ldsongs", self.mVenueNameField.text, self.mLiveDayField.text, songCount];
            
            UIAlertController *compAlert = [UIAlertController alertControllerWithTitle:@"Confirmation!" message:artistCompStr preferredStyle:UIAlertControllerStyleAlert];
            [compAlert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                //DBに格納
                //会場名、ライブ日時
                VenueLiveData *venueData = [[VenueLiveData alloc]init];
                venueData.venue_name = self.mVenueNameField.text;
                venueData.live_date = self.mLiveDayField.text;
                NSInteger venueID = [self.mDBConnecter insertVenueData:venueData];
                
                //会場に対応した曲順の情報
                //登録した会場のDB上のidを取得
                for (int i = 0; [self.mTrackArr count] > i; i++) {
                    SetRelationData *setRelationData = [[SetRelationData alloc]init];
                    
                    NSMutableArray *ownArr = [self.mTrackArr objectAtIndex:i];
                    NSInteger songIDInt = [[ownArr objectAtIndex:4]integerValue];
                    
                    setRelationData.venue_id = venueID;
                    setRelationData.set_list_id = songIDInt;
                    [self.mDBConnecter insertRelationData:setRelationData];
                }
                
                //アラートを閉じて前の画面に戻る
                [compAlert dismissViewControllerAnimated:YES completion:nil];
                [self dismissViewControllerAnimated:YES completion:nil];
                
                //ListViewに入力したデータを反映する為にreload
                [self.mArtistListView reloadTable];
                
            }]];
            
            [compAlert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //アラートを閉じる
                [compAlert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:compAlert animated:YES completion:nil];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TrackOrderCell * cell = [self.mSongListTable cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        
        NSMutableArray *ownArr = [[NSMutableArray alloc]init];
        [ownArr addObject:@(indexPath.row)];
        [ownArr addObject:cell.mCellSongNameLbl.text];
        [ownArr addObject:cell.mCellFeaturesLbl.text];
        [ownArr addObject:@(self.mTrackCount)];
        [ownArr addObject:@(cell.mCellDeleteBtn.tag)];
        //選択された曲を管理用Arrに格納
        [self.mTrackArr addObject:ownArr];
        
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.mCellNumberLbl.textColor = TEXT_COLOR;
        cell.mCellSongNameLbl.textColor = TEXT_COLOR;
        cell.mCellFeaturesLbl.textColor = TEXT_COLOR;
        cell.mCellDeleteBtn.hidden = YES;
        
        self.mTrackCount = self.mTrackCount + 1;
        
    }else{
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mCellNumberLbl.text = nil;
        cell.mCellSongNameLbl.textColor = [UIColor grayColor];
        cell.mCellFeaturesLbl.textColor = [UIColor grayColor];
        cell.mCellDeleteBtn.hidden = NO;
        
        //Cell管理用ArrからCheckを外したCellのindexPathを削除
        for (int i = 0; i < [self.mTrackArr count]; i++) {
            NSMutableArray *delDateArr = [self.mTrackArr objectAtIndex:i];
            
            NSNumber *delIndexPath = [delDateArr objectAtIndex:0];
            NSString *delSongName = [delDateArr objectAtIndex:1];
            NSString *delFeatures = [delDateArr objectAtIndex:2];
            NSNumber *delTrackNum = [delDateArr objectAtIndex:3];
            
            //indexPath/name/InstrumentLblが等しければmTrackArr から削除
            NSComparisonResult result = [delIndexPath compare:@(indexPath.row)];
            if (result == NSOrderedSame && [cell.mCellSongNameLbl.text isEqualToString: delSongName] && [cell.mCellFeaturesLbl.text isEqualToString: delFeatures]) {
                
                //TrackNumberを更新してから、Checkを外したCellの情報を削除する。
                for (int i = 0; i < [self.mTrackArr count]; i++) {
                    NSMutableArray *comparisonArr = [self.mTrackArr objectAtIndex:i];
                    NSNumber *comparisonTrackNum = [comparisonArr objectAtIndex:3];
                    NSComparisonResult result2 = [delTrackNum compare:comparisonTrackNum];
                    if (result2 == NSOrderedAscending) {
                    
                        NSInteger newTrackNum = [comparisonTrackNum integerValue] - 1;
                        [comparisonArr replaceObjectAtIndex:3 withObject:@(newTrackNum)];
                        [self.mTrackArr replaceObjectAtIndex:i withObject:comparisonArr];
                    }
                }
                [self.mTrackArr removeObjectAtIndex:i];
                NSLog(@"%@",self.mTrackArr);
            }
        }
        self.mTrackCount = self.mTrackCount - 1;
    }
    
    //Cellに番号を付与
    if ([self.mTrackArr count] > 0) {
        for (int i = 0; i < [self.mTrackArr count]; i ++) {
            NSMutableArray *ownArr = [self.mTrackArr objectAtIndex:i];
            NSNumber *selectIndexPathNum = [ownArr objectAtIndex:0];
            NSNumber *trackNumber = [ownArr objectAtIndex:3];
            
            //TableViewからIndexPathを使ってcellを指定する。
            NSIndexPath *selectIndexPath = [NSIndexPath indexPathForRow:[selectIndexPathNum integerValue] inSection:0];
            TrackOrderCell *cell = [self.mSongListTable cellForRowAtIndexPath:selectIndexPath];
            cell.mCellNumberLbl.text = [trackNumber stringValue];
        }
    }else if ([self.mTrackArr count] == 0){
        
        //選択されたcellがない場合は全てのcellのmNumberLblをnilにする
        //※mTrackCountの初期値が1の為、-1をしても最後のcellに数字が残るため
        for (TrackOrderCell *cell in [self.mSongListTable visibleCells]) {
            cell.mCellNumberLbl.text = nil;
            
            self.mTrackCount = 1;
        }
        
    }
    
//    //全てのセルに処理を行いたい時の時のfor文
//    for (TrackOrderCell *cell in [self.mSongListTable visibleCells]) {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
    
    //書き換えたデータを格納
//    [self.mSongListTable reloadData];
}

//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger rowCount;
    NSInteger setListCount = [self.mDBConnecter getSetListDataCount];
    if (setListCount == 0) {
        //Rowが0の場合、テーブルビューのCellの色が指定の色とならない為リストにメンバーがいない時は5を返す
        rowCount = 5;
    }else{
        rowCount = setListCount;
    }
    return rowCount;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = TRUCK_ORDER_CELL_IDENTIFIER;
    TrackOrderCell *cell = [self.mSongListTable dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[TrackOrderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
//    cell.textLabel.textColor = [UIColor yellowColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    //セル押下時ハイライトの無効化
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //NameLabelの生成:1
    cell.mCellSongNameLbl.font= [UIFont boldSystemFontOfSize:13];
    cell.mCellSongNameLbl.textColor = [UIColor grayColor];
    
    //InstrumentLabelの生成:2
    cell.mCellFeaturesLbl.font= [UIFont boldSystemFontOfSize:13];
    cell.mCellFeaturesLbl.textColor = [UIColor grayColor];
    
    //初回表示との分岐
    if ([self.mDBConnecter getSetListDataCount] == 0) {
        cell.mCellNumberLbl.text = nil;
        cell.mCellSongNameLbl.text = @"No song data";
        cell.mCellFeaturesLbl.text = @"No features data";
        cell.mCellDeleteBtn.hidden = YES;
        cell.mCellDeleteBtn.enabled = NO;
        
        self.mSongListTable.allowsSelection = false;
    }else{
        NSMutableArray *songListArr = [self.mDBConnecter getSetList];
        SetListData *setListData = [songListArr objectAtIndex:indexPath.row];
        cell.mCellSongNameLbl.text = setListData.song_name;
        cell.mCellFeaturesLbl.text = setListData.features;
        cell.mCellDeleteBtn.hidden = NO;
        cell.mCellDeleteBtn.enabled = YES;
        //memberのidをdelボタンのタグとして保持
        cell.mCellDeleteBtn.tag = setListData.id;
        
        self.mSongListTable.allowsSelection = true;
    }
    
    //Deleteボタンの生成:3
    [cell.mCellDeleteBtn addTarget:self action:@selector(deleteBtnAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [cell.mCellDeleteBtn setTitle:@"del" forState:UIControlStateNormal];
    
    if ([self.mTrackArr count] > 0) {
        
        NSInteger makingIndexPathInt = indexPath.row;
        NSLog(@"%ld",makingIndexPathInt);
        
        for (int i = 0; [self.mTrackArr count] > i; i ++) {
            NSMutableArray *ownArr = [self.mTrackArr objectAtIndex:i];
            NSInteger searchIndexPathInt = [[ownArr objectAtIndex:0]integerValue];
            NSNumber *searchTrackNum = [ownArr objectAtIndex:3];
            
            NSLog(@"%ld",searchIndexPathInt);
            
            if (searchIndexPathInt == makingIndexPathInt) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                cell.mCellSongNameLbl.textColor = TEXT_COLOR;
                cell.mCellFeaturesLbl.textColor = TEXT_COLOR;
                cell.mCellDeleteBtn.hidden = YES;
                cell.mCellNumberLbl.text = [searchTrackNum stringValue];
                
                //一致した時点で繰り返し終了
                return  cell;
            }else{
                cell.accessoryType = UITableViewCellSelectionStyleNone;
                cell.mCellSongNameLbl.textColor = [UIColor grayColor];
                cell.mCellFeaturesLbl.textColor = [UIColor grayColor];
                cell.mCellDeleteBtn.hidden = NO;
                cell.mCellNumberLbl.text = nil;
            }
        }
    }
    else{
//        cell.accessoryType = UITableViewCellSelectionStyleNone;
//        cell.mCellSongNameLbl.textColor = [UIColor grayColor];
//        cell.mCellFeaturesLbl.textColor = [UIColor grayColor];
//        cell.mCellDeleteBtn.hidden = NO;
//        cell.mCellNumberLbl.text = nil;
    }
    return cell;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
