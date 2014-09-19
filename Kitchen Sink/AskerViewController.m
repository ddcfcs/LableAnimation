//
//  AskerViewController.m
//  Kitchen Sink
//
//  Created by Cruise on 14-6-15.
//  Copyright (c) 2014年 Ding. All rights reserved.
//

#import "AskerViewController.h"
#import "KitchenSinkViewController.h"

@interface AskerViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *questionLabel;
@property (weak, nonatomic) IBOutlet UITextField *answerTextFielld;

@end

@implementation AskerViewController
@synthesize questionLabel = _questionLabel;
@synthesize answerTextFielld = _answerTextFielld;
@synthesize question = _question;
@synthesize answer = _answer;
@synthesize delegate = _delegate;

-(void) setQuestion:(NSString *)question
{
    NSLog(@"question = %@",question);
    _question = question;
    self.questionLabel.text = question;
}
 
-(void) viewDidLoad
{
    [super viewDidLoad];
    // NSLog(@"question = %@",self.question);
    self.questionLabel.text = self.question;
    self.answerTextFielld.placeholder = self.answer;
    self.answerTextFielld.delegate = self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.answerTextFielld becomeFirstResponder];
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    self.answer = textField.text;
    if (![textField.text length]) {
        //[[self presentingViewController] dismissModalViewControllerAnimated:YES];
    }else{
        [self.delegate askerViewController:self didAskQuestion:self.question andGotAnswer:self.answer];
    }
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text length]) {
        [textField resignFirstResponder];
        [[self presentingViewController] dismissModalViewControllerAnimated:YES];   //因为AskerViewController是modal弹出方式，要用此方法隐藏
        //[self.navigationController popViewControllerAnimated:YES];                //此方法用来针对push的弹出方式，可以返回上一个ViewController
        return YES;
    }else{
        return NO;
    }
}

@end
