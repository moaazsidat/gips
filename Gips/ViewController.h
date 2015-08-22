//
//  ViewController.h
//  Gips
//
//  Created by Moaaz Sidat on 2015-08-18.
//  Copyright (c) 2015 MS. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ImageIO/ImageIO.h>


@interface ViewController : NSViewController
@property (weak) IBOutlet NSPathControl *imagePath;
@property (weak) IBOutlet NSButton *exportButton;
@property (weak) IBOutlet NSTextField *imageHeight;
@property (weak) IBOutlet NSTextField *imageWidth;

/* Actions */

- (IBAction)fileSelected:(id)sender;
- (IBAction)heightChanged:(id)sender;
- (IBAction)widthChanged:(id)sender;
- (IBAction)gipsImage:(id)sender;


/* NSTask */
@property (nonatomic, strong) __block NSTask *gipsTask;
@property (nonatomic) BOOL isRunning;
@property (nonatomic) BOOL isImage;

/* Image file */
@property (nonatomic) NSArray *aspectRatio;
@property (nonatomic) int width;
@property (nonatomic) int height;

@end

