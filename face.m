#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
//#import <UIKit/UIKit.h>


// to store the bounding box
typedef struct {
    int* top;
    int* left;
    int* width;
    int* height;
} Face;


int main(int argc, const char * argv[])
{
    Face groundTruth;
    Face selfie;
    NSString* faceId = nil;
    NSString* selfieId = nil;

    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];



    // ANALYZE STORED (GROUND TRUTH) IMAGE    
    NSString* path = @"https://api.projectoxford.ai/face/v0/detections";
    path = [path stringByAppendingFormat:@"?entities=true&analyzesFaceLandmarks=true&analyzesAge=false&analyzesGender=false&analyzesHeadPose=false"];
    NSLog(@"%@", path);
    NSMutableURLRequest* _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [_request setValue:@"c9c3f42528ad4642910d3fc587c06b18" forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];
    [_request setHTTPMethod:@"POST"];

    // local image
    /*
    UIImage *image = [UIImage imageWithContentsOfFile: @"./img/photo.jpg"];
    NSData *imageData = [NSData dataWithData:UIImageJPEGRepresentation(image)];

    [_request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];

    NSString *boundary = @"14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [_request addValue:contentType forHTTPHeaderField: @"Content-Type"];

    //NSData *imageData = UIImageJPEGRepresentation("./img/photo.jpg", 0.2);
    NSMutableData *body = [NSMutableData data];
    //[body appendData:[NSData datawithData:imageData]];

    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition:form-data; name=\"file\"; filename=\"%@\"\r\n","./img/photo.jpg"] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    */

    
    // image URL 
    [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary * jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
			    @"http://web.eecs.umich.edu/~ewah/img/photo.jpg", @"url",
			    nil];
    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
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

    // image URL 
    [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary * selfieDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                @"http://vision.ucsd.edu/~cwah/assets/img.jpg", @"url",
                nil];
    error = nil;
    body = [NSJSONSerialization dataWithJSONObject:selfieDict options:NSJSONWritingPrettyPrinted error:&error];
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
    // NSLog(@"%@", verifyDict);
    // NSLog(@"Face values: %@", [verifyDict allValues]);
    // NSLog(@"Face keys: %@", [verifyDict allKeys]);

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


    [pool drain];

    return 0;
}
