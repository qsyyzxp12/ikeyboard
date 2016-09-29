//
//  iKeyboardMenuViewController.m
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//
#import "AppDelegate.h"
#import "iKeyboardMenuViewController.h"
#import "iKeyboardNormalModeViewController.h"
//#undef DEBUG


@interface iKeyboardMenuViewController ()

@end

@implementation iKeyboardMenuViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    
    //self.normalModeViewController = [[iKeyboardNormalModeViewController alloc] initWithNibName:nil bundle:nil];
    self.normalModeViewController = [[iKeyboardNormalModeViewController alloc] init];
    self.normalModeViewController.delegate = self;
    //self.normalModeViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    self.appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.navigationController.navigationBar.hidden = YES;
    
    self.pageID = 0;
    
    UIImageView* BGimageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iKeybo_Base0.png"]];
    BGimageView.frame = self.view.frame;
    [self.view addSubview:BGimageView];
    
    UIButton* iKeyBoConnectButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)*0.07, CGRectGetHeight(self.view.frame)*0.17, CGRectGetWidth(self.view.frame)*0.49, CGRectGetHeight(self.view.frame)*0.21)];
    [iKeyBoConnectButton setImage:[UIImage imageNamed:@"Connect1.png"] forState:UIControlStateNormal];
    [iKeyBoConnectButton setImage:[UIImage imageNamed:@"Connect_Pushed1.png"] forState:UIControlStateHighlighted];
    [iKeyBoConnectButton addTarget:self action:@selector(iKeyboConnectionButtonClicked) forControlEvents:UIControlEventTouchUpInside];
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

    [self.view addSubview:backButton];
    
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.spinner.frame = CGRectMake(CGRectGetMidX(self.view.frame)-25, CGRectGetMidY(self.view.frame)-25, 50, 50);
    self.spinner.backgroundColor = [UIColor grayColor];
    //self.spinner.alpha = 0.7;
    self.spinner.layer.cornerRadius = 5;
    [self.spinner startAnimating];
    
    self.mistView = [[UIView alloc] initWithFrame:self.view.frame];
    self.mistView.backgroundColor = [UIColor blackColor];
    self.mistView.alpha = 0.5;
    
    [self startAutoConnect];
}

-(void) bluetoothReady
{
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    NSArray<CBUUID*>* iKeyboService = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"FFA0"]];
    NSArray<CBPeripheral*>* iKeyboperipherals = [self.cbManager retrieveConnectedPeripheralsWithServices:iKeyboService];
    if(iKeyboperipherals.count == 1){
        _appDelegate.serafimPeripheral = [iKeyboperipherals objectAtIndex:0];
        NSLog(@"bluetoothReady");
    }
    else
        [self.cbManager scanForPeripheralsWithServices:nil options:options];
}


-(void) bluetoothConnect
{
    [self bluetoothReady];
    if(_appDelegate.serafimPeripheral)
        [self.cbManager connectPeripheral:_appDelegate.serafimPeripheral options:nil];
    //else
    
}

#pragma mark - Actions

-(void)iKeyboConnectionButtonClicked
{
    [self bluetoothReady];
    if(_appDelegate.serafimPeripheral){
        [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(connectTimeout:) userInfo:nil repeats:NO];
        [self.view addSubview:self.mistView];
        [self.view addSubview:self.spinner];
        [NSThread detachNewThreadSelector:@selector(bluetoothConnect) toTarget:self withObject:nil];
    }
    else
    {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Oops"
                                     message:@"There is no serafim device around you or the bluetooth service doesn't available."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {/*do nothing*/}];
        
        [alert addAction:yesButton];
        [self presentViewController:alert animated:YES completion:nil];
        NSLog(@"No Serafim device found");
        return;
    }
}

-(void)connectTimeout:(NSTimer*)timer{
    NSLog(@"%d",(int)_pageID);
    if(_pageID == 0){
        UIAlertController* alert = [UIAlertController
                                     alertControllerWithTitle:@"Oops"
                                     message:@"Connect fail."
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* yesButton = [UIAlertAction
                                    actionWithTitle:@"OK"
                                    style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {
                                        [self startAutoConnect];
                                    }];
        
        UIAlertAction* connButton = [UIAlertAction
                                     actionWithTitle:@"reconnect"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         [self iKeyboConnectionButtonClicked];}];
        [alert addAction:yesButton];
        [alert addAction:connButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    [self.mistView removeFromSuperview];
    [self.spinner removeFromSuperview];
}

-(void)getOneButtonClicked
{
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
}

-(void)backButtonClicked
{
    self.pageID = 1;
    [self startAutoConnect];
    [self presentViewController:self.normalModeViewController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CBCentralManagerDelegate

-(void)centralManagerDidUpdateState:(CBCentralManager *)cManager
{
    NSMutableString* nsmstring=[NSMutableString stringWithString:@"UpdateState:"];
    switch (cManager.state) {
        case CBCentralManagerStateUnknown:
            [nsmstring appendString:@"Unknown\n"];
            break;
        case CBCentralManagerStateUnsupported:
            [nsmstring appendString:@"Unsupported\n"];
            break;
        case CBCentralManagerStateUnauthorized:
            [nsmstring appendString:@"Unauthorized\n"];
            break;
        case CBCentralManagerStateResetting:
            [nsmstring appendString:@"Resetting\n"];
            break;
        case CBCentralManagerStatePoweredOff:
            [nsmstring appendString:@"PoweredOff\n"];
            //      if (connectedPeripheral!=NULL){
            //        [CM cancelPeripheralConnection:connectedPeripheral];
            //  }
            //[self.cbManager cancelPeripheralConnection:_appDelegate.serafimPeripheral];
            break;
        case CBCentralManagerStatePoweredOn:
            [nsmstring appendString:@"PoweredOn\n"];
            [self bluetoothReady];
            break;
        default:
            [nsmstring appendString:@"none\n"];
            break;
    }
#ifdef DEBUG
    NSLog(@"%@",nsmstring);
#endif
}

//看周圍可以連藍芽的東西是不是serafim的產品，如果是就把serafimPeripheral連過去
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
//#ifdef DEBUG
    NSMutableString* nsmstring=[NSMutableString stringWithString:@"\n"];
    [nsmstring appendString:@"Peripheral Info:"];
    [nsmstring appendFormat:@"NAME: %@\n",peripheral.name];
    [nsmstring appendFormat:@"RSSI: %@\n",RSSI];
    
    
    [nsmstring appendFormat:@"adverisement:%@",advertisementData];
    [nsmstring appendString:@"didDiscoverPeripheral\n"];
     //NSLog(@"%@",nsmstring);
//#endif
    //if([[advertisementData objectForKey:@"kCBAdvDataLocalName"] isEqualToString:@"Serafim iKeybo"]){
    if([[peripheral name] isEqualToString:@"Serafim iKeybo"]){
        _appDelegate.serafimPeripheral = peripheral;
        [_cbManager stopScan];
    }
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    [self stopAutoConnect];
    
    peripheral.delegate = self.normalModeViewController;
    [peripheral discoverServices:nil];
    NSLog(@"connected");
    if(self.pageID != 1){
        self.pageID = 1;
        [self presentViewController:self.normalModeViewController animated:YES completion:nil];
        [self.mistView removeFromSuperview];
        [self.spinner removeFromSuperview];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"We lose connection of your serafim device." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Reconnect", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        _pageID = 0;
        [self dismissViewControllerAnimated:YES completion:nil];
        [self iKeyboConnectionButtonClicked];
    }
    else {[self startAutoConnect];}
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"connection fail");
}

- (void)keyboViewDismissed:(NSInteger *)pageIDForFirst
{
    self.pageID = pageIDForFirst; //And there you have it.....
}

- (void) startAutoConnect{
    _autoConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self           selector:@selector(bluetoothConnect) userInfo:nil repeats:YES];
}

- (void) stopAutoConnect{
    [_autoConnectionTimer invalidate];
    _autoConnectionTimer = nil;
}


@end
