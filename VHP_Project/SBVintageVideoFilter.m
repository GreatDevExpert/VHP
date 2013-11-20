//
//  SBVintageVideoFilter.m
//  SongBooth
//
//  Created by Eric Yang on 11/23/12.
//  Copyright (c) 2012 LogN. All rights reserved.
//

#import "SBVintageVideoFilter.h"

@implementation SBVintageVideoFilter

- (id)init
{
	if (self = [super init]) {
		UIImage *image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"bw_overlay.png" ofType:nil inDirectory:@"videoEffects/vintage"]];
		NSURL *movieURL = [[NSBundle mainBundle] URLForResource:@"overlay.m4v" withExtension:nil subdirectory:@"videoEffects/vintage"];
		GPUImageMovie *movieFile = [[GPUImageMovie alloc] initWithAsset:[AVAsset assetWithURL:movieURL]];
		movieFile.playAtActualSpeed = YES;
		GPUImagePicture *imageFile = [[GPUImagePicture alloc] initWithImage:image];
        
		GPUImageUnsharpMaskFilter *filter = [[GPUImageUnsharpMaskFilter alloc] init];
		[movieFile addTarget:filter];
		[imageFile addTarget:filter];
		[imageFile processImage];
        self.initialFilters = @[filter];
		self.terminalFilter = filter;
	}
	return self;
}

@end
