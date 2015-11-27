//
//  Filter.m
//  Task_1
//
//  Created by Евгений on 26.11.15.
//  Copyright © 2015 Eugene Kirtaev. All rights reserved.
//

#import "Filter.h"
#import <CoreImage/CoreImage.h>
#import <UIKit/UIKit.h>

@interface Filter ()

@property (strong, nonatomic) CIFilter * controlsFilter;
@property (strong, nonatomic) CIContext * context;

@end

@implementation Filter

+(instancetype)sharedFilter{
    static Filter * filter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        filter = [Filter new];
    });
    return filter;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.controlsFilter = [CIFilter filterWithName:@"CITemperatureAndTint"];
        self.context = [CIContext contextWithOptions:nil];
    }
    return self;
}

- (UIImage *)imagewithFilter:(UIImage *)image{
    CIImage * beginImage = [CIImage imageWithCGImage:image.CGImage];
    [self.controlsFilter setValue:beginImage forKey:kCIInputImageKey];
    [self.controlsFilter setValue:[CIVector vectorWithX:6500 Y:500] forKey:@"inputNeutral"];
    [self.controlsFilter setValue:[CIVector vectorWithX:1000 Y:630] forKey:@"inputTargetNeutral"];
    CIImage *result = [self.controlsFilter valueForKey:kCIOutputImageKey];
    CGRect extent = [result extent];
    CGImageRef cgImage = [self.context createCGImage:result fromRect:extent];
    UIImage * newImage = [UIImage imageWithCGImage:cgImage];
    return newImage;
}

@end
