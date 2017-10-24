//
//  MenuListView.m
//  misha
//
//  Created by 一木　英希 on 2016/03/08.
//  Copyright © 2016年 clincs. All rights reserved.
//

#import "MenuListView.h"
#import "ArtistViewController.h"
#import "MemberEditCell.h"
#import "DBConnecter.h"
#import "MemberData.h"
#import "AppDelegate.h"

//テキストの色(ゴールド)
#define TEXT_COLOR [[UIColor alloc]initWithRed:231.0/255.0 green:189.0/255.0 blue:44.0/255.0 alpha:1.0]
//#000000(R0G0B0)：テーブル背景
#define TABLE_BACK_SMOKE    [[UIColor alloc]initWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8]

//セルの高さ
#define CELL_HEIGHT 65
//Cell内のCheckボタンの描画位置
#define CHECK_BUTTON_POSITION CGRectMake(8.0f, 22.0f, 20.0f, 20.0f)
//Cell内の名前描画位置
#define NAME_LABEL_POSITION CGRectMake(36.0f, 8.0f, 169.0f, 21.0f)
//Cell内の楽器名描画位置
#define INSTRUMENT_LABEL_POSITION CGRectMake(36.0f, 36.0f, 169.0f, 21.0f)
//Cell内のDeleteボタン描画位置
#define DELETE_BUTTON_POSITION CGRectMake(213.0f, 0.0f, 40.0f, 65.0f)
//CellのID
#define MEMBER_EDIT_CELL_IDENTIFIER @"MemberEditCell"


@implementation MenuListView

//-(id)initWithFrame:(CGRect)frame facebookFlg:(BOOL)facebookFlg twitterFlg:(BOOL)twitterFlg{
//    
//    self = [self initWithFrame:frame];
////    self.mFacebookFlg = facebookFlg;
////    self.mTwitterFlg = twitterFlg;
//    return self;
//}

- (id)initWithFrame:(CGRect)frame modalView:(UIViewController *)modalView{
    
    self = [super initWithFrame:frame];
    if (self) {
        UINib *nib = [UINib nibWithNibName:@"MenuListView" bundle:nil];
        self = [nib instantiateWithOwner:nil options:nil][0];
        self.mNameLbl.textColor = TEXT_COLOR;
        self.mInstrumentLbl.textColor = TEXT_COLOR;
        self.mInfoLbl.textColor = TEXT_COLOR;
        
        //CustomCellの登録
        [self.mTableView registerNib:[UINib nibWithNibName:@"MemberEditCell" bundle:nil]
             forCellReuseIdentifier:MEMBER_EDIT_CELL_IDENTIFIER];
        //描画元のViewControllerを格納
        self.mModalView = modalView;
        
        self.mTableView.delegate = self;
        
        self.mTableView.separatorColor = [UIColor whiteColor];
        self.mTableView.backgroundColor = [UIColor clearColor];
        
        //追加したメンバー情報の格納用Arr
        self.mCheckIndexArr = [[NSMutableArray alloc]init];
        self.mArtistMemberArr = [[NSMutableArray alloc]init];
        
        UIToolbar *toolBar = [Util makeToolBar:self];
        // ToolbarをTextViewのinputAccessoryViewに設定
        self.mNameField.inputAccessoryView = toolBar;
        self.mInstrumentField.inputAccessoryView = toolBar;
        
        //各フィールドに文字列の変化があるごとに呼ぶメソッド
        [self.mNameField addTarget:self action:@selector(didChangeTextField:) forControlEvents:UIControlEventEditingChanged];
        [self.mInstrumentField addTarget:self action:@selector(didChangeTextField:) forControlEvents:UIControlEventEditingChanged];

        self.mDBConnecter = [DBConnecter sharedManager];
    }
    return self;
}

//キーボードを閉じる
-(void)closeKeyboard:(id)sender{
    [self.mNameField resignFirstResponder];
    [self.mInstrumentField resignFirstResponder];
}

- (void)didChangeTextField:(UITextField *)textField
{
    self.mName = self.mNameField.text;
    self.mInstrument = self.mInstrumentField.text;
}


//セクションの数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //CustomCellの登録
//    [self.mTableView registerNib:[UINib nibWithNibName:@"MemberEditCell" bundle:nil]
//          forCellReuseIdentifier:MEMBER_EDIT_CELL_IDENTIFIER];
    return 1;
}

//ロウの数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rowCount;
    NSInteger memberCount = [self.mDBConnecter getMemberDataCount];
    if (memberCount == 0) {
        //Rowが0の場合、テーブルビューのCellの色が指定の色とならない為リストにメンバーがいない時は5を返す
        rowCount = 5;
    }else{
        rowCount = memberCount;
    }
    return rowCount;
}

//セルの高さ
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return CELL_HEIGHT;
}

//cellのタップで反応:セル描画直前の処理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MemberEditCell * cell = [self.mTableView cellForRowAtIndexPath:indexPath];
    
    if (cell.accessoryType == UITableViewCellAccessoryNone) {
        cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_on.png"];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.mCellNameLbl.textColor = TEXT_COLOR;
        cell.mCellInstrumentLbl.textColor = TEXT_COLOR;
        cell.mCellDeleteBtn.hidden = YES;
        //CheckしたCellをCell管理用ArrにindexPathを追加
        [self.mCheckIndexArr addObject:@(indexPath.row)];
        
        //必要な情報をArrに追加
        NSMutableArray *ownArr = [[NSMutableArray alloc]init];
        [ownArr addObject:indexPath];
        [ownArr addObject:cell.mCellNameLbl.text];
        [ownArr addObject:cell.mCellInstrumentLbl.text];
        
        //最終的に必要となるメンバーの情報を格納
        [self.mArtistMemberArr addObject:ownArr];
        NSLog(@"%@",self.mArtistMemberArr);
        
        
    }else{
        cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_off.png"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mCellNameLbl.textColor = [UIColor grayColor];
        cell.mCellInstrumentLbl.textColor = [UIColor grayColor];
        cell.mCellDeleteBtn.hidden = NO;
        //Cell管理用ArrからCheckを外したCellのindexPathを削除
        [self.mCheckIndexArr removeObject:@(indexPath.row)];
        
        //最終的に必要となるメンバーの情報から削除
        for (int i = 0; i < [self.mArtistMemberArr count]; i++) {
            NSMutableArray *delDateArr = [self.mArtistMemberArr objectAtIndex:i];
            NSIndexPath *delPathRow = [delDateArr objectAtIndex:0];
            NSString *delName = [delDateArr objectAtIndex:1];
            NSString *delInstrumentName = [delDateArr objectAtIndex:2];
            
            //indexPath/name/InstrumentLblが等しければmArtistMemberArr から削除
            NSComparisonResult result = [delPathRow compare:indexPath];
            if (result == NSOrderedSame && [cell.mCellNameLbl.text isEqualToString: delName] && [cell.mCellInstrumentLbl.text isEqualToString: delInstrumentName]) {
                [self.mArtistMemberArr removeObjectAtIndex:i];
                NSLog(@"%@",self.mArtistMemberArr);
            }
        }
    }
    //書き換えたデータを格納
    [self.mTableView reloadData];
}

//セルの設定
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{    
    static NSString *CellIdentifier = MEMBER_EDIT_CELL_IDENTIFIER;
    MemberEditCell *cell = [self.mTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[MemberEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor yellowColor];
    cell.accessoryType = UITableViewCellAccessoryNone;
    //セル押下時ハイライトの無効化
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //NameLabelの生成:1
    cell.mCellNameLbl.font= [UIFont boldSystemFontOfSize:13];
    cell.mCellNameLbl.textColor = [UIColor grayColor];

    //InstrumentLabelの生成:2
    cell.mCellInstrumentLbl.font= [UIFont boldSystemFontOfSize:13];
    cell.mCellInstrumentLbl.textColor = [UIColor grayColor];
    
    //初回表示との分岐
    if ([self.mDBConnecter getMemberDataCount] == 0) {
        cell.mCellNameLbl.text = @"No name data";
        cell.mCellInstrumentLbl.text = @"No instrument data";
        cell.mCellDeleteBtn.hidden = YES;
        cell.mCellDeleteBtn.enabled = NO;
        
        self.mTableView.allowsSelection = false;
    }else{
        NSMutableArray * memberListArr = [self.mDBConnecter getMemberList];
        MemberData *memberData = [memberListArr objectAtIndex:indexPath.row];
        cell.mCellNameLbl.text = memberData.name;
        cell.mCellInstrumentLbl.text = memberData.instrument;
        cell.mCellDeleteBtn.hidden = NO;
        cell.mCellDeleteBtn.enabled = YES;
        //memberのidをdelボタンのタグとして保持
        cell.mCellDeleteBtn.tag = memberData.id;
        
        self.mTableView.allowsSelection = true;
    }
    
    //Deleteボタンの生成:3
    [cell.mCellDeleteBtn addTarget:self action:@selector(deleteBtnAction:event:) forControlEvents:UIControlEventTouchUpInside];
    [cell.mCellDeleteBtn setTitle:@"del" forState:UIControlStateNormal];
    
    if (self.mCheckIndexArr && [self.mCheckIndexArr containsObject:@(indexPath.row)]) {
        cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_on.png"];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.mCellNameLbl.textColor = TEXT_COLOR;
        cell.mCellInstrumentLbl.textColor = TEXT_COLOR;
        cell.mCellDeleteBtn.hidden = YES;
    }else{
        cell.mCellCheckImg.image = [UIImage imageNamed:@"checd_off.png"];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.mCellNameLbl.textColor = [UIColor grayColor];
        cell.mCellInstrumentLbl.textColor = [UIColor grayColor];
        cell.mCellDeleteBtn.hidden = NO;
    }

    return cell;
}

// UIControlEventからタッチ位置のindexPathを取得する
- (NSIndexPath *)indexPathForControlEvent:(UIEvent *)event{
    NSLog(@"%@",self.mTableView);
    
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint point = [touch locationInView:self.mTableView];
    NSIndexPath *indexPath = [self.mTableView indexPathForRowAtPoint:point];
    NSLog(@"%ld",indexPath.row);
    
    return indexPath;
    
}

//addNewMemberボタンが押下された時のアクション
- (IBAction)addMemberAction:(id)sender {
    
    if (self.mNameField.text.length == 0 || self.mInstrumentField.text.length == 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Not yet entered!"message:@"Please enter a member name and an instrument name.\n「登録するメンバーの名前」と「担当楽器」を入力して下さい。" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self.mModalView presentViewController:alert animated:YES completion:nil];
        
        }else{
            
            //入力されたデータをDBに格納
            MemberData *menberData = [[MemberData alloc]init];
            menberData.name = self.mName;
            menberData.instrument = self.mInstrument;
            
            [self.mDBConnecter insertMemberData:menberData];
            
            self.mNameField.text = nil;
            self.mInstrumentField.text = nil;
            
            //チェックのズレ込み防止処理:格納しているArrの中の全てのindexPathRowを+1する
            if ([self.mCheckIndexArr count] != 0) {
                for (int i = 0; i < [self.mCheckIndexArr count]; i++) {
                    NSInteger checkCellInt = [[self.mCheckIndexArr objectAtIndex:i]integerValue];
                    NSIndexPath *correctionIndexPath = [NSIndexPath indexPathForRow:checkCellInt + 1 inSection:0];
                    [self.mCheckIndexArr replaceObjectAtIndex:i withObject:@(correctionIndexPath.row)];
                }
            }
            //TableViewの更新
            [self.mTableView reloadData];
        }
}

//Deleteボタン押下時のアクション
- (void)deleteBtnAction:(UIButton *)sender event:(UIEvent *)event{
    // 押されたボタンのセルのインデックスを取得
    
    NSIndexPath *delIndexPath  = [self indexPathForControlEvent:event];
    
    UIButton *delBtn = sender;
    NSInteger delID = delBtn.tag;
    NSLog(@"%ld",delID);
    
        //アラートコントローラーのインスタンスを生成
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Delete Member Information!" message:@"Do you want to delete the member information?\nこのメンバーの情報を削除しますがよろしいですか？" preferredStyle:UIAlertControllerStyleAlert];
    // 左から順にボタンが配置
    [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        //Cell管理用Arrの更新(削除したCell以降のCellに-1)
        if ([self.mCheckIndexArr count] > 0) {
            for (int i = 0; i < [self.mCheckIndexArr count]; i++) {
                NSNumber *editIndexPath = [self.mCheckIndexArr objectAtIndex:i];
                
                NSNumber *delINdexNum = @(delIndexPath.row);
                NSComparisonResult result = [delINdexNum compare:editIndexPath];
                //delIndexPathがeditIndexPathより大きかったらeditIndexPathを1減らしてリプレイス
                if (result == NSOrderedAscending) {
                    NSInteger editIndexPathInt = [editIndexPath integerValue];
            
                    NSIndexPath *correctionIndexPath = [NSIndexPath indexPathForRow:editIndexPathInt - 1 inSection:0];
                    [self.mCheckIndexArr replaceObjectAtIndex:i withObject:@(correctionIndexPath.row)];
                }
            }
        }
        NSLog(@"%@",self.mCheckIndexArr);
        NSLog(@"%@",self.mArtistMemberArr);
        
        [self.mDBConnecter deleteMemberData:delID];
        [self.mTableView reloadData];
        
    }]];

    [alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self.mModalView presentViewController:alert animated:YES completion:nil];
}

@end
