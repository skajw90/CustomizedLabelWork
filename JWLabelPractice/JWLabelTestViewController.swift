//
//  ViewController.swift
//  JWLabelPractice
//
//  Created by Jiwon Nam on 4/9/21.
//

import UIKit

class JWLabelTestViewController: UIViewController {
    var tableViewBottomConstraint: NSLayoutConstraint!
    let viewModel = JWLabelTestViewModel()
    
    lazy var textView: JWTextView = {
        let textView = JWTextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.isScrollEnabled = false
        textView.placeHolder = "Please Enter your Text"
        textView.placeHolderTextColor = .lightGray
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.layer.cornerRadius = 8
        textView.alwaysBounceHorizontal = false
        return textView
    } ()
    
    lazy var submitButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Submit", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(UIColor.white.withAlphaComponent(0.55), for: .highlighted)
        button.addTarget(self, action: #selector(submitButtonTouchUpInside), for: .touchUpInside)
        return button
    } ()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor.black.withAlphaComponent(0.22)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(JWLabelTestTableViewCell.self, forCellReuseIdentifier: "jw_label")
        view.addSubview(tableView)
        return tableView
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setConstraints()
        setNavigationBarProperties()
        configuration()
    }
    
    @objc private func submitButtonTouchUpInside() {
        viewModel.addUserInputToList(
            completion: { [weak self] in
                guard let self = self else { return }
                self.textView.text = nil
                self.textView.endEditing(true)
                
            }, listUpdated: {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            })
    }
    
    private func configuration() {
        textView.thresholdHeight = view.bounds.height / 4
    }

    private func setNavigationBarProperties() {
        title = "JWLabel Tester"
        view.backgroundColor = .lightGray
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    private func setConstraints() {
        let textViewWrapper = UIView()
        textViewWrapper.translatesAutoresizingMaskIntoConstraints = false
        textViewWrapper.backgroundColor = .darkGray
        view.addSubview(textViewWrapper)
        
        textViewWrapper.addSubview(textView)
        textViewWrapper.addSubview(submitButton)
        
        NSLayoutConstraint.activate([
            textViewWrapper.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textViewWrapper.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            textViewWrapper.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: textViewWrapper.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: submitButton.leadingAnchor, constant: -20),
            textView.topAnchor.constraint(equalTo: textViewWrapper.topAnchor, constant: 20),
            textView.bottomAnchor.constraint(equalTo: textViewWrapper.bottomAnchor, constant: -20)
        ])
        
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: textViewWrapper.topAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: textViewWrapper.trailingAnchor, constant: -20),
            submitButton.widthAnchor.constraint(equalToConstant: submitButton.intrinsicContentSize.width)
        ])
        
        tableViewBottomConstraint = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: textViewWrapper.bottomAnchor),
            tableViewBottomConstraint
        ])
    }
}


extension JWLabelTestViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numOfTableViewSection
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let identifier = viewModel.getTableViewIdentifier(at: indexPath.section, row: indexPath.row), let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? JWLabelTestTableViewCell else {
            // log
            return UITableViewCell()
        }
        cell.tag = indexPath.row
        cell.selectionStyle = .none
        cell.swipeGesture?.delegate = self
        cell.bindData(text: viewModel.getTableViewRowData(section: indexPath.section, row: indexPath.row))
        cell.delegate = self
        return cell
    }
}

extension JWLabelTestViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
    }
}

extension JWLabelTestViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        // toggle placeholder
        (textView as? JWTextView)?.togglePlaceHolder(isHidden: !(textView.text?.isEmpty ?? false))
        viewModel.userInputBuffer = textView.text
    }
}

extension JWLabelTestViewController: TestTableViewCellDelegate {
    func deleteCell(at row: Int, section: Int) {
        viewModel.removeUserInputList(section: section, row: row, completion: {
            self.tableView.performBatchUpdates({
                self.tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: .right)
            }, completion: { _ in
                self.tableView.reloadData()
            })
        })
    }
}


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
