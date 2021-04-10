//
//  JWTextView.swift
//  JWLabelPractice
//
//  Created by Jiwon Nam on 4/10/21.
//

import UIKit

class JWTextView: UITextView, NSTextStorageDelegate {
    var thresholdHeight: CGFloat?
    let MIN_HEIGHT_THRESHOLD: CGFloat = 16
    private var placeholderLeadingConstraint: NSLayoutConstraint!
    private var placeholderTrailingConstraint: NSLayoutConstraint!
    private var placeholderTopConstraint: NSLayoutConstraint!
    private var minHeightConstraint: NSLayoutConstraint!
    var placeHolder: String = "" {
        didSet {
            placeholderLabel.text = placeHolder
        }
    }
    var placeHolderTextColor: UIColor = .black {
        didSet {
            placeholderLabel.textColor = placeHolderTextColor
        }
    }
    lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = !self.text.isEmpty
        addSubview(label)
        return label
    } ()
    
    override var text: String! {
        didSet {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
    
    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
            minHeightConstraint.constant = font?.pointSize ?? MIN_HEIGHT_THRESHOLD
        }
    }
    
    override var contentInset: UIEdgeInsets {
        didSet {
            placeholderLeadingConstraint.constant = contentInset.left + textContainerInset.left
            placeholderTrailingConstraint.constant = -(contentInset.right + textContainerInset.right)
            placeholderTopConstraint.constant = contentInset.top + textContainerInset.top
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.textContainer.lineFragmentPadding = 8
        setPlaceholderConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // auto resizing text view by its threshold
        if let threshold = thresholdHeight,
           self.contentSize.height >= threshold {
            self.isScrollEnabled = true
        }
        else {
            self.isScrollEnabled = false
        }
    }
    
    func togglePlaceHolder(isHidden: Bool) {
        placeholderLabel.isHidden = isHidden
    }
    
    private func setPlaceholderConstraints() {
        minHeightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .height, multiplier: 1, constant: font?.pointSize ?? (MIN_HEIGHT_THRESHOLD))
        placeholderLeadingConstraint = NSLayoutConstraint(item: placeholderLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: contentInset.left + textContainerInset.left + textContainer.lineFragmentPadding)
        placeholderTrailingConstraint = NSLayoutConstraint(item: placeholderLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: -(contentInset.right + textContainerInset.right + textContainer.lineFragmentPadding))
        placeholderTopConstraint = NSLayoutConstraint(item: placeholderLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: contentInset.top + textContainerInset.top)
        
        NSLayoutConstraint.activate([
            placeholderLeadingConstraint,
            placeholderTrailingConstraint,
            placeholderTopConstraint,
        ])
        
        minHeightConstraint.isActive = true
    }
}
