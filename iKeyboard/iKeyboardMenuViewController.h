//
//  iKeyboardMenuViewController.h
//  iKeyboard
//
//  Created by Lin Chih-An on 2016/4/13.
//  Copyright © 2016年 Lin Chih-An. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "iKeyboardNormalModeViewController.h"

@interface iKeyboardMenuViewController : UIViewController<CBCentralManagerDelegate>

@property CBCentralManager* cbManager;
@property CBPeripheral* serafimPeripheral;
@property iKeyboardNormalModeViewController* normalModeViewController;
@end
