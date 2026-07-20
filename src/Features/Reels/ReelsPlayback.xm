#import "../../Utils.h"

%hook IGSundialPlaybackControlsTestConfiguration
- (id)initWithLauncherSet:(id)set
                     tapToPauseEnabled:(_Bool)tapPauseEnabled
      combineSingleTapPlaybackControls:(_Bool)controls
        isVideoPreviewThumbnailEnabled:(_Bool)previewThumbEnabled
                minScrubberDurationSec:(long long)minSec
         seekResumeScrubberCooldownSec:(double)seekSec
          tapResumeScrubberCooldownSec:(double)tapSec
    persistentScrubberMinVideoDuration:(long long)duration
        isScrubberForShortVideoEnabled:(_Bool)shortScrubberEnabled
{
    /*
     * TRUCO PARA COMPILAR:
     * Al poner %orig() sin argumentos, Logos pasa automáticamente 
     * los valores originales (set, tapPauseEnabled, etc.) sin quejarse.
     * Esto arregla el error "Invalid argument structure in %orig".
     * Se omiten las modificaciones de SCInsta para esta función para 
     * poder compilar la IPA.
     */
    return %orig();
}
%end

%hook IGSundialFeedViewController
- (void)_refreshReelsWithParamsForNetworkRequest:(NSInteger)arg1 userDidPullToRefresh:(BOOL)arg2 {
    if ([SCIUtils getBoolPref:@"prevent_doom_scrolling"]) {
        IGRefreshControl *_refreshControl = MSHookIvar<IGRefreshControl *>(self, "_refreshControl");
        [self refreshControlDidEndFinishLoadingAnimation:_refreshControl];

        return;
    }

    if ([SCIUtils getBoolPref:@"refresh_reel_confirm"]) {
        NSLog(@"[SCInsta] Reel refresh triggered");
        
        [SCIUtils showConfirmation:^(void) { %orig(arg1, arg2); }
                     cancelHandler:^(void) {
                         IGRefreshControl *_refreshControl = MSHookIvar<IGRefreshControl *>(self, "_refreshControl");
                         [self refreshControlDidEndFinishLoadingAnimation:_refreshControl];
                     }
                             title:@"Refresh Reels"];
    } else {
        return %orig(arg1, arg2);
    }
}
%end

// * Disable volume/mute button triggering unmutes
%hook IGAudioStatusAnnouncer
- (void)_muteSwitchStateChanged:(id)changed {
    if (![SCIUtils getBoolPref:@"disable_auto_unmuting_reels"]) {
        %orig(changed);
    }
}
- (void)_didPressVolumeButton:(id)button {
    if (![SCIUtils getBoolPref:@"disable_auto_unmuting_reels"]) {
        %orig(button);
    }
}
- (void)_didUnplugHeadphones:(id)headphones {
    if (![SCIUtils getBoolPref:@"disable_auto_unmuting_reels"]) {
        %orig(headphones);
    }
}
%end
