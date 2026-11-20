#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
// NSUserDefaults key: when YES, the Battle.net web session is kept on disk across launches.
extern NSString *const TKBattleNetStaySignedInKey;
@interface TKBattleNetBrowser : UIViewController
+ (BOOL)staySignedIn;
// Removes the in-memory session, the saved on-disk session and any pending ticket.
+ (void)clearSavedSignInWithCompletion:(void (^)(void))completion;
// Removes only the saved on-disk session (used when "Stay signed in" is turned off).
+ (void)forgetSavedSignInWithCompletion:(void (^)(void))completion;
- (instancetype)initWithRegion:(NSString *)region locale:(NSString *)locale;
@property(nonatomic, copy, nullable) void (^completion)(BOOL received);
@end
NS_ASSUME_NONNULL_END
