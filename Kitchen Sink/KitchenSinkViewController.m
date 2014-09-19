//
//  KitchenSinkViewController.m
//  Kitchen Sink
//
//  Created by Cruise on 14-6-15.
//  Copyright (c) 2014年 Ding. All rights reserved.
//

#import "KitchenSinkViewController.h"
#import "AskerViewController.h"

@interface KitchenSinkViewController () <AskerViewControllerDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIView *kitchenSink;
@property (weak, nonatomic) NSTimer *drainTimer;
@property (weak, nonatomic) UIActionSheet *actionSheet;
@end

@implementation KitchenSinkViewController
@synthesize kitchenSink = _kitchenSink;
@synthesize drainTimer = _drainTimer;
@synthesize actionSheet = _actionSheet;

 
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier hasPrefix:@"Create Label"]) {
        AskerViewController* asker = (AskerViewController*)segue.destinationViewController;
        asker.question = @"what do you want your label to say?";
        asker.answer = @"Label Text";
        asker.delegate = self;
    }
}

-(void) setRandomLocationForView:(UIView*)view
{
    [view sizeToFit];
    CGRect sinkBounds = CGRectInset(self.kitchenSink.bounds, view.frame.size.width/2, view.frame.size.height/2);
    CGFloat x = arc4random()%(int)sinkBounds.size.width+view.frame.size.width/2;
    CGFloat y = arc4random()%(int)sinkBounds.size.height+view.frame.size.height/2;
    view.center = CGPointMake(x, y);
}

- (IBAction)tap:(UITapGestureRecognizer *)gesture
{
    CGPoint tapLocation = [gesture locationInView:self.kitchenSink];
    for (UIView *view in self.kitchenSink.subviews)
    {
        if (CGRectContainsPoint(view.frame, tapLocation))
        {
            [UIView animateWithDuration:4.0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                                                         [self setRandomLocationForView:view];
                //view.transform = CGAffineTransformIdentity;   //如果此时把transform恢复为CGAffineTransformIdentity，那么drain会冲走view，因为必须满足transform为原始尺寸这一条件，才能触发drain的动画
                view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.99, 0.99);
            }completion:^(BOOL finished){
                view.transform = CGAffineTransformIdentity; //恢复动画结束以后，把transform设置为CGAffineTransformIdentity，drain动画就又可以工作了
            }];
        }
    }
}

#define DRAIN_TIMES 5.0
#define DRAIN_DURATION 3.0

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.drainTimer = [NSTimer scheduledTimerWithTimeInterval:DRAIN_TIMES target:self selector:@selector(drain) userInfo:nil repeats:YES];
    [self drip];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self.drainTimer invalidate];
}

-(void) addLabel:(NSString*)text
{
    UILabel *label = [[UILabel alloc] init];
    static NSDictionary *colors = nil;
    if (!colors) colors = [NSDictionary dictionaryWithObjectsAndKeys:
                           [UIColor blueColor], @"Blue",
                           [UIColor greenColor],@"Green",
                           [UIColor orangeColor],@"Orange",
                           nil];
    if (![text length]) {
        NSString *color = [[colors allKeys] objectAtIndex:arc4random()%[colors count]];
        text = color;
        label.textColor = [colors objectForKey:color];
    }
    label.text = text;
    label.font = [UIFont systemFontOfSize:48.0];
    label.backgroundColor = [UIColor clearColor];
    [self setRandomLocationForView:label];
    [self.kitchenSink addSubview:label];
}

- (void) askerViewController:(id)sender didAskQuestion:(NSString *)question andGotAnswer:(NSString *)answer
{
    [self addLabel:answer];
    //[self dismissModalViewControllerAnimated:YES];
}

-(void) drain:(NSTimer *)timer
{
    [self drain];
}

-(void) drain
{
    for (UIView *view in self.kitchenSink.subviews) {
        CGAffineTransform transform = view.transform;
        if (CGAffineTransformIsIdentity(transform)) {
            UIViewAnimationOptions options = UIViewAnimationOptionCurveLinear;
            [UIView animateWithDuration:DRAIN_DURATION/3 delay:0 options:options animations:^{
                view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.7, 0.7), 2*M_PI/3);
            }completion:^(BOOL finished){
                if (finished) {
                    [UIView animateWithDuration:DRAIN_DURATION/3 delay:0 options:options animations:^{
                        view.transform = CGAffineTransformRotate(CGAffineTransformScale(transform, 0.4, 0.4), -2*M_PI/3);
                    }completion:^(BOOL finished){
                        if (finished) {
                            [UIView animateWithDuration:DRAIN_DURATION/3 delay:0 options:options animations:^{
                                view.transform = CGAffineTransformScale(transform, 0.1, 0.1);
                            }completion:^(BOOL finished){
                                if (finished) {
                                    [view removeFromSuperview];
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }
}

-(void) drip
{
    if (self.kitchenSink.window) {
        [self addLabel:nil];
        [self performSelector:@selector(drip) withObject:nil afterDelay:2.0];
    }
}
- (IBAction)controlSink:(UIBarButtonItem*)sender
{
    if (self.actionSheet) {
        //do nothing
    }else{
        NSString *drainbutton = self.drainTimer?@"Stopper drain":@"Unstopper";
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Sink Controls" delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:@"empty Sink" otherButtonTitles:drainbutton , nil];
        [actionSheet showFromBarButtonItem:sender animated:YES];
    }   //destructiveButton点击这个button UIActionSheet撤销，同时执行相应的操作
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *choice = [actionSheet buttonTitleAtIndex:buttonIndex];
    if (buttonIndex == [actionSheet destructiveButtonIndex]) {
        [self.kitchenSink.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)]; //遍历subviews数组全部元素，都执行selector
    }else if ([choice isEqualToString:@"Stopper drain"]){
        [self.drainTimer invalidate];
    }else if ([choice isEqualToString:@"Unstopper"]){
           self.drainTimer = [NSTimer scheduledTimerWithTimeInterval:DRAIN_TIMES target:self selector:@selector(drain) userInfo:nil repeats:YES];
    }
}
- (IBAction)addImage:(UIBarButtonItem *)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        NSArray *mediaType = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    }
}

@end









