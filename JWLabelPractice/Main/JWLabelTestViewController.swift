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
