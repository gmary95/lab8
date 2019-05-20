//
//  ViewController.swift
//  lab8
//
//  Created by Mary Gerina on 5/18/19.
//  Copyright © 2019 Mary Gerina. All rights reserved.
//

import Cocoa
import Foundation

class ViewController: NSViewController {
    @IBOutlet weak var NxText: NSTextFieldCell!
    @IBOutlet weak var qText: NSTextFieldCell!
    @IBOutlet weak var epsText: NSTextFieldCell!
    @IBOutlet weak var betaText: NSTextFieldCell!
    @IBOutlet weak var parameterTable: NSTableView!
    
    @IBOutlet weak var pText: NSTextFieldCell!
    @IBOutlet weak var p2Text: NSTextFieldCell!
    @IBOutlet weak var varienceText: NSTextFieldCell!
    
    @IBOutlet weak var experimentTable: NSTableView!
    @IBOutlet weak var resultsTable: NSTableView!
    
    let path = "/Users/gmary/Library/Containers/com.gmary.lab6/Data/Documents/"
    
    var Nx = 2
    var q = 2
    var eps = 0.01
    var beta = 0.95
    var fileModels: [FileModel] = []
    var yArray: [[Double]] = []
    var xArray: [[Int]] = []
    var yAvArray: [Double] = []
    var dArray: [Double] = []
    var bArray: [Double] = []
    var tArray: [Double] = []
    var Tstud: Double = 1.96
    var dAd = 0.0
    
    var text1 = ""
    var text2 = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func startPart2(_ sender: Any) {
        let variance = Double(varienceText.title) ?? 0.01
        var result: Double = pow(variance,2.0) / (pow(eps, 2.0) * (1.0 - beta))
        pText.title = result.rounded(toPlaces: 6).description
        
        result = pow(variance * 1.96, 2.0) / pow(eps, 2.0)
        p2Text.title = ceil(result).description
    }
    
    @IBAction func openFirstRart(_ sender: Any) {
        readParam()
        
        fileModels = []
        yArray = []
        xArray = []
        yAvArray = []
        dArray = []
        bArray = []
        tArray = []
        
        let dialog = NSOpenPanel()
        
        dialog.directoryURL = NSURL.fileURL(withPath: path, isDirectory: true)
        dialog.title                   = "Choose a file"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = true
        dialog.canCreateDirectories    = true
        dialog.allowsMultipleSelection = false
        dialog.allowedFileTypes        = ["dat", "txt"]
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url // Pathname of the file
            
            if (result != nil) {
                openAndRead(filePath: result!)
                createYArr()
                print(yArray)
                creatX()
                createYAv()
                createD()
                createB()
                createT()
                
                Tstud = Quantil.StudentQuantil(p: Double(yArray[0].count - 1), v: Double(yAvArray.count))
                
                dAd = calcDAd()
                
                experimentTable.reloadData()
                resultsTable.reloadData()
            }
        } else {
            // User clicked on "Cancel"
            return
        }
    }
    
    func openAndRead(filePath: URL) {
        do {
            let content = try String(contentsOf: filePath)
            let elements = content.components(separatedBy: "\n")
            elements.forEach {
                var parameters:[Double] = []
                var result: [Double] = []
                let elem = $0.components(separatedBy: ",")
                
                for i in 0 ..< Nx {
                    if let value = Double(elem[i]){
                        parameters.append(value)
                    }
                }
                
                for i in Nx ..< elem.count {
                    if let value = Double(elem[i]){
                        result.append(value)
                    }
                }
                
                fileModels.append(FileModel(parameters: parameters, result: result))
            }
            
            parameterTable.reloadData()
            
        } catch {
            _ = AlertHelper().dialogCancel(question: "Sopmething went wrong!", text: "You choose incorect file or choose noone.")
        }
    }
    
    func openFile(filePath: URL) {
        do {
            let content = try String(contentsOf: filePath)
            let elements = content.components(separatedBy: "\n")
            elements.forEach {
                let elem = $0.components(separatedBy: ",")
                
                var y: [Double] = []
                for el in elem {
                    y.append(Double(el) ?? 0.0)
                }
                
                yArray.append(y)
            }
            
        } catch {
            _ = AlertHelper().dialogCancel(question: "Sopmething went wrong!", text: "You choose incorect file or choose noone.")
        }
    }
    
    func readParam() {
        self.Nx = Int(NxText.title) ?? 2
        self.q = Int(qText.title) ?? 2
        self.eps = Double(epsText.title) ?? 0.01
        self.beta = Double(betaText.title) ?? 0.95
    }
    
    func createYArr() {
        for i in 0 ..< fileModels.count {
            var y: [Double] = []
            for j in 0..<fileModels[i].result.count {
                y.append(Double(fileModels[i].result[j]) ?? 0.0)
            }
            
            yArray.append(y)
        }
    }
    
    func creatX() {
        xArray = []
        for i in 0 ..< yArray.count {
            var x: [Int] = []
            for j in 0 ..< Nx + 2 {
                switch j {
                case 0:
                    x.append(1)
                case 1:
                    if i % 2 == 0 {
                        x.append(-1)
                    } else {
                        x.append(1)
                    }
                case 2:
                    if Int(i / 2) % 2 != 0 {
                        x.append(1)
                    } else {
                        x.append(-1)
                    }
                default:
                    x.append(x[1] * x[2])
                }
            }
            xArray.append(x)
        }
    }
    
    func createYAv() {
        for i in 0 ..< yArray.count {
            yAvArray.append(ArrayHelper.findAv(array: yArray[i]))
        }
    }
    
    func createD() {
        for i in 0 ..< yArray.count {
            dArray.append(ArrayHelper.findVarience(array: yArray[i]))
        }
    }
    
    func createB() {
        for i in 0 ..< Nx + 2 {
            var result = 0.0
            for j in 0 ..< yAvArray.count {
                result += Double(xArray[j][i]) * yAvArray[j]
            }
            bArray.append(result)
        }
    }
    
    func createT() {
        let N: Double = Double(bArray.count)
        let p: Double = Double(yArray[0].count)
        let d = ArrayHelper.findAv(array: dArray)
        let coif = sqrt(N * p / d)
        for i in 0 ..< bArray.count {
            tArray.append(fabs(bArray[i]) * coif)
        }
    }
    
    func calcDAd() -> Double{
        var result = 0.0
        for i in 0 ..< fileModels.count {
            result += pow(fileModels[i].result[0] - calcReg(i: i), 2.0)
        }
        result /= Double(fileModels.count - calcL())
        return result
    }
    
    func calcReg(i: Int) -> Double {
        var result = 0.0
        let x0 = 1.0
        let x10 = ArrayHelper.findAvPlus(array: fileModels, iParam: 0)
        let x20 = ArrayHelper.findAvPlus(array: fileModels, iParam: 1)
        let dx1 = ArrayHelper.findDx(array: fileModels, iParam: 0)
        let dx2 = ArrayHelper.findDx(array: fileModels, iParam: 1)
        let x1 = (fileModels[i].parameters[0] - x10) / dx1
        let x2 = (fileModels[i].parameters[1] - x20) / dx2
        result = bArray[0] * x0 + bArray[1] * x1 + bArray[2] * x2 + bArray[3] * x1 * x2
        return result
    }
    
    func calcL() -> Int {
        var result = 0
        for i in 0 ..< tArray.count {
            if tArray[i] > Tstud {
                result += 1
            }
        }
        return result
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == parameterTable {
            let numberOfRows:Int = Nx
            return numberOfRows
        }
        if tableView == experimentTable {
            let numberOfRows:Int = yArray.count
            return numberOfRows
        }
        
        return 1
    }
    
}


extension ViewController: NSTableViewDelegate {
    
    fileprivate enum CellIdentifiersSelectionTable {
        static let XiCell = "XiID"
        static let DXCell = "DXID"
        static let XMinCell = "XMinID"
        static let X0Cell = "X0ID"
        static let XMaxCell = "XMaxID"
    }
    
    fileprivate enum CellIdentifiersDetectionTable {
        static let TwoCell = "2ID"
        static let X0Cell = "X0ID"
        static let X1Cell = "X1ID"
        static let X2Cell = "X2ID"
        static let X1X2Cell = "X1X2ID"
        static let Y1Cell = "Y1ID"
        static let Y2Cell = "Y2ID"
        static let Y3Cell = "Y3ID"
        static let Y4Cell = "Y4ID"
        static let YCell = "YID"
        static let DCell = "DID"
        static let BCell = "BID"
        static let TCell = "TID"
        static let TstudCell = "TstudID"
        static let ResultCell = "ResultID"
    }
    
    fileprivate enum CellIdentifiersSpearmanTable {
        static let ValueCell = "ValueID"
        static let QuantilCell = "QuantilID"
        static let ResultCell = "ResultID"
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == parameterTable {
            return loadSelection(tableView, viewFor: tableColumn, row: row)
        }
        if tableView == experimentTable {
            return loadExper(tableView, viewFor: tableColumn, row: row)
        }
        
        if tableView == resultsTable {
            return self.loadPirsonTest(tableView, viewFor: tableColumn, row: row)
        }
        return nil
    }
    
    func loadSelection(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        
        if fileModels.count > 0 {
            var text: String = ""
            var cellIdentifier: String = ""
            
            if tableColumn == tableView.tableColumns[0] {
                text = "\(row + 1)"
                cellIdentifier = CellIdentifiersSelectionTable.XiCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(ArrayHelper.findDx(array: fileModels, iParam: row).rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSelectionTable.DXCell
            } else if tableColumn == tableView.tableColumns[2] {
                    text = "\(ArrayHelper.findMin(array: fileModels, iParam: row).rounded(toPlaces: 6))"
                    cellIdentifier = CellIdentifiersSelectionTable.XMinCell
            } else if tableColumn == tableView.tableColumns[3] {
                text = "\(ArrayHelper.findAv(array: fileModels, iParam: row).rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSelectionTable.XMinCell
            } else if tableColumn == tableView.tableColumns[4] {
                text = "\(ArrayHelper.findMax(array: fileModels, iParam: row).rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSelectionTable.XMinCell
            }
            
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }
            
        }
        return nil
    }
    
    func loadExper(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {

        if yArray.count > 0 {
            var text: String = ""
            var cellIdentifier: String = ""

            if tableColumn == tableView.tableColumns[0] {
                text = "\(row + 1)"
                cellIdentifier = CellIdentifiersDetectionTable.TwoCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "+"
                cellIdentifier = CellIdentifiersDetectionTable.X0Cell
            } else if tableColumn == tableView.tableColumns[2] {
                if xArray[row][1] == 1 {
                    text = "+"
                } else {
                    text = "-"
                }
                text1 = text
                    cellIdentifier = CellIdentifiersDetectionTable.X1Cell
            }  else if tableColumn == tableView.tableColumns[3] {
                if xArray[row][2] == 1 {
                    text = "+"
                } else {
                    text = "-"
                }
                text2 = text
                cellIdentifier = CellIdentifiersDetectionTable.X2Cell
            } else if tableColumn == tableView.tableColumns[4] {
                if xArray[row][3] == 1 {
                    text = "+"
                } else {
                    text = "-"
                }
                cellIdentifier = CellIdentifiersDetectionTable.X1X2Cell
            } else if tableColumn == tableView.tableColumns[5] {
                text = "\(yArray[row][0])"
                cellIdentifier = CellIdentifiersDetectionTable.Y1Cell
            } else if tableColumn == tableView.tableColumns[6] {
                text = "\(yArray[row][1])"
                cellIdentifier = CellIdentifiersDetectionTable.Y2Cell
            } else if tableColumn == tableView.tableColumns[7] {
                text = "\(yArray[row][2])"
                cellIdentifier = CellIdentifiersDetectionTable.Y3Cell
            } else if tableColumn == tableView.tableColumns[8] {
                text = "\(yArray[row][3])"
                cellIdentifier = CellIdentifiersDetectionTable.Y4Cell
            } else if tableColumn == tableView.tableColumns[9] {
                text = "\(yAvArray[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersDetectionTable.YCell
            } else if tableColumn == tableView.tableColumns[10] {
                text = "\(dArray[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersDetectionTable.DCell
            } else if tableColumn == tableView.tableColumns[11] {
                text = "\(bArray[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersDetectionTable.BCell
            } else if tableColumn == tableView.tableColumns[12] {
                text = "\(tArray[row].rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersDetectionTable.TCell
            } else if tableColumn == tableView.tableColumns[13] {
                text = "\(Tstud.rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersDetectionTable.TstudCell
            } else if tableColumn == tableView.tableColumns[14] {
                if tArray[row] > Tstud {
                    text = "+"
                } else {
                    text = "-"
                }
                cellIdentifier = CellIdentifiersDetectionTable.ResultCell
            }

            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
                cell.textField?.stringValue = text
                return cell
            }

        }
        return nil
    }

    func loadPirsonTest(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSTableCellView? {
        var text: String = ""
        var cellIdentifier: String = ""
        if dAd != 0 {
            let N: Double = Double(bArray.count)
            let p: Double = Double(yArray[0].count)

            if tableColumn == tableView.tableColumns[0] {
                text = "\(dAd.rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSpearmanTable.ValueCell
            } else if tableColumn == tableView.tableColumns[1] {
                text = "\(Quantil.FisherQuantil(p: 0.05, v1: N * (p - 1), v2: p - 1).rounded(toPlaces: 6))"
                cellIdentifier = CellIdentifiersSpearmanTable.QuantilCell
            } else if tableColumn == tableView.tableColumns[2] {
                if dAd <= Quantil.FisherQuantil(p: 0.05, v1: N * (p - 1), v2: p - 1) {
                    text = "Match"
                } else {
                    text = "Doesn't match"
                }
                cellIdentifier = CellIdentifiersSpearmanTable.ResultCell
            }
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
}



