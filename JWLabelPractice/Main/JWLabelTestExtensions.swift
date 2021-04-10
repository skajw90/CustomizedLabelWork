//
//  JWLabelTestExtensions.swift
//  JWLabelPractice
//
//  Created by Jiwon Nam on 4/10/21.
//

import UIKit

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
