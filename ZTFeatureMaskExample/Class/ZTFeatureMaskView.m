//
//  ZTFeatureMaskView.m
//  ZTFeatureMaskExample
//
//  Created by zuo ming on 16/1/25.
//  Copyright © 2016年 zuo ming. All rights reserved.
//

#import "ZTFeatureMaskView.h"

CGMutablePathRef CGPathCreateRoundedRect(CGRect rect, CGFloat cornerRadius){
    
    CGMutablePathRef result = CGPathCreateMutable();
    
    CGPathMoveToPoint(result, nil, CGRectGetMinX(rect)+cornerRadius, (CGRectGetMinY(rect)) );
    
    CGPathAddArc(result, nil, (CGRectGetMinX(rect)+cornerRadius), (CGRectGetMinY(rect)+cornerRadius), cornerRadius, M_PI*1.5, M_PI*1.0, 1);//topLeft
    CGPathAddArc(result, nil, (CGRectGetMinX(rect)+cornerRadius), (CGRectGetMaxY(rect)-cornerRadius), cornerRadius, M_PI*1.0, M_PI*0.5, 1);//bottomLeft
    CGPathAddArc(result, nil, (CGRectGetMaxX(rect)-cornerRadius), (CGRectGetMaxY(rect)-cornerRadius), cornerRadius, M_PI*0.5, 0.0, 1);//bottomRight
    CGPathAddArc(result, nil, (CGRectGetMaxX(rect)-cornerRadius), (CGRectGetMinY(rect)+cornerRadius), cornerRadius, 0.0, M_PI*1.5, 1);//topRight
    CGPathCloseSubpath(result);
    
    return result;
}

#pragma mark - ZTTransparencyArea

@interface ZTTransparencyArea : NSObject

@property (nonatomic, assign) CGRect rect; /**<  */
@property (nonatomic, assign) CGFloat radius; /**<  */

+ (ZTTransparencyArea *)areaWithRect:(CGRect)rect radius:(CGFloat)radius;

@end

@implementation ZTTransparencyArea

+ (ZTTransparencyArea *)areaWithRect:(CGRect)rect radius:(CGFloat)radius
{
    ZTTransparencyArea *area = [[ZTTransparencyArea alloc] init];
    area.rect = rect;
    area.radius = radius;
    
    return area;
}

@end


#pragma mark - ZTFeatureMaskView

@interface ZTFeatureMaskView ()

@property (nonatomic, strong) UIColor *maskColor; /**< 半透明背景颜色 */
@property (nonatomic, assign) CGFloat maskAlpha;  /**< 背景颜色透明度 */
@property (nonatomic, strong) NSString *oneTimeKey; /**< 只显示一次时，需要设定 */
@property (nonatomic, strong) NSMutableArray *transparencies; /**< 透明高亮区域 */
@property (nonatomic, strong) UIView *maskedView; /**< 被蒙板的视图 */

@property (nonatomic, strong) UITapGestureRecognizer *closeGuesture; /**<  */

@end


@implementation ZTFeatureMaskView

#pragma mark - 生命周期

- (instancetype)init
{
    return [self initWithOneTimeKey:nil];
}

- (instancetype)initWithOneTimeKey:(NSString *)oneTimeKey
{
    self = [super init];
    if (self) {
        self.oneTimeKey = oneTimeKey;
        self.maskColor = [UIColor blackColor];
        self.maskAlpha = 0.7f;
        self.backgroundColor = [UIColor clearColor];
        self.opaque =NO;
        self.closeGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMaskView)];
        [self addGestureRecognizer:self.closeGuesture];

        self.transparencies = [NSMutableArray array];
    }
    
    return self;
}

#pragma mark - draw

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat red = 0.0f;
    CGFloat green = 0.0f;
    CGFloat blue = 0.0f;
    CGFloat alpha = 0.0f;
    [self.maskColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    UIColor *color = [UIColor colorWithRed:red green:green blue:blue alpha:self.maskAlpha];
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    
    CGContextAddRect(context, rect);
    for (ZTTransparencyArea *area in self.transparencies) {
        CGRect arect = area.rect;
        CGFloat radius = area.radius;
        
        CGMutablePathRef roundRect = CGPathCreateRoundedRect(arect, radius);
        CGContextAddPath(context, roundRect);
        CGPathRelease(roundRect);
        
    }
    CGContextEOFillPath(context);
}

#pragma mark - 事件处理

- (void)clickMaskView
{
    [self markShowed];
    if (self.featureDidClosed) {
        self.featureDidClosed();
    }
    [self removeFromSuperview];
}

- (void)clickCloseButton:(UIButton *)button
{
    [self markShowed];
    if (self.featureDidClosed) {
        self.featureDidClosed();
    }
    [self removeFromSuperview];
}

#pragma mark - 设置

- (void)setMaskedView:(UIView *)maskedView
{
    _maskedView = maskedView;
}

- (void)setMaskColor:(UIColor *)maskColor
{
    _maskColor = maskColor;
}

- (void)setMaskAlpha:(CGFloat)maskAlpha
{
    _maskAlpha = maskAlpha;
}

#pragma mark - 显示

- (void)show;
{
    if (![self canShow]) {
        return;
    }
    
    [self removeShowing];
    
    self.frame = self.maskedView.bounds;
    [self.maskedView addSubview:self];
}

- (void)markShowed
{
    if (!self.oneTimeKey) {
        return;
    }
    NSUserDefaults *userDefaluts = [NSUserDefaults standardUserDefaults];
    [userDefaluts setValue:@"showing" forKey:self.oneTimeKey];
    [userDefaluts synchronize];
}

- (BOOL)canShow
{
    if (self.oneTimeKey) {
        NSUserDefaults *userDefaluts = [NSUserDefaults standardUserDefaults];
        NSString *exist = [userDefaluts valueForKey:self.oneTimeKey];
        if (exist) {
            return NO;
        }
    }
    return YES;
}
- (void)removeShowing
{
    for (UIView *subview in self.maskedView.subviews) {
        if ([subview isKindOfClass:[ZTFeatureMaskView class]]) {
            [subview removeFromSuperview];
        }
    }
}

#pragma mark - add transparency area

- (void)addTransparencyRect:(CGRect)transparencyRect
{
    [self addTransparencyRect:transparencyRect radius:0.0f];
}

- (void)addTransparencyInReferenceView:(UIView *)referenceView
{
    [self addTransparencyInReferenceView:referenceView radius:0.0f];
}

- (void)addTransparencyInReferenceView:(UIView *)referenceView wider:(CGFloat)wider
{
    [self addTransparencyInReferenceView:referenceView wider:wider radius:0.0f];
}

- (void)addTransparencyInReferenceView:(UIView *)referenceView innerRect:(CGRect)innerRect
{
    [self addTransparencyInReferenceView:referenceView radius:0.0f innerRect:innerRect];
}

- (void)addTransparencyRect:(CGRect)transparencyRect radius:(CGFloat)radius
{
    ZTTransparencyArea *area = [ZTTransparencyArea areaWithRect:transparencyRect radius:radius];
    [self.transparencies addObject:area];
}

- (void)addTransparencyInReferenceView:(UIView *)referenceView radius:(CGFloat)radius
{
    [self addTransparencyInReferenceView:referenceView radius:radius innerRect:CGRectMake(0.0f, 0.0, referenceView.frame.size.width, referenceView.frame.size.height)];
}

- (void)addTransparencyInReferenceView:(UIView *)referenceView wider:(CGFloat)wider radius:(CGFloat)radius
{
    CGPoint origin = referenceView.frame.origin;
    CGPoint newOrigin = [referenceView.superview convertPoint:origin toView:self.maskedView];
    
    CGRect transparencyRect = CGRectMake(newOrigin.x - wider,
                                         newOrigin.y - wider,
                                         referenceView.frame.size.width + wider * 2,
                                         referenceView.frame.size.height + wider * 2);
    
    [self addTransparencyRect:transparencyRect radius:radius];
}

- (void)addTransparencyInReferenceView:(UIView *)referenceView radius:(CGFloat)radius innerRect:(CGRect)innerRect
{
    CGPoint innerOrigin = innerRect.origin;
    CGPoint newOrigin = [referenceView convertPoint:innerOrigin toView:self.maskedView];
    
    CGRect transparencyRect = CGRectMake(newOrigin.x,
                                         newOrigin.y,
                                         innerRect.size.width,
                                         innerRect.size.height);
    
    [self addTransparencyRect:transparencyRect radius:radius];
}


#pragma mark - add guide view

- (void)addImage:(UIImage *)image inRect:(CGRect)rect
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = rect;
    
    [self addSubview:imageView];
}

/** 覆盖在referenceView上，并居中显示 */
- (void)addImage:(UIImage *)image inReferenceView:(UIView *)referenceView
{
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x + (referenceView.frame.size.width - imageWidth) / 2;
    CGFloat y = newReferenceViewOrigin.y + (referenceView.frame.size.height - imageHeight) / 2;
    
    [self addImage:image inRect:CGRectMake(x, y, imageWidth, imageHeight)];
}

- (void)addImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingLeft:(CGFloat)spacingLeft spacingTop:(CGFloat)spacingTop
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x - spacingLeft - width;
    CGFloat y = newReferenceViewOrigin.y - spacingTop - height;
    
    [self addImage:image inRect:CGRectMake(x, y, width, height)];
    
}

- (void)addImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingLeft:(CGFloat)spacingLeft spacingBottom:(CGFloat)spacingBottom
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x - spacingLeft - width;
    CGFloat y = newReferenceViewOrigin.y + referenceView.frame.size.height + spacingBottom;
    
    [self addImage:image inRect:CGRectMake(x, y, width, height)];
}

- (void)addImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingRight:(CGFloat)spacingRight spacingTop:(CGFloat)spacingTop
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x + referenceView.frame.size.width + spacingRight;
    CGFloat y = newReferenceViewOrigin.y - spacingTop - height;
    
    [self addImage:image inRect:CGRectMake(x, y, width, height)];
}

- (void)addImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingRight:(CGFloat)spacingRight spacingBottom:(CGFloat)spacingBottom
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x + referenceView.frame.size.width + spacingRight;
    CGFloat y = newReferenceViewOrigin.y + referenceView.frame.size.height + spacingBottom;
    
    [self addImage:image inRect:CGRectMake(x, y, width, height)];
}

- (void)addImage:(UIImage *)image referenceView:(UIView *)referenceView withInnerSpacingLeft:(CGFloat)spacingLeft spacingTop:(CGFloat)spacingTop
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x + spacingLeft;
    CGFloat y = newReferenceViewOrigin.y + spacingTop;
    
    [self addImage:image inRect:CGRectMake(x, y, width, height)];
}


#pragma mark - add guide view

- (void)addCloseButtonWithImage:(UIImage *)image inRect:(CGRect)rect
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    button.frame = rect;
    [button addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self removeGestureRecognizer:self.closeGuesture];
    
    [self addSubview:button];
}

- (void)addCloseButtonWithImage:(UIImage *)image inReferenceView:(UIView *)referenceView
{
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x + (referenceView.frame.size.width - imageWidth) / 2;
    CGFloat y = newReferenceViewOrigin.y + (referenceView.frame.size.height - imageHeight) / 2;
    
    [self addCloseButtonWithImage:image inRect:CGRectMake(x, y, imageWidth, imageHeight)];
}

- (void)addCloseButtonWithImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingLeft:(CGFloat)spacingLeft spacingTop:(CGFloat)spacingTop
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x - spacingLeft - width;
    CGFloat y = newReferenceViewOrigin.y - spacingTop - height;
    
    [self addCloseButtonWithImage:image inRect:CGRectMake(x, y, width, height)];
    
}

- (void)addCloseButtonWithImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingLeft:(CGFloat)spacingLeft spacingBottom:(CGFloat)spacingBottom
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x - spacingLeft - width;
    CGFloat y = newReferenceViewOrigin.y + referenceView.frame.size.height + spacingBottom;
    
    [self addCloseButtonWithImage:image inRect:CGRectMake(x, y, width, height)];
}

- (void)addCloseButtonWithImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingRight:(CGFloat)spacingRight spacingTop:(CGFloat)spacingTop
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x + referenceView.frame.size.width + spacingRight;
    CGFloat y = newReferenceViewOrigin.y - spacingTop - height;
    
    [self addCloseButtonWithImage:image inRect:CGRectMake(x, y, width, height)];
}

- (void)addCloseButtonWithImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingRight:(CGFloat)spacingRight spacingBottom:(CGFloat)spacingBottom
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x + referenceView.frame.size.width + spacingRight;
    CGFloat y = newReferenceViewOrigin.y + referenceView.frame.size.height + spacingBottom;
    
    [self addCloseButtonWithImage:image inRect:CGRectMake(x, y, width, height)];
}

- (void)addCloseButtonWithImage:(UIImage *)image referenceView:(UIView *)referenceView withInnerSpacingLeft:(CGFloat)spacingLeft spacingTop:(CGFloat)spacingTop
{
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGPoint oldReferenceViewOrigin = referenceView.frame.origin;
    CGPoint newReferenceViewOrigin = [referenceView.superview convertPoint:oldReferenceViewOrigin toView:self.maskedView];
    
    CGFloat x = newReferenceViewOrigin.x + spacingLeft;
    CGFloat y = newReferenceViewOrigin.y + spacingTop;
    
    [self addCloseButtonWithImage:image inRect:CGRectMake(x, y, width, height)];
}

@end
