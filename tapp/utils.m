#import "utils.h"
//#import "ImgurSession/IMGSession.h"
//#import "ImgurSession/Requests/IMGImageRequest.h"
//#import "ImgurSession/Models/IMGImage.h"

@implementation Utils : NSObject



- (AllFaces) sendImage : (UIImage *) secret_image IMGARG2 : (UIImage *) guessed_image
{
    @autoreleasepool {
        
        Face groundTruth;
        Face selfie;
        NSString* faceId = nil;
        NSString* selfieId = nil;
        
        NSError *error = nil;
        
        
        ///////////////////////////////////////////////////////////////////////////
        // ANALYZE STORED (GROUND TRUTH) IMAGE
        NSString* path = @"https://api.projectoxford.ai/face/v0/detections";
        path = [path stringByAppendingFormat:@"?entities=true&analyzesFaceLandmarks=true&analyzesAge=false&analyzesGender=false&analyzesHeadPose=false"];
        NSLog(@"%@", path);
        NSMutableURLRequest* _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
        [_request setValue:@"c9c3f42528ad4642910d3fc587c06b18" forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
        [_request setHTTPMethod:@"POST"];
        
        // ======================================================================
        // local image
        [_request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
        NSData *body = [NSData dataWithData:UIImageJPEGRepresentation(secret_image,1)];
        
        // ======================================================================
        
        
        [_request setHTTPBody:body];
        
        NSURLResponse *response = nil;
        NSData* _connectionData = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
        
        if (nil != error) {
            NSLog(@"Error: %@", error);
        } else {
            NSError* error = nil;
            NSArray* json = nil;
            
            if (nil != _connectionData) {
                json = [NSJSONSerialization JSONObjectWithData:_connectionData options:NSJSONReadingMutableContainers error:&error];
            }
            if (error || !json) {
                NSLog(@"Could not parse loaded json with error:%@", error);
            }
            
            NSLog(@"%@", json);
            // now get the face ID of the image here
            for (NSDictionary * dict in json) {
                faceId = [dict objectForKey:@"faceId"];
                NSLog(@"%@", faceId);
                
                // get face bounding box
                NSDictionary * rect = [dict objectForKey:@"faceRectangle"];
                groundTruth.top = [[rect objectForKey:@"top"] intValue];
                groundTruth.left = [[rect objectForKey:@"left"] intValue];
                groundTruth.width = [[rect objectForKey:@"width"] intValue];
                groundTruth.height = [[rect objectForKey:@"height"] intValue];
                
                // NSLog(@"%@", groundTruth.top);
            }
            _connectionData = nil;
        }
        
        
        
        
        path = [path stringByAppendingFormat:@"?entities=true&analyzesFaceLandmarks=true&analyzesAge=false&analyzesGender=false&analyzesHeadPose=false"];
        NSLog(@"%@", path);
        _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
        [_request setValue:@"c9c3f42528ad4642910d3fc587c06b18" forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
        [_request setHTTPMethod:@"POST"];
        
        // ======================================================================
        // local image
        [_request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
        body = [NSData dataWithData:UIImageJPEGRepresentation(guessed_image,1)];
        
        // ======================================================================
        
        
        [_request setHTTPBody:body];
        
        response = nil;
        _connectionData = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
        
        
        
        
        if (nil != error) {
            NSLog(@"Error: %@", error);
        } else  {
            NSError* error = nil;  NSArray* json = nil;
            if (nil != _connectionData) {
                json = [NSJSONSerialization JSONObjectWithData:_connectionData options:NSJSONReadingMutableContainers error:&error];
            }
            if (error || !json) {
                NSLog(@"Could not parse loaded json with error:%@", error);
            }
            NSLog(@"%@", json);
            // now get the selfie ID of the image here
            for (NSDictionary * dict in json) {
                selfieId = [dict objectForKey:@"faceId"];
                NSLog(@"%@", selfieId);
                
                // get face bounding box
                NSDictionary * rect = [dict objectForKey:@"faceRectangle"];
                selfie.top = [[rect objectForKey:@"top"] intValue];
                selfie.left = [[rect objectForKey:@"left"] intValue];
                selfie.width = [[rect objectForKey:@"width"] intValue];
                selfie.height = [[rect objectForKey:@"height"] intValue];
            }
            _connectionData = nil;
        }
        
        
        
        
        
        //////////////////////////////////////////////////////////////////////////////////
        // PERFORM VERIFICATION
        bool identical = nil;
        double confidence = 0.0;
        
        NSString * path2 = @"https://api.projectoxford.ai/face/v0/verifications";
        NSLog(@"%@", path2);
        _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path2]];
        [_request setValue:@"67d31b95273e486da2958d75dcd50114" forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
        [_request setHTTPMethod:@"POST"];
        
        [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        NSDictionary * verifyDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     faceId, @"faceId1", selfieId, @"faceId2", nil];
        
        error = nil;
        NSData *verifyBody = [NSJSONSerialization dataWithJSONObject:verifyDict options:0 error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:verifyBody encoding:NSUTF8StringEncoding];
        NSLog(@"%@", jsonString);
        
        [_request setHTTPBody:verifyBody];
        response = nil;
        NSData* _connectionData2 = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];
        
        if (nil != error) {
            NSLog(@"Error: %@", error);
        } else {
            NSString* jsonString = [[NSString alloc] initWithData:_connectionData2 encoding:NSUTF8StringEncoding];
            NSLog(@"%@", jsonString);
            
            // determine if identical = true
            NSRange checkTrue = [jsonString rangeOfString:@"true"];
            if (checkTrue.location == NSNotFound) {
                NSLog(@"not identical");
                identical = false;
            } else {
                identical = true;
                if (identical) {
                    NSLog(@"identical");
                }
            }
            
            // extract confidence value
            NSRange conf = [jsonString rangeOfString:@"confidence"];
            if (conf.location == NSNotFound) {
                NSLog(@"this is a problem");
            } else {
                NSRange range = NSMakeRange(conf.location + conf.length + 2, 6);
                NSLog(@"%@", [jsonString substringWithRange:range]);
                
                NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
                f.numberStyle = NSNumberFormatterDecimalStyle;
                confidence = [[f numberFromString:[jsonString substringWithRange:range]] doubleValue];
                NSLog(@"%lf", confidence);
            }
            
            _connectionData2 = nil;
        }
        
        AllFaces allFaces;
        allFaces.secret = groundTruth;
        allFaces.guessed = selfie;
        allFaces.identical = identical;
        
        return allFaces;
        
        
        
    }
        
        
    
}

@end
