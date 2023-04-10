//
//  SettingPopupViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

class SettingPopupViewController: UIViewController {

    
    var kind : PopUpKind = .height
    
    let model = SettingsViewModel()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var picker : UIPickerView!
    @IBOutlet weak var secondLabel: UILabel!
    
    var selectedValue : String!
    var info = InfoModel()
    var initialValue : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sheetPresentationController?.detents = [.medium()]
        
        titleLabel.text = "Choose your \(kind.rawValue)"
        
        
        startFromPreviousSelection()
        
        if kind == .activityLevel {
            secondLabel.isHidden = false
            secondLabel.text = info.activityLevelInfo[0]
        }
        
    }
    
    private func startFromPreviousSelection () {
        
        switch kind {
        case .height:
            switch SettingsViewModel.shared.system {
            case .Metric:
                let array = heights()
                if let savedHeight = model.height {
                    guard let index = array.firstIndex(of: Float(savedHeight.value)) else {return}
                    picker.selectRow(index, inComponent: 0, animated: true)
                } else if let selectedLabel = initialValue {
                    guard let i = array.firstIndex(of: Float(selectedLabel)!) else {return}
                    picker.selectRow(i, inComponent: 0, animated: true)
                }
            case .Imperial:
                let array  = feet()
                if let savedHeight = model.height {
                    
                    let feet = CalculatorViewModel().fromInchesToFeet(height: savedHeight)
                    let index = array.firstIndex(of: feet)!
                    
                    picker.selectRow(index, inComponent: 0, animated: true)
                } else if let selectedLabel = initialValue {
                    guard let i = array.firstIndex(of: selectedLabel) else {return}
                    picker.selectRow(i, inComponent: 0, animated: true)
                }
            }
        
    case .age:
        let array = ages()
            if let savedAge = model.age { //if previous age has been found
                let index = array.firstIndex(of: savedAge)!
                picker.selectRow(index, inComponent: 0, animated: true)
            } else if let selectedLabel = initialValue { //an arbitrary starting value
                guard let i = array.firstIndex(of: Int(selectedLabel)!) else {return}
                picker.selectRow(i, inComponent: 0, animated: true)
            }
       
    case .activityLevel:
        let array = ActivityLevel.allCases
            if let savedLevel = model.activityLevel {
                let index = array.firstIndex(of: savedLevel)!
                picker.selectRow(index, inComponent: 0, animated: true)
            } else if let selectedLabel = initialValue {
                guard let i = array.firstIndex(of: ActivityLevel(rawValue: selectedLabel)!) else {return}
                picker.selectRow(i, inComponent: 0, animated: true)
            }
    }
        
    }
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard selectedValue != nil else {
            defaultSelection()
            saveButtonPressed(sender)
            return
        }
        
        var userInfo = [AnyHashable : Any]()
        
        userInfo["kind"] = kind.rawValue
        userInfo["value"] = selectedValue
        
        NotificationCenter.default.post(name: settingsChangedNotification, object: nil, userInfo: userInfo)
        self.dismiss(animated: true)
    }

    /**
     If picker hasn't move, choose current title .
     */
    func defaultSelection () {
        let i = picker.selectedRow(inComponent: 0)

        switch kind {
        case .height:
            switch SettingsViewModel.shared.system {
            case .Metric:
                selectedValue = String(format: "%.2f", heights()[i])
            case .Imperial:

                selectedValue = feet()[i]
            }
            
        case .age:
            selectedValue = ages()[i].description
        case .activityLevel:
            selectedValue = ActivityLevel.allCases[i].rawValue
        }
        
    }
    
}
// MARK: - Picker view funcs
extension SettingPopupViewController : UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch kind {
        case .height:
            switch SettingsViewModel.shared.system {
            case .Metric:
                return heights().count
            case .Imperial:
                return feet().count
            }

        case .age:
            return ages().count
        case .activityLevel:
            return ActivityLevel.allCases.count
            
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        self.view.frame.width * 0.8
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch kind {
        case .height :
            switch SettingsViewModel.shared.system {
            case .Metric:
                let heights = heights()
                return String(format: "%.2f", heights[row])
            case .Imperial:
                return feet()[row]
            }
            
        case .age:
            let ages = ages()
            return ages[row].description
        case .activityLevel:
            return ActivityLevel.allCases[row].rawValue
       
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch kind {
        case .height:
            switch SettingsViewModel.shared.system {
            case .Metric:
                selectedValue = String(format: "%.2f", heights()[row])
            case .Imperial:
                selectedValue = feet()[row]

            }
        case .age:
            selectedValue = String(ages()[row])
        case .activityLevel:
            selectedValue = ActivityLevel.allCases[row].rawValue
            secondLabel.text = info.activityLevelInfo[row]
        }
        
        
        
    }
}

enum PopUpKind : String, CaseIterable {
    case age = "age"
    case height = "height"
    case activityLevel = "activity Level"
    
}
