//
//  JWLabel.swift
//
//  Created by Jiwon Nam on 2020/11/17.
//

import UIKit
// MARK: - Constant
let JW_LINE_SPACING: CGFloat = 2
var font_increment: CGFloat = 0

/// JWLabel
///
/// label text attribution affected by user input with specific code set.
///
/// customized values will be detected, and affect attribution to this label.
///
/// You can set specific attributions in JWTextAttributeDataSource
class JWLabel: UILabel {
    
    lazy var storage: NSTextStorage = {
        let storage = NSTextStorage()
        return storage
    } ()
    
    let layoutManager = JWUnderlineLayoutManager()
    
    /// link touch enable property
    ///
    /// if true, touching link navigate to webview with link url
    var linkEnabled: Bool = false {
        didSet {
            isUserInteractionEnabled = linkEnabled
        }
    }
    
    /// line spacing between each line
    var customLineSpacing: CGFloat = JW_LINE_SPACING
    
    /// list of url range in text
    private var urlRanges: [NSRange]?
    
    lazy var container: NSTextContainer = {
        let container = NSTextContainer()
        container.lineBreakMode = .byTruncatingTail
        container.lineFragmentPadding = 0
        container.widthTracksTextView = true
        container.maximumNumberOfLines = self.numberOfLines
        return container
    } ()
    
    // MARK: - Override Properties
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        adjustsFontForContentSizeCategory = true
        layoutManager.textStorage = storage
        storage.addLayoutManager(self.layoutManager)
        layoutManager.addTextContainer(self.container)
        container.layoutManager = layoutManager
        // oha default color
        textColor = UIColor.SampleColors.black
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        container.size = bounds.size
    }
    
    override var frame: CGRect {
        didSet {
            setContainerSize(rect: frame)
        }
    }
    
    override var bounds: CGRect {
        didSet {
            setContainerSize(rect: bounds)
        }
    }
    
    override var preferredMaxLayoutWidth: CGFloat {
        didSet {
            setContainerSize(rect: bounds)
        }
    }
    
    override var numberOfLines: Int {
        didSet {
            container.maximumNumberOfLines = numberOfLines
        }
    }
    
    override var lineBreakMode: NSLineBreakMode {
        didSet {
            container.lineBreakMode = lineBreakMode
        }
    }

    override var attributedText: NSAttributedString? {
        didSet {
            if let attributedText = attributedText {
                storage.setAttributedString(attributedText)
                self.invalidateIntrinsicContentSize()
            }
        }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let savedTextContainerSize = container.size
        let savedTextContainerNumberOfLines = container.maximumNumberOfLines
        container.size = bounds.size
        container.maximumNumberOfLines = numberOfLines
    
        let glyphRange: NSRange = self.layoutManager.glyphRange(for: self.container)
        var textBounds = self.layoutManager.boundingRect(forGlyphRange: glyphRange, in: self.container)
        
        textBounds.origin = bounds.origin
        textBounds.size.width = CGFloat(ceilf(Float(textBounds.size.width)))
        textBounds.size.height = CGFloat(ceilf(Float(textBounds.size.height)))
        
        container.size = savedTextContainerSize
        container.maximumNumberOfLines = savedTextContainerNumberOfLines
        // when label doesnt have contents, size to zero
        if textBounds.width == 0 { textBounds.size.height = 0 }
        return textBounds
    }
    
    override func drawText(in rect: CGRect) {
        let glyphRange = layoutManager.glyphRange(for: container)
        let textOffset = textOffsetForGlyphRange(glyphRange: glyphRange)
        
        layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: textOffset)
    }
    
    /// remove all properties for reuse
    func prepareForReuse() {
        urlRanges = nil
        attributedText = nil
        text = nil
        if let gestures = gestureRecognizers {
            for gesture in gestures {
                removeGestureRecognizer(gesture)
            }
        }
    }
    
    // MARK: - set Attribution
    /// Main Call for set attributed text in label
    /// - Parameter text: user input text
    func setJWAttributedText(text: String?) {
        guard let text = text else {
            prepareForReuse()
            return
        }
        let attr = setOhaAttribution(text: text, baseFont: font, baseColor: self.textColor)
        
        attributedText = attr
    }
    
    // MARK: - Helper functions
    
    /// Get Text offset for glyph range
    /// - Parameter glyphRange: range
    /// - Returns: text offset
    private func textOffsetForGlyphRange(glyphRange: NSRange) -> CGPoint {
        var textOffset: CGPoint = .zero
        let textBounds = layoutManager.boundingRect(forGlyphRange: glyphRange, in: container)
        let paddingHeight = (bounds.size.height - textBounds.size.height) / 2.0
        if paddingHeight > 0 {
            textOffset.y = paddingHeight
        }
        return textOffset
    }
    
    /// set container size
    /// - Parameter rect: frame, bounds, or maxwidth
    private func setContainerSize(rect: CGRect) {
        var size = rect.size
        size.width = min(size.width, self.preferredMaxLayoutWidth)
        size.height = 0
        container.size = size
    }
    
    /// Url tap gesture handler
    /// - Parameter gesture: tap gesture recognizer
    @objc private func urlTapped(gesture: UITapGestureRecognizer) {
        guard let urlRanges = urlRanges, let text = text else { return }
        for range in urlRanges {
            guard let textRange = Range(range, in: text) else { return }
            let indexOfCharacter = layoutManager.characterIndex(for: gesture.location(in: self), in: container, fractionOfDistanceBetweenInsertionPoints: nil)

            if NSLocationInRange(indexOfCharacter, range) {
                // push webview controller
                let controller = JWWebViewController()
                controller.setNavigationBarTitle(title: "JW Label Link")
                controller.urlString = String(text[textRange])
                // if navigation view controller
                if let topVC = UIApplication.topViewController() {
                    topVC.navigationController?.pushViewController(controller, animated: true)
                }
                // TODO: - else modal view controller
                else {
                    
                }
                return
            }
        }
    }
    
    /// set attribution
    /// - Parameters:
    ///   - text: user input
    ///   - baseFont: common font for all
    ///   - baseColor: common text color for all
    /// - Returns: mutable attributed string
    private func setOhaAttribution(text: String, baseFont: UIFont, baseColor: UIColor) -> NSMutableAttributedString {
        // set base font and color
        var output = text
        
        var pureText = output
        for attr in AttributionCase.allCases {
            pureText = pureText.replacingOccurrences(of: attr.textForm.from, with: "")
            pureText = pureText.replacingOccurrences(of: attr.textForm.to, with: "")
        }
        self.text = pureText
        // get all attributed text ranges and replace text without attribution text
        var targetWithAttribution = getAttributionRanges(text: &output)
        
        // detect url
        urlRanges = []
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: output, options: [], range: NSRange(location: 0, length: output.utf16.count))
        for match in matches {
            urlRanges?.append(match.range)
        }
        if urlRanges?.count ?? 0 > 0 {
            targetWithAttribution[.l] = urlRanges
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(urlTapped))
            addGestureRecognizer(tapGesture)
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = customLineSpacing  // MARK: - line height
     
        let attributedString = NSMutableAttributedString(string: output)
        let range = (output as NSString).range(of: output)

        // set base font and color of text
        let baseAttribution: [NSAttributedString.Key: Any] = [.font: baseFont,
                                                              .foregroundColor: baseColor,
                                                              .paragraphStyle : paragraphStyle]
        attributedString.addAttributes(baseAttribution, range: range)
        // set target attribution
        for targets in targetWithAttribution {
            for range in targets.value {
                attributedString.addAttributes(getAttributedKey(attr: targets.key), range: range)
            }
        }
        return attributedString
    }
    
    /// Detect attributions in text, and return the ranges of attribution in text
    /// - Parameter text: ref user input, could be editible
    /// - Returns: [AttributionCase : [NSRange]]
    private func getAttributionRanges(text: inout String) -> [AttributionCase : [NSRange]] {
        var attributionRanges: [AttributionCase : [NSRange]] = [:]
        var hasAttributed: Bool = false, fromStarted: Bool = false, toStarted: Bool = false
        var regexFrom: String = "", regexTo: String = "", affectedWord: String = ""
        for char in text {
            if hasAttributed {  // detect attribution end point
                if char == "<" {
                    if toStarted { affectedWord += regexTo }
                    toStarted = true
                    regexTo = String(char)
                }
                else if char == ">" && toStarted {
                    regexTo += String(char)
                    if let to = AttributionCase.getAttributionByCode(code: regexTo),
                       let attribution = AttributionCase.getAttributionByCode(code: regexFrom),
                       to == attribution {
                        toStarted = false
                        let replacingText = regexFrom + affectedWord + regexTo
                        let location = (text as NSString).range(of: replacingText).location
                        let length = affectedWord.count
                        let range = NSRange(location: location, length: length)
                        
                        if attributionRanges.contains(where: { key, _ in key == attribution}) {
                            attributionRanges[attribution]?.append(range)
                        }
                        else { attributionRanges[attribution] = [range] }
                        
                        text = text.replacingFirstOccurrence(of: replacingText, with: affectedWord)
                        
                        // reset
                        hasAttributed = false
                        regexFrom = ""
                        affectedWord = ""
                    }
                    else {
                        affectedWord += regexTo
                    }
                    regexTo = ""
                }
                else if toStarted {
                    regexTo += String(char)
                }
                else { affectedWord += String(char) }
            }
            else {
                // detect attribution start point
                if char == "<" {
                    fromStarted = true
                    regexFrom = String(char)
                }
                else if char == ">" && fromStarted {
                    fromStarted = false
                    regexFrom += String(char)
                    if let _ = AttributionCase.getAttributionByCode(code: regexFrom) {
                        hasAttributed = true
                    }
                    else { regexFrom = "" }
                }
                else if fromStarted { regexFrom += String(char) }
            }
        }
        return attributionRanges
    }
    
    /// create attribution
    /// - Parameter attr: attribution cse
    /// - Returns:[NSAttributedString.Key : Any]
    private func getAttributedKey(attr: AttributionCase) -> [NSAttributedString.Key : Any] {
        var output: [NSAttributedString.Key : Any] = [:]
        // bold
        if attr.textBold {
            output[NSAttributedString.Key.font] = UIFont.systemFont(ofSize: font.pointSize, weight: .bold)
        }
        // background
        if let backgroundColor = attr.textBackgroundColor {
            output[NSAttributedString.Key.underlineStyle] = JWUnderlineLayoutManager.JWBackgroundStyle
            output[NSAttributedString.Key.underlineColor] = backgroundColor
        }
        // foreground
        if let textColor = attr.textColor {
            output[NSAttributedString.Key.foregroundColor] = textColor
        }
        // underline
        if let underline = attr.underlineColor {
            output[NSAttributedString.Key.underlineStyle] = (attr == .cbu || attr == .bu) ? JWUnderlineLayoutManager.JWUnderLineStyle : NSUnderlineStyle.single.rawValue
            output[NSAttributedString.Key.underlineColor] = underline.color ?? textColor
        }
        
        return output
    }
}


extension UIFont {
    /// weight for the font
    var weight: UIFont.Weight {
        guard let weightNumber = traits[.weight] as? NSNumber else { return .regular }
        let weightRawValue = CGFloat(weightNumber.doubleValue)
        let weight = UIFont.Weight(rawValue: weightRawValue)
        return weight
    }
    
    static func customFont(ofSize: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        return UIFont.systemFont(ofSize: ofSize + font_increment, weight: weight)
    }
    
    private var traits: [UIFontDescriptor.TraitKey: Any] {
        return fontDescriptor.object(forKey: .traits) as? [UIFontDescriptor.TraitKey: Any]
            ?? [:]
    }
}

extension String {
    /// relace first occured word in text with replacement
    func replacingFirstOccurrence(of string: String, with replacement: String) -> String {
        guard let range = self.range(of: string) else { return self }
        return replacingCharacters(in: range, with: replacement)
    }
}


extension UIApplication {

    /// Get top view controller
    class func topViewController(base: UIViewController? =  UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController,
                  let selected = tab.selectedViewController {
            return topViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}
