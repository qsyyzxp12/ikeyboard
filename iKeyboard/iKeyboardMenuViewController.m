//
//  iKeyboardMenuViewController.m
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import "iKeyboardMenuViewController.h"

@interface iKeyboardMenuViewController ()

@end

@implementation iKeyboardMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    
    UIImageView* BGimageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iKeybo_Base0.png"]];
    BGimageView.frame = self.view.frame;
    [self.view addSubview:BGimageView];
    
    UIButton* iKeyBoConnectButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.07, CGRectGetHeight(self.view.frame)*0.17, CGRectGetWidth(self.view.frame)*0.49, CGRectGetHeight(self.view.frame)*0.21)];
    [iKeyBoConnectButton setImage:[UIImage imageNamed:@"Connect1.png"] forState:UIControlStateNormal];
    [iKeyBoConnectButton setImage:[UIImage imageNamed:@"Connect_Pushed1.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:iKeyBoConnectButton];
    
    UILabel* textLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.09, CGRectGetHeight(self.view.frame)*0.47, CGRectGetWidth(iKeyBoConnectButton.frame)*0.7, CGRectGetHeight(self.view.frame)*0.18)];
    textLabel.text = @"Don't have iKeybo?";
    textLabel.adjustsFontSizeToFitWidth = YES;
    textLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:textLabel];
    
    UIButton* getOneButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(iKeyBoConnectButton.frame), CGRectGetHeight(self.view.frame)*0.55, CGRectGetWidth(self.view.frame)*0.2, CGRectGetHeight(self.view.frame)*0.25)];
    [getOneButton setImage:[UIImage imageNamed:@"Get_One1.png"] forState:UIControlStateNormal];
    [getOneButton setImage:[UIImage imageNamed:@"Get_One_pushed1.png"] forState:UIControlStateHighlighted];
    [getOneButton addTarget:self action:@selector(getOneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:getOneButton];
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.455, CGRectGetHeight(self.view.frame)*0.9, CGRectGetWidth(self.view.frame)*0.09, CGRectGetHeight(self.view.frame)*0.06)];
    [backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
  //  [backButton setBackgroundColor:[UIColor redColor]];
  //  backButton.alpha = 0.5;
    [self.view addSubview:backButton];
}

-(void)getOneButtonClicked
{
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
}

-(void)backButtonClicked
{
    [self performSegueWithIdentifier:@"showNormalModeViewController" sender:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
