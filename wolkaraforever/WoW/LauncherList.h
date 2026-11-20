// The launcher's settings lists: rows, the inset-grouped sections that hold them, and the
// scrolling page a tab shows. Drawn by hand rather than with UICollectionView so every row stays
// the same live control the page has always owned: it keeps its accessibility identifier, its
// target and action, and its enabled state, and the page's own render pass sets its words.

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TKListAccessory) {
    TKListAccessoryNone,
    TKListAccessoryChevron,     // opens a page
    TKListAccessoryChoices,     // offers a short list of choices
    TKListAccessoryExternal,    // leaves the app
};

/// The colour of a row's icon tile. The system's own colours, as Settings uses them.
typedef NS_ENUM(NSInteger, TKListTint) {
    TKListTintGold, TKListTintBlue, TKListTintTeal, TKListTintGreen, TKListTintIndigo,
    TKListTintOrange, TKListTintRed, TKListTintGray, TKListTintPink,
};

/// One row: an icon tile, a title, an optional value on the trailing side, and an accessory.
/// A button, so it is pressed, enabled and identified the way every other control is.
@interface TKListRow : UIButton
- (instancetype)initWithIdentifier:(NSString *)identifier symbol:(NSString *)symbol tint:(TKListTint)tint;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy, nullable) NSString *value;
@property(nonatomic) TKListAccessory accessory;
/// Red words and no tile colour change: the row does something that cannot be undone.
@property(nonatomic) BOOL destructive;
@end

/// A row whose control is a switch. The words are fixed; the switch says the state.
@interface TKListSwitchRow : UIView
- (instancetype)initWithIdentifier:(NSString *)identifier symbol:(NSString *)symbol tint:(TKListTint)tint
                            target:(id)target action:(SEL)action;
@property(nonatomic, readonly) UILabel *titleLabel;
@property(nonatomic, readonly) UISwitch *toggle;
@property(nonatomic, getter=isEnabled) BOOL enabled;
- (void)applyTitle:(NSString *)title;
@end

/// An inset-grouped section: a header, a rounded group of rows with separators, and a footer.
@interface TKListSection : UIView
- (instancetype)initWithIdentifier:(NSString *)identifier rows:(NSArray<UIView *> *)rows;
@property(nonatomic, readonly) UILabel *headerLabel;
@property(nonatomic, readonly) UILabel *footerLabel;
@property(nonatomic, readonly) NSArray<UIView *> *rows;
@end

/// A tab's page: a scrolling column of views, at a readable width on a wide screen.
@interface TKLauncherPage : UIViewController
- (instancetype)initWithIdentifier:(NSString *)identifier;
@property(nonatomic, readonly) UIScrollView *scrollView;
@property(nonatomic, readonly) UIStackView *column;
/// The widest the column grows, so a list on an iPad or the Duo's inner screen does not stretch
/// a row's title and value a whole screen apart.
@property(nonatomic) CGFloat readableWidth;
/// Draws the launcher's gradient behind the page instead of the plain ink.
@property(nonatomic) BOOL showsGradient;
/// Runs after the page lays out, for an arrangement that depends on the page's own width.
@property(nonatomic, copy, nullable) void (^didLayout)(TKLauncherPage *page);
- (void)addArrangedView:(UIView *)view;
@end

NS_ASSUME_NONNULL_END
