#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import <UIKit/UIKit.h>



NSData* getImageViaURL(NSString *url, NSMutableURLRequest* _request) {
    [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    NSDictionary * jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                url, @"url", nil];
    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
    return body;
}

// assumes JPG representation for images
NSData* getImageLocally(UIImage *image, NSMutableURLRequest* _request) {
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image)];

    NSString *boundary = @"14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [_request addValue:contentType forHTTPHeaderField: @"Content-Type"];

    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];

    return body;
}




int main(int argc, const char * argv[])
{
    Face groundTruth;
    Face selfie;
    NSString* faceId = nil;
    NSString* selfieId = nil;

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
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
    // NSData* body = getImageLocally(image, _request);
    
    // image URL 
    NSData* body = getImageViaURL(@"http://web.eecs.umich.edu/~ewah/img/photo.jpg", _request);
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
            groundTruth.top = (int*) [rect objectForKey:@"top"];
            groundTruth.left = (int*) [rect objectForKey:@"left"];
            groundTruth.width = (int*) [rect objectForKey:@"width"];
            groundTruth.height = (int*) [rect objectForKey:@"height"];
            
            // NSLog(@"%@", groundTruth.top);
        }
        _connectionData = nil;
    }
    
    //////////////////////////////////////////////////////////////////////////////////
    // ANALYZE SELFIE

    // ======================================================================
    // local image
    // NSData* body2 = getImageLocally(image2, _request);

    // image URL 
    NSData* body2 = getImageViaURL(@"http://vision.ucsd.edu/~cwah/assets/img.jpg", _request);
    // ==================================================

    [_request setHTTPBody:body2];
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
            selfie.top = (int*) [rect objectForKey:@"top"];
            selfie.left = (int*) [rect objectForKey:@"left"];
            selfie.width = (int*) [rect objectForKey:@"width"];
            selfie.height = (int*) [rect objectForKey:@"height"];
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

        // TODO: could not get JSON parsing to work correctly
        // if (nil != _connectionData2) {
        //     json = [NSJSONSerialization JSONObjectWithData:_connectionData2 options:NSJSONReadingAllowFragments error:&error];
        // }
        // if ([json isKindOfClass:[NSDictionary class]] && error == nil) {
        //     NSLog(@"dictionary: %@", json);
        // }
        // if (error || !json) {
        //     NSLog(@"Could not parse loaded json with error:%@", error);
        // }
        // NSLog(@"%@", json);
        // // now get the verification results
        // bool match = (bool) [json objectForKey:@"isIdentical"];
        // NSNumber * conf = [[NSNumber alloc] init];
        // conf = [json objectForKey:@"confidence"];
        // NSLog(@"%@", json);
        // NSLog(@"%@", match);
        // NSLog(@"%@", conf);

        _connectionData2 = nil;
    }


    // TODO if confidence is greater than some threshold and identical == true, then should be a match!


    [pool drain];

    return 0;
}
