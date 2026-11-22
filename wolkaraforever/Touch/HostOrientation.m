// The game's own window is landscape on a phone.
//
// The launcher on an iPhone turns upright as well as sideways, because the Duo's cover screen is
// an upright screen and a list of settings reads best that way. The game does not: it is drawn
// for a landscape surface, and it sizes that surface from the scene at the moment its first
// window opens (patch 0046). So the window it opens refuses portrait on a phone, and the
// launcher turns the scene to landscape before it starts the game (TKWoWViewController).
// The exception is an unfolded phone, hinge open: upright, the game keeps that landscape surface
// on the top screen and the controller takes the bottom one (TwoScreenLayout.m).
// A tablet is left as the platform made it: every orientation.

#import <UIKit/UIKit.h>
#import "TwoScreenLayout.h"

@interface AKHostViewController : UIViewController
@end

@implementation AKHostViewController (WKPhoneLandscape)
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (UIDevice.currentDevice.userInterfaceIdiom!=UIUserInterfaceIdiomPhone) return UIInterfaceOrientationMaskAll;
    return AKHingeOpen() ? UIInterfaceOrientationMaskAllButUpsideDown : UIInterfaceOrientationMaskLandscape;
}
@end
