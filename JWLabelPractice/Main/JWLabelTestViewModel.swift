//
//  JWLabelTestViewModel.swift
//  JWLabelPractice
//
//  Created by Jiwon Nam on 4/10/21.
//

import Foundation

class JWLabelTestViewModel {
    var userInputBuffer: String?
    private var textSampleList: [String] = []
    var numOfTableViewSection: Int = 1
    
    /// Number of tableview rows in section
    /// - Parameter section: section index
    /// - Returns: num of rows
    func getNumOfRows(in section: Int) -> Int {
        return textSampleList.count
    }
    
    /// Get table view dequeue reusable cell identifier name
    /// - Parameters:
    ///   - section: section index
    ///   - row: row index
    /// - Returns: identifier name
    func getTableViewIdentifier(at section: Int, row: Int) -> String? {
        return "jw_label"
    }
    
    /// Get table view cell data
    /// - Parameters:
    ///   - section: section index
    ///   - row: row index
    /// - Returns: String type only in this case
    func getTableViewRowData(section: Int, row: Int) -> String? {
        let listCount = textSampleList.count
        let index = listCount - row - 1
        if index >= listCount || index < 0 { return nil }
        return textSampleList[index]
    }
    
    /// delete user text in the list
    /// - Parameters:
    ///   - section: section index
    ///   - row: row index
    ///   - completion: escaping if needed (if the method has global sync)
    func removeUserInputList(
        section: Int, row: Int,
        completion: @escaping () -> Void) {
        let listCount = textSampleList.count
        let index = listCount - row - 1
        if index < 0 || index >= listCount { return }
        textSampleList.remove(at: index)
        completion()
    }
    
    /// add user text in the list
    /// - Parameters:
    ///   - completion: escaping if needed (if the method has global sync)
    ///   - listUpdated: escaping if needed (if the method has global sync)
    func addUserInputToList(
        completion: @escaping () -> Void,
        listUpdated: @escaping () -> Void) {
        completion()
        guard let buffer = userInputBuffer else {
            return
        }
        self.textSampleList.append(buffer)
        
        userInputBuffer = nil
        listUpdated()
    }
}
