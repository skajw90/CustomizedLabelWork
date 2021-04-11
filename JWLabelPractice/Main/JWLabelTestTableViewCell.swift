//
//  JWLabelTestTableViewCell.swift
//  JWLabelPractice
//
//  Created by Jiwon Nam on 4/10/21.
//

import UIKit

protocol TestTableViewCellDelegate: class {
    func deleteCell(at row: Int, section: Int)
}

enum JWLabelTestTableViewCellMode {
    case normal
    case delete
}

class JWLabelTestTableViewCell: UITableViewCell {
    var isSwipeInActive: Bool = false
    var section: Int = 0
    var swipeGesture: UIPanGestureRecognizer?
    weak var delegate: TestTableViewCellDelegate?
    var mode: JWLabelTestTableViewCellMode = .normal {
        didSet {
            switch mode {
            case .normal:
                deleteButtonWidthConstraint.constant = 0
            case .delete:
                deleteButtonWidthConstraint.constant = deleteButtonMaximumSize
            }
        }
    }
    
    var deleteButtonMaximumSize: CGFloat {
        get {
            return deleteButton.intrinsicContentSize.width + deleteButton.titleEdgeInsets.left + deleteButton.titleEdgeInsets.right
        }
    }
    
    var deleteButtonWidthConstraint: NSLayoutConstraint!
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleEdgeInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.55), for: .highlighted)
        button.backgroundColor = UIColor.systemRed.withAlphaComponent(0.55)
        button.addTarget(self, action: #selector(deleteButtonTouchUpInside), for: .touchUpInside)
        contentView.addSubview(button)
        return button
    } ()
    
    lazy var attributedLabel: JWLabel = {
        let label = JWLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.linkEnabled = true
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.black
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    } ()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        setConstraints()
        swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureSwipeHandler))
        contentView.addGestureRecognizer(swipeGesture!)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        mode = .normal
        attributedLabel.prepareForReuse()
        isSwipeInActive = false
    }
    
    @objc private func deleteButtonTouchUpInside() {
        delegate?.deleteCell(at: tag, section: section)
    }
    
    /// Cell Pan gesture Animation handler
    /// - Parameter gesture: pan gesture recognizer
    @objc private func panGestureSwipeHandler(gesture: UIPanGestureRecognizer) {
        // horizontal only
        let state = gesture.state
        let velocity = gesture.velocity(in: contentView).x
        if abs(velocity) < abs(gesture.velocity(in: contentView).y) { return }
        let threshold: CGFloat = 500
        let removingTriggerThreshold: CGFloat = 1000
        if state == .ended {
            // remove cell right away
            if velocity > removingTriggerThreshold {
                deleteButtonWidthConstraint.constant = deleteButtonMaximumSize
                delegate?.deleteCell(at: tag, section: section)
                return
            }
            else if velocity > threshold {
                deleteButtonWidthConstraint.constant = deleteButtonMaximumSize
            }
            else if -velocity > threshold {
                deleteButtonWidthConstraint.constant = 0
            }
            else if deleteButtonWidthConstraint.constant >= deleteButtonMaximumSize / 2 {
                deleteButtonWidthConstraint.constant = deleteButtonMaximumSize
            }
            else {
                deleteButtonWidthConstraint.constant = 0
            }
                
            UIView.animate(withDuration: 0.5, animations: {
                self.layoutIfNeeded()
            })
            return
        }
        
        let targetWidth = deleteButtonWidthConstraint.constant + velocity * 0.01
        deleteButtonWidthConstraint.constant = max(0, min(targetWidth, deleteButtonMaximumSize))
        
    }
        
    
    func bindData(text: String?) {
        attributedLabel.setJWAttributedText(text: text)
    }
    
    private func setConstraints() {
        deleteButtonWidthConstraint = NSLayoutConstraint(item: deleteButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([
            deleteButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            deleteButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            deleteButtonWidthConstraint
        ])
        
        let wrapper = UIView()
        wrapper.translatesAutoresizingMaskIntoConstraints = false
        wrapper.layer.cornerRadius = 8
        wrapper.backgroundColor = .white
        contentView.addSubview(wrapper)
        wrapper.addSubview(attributedLabel)
        NSLayoutConstraint.activate([
            wrapper.leadingAnchor.constraint(equalTo: deleteButton.trailingAnchor, constant: 20),
            wrapper.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            wrapper.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            wrapper.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            attributedLabel.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor, constant: 10),
            attributedLabel.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor, constant: -10),
            attributedLabel.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 10),
            attributedLabel.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor, constant: -10)
        ])
    }
}
