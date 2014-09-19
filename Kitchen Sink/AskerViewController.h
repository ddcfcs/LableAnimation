//
//  AskerViewController.h
//  Kitchen Sink
//
//  Created by Cruise on 14-6-15.
//  Copyright (c) 2014年 Ding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KitchenSinkViewController.h"

@class AskerViewController;

@protocol AskerViewControllerDelegate <NSObject>

-(void) askerViewController:(AskerViewController*)sender
             didAskQuestion:(NSString*)question
               andGotAnswer:(NSString*)answer;

@end

@interface AskerViewController : UIViewController

@property (nonatomic,copy) NSString *question;
@property (nonatomic,copy) NSString *answer;

@property (nonatomic,weak) id <AskerViewControllerDelegate> delegate;

@end
