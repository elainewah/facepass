//
//  ViewController.h
//  tapp
//
//  Created by Travis Martin on 9/12/15.
//  Copyright (c) 2015 Travis Martin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *statusTest;

@end

