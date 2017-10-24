//
//  ArtistViewController.m
//  SettingSheet
//
//  Created by 一木 英希 on 2017/01/17.
//  Copyright © 2017年 一木 英希. All rights reserved.
//

#import "ArtistViewController.h"
#import "DBConnecter.h"
#import "MenuListView.h"
#import "AppDelegate.h"
#import "Util.h"
#import "ArtistData.h"

@interface ArtistViewController ()

//@property (nonatomic, retain) NSString *artist_name;  // アーティスト名
//@property (nonatomic, retain) NSString *photo_data;   // アーティストイメージ
//@property (nonatomic, retain) NSString *tel;          // 連絡先電話番号
//@property (nonatomic, retain) NSString *e_mail;       // 連絡先メールアドレス
//@property (nonatomic, retain) NSString *hp_url;       // ホームページURL
//@property (nonatomic, retain) NSString *sns_account;  // SNSアカウント
//@property (nonatomic, retain) NSDate *create_date;    // 登録日
//@property (nonatomic, retain) NSDate *update_date;    // 更新日
//@property (nonatomic, assign) BOOL delete_flag;       // 削除フラグ

//設定一覧画面の待機位置
#define MENU_BEFORE_POSITION CGRectMake(self.view.window.frame.size.width, self.view.window.frame.origin.y + self.mStatusBarHeight, self.mMenuViewWidth, self.mMenuView.frame.size.height)
//設定一覧画面の描画位置
#define MENU_AFTER_POSITION CGRectMake(self.view.window.frame.size.width - self.mMenuViewWidth, self.view.window.frame.origin.y + self.mStatusBarHeight, self.mMenuViewWidth, self.mMenuView.frame.size.height)
//#000000(R0G0B0)：テーブル背景
#define TABLE_BACK_SMOKE    [[UIColor alloc]initWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.8]
//設定一覧の画面幅
#define MENUVIEW_WIDTH 253

@property (weak, nonatomic) IBOutlet UITextField *mArtistNameField;
@property (weak, nonatomic) IBOutlet UITextField *mPhoneticField;
@property (weak, nonatomic) IBOutlet UITextField *mTelField;
@property (weak, nonatomic) IBOutlet UITextField *mMailField;
@property (weak, nonatomic) IBOutlet UITextField *mUrlField;
@property (weak, nonatomic) IBOutlet UITextField *mSnsField;
@property (weak, nonatomic) IBOutlet UILabel *mMemberCountLbl;
@property (weak, nonatomic) IBOutlet UIButton *mPhotoBtn;
@property (weak, nonatomic) IBOutlet UIButton *mCancelBtn;
@property (weak, nonatomic) IBOutlet UIButton *mSaveBtn;
@property (weak, nonatomic) IBOutlet UILabel *mDateLbl;

//選択されたメンバーの情報を格納
@property (nonatomic, strong)NSMutableArray *mMemberList;
//Member選択リストinstanceの格納用
@property (nonatomic, strong) MenuListView *mMenuView;
//AddMember押下時のメンバーリストの背景をボタンとして生成
@property (nonatomic, strong) UIButton *mBgView;
@property NSInteger mMenuViewWidth;
@property float mStatusBarHeight;
//イメージピッカー保管用
@property (nonatomic, strong) UIImagePickerController *mPicker;
//DBに格納するArtistのイメージ保管用
@property (nonatomic, strong) UIImage *mArtistImagePhoto;
//DB関連
@property (nonatomic, strong) DBConnecter *mDBConnecter;
@property (nonatomic, strong) ArtistData *mArtistData;

@end

@implementation ArtistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //メンバーリスト画面の横幅
    self.mMenuViewWidth = MENUVIEW_WIDTH;
    
    //ステータスバーの高さ取得
    self.mStatusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    
    //最前面のView
//    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
//    self.mFrontView = delegate.window.rootViewController;
    
    UIToolbar *toolBar = [Util makeToolBar:self];
    
    // ToolbarをTextViewのinputAccessoryViewに設定
    self.mArtistNameField.inputAccessoryView = toolBar;
    self.mPhoneticField.inputAccessoryView = toolBar;
    self.mTelField.inputAccessoryView = toolBar;
    [self.mTelField setKeyboardType:UIKeyboardTypeNumberPad];
    
    self.mMailField.inputAccessoryView = toolBar;
    self.mMailField.borderStyle = UITextBorderStyleRoundedRect;
    [self.mMailField setKeyboardType:UIKeyboardTypeURL];
    
    self.mUrlField.inputAccessoryView = toolBar;
    [self.mUrlField setKeyboardType:UIKeyboardTypeURL];
    
    self.mSnsField.inputAccessoryView = toolBar;
    self.mSnsField.borderStyle = UITextBorderStyleRoundedRect;
    
    self.mMemberCountLbl.text = @"0";
    
    NSDateFormatter *dateformat = [[NSDateFormatter alloc] init];
    dateformat.dateFormat  = @"yyyy/MM/dd";
    NSString *dateStr = [dateformat stringFromDate:[NSDate date]];
    self.mDateLbl.text = dateStr;
    
    [self.mPhotoBtn setTitle:@"No image" forState:UIControlStateNormal];
    self.mPhotoBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //メンバーリスト格納用Arr
    self.mMemberList = [[NSMutableArray alloc]init];
    //DBの初期化
    self.mDBConnecter = [DBConnecter sharedManager];
}

//キーボードを閉じる(閉じるボタンTap)
-(void)closeKeyboard:(id)sender{
    [self.mArtistNameField resignFirstResponder];
    [self.mPhoneticField resignFirstResponder];
    [self.mTelField resignFirstResponder];
    [self.mMailField resignFirstResponder];
    [self.mUrlField resignFirstResponder];
    [self.mSnsField resignFirstResponder];
}
////キーボードを閉じる(キーボード外をTap)
//- (IBAction)onSingleTap:(id)sender {
//    [self.view endEditing:YES];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addMemberAction:(id)sender {
    
    //メンバーリスト描画時の本体画面
    CGRect bgViewSize = CGRectMake(self.view.window.frame.origin.x, self.view.window.frame.origin.y, self.view.window.frame.size.width, self.view.window.frame.size.height);
    self.mBgView = [[UIButton alloc]initWithFrame:bgViewSize];
    self.mBgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    [self.mBgView addTarget:self action:@selector(closedMenuView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mBgView];
    
//    self.mMenuView = [[MenuListView alloc]initWithFrame:self.mMenuView.frame];
    self.mMenuView = [[MenuListView alloc]initWithFrame:self.mMenuView.frame modalView:self];

    self.mMenuView.frame = MENU_BEFORE_POSITION;
    self.mMenuView.backgroundColor = TABLE_BACK_SMOKE;
    [self.mBgView addSubview:self.mMenuView];
    
    //アニメーション
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        self.mMenuView.frame = MENU_AFTER_POSITION;
    } completion:nil];
}

//メンバー画面の非表示処理
- (void)closedMenuView:(id)sender
{
    NSInteger menberCount = [self.mMenuView.mArtistMemberArr count];
    
    if (menberCount > 0) {
        
        NSString *memberCompStr = [NSString stringWithFormat:@"We added %ld people to the group.\n%ld人の情報をグループに追加しました。", menberCount, menberCount];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Member addition completed!"message:memberCompStr preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            //追加されたメンバーの情報を継承
            self.mMemberList = self.mMenuView.mArtistMemberArr;
            //追加されたメンバーの人数を描画
            self.mMemberCountLbl.text = [NSString stringWithFormat:@"%ld",menberCount];            
            [alert dismissViewControllerAnimated:YES completion:nil];
            [self closeMenuList];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else{
        [self closeMenuList];
    }
}

-(void)closeMenuList{
    //アニメーション
    [UIView animateWithDuration:0.3f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^ {
        self.mMenuView.frame = MENU_BEFORE_POSITION;
    } completion:^ (BOOL finished){
        [self.mMenuView removeFromSuperview];
        [self.mBgView removeFromSuperview];
    }];
}

//CancelButton押下時Action
- (IBAction)cancelBtnAction:(id)sender {
    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Caution!" message:@"The data being edited will not be saved, is it OK?\n編集中のデータは保存されません。\nよろしいですか？" preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        
//        [alert dismissViewControllerAnimated:YES completion:nil];
//        //前の画面に戻る
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }]];
//    
//    [alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        
//        [alert dismissViewControllerAnimated:YES completion:nil];
//    }]];
//    [self presentViewController:alert animated:YES completion:nil];
    
    [Util makeCancelAlert:self];
}

//ImageButtonボタン押下時Action
- (IBAction)photoBtnAction:(id)sender {
    self.mPicker = [[UIImagePickerController alloc]init];
    self.mPicker.delegate = self;
    [self.mPicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:self.mPicker animated:YES completion:nil];
}

//選択した画像は引数のUIImageに入る
- (void)imagePickerController :(UIImagePickerController *)picker
        didFinishPickingImage :(UIImage *)image editingInfo :(NSDictionary *)editingInfo {
    
    //DB格納用プロパティに格納
    self.mArtistImagePhoto = image;
    // 読み込んだ画像表示(setBackgroundImageで画像を設定するとScaleAspectFit等の設定が効かない)
    [self.mPhotoBtn setTitle:nil forState:UIControlStateNormal];
    [self.mPhotoBtn setImage:image forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//SaveButtonボタン押下時Action
- (IBAction)saveBtnAction:(id)sender {
    
    if (self.mArtistNameField.text.length == 0 || self.mPhoneticField.text.length == 0 || self.mTelField.text.length == 0 || self.mMailField.text.length == 0) {
        //必須入力項目未記入の場合
        UIAlertController *incompAlert = [UIAlertController alertControllerWithTitle:@"Caution!" message:@"Required input items are not filled in.\n必須入力項目が記入されていません。" preferredStyle:UIAlertControllerStyleAlert];
        [incompAlert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //アラートを閉じる
            [incompAlert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:incompAlert animated:YES completion:nil];

    }else{
        //メンバーが追加されてない場合
        if ([self.mMemberList count] == 0) {
        UIAlertController *noMemberAlert = [UIAlertController alertControllerWithTitle:@"Caution!" message:@"Please press the「BAND MEMBERS」to add members.\n「BAND MEMBERS」を押してメンバーを追加して下さい。" preferredStyle:UIAlertControllerStyleAlert];
            [noMemberAlert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //アラートを閉じる
                [noMemberAlert dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:noMemberAlert animated:YES completion:nil];
            
        }else{
            
            //必須入力項目記入済みの場合
            NSString *artistCompStr = [NSString stringWithFormat:@"Do you want to save this information?\nこの情報を保存しますか？\nArtist Name:%@\nPhonetic:%@\nTel:%@\nMail:%@\nHP URL:%@\nSNS Account:%@", self.mArtistNameField.text, self.mPhoneticField.text, self.mTelField.text, self.mMailField.text, self.mUrlField.text, self.mSnsField.text];
            
            UIAlertController *compAlert = [UIAlertController alertControllerWithTitle:@"Confirmation!" message:artistCompStr preferredStyle:UIAlertControllerStyleAlert];
            [compAlert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                //DBに格納
                ArtistData *artistData = [[ArtistData alloc]init];
                artistData.artist_name = self.mArtistNameField.text;
                artistData.artist_kana = self.mPhoneticField.text;
                artistData.tel = self.mTelField.text;
                artistData.e_mail = self.mMailField.text;
                artistData.hp_url = self.mUrlField.text;
                artistData.sns_account = self.mSnsField.text;
                
                //指定したイメージ画像をBase64エンコードして保存
                NSString *strImg = [[NSString alloc]init];
                if (self.mArtistImagePhoto != nil) {
                    strImg = [Util encodeToBase64String:self.mArtistImagePhoto];
                }else{
                    //encodeToBase64Stringは引数がNULLだと落ちるため文字列を格納
                    strImg = @"No Image";
                }
                artistData.photo_data = strImg;

                [self.mDBConnecter insertArtistData:artistData];
                
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
