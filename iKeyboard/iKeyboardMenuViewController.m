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
    
    self.normalModeViewController = [[iKeyboardNormalModeViewController alloc] init];
    
    self.cbManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    self.navigationController.navigationBar.hidden = YES;
    
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
  //  [backButton setBackgroundColor:[UIColor redColor]];
  //  backButton.alpha = 0.5;
    [self.view addSubview:backButton];
}

-(void)bluetoothReady
{
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    NSArray<CBUUID*>* iKeyboService = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"FFA0"]];
    NSArray<CBPeripheral*>* iKeyboperipherals = [self.cbManager retrieveConnectedPeripheralsWithServices:iKeyboService];
    if(iKeyboperipherals.count == 1)
        self.serafimPeripheral = [iKeyboperipherals objectAtIndex:0];
    else
        [self.cbManager scanForPeripheralsWithServices:nil options:options];
    
}

#pragma mark - Actions

-(void)iKeyboConnectionButtonClicked
{
    if(self.serafimPeripheral)
        [self.cbManager connectPeripheral:self.serafimPeripheral options:nil];
    else
    {
        NSLog(@"No Serafim device found");
        return;
    }
}

-(void)getOneButtonClicked
{
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.google.com"]];
}

-(void)backButtonClicked
{
    [self presentViewController:self.normalModeViewController animated:YES completion:nil];
  //  [self performSegueWithIdentifier:@"showNormalModeViewController" sender:nil];
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
            break;
        case CBCentralManagerStatePoweredOn:
            [nsmstring appendString:@"PoweredOn\n"];
            [self bluetoothReady];
            break;
        default:
            [nsmstring appendString:@"none\n"];
            break;
    }
    NSLog(@"%@",nsmstring);
    //  [delegate didUpdateState:isWork message:nsmstring getStatus:cManager.state];
}

-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    /*
    NSMutableString* nsmstring=[NSMutableString stringWithString:@"\n"];
    [nsmstring appendString:@"Peripheral Info:"];
    [nsmstring appendFormat:@"NAME: %@\n",peripheral.name];
    [nsmstring appendFormat:@"RSSI: %@\n",RSSI];
    
    
    [nsmstring appendFormat:@"adverisement:%@",advertisementData];
    [nsmstring appendString:@"didDiscoverPeripheral\n"];
     NSLog(@"%@",nsmstring);
     */
    if([[advertisementData objectForKey:@"kCBAdvDataLocalName"] isEqualToString:@"Serafim iKeybo"])
        self.serafimPeripheral = peripheral;
}

-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self.normalModeViewController;
  //  self.normalModeViewController.serafimPeripheral = self.serafimPeripheral;
    [peripheral discoverServices:nil];
    [self presentViewController:self.normalModeViewController animated:YES completion:nil];
}

@end
