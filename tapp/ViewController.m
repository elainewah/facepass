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

NSString *pick_secret_image = @"Take your FacePass";
NSString *pick_secret_points = @"Tap a spot on your face";
NSString *pick_guess_image = @"Thanks! Take a selfie to authenticate";
NSString *pick_guess_points = @"Tap your FacePass";
NSString *success_string = @"Success!";
NSString *failure_string = @"Failure!";
NSString *wrong_face = @"FacePasses don't match";

float secret_sleep = 1;
float guess_sleep = 1;

AllFaces allFaces;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    
    
    
    //Utils *u = [[Utils alloc] init];
    //[u sendImage : [UIImage imageNamed:@"travis"]];
    
    if ([_statusTest.text isEqualToString:@"status"]) {
        _statusTest.text = pick_secret_image;
        [NSThread sleepForTimeInterval:secret_sleep];
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
        
        Utils *u = [[Utils alloc] init];
        allFaces = [u sendImage : secret_image IMGARG2 : image];
        if (!allFaces.identical) {
            _statusTest.text = wrong_face;
            self.imageView.image = [UIImage imageNamed:@"failure"];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


float calc_pct(float coord, int begin, int length) {
    return (coord - begin) / length;
}


- (bool) close:(CGPoint)test_point {
    // First convert to percentages
    float test_x_pct = calc_pct(test_point.x, allFaces.guessed.left, allFaces.guessed.width);
    float test_y_pct = calc_pct(test_point.y, allFaces.guessed.top, allFaces.guessed.height);
    
    float secret_x_pct = calc_pct(secret_point.x, allFaces.secret.left, allFaces.secret.width);
    float secret_y_pct = calc_pct(secret_point.y, allFaces.secret.top, allFaces.secret.height);
    
    
    CGFloat dx = test_x_pct - secret_x_pct;
    CGFloat dy = test_y_pct - secret_y_pct;
    
    if (dx*dx + dy*dy < .10) {
        return true;
    }
    else {
        return false;
    }
}


- (void) touchesBegan:(NSSet *)touches
            withEvent:(UIEvent *)event {
    // When secret points are selected, we solicit a verification
    if ([_statusTest.text isEqualToString: pick_secret_points]) {
        _statusTest.text = pick_guess_image;
    }
}

int wrong_tries = 0;

- (void) touchesEnded:(NSSet *)touches
            withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];

    NSLog(@"%@", _statusTest.text);
    
    // When secret points are selected, we solicit a verification
    if ([_statusTest.text isEqualToString: pick_guess_image]) {
        secret_point = point;
        //NSLog(@"%f, %f", secret_point.x, secret_point.y);
        
        [NSThread sleepForTimeInterval:guess_sleep];
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
        imagePickerController.delegate = self;
        [self presentViewController:imagePickerController animated:NO completion:nil];
        
    }
    // This is the case when the new image has been set
    else if(![_statusTest.text isEqualToString: success_string] && ![_statusTest.text isEqualToString: failure_string] && ![_statusTest.text isEqualToString: wrong_face]){
        
        if ([self close:point]) {
            _statusTest.text = success_string;
            self.imageView.image = [UIImage imageNamed:@"success"];
        }
        else {
            CGFloat dX = secret_point.x - point.x;
            CGFloat dY = secret_point.y - point.y;
            
            wrong_tries += 1;
            
            if (wrong_tries > 2) {
                self.imageView.image = [UIImage imageNamed:@"failure"];
                _statusTest.text = failure_string;
            }
            
            else {
                _statusTest.text = [NSString stringWithFormat:
                                    @"Wrong! %d guesses remaining", 4-wrong_tries];
                                //@"%.1f, %.1f, Wrong guess #%d", dX, dY, wrong_tries];
            }
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
