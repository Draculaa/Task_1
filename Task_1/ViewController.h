//
//  ViewController.h
//  Task_1
//
//  Created by Евгений on 25.11.15.
//  Copyright © 2015 Eugene Kirtaev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *inputImageView;
@property (strong, nonatomic) IBOutlet UIImageView *outputImageView;
- (IBAction)pushFilterButton:(id)sender;
- (IBAction)pushSaveButton:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *FilterButton;
@property (strong, nonatomic) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

