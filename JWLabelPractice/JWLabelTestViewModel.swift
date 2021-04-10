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
    func getNumOfRows(in section: Int) -> Int {
        return textSampleList.count
    }
    
    func getTableViewIdentifier(at section: Int, row: Int) -> String? {
        return "jw_label"
    }
    
    func getTableViewRowData(section: Int, row: Int) -> String? {
        let listCount = textSampleList.count
        let index = listCount - row - 1
        if index >= listCount || index < 0 { return nil }
        return textSampleList[index]
    }
    
    func removeUserInputList(
        section: Int, row: Int,
        completion: @escaping () -> Void) {
        let listCount = textSampleList.count
        let index = listCount - row - 1
        if index < 0 || index >= listCount { return }
        textSampleList.remove(at: index)
        completion()
    }
    
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
