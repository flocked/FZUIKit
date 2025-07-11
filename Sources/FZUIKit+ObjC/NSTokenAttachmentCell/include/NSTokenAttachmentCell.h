//
//  NSTokenAttachmentCell.h
//  NSTokenAttachmentCell
//
//  Created by Joel Saltzman on 8/30/18.
//

#import <Cocoa/Cocoa.h>

//! Project version number for Token.
FOUNDATION_EXPORT double NSTokenAttachmentCellVersionNumber;

//! Project version string for NSTokenAttachmentCell.
FOUNDATION_EXPORT const unsigned char NSTokenAttachmentCellVersionString[];

@interface NSTokenAttachmentCell : NSTextAttachmentCell
{
    id _representedObject;
    id _textColor;
    id _reserved;
    struct {
        unsigned int _selected:1;
        unsigned int _edgeStyle:2;
        unsigned int _reserved:29;
    } _tacFlags;
}

+ (void)initialize;
- (nonnull instancetype)init;
- (BOOL)_hasMenu;
- (nonnull NSColor *)tokenForegroundColor;
- (nonnull NSColor *)tokenBackgroundColor;
- (nullable NSColor *)textColor;
- (void)setTextColor:(nullable NSColor *)textColor;
- (nonnull NSImage *)pullDownImage;
- (nullable NSMenu *)menu;
- (NSSize)cellSizeForBounds:(NSRect)bounds;
- (NSSize)cellSize;
- (nonnull NSDictionary<NSAttributedStringKey, id> *)_textAttributes;
- (NSUInteger)tokenStyle;
- (nullable NSColor *)tokenTintColor;
- (NSRect)drawingRectForBounds:(NSRect)bounds;
- (NSRect)titleRectForBounds:(NSRect)bounds;
- (NSRect)cellFrameForTextContainer:(nullable NSTextContainer *)textContainer proposedLineFragment:(NSRect)fp12 glyphPosition:(NSPoint)glyphPosition characterIndex:(unsigned int)index;
- (NSPoint)cellBaselineOffset;
- (NSRect)pullDownRectForBounds:(NSRect)bounds;
- (void)drawTokenWithFrame:(NSRect)frame inView:(nonnull NSView *)view;
- (void)drawInteriorWithFrame:(NSRect)frame inView:(nonnull NSView *)view;

@end

