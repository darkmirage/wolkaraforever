#import "LauncherList.h"
#import "../App/WolkaraForeverTheme.h"

static const CGFloat TKListTileSize = 30;
static const CGFloat TKListInset = 16;
static const CGFloat TKListTileGap = 12;
static const CGFloat TKListMinimumHeight = 48;

static UIColor *TKListTileColor(TKListTint tint) {
    switch (tint) {
        case TKListTintGold:   return WKGold();
        case TKListTintBlue:   return UIColor.systemBlueColor;
        case TKListTintTeal:   return UIColor.systemTealColor;
        case TKListTintGreen:  return UIColor.systemGreenColor;
        case TKListTintIndigo: return UIColor.systemIndigoColor;
        case TKListTintOrange: return UIColor.systemOrangeColor;
        case TKListTintRed:    return UIColor.systemRedColor;
        case TKListTintGray:   return UIColor.systemGrayColor;
        case TKListTintPink:   return UIColor.systemPinkColor;
    }
    return UIColor.systemGrayColor;
}

// A Settings-style tile: the symbol in white on the tint, or in the dark ink on gold, which is
// the one tile white would not read on.
static UIView *TKListTile(NSString *symbol, TKListTint tint) {
    UIView *tile=[UIView new];
    tile.translatesAutoresizingMaskIntoConstraints=NO;
    tile.backgroundColor=TKListTileColor(tint);
    tile.layer.cornerRadius=7;
    tile.layer.cornerCurve=kCACornerCurveContinuous;
    tile.userInteractionEnabled=NO;
    UIImageSymbolConfiguration *configuration=[UIImageSymbolConfiguration configurationWithPointSize:15
        weight:UIImageSymbolWeightSemibold];
    UIImageView *glyph=[[UIImageView alloc] initWithImage:[UIImage systemImageNamed:symbol withConfiguration:configuration]];
    glyph.tintColor=tint==TKListTintGold?WKOnGold():UIColor.whiteColor;
    glyph.contentMode=UIViewContentModeCenter;
    glyph.translatesAutoresizingMaskIntoConstraints=NO;
    [tile addSubview:glyph];
    [NSLayoutConstraint activateConstraints:@[
        [tile.widthAnchor constraintEqualToConstant:TKListTileSize],
        [tile.heightAnchor constraintEqualToConstant:TKListTileSize],
        [glyph.centerXAnchor constraintEqualToAnchor:tile.centerXAnchor],
        [glyph.centerYAnchor constraintEqualToAnchor:tile.centerYAnchor],
    ]];
    return tile;
}

static UILabel *TKListLabel(UIFontTextStyle style, UIColor *color) {
    UILabel *label=[UILabel new];
    label.font=WKFont(style, UIFontWeightRegular);
    label.adjustsFontForContentSizeCategory=YES;
    label.textColor=color;
    label.numberOfLines=0;
    label.userInteractionEnabled=NO;
    return label;
}

#pragma mark - Row

@implementation TKListRow {
    UIView *_tile;
    UILabel *_titleText, *_valueText;
    UIImageView *_accessoryImage;
    UIStackView *_labels;
}
- (instancetype)initWithIdentifier:(NSString *)identifier symbol:(NSString *)symbol tint:(TKListTint)tint {
    if (!(self=[super initWithFrame:CGRectZero])) return nil;
    self.accessibilityIdentifier=identifier;
    self.isAccessibilityElement=YES;
    _title=@"";
    _tile=TKListTile(symbol, tint);
    _titleText=TKListLabel(UIFontTextStyleBody, WKText());
    _titleText.accessibilityIdentifier=[identifier stringByAppendingString:@".title"];
    _valueText=TKListLabel(UIFontTextStyleBody, WKMuted());
    _valueText.accessibilityIdentifier=[identifier stringByAppendingString:@".value"];
    _valueText.textAlignment=NSTextAlignmentNatural;
    [_titleText setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [_valueText setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh+1 forAxis:UILayoutConstraintAxisHorizontal];
    [_valueText setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    _accessoryImage=[UIImageView new];
    _accessoryImage.tintColor=[WKMuted() colorWithAlphaComponent:0.7];
    _accessoryImage.contentMode=UIViewContentModeCenter;
    [_accessoryImage setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_accessoryImage setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    _labels=[[UIStackView alloc] initWithArrangedSubviews:@[_titleText,_valueText]];
    _labels.spacing=8;
    _labels.alignment=UIStackViewAlignmentCenter;
    UIStackView *row=[[UIStackView alloc] initWithArrangedSubviews:@[_tile,_labels,_accessoryImage]];
    row.spacing=TKListTileGap;
    row.alignment=UIStackViewAlignmentCenter;
    row.userInteractionEnabled=NO;
    row.translatesAutoresizingMaskIntoConstraints=NO;
    [row setCustomSpacing:10 afterView:_labels];
    [self addSubview:row];
    [NSLayoutConstraint activateConstraints:@[
        [row.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:TKListInset],
        [row.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-TKListInset],
        [row.topAnchor constraintEqualToAnchor:self.topAnchor constant:10],
        [row.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-10],
        [self.heightAnchor constraintGreaterThanOrEqualToConstant:TKListMinimumHeight],
    ]];
    self.accessory=TKListAccessoryChevron;
    [self arrangeForTextSize];
    [self restyle];
    return self;
}
// At the accessibility text sizes a title and a value side by side leave each a word per line,
// so the value goes under the title, as Settings does.
- (void)arrangeForTextSize {
    BOOL large=UIContentSizeCategoryIsAccessibilityCategory(self.traitCollection.preferredContentSizeCategory);
    _labels.axis=large?UILayoutConstraintAxisVertical:UILayoutConstraintAxisHorizontal;
    _labels.alignment=large?UIStackViewAlignmentLeading:UIStackViewAlignmentCenter;
    _valueText.textAlignment=large?NSTextAlignmentNatural:
        (self.effectiveUserInterfaceLayoutDirection==UIUserInterfaceLayoutDirectionRightToLeft
            ?NSTextAlignmentLeft:NSTextAlignmentRight);
}
- (void)traitCollectionDidChange:(UITraitCollection *)previous {
    [super traitCollectionDidChange:previous];
    if (previous.preferredContentSizeCategory!=self.traitCollection.preferredContentSizeCategory) [self arrangeForTextSize];
}
- (void)setTitle:(NSString *)title {
    _title=[title copy] ?: @"";
    _titleText.text=_title;
    self.accessibilityLabel=_title;
}
- (void)setValue:(NSString *)value {
    _value=[value copy];
    _valueText.text=_value;
    _valueText.hidden=_value.length==0;
    self.accessibilityValue=_value;
}
- (void)setAccessory:(TKListAccessory)accessory {
    _accessory=accessory;
    NSString *symbol=nil;
    switch (accessory) {
        case TKListAccessoryNone: break;
        case TKListAccessoryChevron: symbol=@"chevron.forward"; break;
        case TKListAccessoryChoices: symbol=@"chevron.up.chevron.down"; break;
        case TKListAccessoryExternal: symbol=@"arrow.up.forward"; break;
    }
    UIImageSymbolConfiguration *configuration=[UIImageSymbolConfiguration
        configurationWithTextStyle:UIFontTextStyleFootnote scale:UIImageSymbolScaleDefault];
    configuration=[configuration configurationByApplyingConfiguration:
        [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightSemibold]];
    _accessoryImage.image=symbol?[UIImage systemImageNamed:symbol withConfiguration:configuration]:nil;
    _accessoryImage.hidden=symbol==nil;
}
- (void)setDestructive:(BOOL)destructive { _destructive=destructive; [self restyle]; }
- (void)setEnabled:(BOOL)enabled { [super setEnabled:enabled]; [self restyle]; }
- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.backgroundColor=highlighted?WKSelectionWash():UIColor.clearColor;
}
// One grey for a row that cannot be used, the same as a disabled switch row beside it.
- (void)restyle {
    BOOL enabled=self.enabled;
    _titleText.textColor=!enabled?WKDisabled():_destructive?UIColor.systemRedColor:WKText();
    _valueText.textColor=enabled?WKMuted():WKDisabled();
    _tile.alpha=enabled?1:0.45;
    _accessoryImage.alpha=enabled?1:0.45;
    self.accessibilityTraits=UIAccessibilityTraitButton|(enabled?0:UIAccessibilityTraitNotEnabled);
}
@end

#pragma mark - Switch row

@implementation TKListSwitchRow {
    UIView *_tile;
}
- (instancetype)initWithIdentifier:(NSString *)identifier symbol:(NSString *)symbol tint:(TKListTint)tint
                            target:(id)target action:(SEL)action {
    if (!(self=[super initWithFrame:CGRectZero])) return nil;
    self.accessibilityIdentifier=identifier;
    _tile=TKListTile(symbol, tint);
    _titleLabel=TKListLabel(UIFontTextStyleBody, WKText());
    _titleLabel.accessibilityIdentifier=[identifier stringByAppendingString:@".label"];
    _titleLabel.isAccessibilityElement=NO;
    [_titleLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    _toggle=[UISwitch new];
    _toggle.onTintColor=WKGold();
    _toggle.accessibilityIdentifier=[identifier stringByAppendingString:@".switch"];
    [_toggle addTarget:target action:action forControlEvents:UIControlEventValueChanged];
    [_toggle setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_toggle setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    UIStackView *row=[[UIStackView alloc] initWithArrangedSubviews:@[_tile,_titleLabel,_toggle]];
    row.spacing=TKListTileGap;
    row.alignment=UIStackViewAlignmentCenter;
    row.translatesAutoresizingMaskIntoConstraints=NO;
    [self addSubview:row];
    [NSLayoutConstraint activateConstraints:@[
        [row.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:TKListInset],
        [row.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-TKListInset],
        [row.topAnchor constraintEqualToAnchor:self.topAnchor constant:8],
        [row.bottomAnchor constraintEqualToAnchor:self.bottomAnchor constant:-8],
        [self.heightAnchor constraintGreaterThanOrEqualToConstant:TKListMinimumHeight],
    ]];
    self.enabled=YES;
    return self;
}
- (void)setEnabled:(BOOL)enabled {
    _enabled=enabled;
    _toggle.enabled=enabled;
    _titleLabel.textColor=enabled?WKText():WKDisabled();
    _tile.alpha=enabled?1:0.45;
}
- (void)applyTitle:(NSString *)title {
    _titleLabel.text=title;
    _toggle.accessibilityLabel=title;
}
@end

#pragma mark - Section

@implementation TKListSection
- (instancetype)initWithIdentifier:(NSString *)identifier rows:(NSArray<UIView *> *)rows {
    if (!(self=[super initWithFrame:CGRectZero])) return nil;
    self.accessibilityIdentifier=identifier;
    _rows=[rows copy];
    _headerLabel=TKListLabel(UIFontTextStyleSubheadline, WKMuted());
    _headerLabel.font=WKFont(UIFontTextStyleSubheadline, UIFontWeightSemibold);
    _headerLabel.accessibilityTraits=UIAccessibilityTraitHeader;
    _headerLabel.accessibilityIdentifier=[identifier stringByAppendingString:@".header"];
    _footerLabel=TKListLabel(UIFontTextStyleFootnote, WKMuted());
    _footerLabel.accessibilityIdentifier=[identifier stringByAppendingString:@".footer"];
    UIView *group=[UIView new];
    group.backgroundColor=WKGrouped();
    group.layer.cornerRadius=14;
    group.layer.cornerCurve=kCACornerCurveContinuous;
    group.clipsToBounds=YES;
    NSMutableArray<UIView *> *stacked=[NSMutableArray new];
    for (UIView *row in rows) {
        if (stacked.count) {
            // A hairline from the title's edge, as Settings draws it: under the text, not under the tile.
            UIView *line=[UIView new];
            line.backgroundColor=[UIColor colorWithWhite:1 alpha:0.10];
            line.translatesAutoresizingMaskIntoConstraints=NO;
            UIView *holder=[UIView new];
            [holder addSubview:line];
            CGFloat hairline=1.0/MAX(1.0, UIScreen.mainScreen.scale);
            [NSLayoutConstraint activateConstraints:@[
                [holder.heightAnchor constraintEqualToConstant:hairline],
                [line.heightAnchor constraintEqualToConstant:hairline],
                [line.topAnchor constraintEqualToAnchor:holder.topAnchor],
                [line.leadingAnchor constraintEqualToAnchor:holder.leadingAnchor
                    constant:TKListInset+TKListTileSize+TKListTileGap],
                [line.trailingAnchor constraintEqualToAnchor:holder.trailingAnchor],
            ]];
            [stacked addObject:holder];
        }
        [stacked addObject:row];
    }
    UIStackView *list=[[UIStackView alloc] initWithArrangedSubviews:stacked];
    list.axis=UILayoutConstraintAxisVertical;
    list.translatesAutoresizingMaskIntoConstraints=NO;
    [group addSubview:list];
    [NSLayoutConstraint activateConstraints:@[
        [list.leadingAnchor constraintEqualToAnchor:group.leadingAnchor],
        [list.trailingAnchor constraintEqualToAnchor:group.trailingAnchor],
        [list.topAnchor constraintEqualToAnchor:group.topAnchor],
        [list.bottomAnchor constraintEqualToAnchor:group.bottomAnchor],
    ]];
    UIView *header=[self inset:_headerLabel];
    UIView *footer=[self inset:_footerLabel];
    UIStackView *column=[[UIStackView alloc] initWithArrangedSubviews:@[header,group,footer]];
    column.axis=UILayoutConstraintAxisVertical;
    column.spacing=7;
    column.translatesAutoresizingMaskIntoConstraints=NO;
    [self addSubview:column];
    [NSLayoutConstraint activateConstraints:@[
        [column.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [column.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [column.topAnchor constraintEqualToAnchor:self.topAnchor],
        [column.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
    return self;
}
// The header and footer line up with the rows' tiles, not with the group's rounded edge.
- (UIView *)inset:(UILabel *)label {
    UIView *holder=[UIView new];
    label.translatesAutoresizingMaskIntoConstraints=NO;
    [holder addSubview:label];
    [NSLayoutConstraint activateConstraints:@[
        [label.leadingAnchor constraintEqualToAnchor:holder.leadingAnchor constant:TKListInset],
        [label.trailingAnchor constraintEqualToAnchor:holder.trailingAnchor constant:-TKListInset],
        [label.topAnchor constraintEqualToAnchor:holder.topAnchor],
        [label.bottomAnchor constraintEqualToAnchor:holder.bottomAnchor],
    ]];
    // An empty header or footer takes no room at all.
    [label addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionInitial context:NULL];
    return holder;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    (void)keyPath; (void)change; (void)context;
    UILabel *label=object;
    label.superview.hidden=label.text.length==0;
}
- (void)dealloc {
    [_headerLabel removeObserver:self forKeyPath:@"text"];
    [_footerLabel removeObserver:self forKeyPath:@"text"];
}
@end

#pragma mark - Page

@implementation TKLauncherPage {
    NSString *_identifier;
    CAGradientLayer *_gradient;
}
- (instancetype)initWithIdentifier:(NSString *)identifier {
    if (!(self=[super initWithNibName:nil bundle:nil])) return nil;
    _identifier=[identifier copy];
    _readableWidth=680;
    _scrollView=[UIScrollView new];
    _column=[UIStackView new];
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=WKInk();
    self.view.accessibilityIdentifier=_identifier;
    if (_showsGradient) {
        _gradient=[CAGradientLayer layer];
        _gradient.colors=@[(id)WKInkTop().CGColor,(id)WKInkBottom().CGColor];
        _gradient.startPoint=CGPointMake(0,0); _gradient.endPoint=CGPointMake(1,1);
        [self.view.layer insertSublayer:_gradient atIndex:0];
    }
    _scrollView.accessibilityIdentifier=[_identifier stringByAppendingString:@".scroll"];
    _scrollView.alwaysBounceVertical=YES;
    _scrollView.translatesAutoresizingMaskIntoConstraints=NO;
    // Above the gradient, and named to the navigation bar so its large title collapses as the
    // list scrolls.
    [self.view addSubview:_scrollView];
    [self setContentScrollView:_scrollView forEdge:NSDirectionalRectEdgeTop];
    _column.axis=UILayoutConstraintAxisVertical;
    _column.spacing=28;
    _column.translatesAutoresizingMaskIntoConstraints=NO;
    [_scrollView addSubview:_column];
    UILayoutGuide *safe=self.view.safeAreaLayoutGuide;
    UILayoutGuide *content=_scrollView.contentLayoutGuide;
    // As wide as the safe area allows, up to the readable width, centred; the content is exactly
    // as wide as the scroll view, so nothing can be dragged sideways.
    NSLayoutConstraint *fill=[_column.widthAnchor constraintEqualToAnchor:safe.widthAnchor constant:-32];
    fill.priority=UILayoutPriorityRequired-1;
    [NSLayoutConstraint activateConstraints:@[
        [_scrollView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [_scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        [_scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [_scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [content.widthAnchor constraintEqualToAnchor:_scrollView.frameLayoutGuide.widthAnchor],
        [_column.topAnchor constraintEqualToAnchor:content.topAnchor constant:8],
        [_column.bottomAnchor constraintEqualToAnchor:content.bottomAnchor constant:-28],
        [_column.centerXAnchor constraintEqualToAnchor:safe.centerXAnchor],
        [_column.leadingAnchor constraintGreaterThanOrEqualToAnchor:safe.leadingAnchor constant:16],
        [_column.trailingAnchor constraintLessThanOrEqualToAnchor:safe.trailingAnchor constant:-16],
        [_column.widthAnchor constraintLessThanOrEqualToConstant:_readableWidth],
        fill,
    ]];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _gradient.frame=self.view.bounds;
    // On a wide screen the column is centred at its readable width; the large title follows it
    // rather than sitting at the screen's edge over empty space.
    UINavigationBar *bar=self.navigationController.navigationBar;
    if (bar && self.navigationController.topViewController==self && _column.bounds.size.width>0) {
        CGFloat leading=[_column convertRect:_column.bounds toView:bar].origin.x;
        if (self.view.effectiveUserInterfaceLayoutDirection==UIUserInterfaceLayoutDirectionRightToLeft)
            leading=bar.bounds.size.width-CGRectGetMaxX([_column convertRect:_column.bounds toView:bar]);
        NSDirectionalEdgeInsets margins=bar.directionalLayoutMargins;
        if (fabs(margins.leading-leading)>0.5) {
            margins.leading=MAX(0,leading);
            bar.directionalLayoutMargins=margins;
        }
    }
    if (_didLayout) _didLayout(self);
}
- (void)addArrangedView:(UIView *)view {
    [self loadViewIfNeeded];
    [_column addArrangedSubview:view];
}
@end
