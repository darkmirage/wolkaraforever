#import "TwoScreenLayout.h"
// The guest log in the app; a plain [ak] line where a fixture builds this file alone.
#if __has_include("AKSupport.h")
#import "AKSupport.h"
#else
#define AKLog(...) NSLog(@"[ak] %@", [NSString stringWithFormat:__VA_ARGS__])
#endif

// The Duo's inner screen held upright is 669 points wide; its cover screen is 466. Anything this
// wide and taller than wide is the inner screen, whose two halves meet at a 19-point hinge.
static const CGFloat AKTwoScreenMinimumWidth = 600;
static const CGFloat AKTwoScreenHinge = 19;

BOOL AKTwoScreenRects(CGSize container, UIEdgeInsets safe, CGRect *top, CGRect *bottom) {
    if (container.height <= container.width || container.width < AKTwoScreenMinimumWidth) return NO;
    CGFloat screen = floor((container.height - AKTwoScreenHinge) / 2);
    CGFloat inset = MIN(MAX(0, safe.top), screen / 2);
    if (top) *top = CGRectMake(0, inset, container.width, screen - inset);
    if (bottom) *bottom = CGRectMake(0, screen + AKTwoScreenHinge, container.width,
                                     container.height - screen - AKTwoScreenHinge);
    return YES;
}

static BOOL hingeOpen;
BOOL AKHingeOpen(void) { return hingeOpen; }

static void AKWatchHinge(UIView *container) {
    if (@available(iOS 27.1, *)) {
        for (id<UIInteraction> interaction in container.interactions)
            if ([interaction isKindOfClass:UIHingeInteraction.class]) return;
        __weak UIView *weakContainer = container;
        [container addInteraction:[[UIHingeInteraction alloc] initWithUpdateHandler:^(UIHingeInteraction *interaction, UIHingeInteractionUpdate *update) {
            (void)interaction;
            UIHingeStatus status = update.hinge ? update.hinge.status : UIHingeStatusUnknown;
            // Measured on the Duo: going to the background reports Unknown, which says nothing
            // about the hinge. The next real reading settles it.
            if (status == UIHingeStatusUnknown) return;
            BOOL open = status == UIHingeStatusPartiallyOpen || status == UIHingeStatusFullyOpen;
            if (open == hingeOpen) return;
            hingeOpen = open;
            AKLog(@"two screens: hinge %@ (status %ld, angle %.2f)", open ? @"open" : @"closed", (long)status, update.hinge.angle);
            [weakContainer.window.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
        }]];
    }
}

CGRect AKLayoutGameView(UIView *game, UIView *container) {
    static int logged = -1;
    BOOL phone = UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone;
    if (phone) AKWatchHinge(container);
    CGSize scene = container.bounds.size;
    if (!phone || scene.height <= scene.width) {
        if (!CGAffineTransformIsIdentity(game.transform)) game.transform = CGAffineTransformIdentity;
        if (!CGRectEqualToRect(game.frame, container.bounds)) game.frame = container.bounds;
        if (logged != 0) { logged = 0; AKLog(@"two screens: off, the game fills %.0fx%.0f", scene.width, scene.height); }
        return CGRectNull;
    }
    CGRect top, bottom;
    BOOL two = AKTwoScreenRects(scene, container.safeAreaInsets, &top, &bottom);
    if (!two) { top = UIEdgeInsetsInsetRect(container.bounds, container.safeAreaInsets); bottom = CGRectNull; }
    // The scene turned sideways: the size the game has had since it started.
    CGSize size = CGSizeMake(scene.height, scene.width);
    CGFloat scale = MIN(top.size.width / size.width, top.size.height / size.height);
    CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
    CGPoint centre = CGPointMake(CGRectGetMidX(top), CGRectGetMidY(top));
    if (!CGSizeEqualToSize(game.bounds.size, size) || !CGAffineTransformEqualToTransform(game.transform, transform)) {
        game.transform = CGAffineTransformIdentity;
        game.bounds = (CGRect){CGPointZero, size};
        game.transform = transform;
    }
    if (!CGPointEqualToPoint(game.center, centre)) game.center = centre;
    if (logged != (two ? 1 : 2)) {
        logged = two ? 1 : 2;
        AKLog(@"two screens: %@, the game keeps %.0fx%.0f scaled %.3f into %@, controls on %@", two ? @"on" : @"upright on one screen",
              size.width, size.height, scale, NSStringFromCGRect(top), two ? NSStringFromCGRect(bottom) : @"the game");
    }
    return bottom;
}
