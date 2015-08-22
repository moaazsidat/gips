//
//  ViewController.m
//  Gips
//
//  Created by Moaaz Sidat on 2015-08-18.
//  Copyright (c) 2015 MS. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.aspectRatio = [[NSArray alloc] initWithObjects:0, 0, nil];
    
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)fileSelected:(id)sender {
    NSString *imageLocation = [self.imagePath.URL path];
        NSLog(@"%@", imageLocation);
    
    [self createCGImageFromFile:imageLocation];
}

- (IBAction)heightChanged:(id)sender {
    NSLog(@"height changed");
    if ([[self.imageHeight stringValue] length]) {
        int heightValue = [[self.imageHeight stringValue] intValue];
        int widthValue = (heightValue * [self width]) / [self height];
        NSLog(@"%d, %d, %d", widthValue, self.width, self.height);
        self.imageWidth.stringValue = [NSString stringWithFormat:@"%d", widthValue];
    }
    
}

- (IBAction)widthChanged:(id)sender {
    NSLog(@"width changed");
    if ([[self.imageWidth stringValue] length]) {
        int widthValue = [[self.imageWidth stringValue] intValue];
        int heightValue = (widthValue * [self height]) / [self width];
        NSLog(@"%d, %d, %d", heightValue, self.width, self.height);
        self.imageHeight.stringValue = [NSString stringWithFormat:@"%d", heightValue];
    }
    

}

- (IBAction)gipsImage:(id)sender {
    NSString *imageLocation = [self.imagePath.URL path];
    NSLog(@"%@", imageLocation);
    
//    /* Calculating epoch string to use within new file */
//    NSDate *now = [NSDate date];
//    NSTimeInterval nowEpochSeconds = [now timeIntervalSince1970];
//    NSLog(@"%.f", floor(nowEpochSeconds*1000000));
    
//    [self createCGImageFromFile:imageLocation];
    
    NSString *newImageLocationPath = [[self.imagePath.URL path] stringByDeletingPathExtension];
//    NSLog(@"%@", newImageLocationPath);
    NSString *imageExtension = [self.imagePath.URL pathExtension];
    NSString *newImageLocation = [newImageLocationPath stringByAppendingString:[NSString stringWithFormat:@"_gipped(%@x%@).%@", [self.imageHeight stringValue], [self.imageWidth stringValue], imageExtension]];
    NSLog(@"%@", newImageLocation);
    
    NSString *maxHeightWidth = [NSString stringWithFormat:@"%d",MAX([[self imageWidth] intValue], [[self imageHeight] intValue])];
    NSLog(@"%@", maxHeightWidth);
    
    NSMutableArray *arguments = [[NSMutableArray alloc] init];
    [arguments addObject:imageLocation];
    [arguments addObject:newImageLocation];
    [arguments addObject:maxHeightWidth];
    [arguments addObject:newImageLocation];
    
    
    
    [self runScript:arguments];
}

- (void) runScript:(NSArray*)arguments {
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    dispatch_async(taskQueue, ^{
        self.isRunning = YES;
        
        @try {
            NSString *path = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:@"GipsScript" ofType:@"command"]];
            
            self.gipsTask = [[NSTask alloc] init];
            self.gipsTask.launchPath = path;
            self.gipsTask.arguments = arguments;
            
            
            [self.gipsTask launch];
            
            [self.gipsTask waitUntilExit];
        }
        @catch (NSException *exception) {
            NSLog(@"Problem running task: %@", [exception description]);
        }
        
        @finally {
            
            self.isRunning = NO;
        }
    });
}

- (CGImageRef) createCGImageFromFile:(NSString *)path {
    NSLog(@"Starting createCGImageFromFile");
    // Get the URL for the pathname passed to the function.
    NSURL *url = [NSURL fileURLWithPath:path];
    CGImageRef myImage = NULL;
    CGImageSourceRef myImageSrc;
    CFDictionaryRef myOptions = NULL;
    CFDictionaryRef imagePropertiesDictionary;
    CFStringRef myKeys[2];
    CFTypeRef myValues[2];
    
    // Setting up options
    myKeys[0] = kCGImageSourceShouldCache;
    myValues[0] = (CFTypeRef) kCFBooleanTrue;
    myKeys[1] = kCGImageSourceShouldAllowFloat;
    myValues[1] = (CFTypeRef) kCFBooleanTrue;
    
    // Create the dictionary
    myOptions = CFDictionaryCreate(NULL, (const void **) myKeys,
                                   (const void **) myValues, 2, &kCFTypeDictionaryKeyCallBacks,& kCFTypeDictionaryValueCallBacks);
    myImageSrc = CGImageSourceCreateWithURL((CFURLRef)url, myOptions);
    CFRelease(myOptions);
    
    if (myImageSrc == NULL) {
        fprintf(stderr, "Image source is NULL.");
        return NULL;
    }
    
    // Create an image from the frist item in the image source & checkc if it is created
    myImage = CGImageSourceCreateImageAtIndex(myImageSrc, 0, NULL);
    
    if (myImage == NULL) {
        fprintf(stderr, "Image not created from image source.");
        
        // Disable exportButton
        [self.exportButton setEnabled:NO];
        
        // Show an alert informing the user of the incorrect file type
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Oops, you did not select an image file"];
        [alert setInformativeText:@"Gips only works with image files."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
//        [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
        return NULL;
    }
    NSLog(@"Returning myImage");
    
    // Enable exportButton
    [self.exportButton setEnabled:YES];
    
    // Fetch height and width of the image
    imagePropertiesDictionary = CGImageSourceCopyPropertiesAtIndex(myImageSrc, 0, NULL);
    NSLog(@"%@", imagePropertiesDictionary);
    CFNumberRef imageW = (CFNumberRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyPixelWidth);
    CFNumberRef imageH = (CFNumberRef)CFDictionaryGetValue(imagePropertiesDictionary, kCGImagePropertyPixelHeight);
    
    int w = 0;
    int h = 0;
    
    CFNumberGetValue(imageW, kCFNumberIntType, &w);
    CFNumberGetValue(imageH, kCFNumberIntType, &h);
    CFRelease(imagePropertiesDictionary);
    CFRelease(myImageSrc);
    self.width = w;
    self.height = h;
    NSLog(@"Width: %d", w);
    NSLog(@"Height: %d", h);
    
    // Set height and width values of the textfields
    self.imageHeight.stringValue = [NSString stringWithFormat:@"%d", h];
    self.imageWidth.stringValue = [NSString stringWithFormat:@"%d", w];
    
    return myImage;
}

//- (void)setHeightWidth:(NSURL*)url {
//    NSString *inputFileName = [[self.imagePath.URL lastPathComponent] stringByDeletingPathExtension];
//    CFURLRef fileurl = CFURLCreateFromFileSystemRepresentation(kCFAllocatorDefault, (const UInt8*), strlen(inputFileName), false);
//    
//    
//}
@end
