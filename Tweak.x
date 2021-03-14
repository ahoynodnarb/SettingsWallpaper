#import "SettingsWallpaper.h"

static void refreshPrefs()
{
    NSDictionary *bundleDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.popsicletreehouse.settingswallpaperprefs"];
    enabled = [bundleDefaults objectForKey:@"isEnabled"] ? [[bundleDefaults objectForKey:@"isEnabled"] boolValue] : YES;
    blur = [bundleDefaults objectForKey:@"isBlur"] ? [[bundleDefaults objectForKey:@"isBlur"]boolValue] : YES;
	blurType = [bundleDefaults objectForKey:@"blurType"] ? [[bundleDefaults objectForKey:@"blurType"]intValue] : 0;
    intensity = [bundleDefaults objectForKey:@"blurIntensity"] ? [[bundleDefaults objectForKey:@"blurIntensity"]floatValue] : 1.0f;
	wallpaperMode = [bundleDefaults objectForKey:@"wallpaperMode"] ? [[bundleDefaults objectForKey:@"wallpaperMode"]intValue] : 0;
}

static void PreferencesChangedCallback(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    refreshPrefs();
}

%hook UITableView
-(void)didMoveToSuperview {
	if(enabled && !self.backgroundView) {
		NSArray *wallpaperStrings = @[@"/var/mobile/Library/SpringBoard/LockBackgroundThumbnail.jpg", @"/var/mobile/Library/SpringBoard/HomeBackgroundThumbnail.jpg"];
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
		if([[NSFileManager defaultManager] fileExistsAtPath:[wallpaperStrings objectAtIndex:wallpaperMode]])
			[backgroundImageView setImage:[UIImage imageWithContentsOfFile:[wallpaperStrings objectAtIndex:wallpaperMode]]];
		else
			[backgroundImageView setImage:[UIImage imageWithContentsOfFile:[wallpaperStrings objectAtIndex:!wallpaperMode]]];
	}
}
%end

%ctor {
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback) PreferencesChangedCallback, CFSTR("com.popsicletreehouse.settingswallpaper.prefschanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	refreshPrefs();
}