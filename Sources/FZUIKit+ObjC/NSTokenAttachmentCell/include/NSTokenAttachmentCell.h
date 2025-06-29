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
- (id)initTextCell:(id)fp8;
- (id)init;
- (void)dealloc;
- (id)representedObject;
- (void)setRepresentedObject:(id)fp8;
- (int)interiorBackgroundStyle;
- (BOOL)_hasMenu;
- (NSColor *)tokenForegroundColor;
- (NSColor *)tokenBackgroundColor;
- (NSColor *)textColor;
- (void)setTextColor:(NSColor *)textColor;
- (NSImage *)pullDownImage;
- (nullable NSMenu *)menu;
- (NSSize)cellSizeForBounds:(NSRect)bounds;
- (NSSize)cellSize;
- (NSDictionary<NSAttributedStringKey, id> *)_textAttributes;
- (unsigned long long)tokenStyle;
- (nullable NSColor *)tokenTintColor;
- (NSRect)drawingRectForBounds:(NSRect)bounds;
- (NSRect)titleRectForBounds:(NSRect)bounds;
- (NSRect)cellFrameForTextContainer:(id)textContainer proposedLineFragment:(NSRect)fp12 glyphPosition:(NSPoint)glyphPosition characterIndex:(unsigned int)index;
- (NSPoint)cellBaselineOffset;
- (NSRect)pullDownRectForBounds:(NSRect)bounds;
- (void)drawTokenWithFrame:(NSRect)frame inView:(NSView *)view;
- (void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)view;
- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view;
- (void)drawWithFrame:(NSRect)frame inView:(NSView *)view characterIndex:(unsigned int)index layoutManager:(id)fp32;
- (void)encodeWithCoder:(id)coder;
- (id)initWithCoder:(id)coder;
- (BOOL)wantsToTrackMouseForEvent:(id)event inRect:(NSRect)fp12 ofView:(NSView *)view atCharacterIndex:(unsigned int)index;
- (BOOL)trackMouse:(id)fp8 inRect:(NSRect)fp12 ofView:(NSView *)fp28 atCharacterIndex:(unsigned int)index untilMouseUp:(BOOL)untilMouseUp;

@end


