// The game's own window is landscape on a phone.
//
// The launcher on an iPhone turns upright as well as sideways, because the Duo's cover screen is
// an upright screen and a list of settings reads best that way. The game does not: it is drawn
// for a landscape surface, and it sizes that surface from the scene at the moment its first
// window opens (patch 0046). So the window it opens refuses portrait on a phone, and the
// launcher turns the scene to landscape before it starts the game (TKWoWViewController).
// A tablet is left as the platform made it: every orientation.

#import <UIKit/UIKit.h>

@interface AKHostViewController : UIViewController
@end

@implementation AKHostViewController (WKPhoneLandscape)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIDevice.currentDevice.userInterfaceIdiom==UIUserInterfaceIdiomPhone
        ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskAll;
}
@end
