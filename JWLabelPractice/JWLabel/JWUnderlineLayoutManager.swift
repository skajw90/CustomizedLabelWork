//
//  OhaUnderlineLayoutManager.swift
//
//  Created by Jiwon Nam on 2021/01/07.
//

import UIKit

/// Custom line layout manager
class JWUnderlineLayoutManager: NSLayoutManager {
    
    static let JWUnderLineStyle = 0x11
    static let JWBackgroundStyle = 0x12
    
    
    /// Draw custom underline
    /// - Parameter rect: CGRect
    private func drawOhaUnderlineForRect(_ rect: CGRect) {
        let test = CGRect(x: rect.minX, y: rect.maxY - (rect.height / 4), width: rect.width, height: (rect.height / 4))
        let path = UIBezierPath(roundedRect: test, cornerRadius: 0)
        UIColor.SampleColors.main.setFill()
        path.fill()
    }
    
    /// Draw custom background for view
    /// - Parameters:
    ///   - rect: background rect
    ///   - color: background color
    private func drawCustomBackgroundForRect(_ rect: CGRect, _ color: UIColor) {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 0)
        color.setFill()
        path.fill()
    }
    
    override func drawUnderline(forGlyphRange glyphRange: NSRange, underlineType underlineVal: NSUnderlineStyle, baselineOffset: CGFloat, lineFragmentRect lineRect: CGRect, lineFragmentGlyphRange lineGlyphRange: NSRange, containerOrigin: CGPoint) {
        
        if underlineVal.rawValue == JWUnderlineLayoutManager.JWUnderLineStyle {
            let charRange = characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            if let underlineColor = textStorage?.attribute(.underlineColor, at: charRange.location, effectiveRange: nil) as? UIColor {
                underlineColor.setStroke()
            }
            
            if let container = textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil) {
                let boundingRect = self.boundingRect(forGlyphRange: glyphRange, in: container)
                let offsetRect = boundingRect.offsetBy(dx: containerOrigin.x, dy: containerOrigin.y)
                
                drawOhaUnderlineForRect(offsetRect)
            }
        }
        else if underlineVal.rawValue == JWUnderlineLayoutManager.JWBackgroundStyle {
            let charRange = characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            guard let backgroundColor = textStorage?.attribute(.underlineColor, at: charRange.location, effectiveRange: nil) as? UIColor else { return }
            backgroundColor.setStroke()
            
            if let container = textContainer(forGlyphAt: glyphRange.location, effectiveRange: nil) {
                let boundingRect = self.boundingRect(forGlyphRange: glyphRange, in: container)
                let offsetRect = boundingRect.offsetBy(dx: containerOrigin.x, dy: containerOrigin.y)
                
                drawCustomBackgroundForRect(offsetRect, backgroundColor)
            }
        }
        else {
            super.drawUnderline(forGlyphRange: glyphRange, underlineType: underlineVal, baselineOffset: baselineOffset, lineFragmentRect: lineRect, lineFragmentGlyphRange: lineGlyphRange, containerOrigin: containerOrigin)
        }
    }
}
