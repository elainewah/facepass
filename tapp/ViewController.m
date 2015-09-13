//
//  ViewController.m
//  tapp
//
//  Created by Travis Martin on 9/12/15.
//  Copyright (c) 2015 Travis Martin. All rights reserved.
//

#import "ViewController.h"
#import "utils.h"
#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

#import <AVFoundation/AVFoundation.h>


@interface ViewController ()

@end


@implementation ViewController

UIImage *secret_image;
CGPoint secret_point;

NSString *pick_secret_image = @"Select your secret image";
NSString *pick_secret_points = @"Press a secret point on your face";
NSString *pick_guess_image = @"Take a selfie to authenticate";
NSString *pick_guess_points = @"Press your secret point";


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    if ([_statusTest.text isEqualToString:@"status"]) {
        _statusTest.text = pick_secret_image;
    }

    // Do any additional setup after loading the view, typically from a nib.
}

// Controlling  the image selection
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    // store a secret image and
    if ( secret_image == nil) {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:NO completion:nil];
        

    }
    else {
    
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [self dismissViewControllerAnimated:YES completion:nil];
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //self.imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;

    // the first time we pick an image, store it as a secret
    if ( secret_image == nil) {
        secret_image = image;
        _statusTest.text = pick_secret_points;
        self.imageView.image = image;
    }
    else {
        _statusTest.text = pick_guess_points;
        self.imageView.image = image;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}



CGPoint begin_point;

- (void) touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event {    UITouch *touch = [touches anyObject];
    begin_point = [touch locationInView:self.view];
   }

- (bool) close:(CGPoint)test_point {
    CGFloat dx = test_point.x - secret_point.x;
    CGFloat dy = test_point.y - secret_point.y;
    if (dx*dx + dy*dy < 100) {
        return true;
    }
    else {
        return false;
    }
}

- (void) touchesEnded:(NSSet *)touches
            withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];

    NSLog(@"%@", _statusTest.text);
    
    // When secret points are selected, we solicit a verification
    if ([_statusTest.text isEqualToString: pick_secret_points]) {
        secret_point = point;
        _statusTest.text = pick_guess_image;
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:NO completion:nil];
        
    }
    // This is the case when the new image has been set
    else if(![_statusTest.text isEqualToString: @"success"]){
        
        if ([self close:point]) {
            _statusTest.text = @"success";
            self.imageView.image = [UIImage imageNamed:@"success"];
        }
        else {
            CGFloat dX = secret_point.x - point.x;
            CGFloat dY = secret_point.y - point.y;
            
            _statusTest.text = [NSString stringWithFormat:
                                @"%.1f, %.1f", dX, dY];
        }
        
        /*
        Utils *u = [[Utils alloc] init];
        [u sendImage];
         */
    }
    
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)useCamera:(id)sender {
}

- (IBAction)useCameraRoll:(id)sender {
}


@end
