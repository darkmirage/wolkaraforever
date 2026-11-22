#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// An unfolded iPhone Duo held upright, flat or half-closed: the game takes the top screen and the
// on-screen controller the bottom one.
//
// The game keeps the landscape surface it started with. Its view is given the scene's landscape
// size and scaled into the top screen, so no rotation ever resizes the game: a client that sizes
// its drawable once (patch 0046) would otherwise stretch. The top screen of a Duo is almost the
// shape of the whole sideways screen, so the scaled picture fills it.

// The two screens of `container`, a scene in points, or NO when it is not an unfolded phone held
// upright. `top` leaves out the top safe-area inset; `bottom` is the whole lower screen, and the
// views placed there take their own safe area.
BOOL AKTwoScreenRects(CGSize container, UIEdgeInsets safe, CGRect *top, CGRect *bottom);

// Lays the game's view out in `container`: filling it, or on two screens scaled into the top one.
// Returns the lower screen's rect when there are two, and CGRectNull otherwise.
// Upright on any other phone screen - the cover screen, if the system ever shows the game upright
// there - the game keeps that size too and is scaled to fit, rather than resized and stretched.
CGRect AKLayoutGameView(UIView *game, UIView *container);

// Whether the phone's hinge is open, fully or half: only then may the game turn upright. Read from a
// UIHingeInteraction that AKLayoutGameView attaches to the container. Closed until the first known
// reading, and an unknown one later (the app in the background) keeps the last. Each change asks
// the window's root to re-read its orientations.
BOOL AKHingeOpen(void);

NS_ASSUME_NONNULL_END
