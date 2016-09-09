//
//  FourTextAttachment.m
//  TEST_Common
//
//  Created by luxiaoming on 16/8/31.
//  Copyright © 2016年 luxiaoming. All rights reserved.
//

#import "FourTextAttachment.h"

@implementation FourTextAttachment

// Returns the image object rendered by NSLayoutManager at imageBounds inside textContainer.  It should return an image appropriate for the target rendering context derived by arguments to this method.  The NSTextAttachment implementation returns -image when non-nil.  If -image==nil, it returns an image based on -contents and -fileType properties.
- (nullable UIImage *)imageForBounds:(CGRect)imageBounds textContainer:(nullable NSTextContainer *)textContainer characterIndex:(NSUInteger)charIndex  NS_AVAILABLE(10_11, 7_0) {
    NSLog(@"imageBounds is %@", NSStringFromCGRect(imageBounds));
    NSLog(@"charIndex is %@", @(charIndex));
    return [super imageForBounds:imageBounds textContainer:textContainer characterIndex:charIndex];
}


// Returns the layout bounds to the layout manager.  The bounds origin is interpreted to match position inside lineFrag.  The NSTextAttachment implementation returns -bounds if not CGRectZero; otherwise, it derives the bounds value from -[image size].  Conforming objects can implement more sophisticated logic for negotiating the frame size based on the available container space and proposed line fragment rect.
- (CGRect)attachmentBoundsForTextContainer:(nullable NSTextContainer *)textContainer proposedLineFragment:(CGRect)lineFrag glyphPosition:(CGPoint)position characterIndex:(NSUInteger)charIndex NS_AVAILABLE(10_11, 7_0) {
    CGRect rect = [super attachmentBoundsForTextContainer:textContainer proposedLineFragment:lineFrag glyphPosition:position characterIndex:charIndex];
//    rect = CGRectMake(100, 50, rect.size.width, rect.size.height);
    NSLog(@"rect is %@", NSStringFromCGRect(rect));
    NSLog(@"lineFrag is %@", NSStringFromCGRect(lineFrag));
    NSLog(@"glyphPosition is %@", NSStringFromCGPoint(position));
    NSLog(@"charIndex is %@", @(charIndex));
    
    return rect;
}

@end
