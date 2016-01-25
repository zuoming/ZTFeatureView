//
//代码地址：https://github.com/zuoming/ZTFeatureView
//  ZTFeatureMaskView.h
//  ZTFeatureMaskExample
//
//  Created by zuo ming on 16/1/25.
//  Copyright © 2016年 zuo ming. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZTFeatureMaskView : UIView

@property (nonatomic, strong) void (^featureDidClosed)(void); /**<  */

/** 使用oneTimeKey初始化，则用oneTimeKey标识的ZTFeatureMaskView只会显示一次 */
- (instancetype)initWithOneTimeKey:(NSString *)oneTimeKey;

/** 设置被覆盖视图 */
- (void)setMaskedView:(UIView *)maskedView;
/** 设置覆盖颜色 */
- (void)setMaskColor:(UIColor *)maskColor;
/** 设置透明度 */
- (void)setMaskAlpha:(CGFloat)maskAlpha;

/** 添加透明区域
 transparencyRect : 此区域显示透明。
 referenceView : 在referenceView所在区域显示透明。
 innerRect : 在referenceView内部坐标体系区域，显示透明。
 radius : 圆角弧度
 */
- (void)addTransparencyRect:(CGRect)transparencyRect;
- (void)addTransparencyInReferenceView:(UIView *)referenceView;
- (void)addTransparencyInReferenceView:(UIView *)referenceView wider:(CGFloat)wider;
- (void)addTransparencyInReferenceView:(UIView *)referenceView innerRect:(CGRect)innerRect;
- (void)addTransparencyRect:(CGRect)transparencyRect radius:(CGFloat)radius;
- (void)addTransparencyInReferenceView:(UIView *)referenceView wider:(CGFloat)wider radius:(CGFloat)radius;
- (void)addTransparencyInReferenceView:(UIView *)referenceView radius:(CGFloat)radius;
- (void)addTransparencyInReferenceView:(UIView *)referenceView radius:(CGFloat)radius innerRect:(CGRect)innerRect;

/*----- 添加指引图 -----*/
/** 在指定位置居中添加图片 */
- (void)addImage:(UIImage *)image inRect:(CGRect)rect;
/** 覆盖在referenceView上，并居中显示 */
- (void)addImage:(UIImage *)image inReferenceView:(UIView *)referenceView;
/** 图片添加至相对位置
 referenceView : maskedView的subview。
 spacingLeft : 距离referenceView左边距离。
 spacingRight : 距离referenceView右边距离。
 spacingTop : 距离referenceView顶部距离
 spacingBottom : 距离referenceView底部距离
 outer : 外边距
 inner : 内边距
 */
- (void)addImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingLeft:(CGFloat)spacingLeft spacingTop:(CGFloat)spacingTop;
- (void)addImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingLeft:(CGFloat)spacingLeft spacingBottom:(CGFloat)spacingBottom;
- (void)addImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingRight:(CGFloat)spacingRight spacingTop:(CGFloat)spacingTop;
- (void)addImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingRight:(CGFloat)spacingRight spacingBottom:(CGFloat)spacingBottom;
- (void)addImage:(UIImage *)image referenceView:(UIView *)referenceView withInnerSpacingLeft:(CGFloat)spacingLeft spacingTop:(CGFloat)spacingTop;

/** 添加关闭按钮 
 如果不设置关闭按钮，则点击任意区域都将关闭指引图 
 */
- (void)addCloseButtonWithImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingLeft:(CGFloat)spacingLeft spacingTop:(CGFloat)spacingTop;
- (void)addCloseButtonWithImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingLeft:(CGFloat)spacingLeft spacingBottom:(CGFloat)spacingBottom;
- (void)addCloseButtonWithImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingRight:(CGFloat)spacingRight spacingTop:(CGFloat)spacingTop;
- (void)addCloseButtonWithImage:(UIImage *)image referenceView:(UIView *)referenceView withOuterSpacingRight:(CGFloat)spacingRight spacingBottom:(CGFloat)spacingBottom;
- (void)addCloseButtonWithImage:(UIImage *)image referenceView:(UIView *)referenceView withInnerSpacingLeft:(CGFloat)spacingLeft spacingTop:(CGFloat)spacingTop;

/** 显示 */
- (void)show;

@end