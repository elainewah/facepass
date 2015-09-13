
#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>
#import <UIKit/UIKit.h>

// to store the bounding box
typedef struct {
    int top;
    int left;
    int width;
    int height;
} Face;

typedef struct {
    Face secret;
    Face guessed;
    bool identical;
} AllFaces;

@interface Utils : NSObject
- (AllFaces) sendImage : (UIImage *) image IMGARG2 : (UIImage *) guessed_image;
@end