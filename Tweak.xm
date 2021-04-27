#import "SettingsWallpaper.h"

extern "C" CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

static void refreshPrefs()
{
    NSDictionary *bundleDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.popsicletreehouse.settingswallpaperprefs"];
    enabled = [bundleDefaults objectForKey:@"isEnabled"] ? [[bundleDefaults objectForKey:@"isEnabled"] boolValue] : YES;
    blur = [bundleDefaults objectForKey:@"isBlur"] ? [[bundleDefaults objectForKey:@"isBlur"]boolValue] : YES;
	alpha = [bundleDefaults objectForKey:@"cellBGAlphaEnabled"] ? [[bundleDefaults objectForKey: @"cellBGAlphaEnabled"] boolValue] : YES;
	blurType = [bundleDefaults objectForKey:@"blurType"] ? [[bundleDefaults objectForKey:@"blurType"]intValue] : 0;
    intensity = [bundleDefaults objectForKey:@"blurIntensity"] ? [[bundleDefaults objectForKey:@"blurIntensity"]floatValue] : 1.0f;
	wallpaperMode = [bundleDefaults objectForKey:@"wallpaperMode"] ? [[bundleDefaults objectForKey:@"wallpaperMode"]intValue] : 0;
	cellAlpha = [bundleDefaults objectForKey: @"cellBackgroundAlpha"] ? [[bundleDefaults objectForKey: @"cellBackgroundAlpha"] floatValue] : 1.0f;
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    refreshPrefs();
}

%hook UITableView
-(void)didMoveToSuperview {
	if(enabled && !self.backgroundView) {
		NSArray *wallpaperStrings = @[@"/var/mobile/Library/SpringBoard/LockBackground.cpbitmap", @"/var/mobile/Library/SpringBoard/HomeBackground.cpbitmap"];
		UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.backgroundView.bounds];
		[backgroundImageView setClipsToBounds:YES];
        [backgroundImageView setContentMode: UIViewContentModeScaleAspectFill];
        [self setBackgroundView: backgroundImageView];
		if(blur) {
			int validBlurs[3] = {4, 2, 1};
			UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:(long)validBlurs[blurType]]];
			blurEffectView.frame = self.backgroundView.bounds;
			blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
			blurEffectView.alpha = intensity;
			[self.backgroundView addSubview:blurEffectView];
		}
		BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[wallpaperStrings objectAtIndex:wallpaperMode]];
		NSData *wallpaperData = fileExists ? [NSData dataWithContentsOfFile:[wallpaperStrings objectAtIndex:wallpaperMode]] : [NSData dataWithContentsOfFile:[wallpaperStrings objectAtIndex:!wallpaperMode]];
		CFDataRef wallpaperDataRef = (__bridge CFDataRef)wallpaperData;
		NSArray *imageArray = (__bridge NSArray *)CPBitmapCreateImagesFromData(wallpaperDataRef, NULL, 1, NULL);
		UIImage *wallpaperImage = [UIImage imageWithCGImage:(CGImageRef)imageArray[0]];
		[backgroundImageView setImage:wallpaperImage];
	}
}

%end

%hook PSTableCell
%new
-(void)applySWChanges {
	if (alpha) {
		CGFloat red = 0.0, green = 0.0, blue = 0.0, dAlpha = 0.0;
		[self.backgroundColor getRed:&red green:&green blue:&blue alpha:&dAlpha];
		self.backgroundColor = [[UIColor alloc] initWithRed:red green:green blue:blue alpha:cellAlpha];
	}
}
-(void)didMoveToWindow {
	%orig;
	[self applySWChanges];
}


-(void)refreshCellContentsWithSpecifier:(id)arg1 {
	%orig(arg1);
	[self applySWChanges];
}

%end


%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.popsicletreehouse.settingswallpaper.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	refreshPrefs();
}