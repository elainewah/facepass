#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import <UIKit/UIKit.h>


int main(int argc, const char * argv[])
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    NSString* path = @"https://api.projectoxford.ai/face/v0/detections";
    path = [path stringByAppendingFormat:@"?analyzesFaceLandmarks=true&analyzesAge=false&analyzesGender=false&analyzesHeadPose=false"];
    NSLog(@"%@", path);
    NSMutableURLRequest* _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:path]];
    [_request setHTTPMethod:@"POST"];

    // local image
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


    /*
    // image URL 
    [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSDictionary *jsonDict = [[NSDictionary alloc] initWithObjectsAndKeys:
			    @"http://web.eecs.umich.edu/~ewah/img/photo.jpg", @"url",
			    nil];
    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:jsonDict options:NSJSONWritingPrettyPrinted error:&error];
    */

    /* for testing json dict
    NSString *strData = [[NSString alloc]initWithData:body encoding:NSUTF8StringEncoding];
    NSLog(@"%@", strData);
    */

    // [_request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    [_request setValue:@"c9c3f42528ad4642910d3fc587c06b18" forHTTPHeaderField:@"Ocp-Apim-Subscription-Key"];


    // Request body
    [_request setHTTPBody:body];
   
    NSURLResponse *response = nil;
    NSData* _connectionData = [NSURLConnection sendSynchronousRequest:_request returningResponse:&response error:&error];

    if (nil != error)
    {
        NSLog(@"Error: %@", error);
    }
    else
    {
        NSError* error = nil;
        NSMutableDictionary* json = nil;
        NSString* dataString = [[NSString alloc] initWithData:_connectionData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", dataString);
        
        if (nil != _connectionData)
        {
            json = [NSJSONSerialization JSONObjectWithData:_connectionData options:NSJSONReadingMutableContainers error:&error];
        }
        
        if (error || !json)
        {
            NSLog(@"Could not parse loaded json with error:%@", error);
        }
        
        NSLog(@"%@", json);
        _connectionData = nil;
    }
    
    [pool drain];

    return 0;
}
