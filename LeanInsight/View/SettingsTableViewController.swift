//
//  SettingsTableViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

/**Keys: (kind, value) : String*/
let settingsChangedNotification = Notification.Name("settingsChanged")
class SettingsTableViewController: UITableViewController {

    
    let vm = SettingsViewModel()
    
    var selectedKind : PopUpKind!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(saveNewSetting(_:)), name: settingsChangedNotification, object: nil)
    }
    /**
     Keys: (kind, value) : String
     */
    @objc private func saveNewSetting (_ sender:Notification) {
        guard let kindStr = sender.userInfo?["kind"] as? String else {return}
        guard let value = sender.userInfo?["value"] as? String else {return}
        
        let kind = PopUpKind(rawValue: kindStr)
        
        switch kind {
        case .height: //row 2
            switch SettingsViewModel.shared.system {
                
            case .Metric:
                guard let v = Double(value)?.decimalRound() else {fatalError()}
                SettingsViewModel.shared.height = Measurement<UnitLength>.init(value: v, unit: .meters)
                
                updateRow(.height)
            case .Imperial:
                 //value (e.g - "5\'11"") -> inches e.g 77.59999 -> round - 77.6
                let inchesFromFeetInDouble = Double(CalculatorViewModel().feetToInches(value)).decimalRound()
                let inchesFromFeet = Measurement<UnitLength>.init(value: inchesFromFeetInDouble, unit: .inches)
                SettingsViewModel.shared.height = inchesFromFeet
                
                updateRow(.height)
            }
            
        case .age: //row 3
            let age = Int(value)!
            SettingsViewModel.shared.age = age
            updateRow(.age)
        case .activityLevel: //row 4
            guard let acticityLevel = ActivityLevel(rawValue: value ) else {fatalError()}
            SettingsViewModel.shared.activityLevel = acticityLevel
            updateRow(.activityLevel)
        default:
            fatalError("missed one! \(kindStr)")
        }
        
        
    }
    
    private func updateRow(_ rowKind:PopUpKind) {
        switch rowKind {
        case .height:
            tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .fade)
        case .age:
            tableView.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .fade)
        case .activityLevel:
            tableView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .fade)
        }
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return UserStats.allCases.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        super.tableView(tableView, cellForRowAt: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        
        cell.textLabel?.text = UserStats.allCases[indexPath.row].rawValue
        cell.backgroundColor = backgroundColor
        
        
        
        if indexPath.row == 0 {
            
            let segmentedControl = vm.cellSegmentedControl(System.allCases.map{$0.rawValue})
            segmentedControl.addTarget(self, action: #selector(segmentedChaged(_:)), for: .valueChanged)
            segmentedControl.tag = 0
            cell.addSubview(segmentedControl)
            vm.setCellConstrains(to: segmentedControl, cell: cell)
            vm.handleSegmentedControlInitialSelection(segmentedControl)
        } else if indexPath.row == 1 {
        
            
            let segmentedControl = vm.cellSegmentedControl(Gender.allCases.map{$0.rawValue})
            segmentedControl.addTarget(self, action: #selector(segmentedChaged(_:)), for: .valueChanged)
            segmentedControl.tag = 1
            cell.addSubview(segmentedControl)
            vm.setCellConstrains(to: segmentedControl, cell: cell)
            vm.handleSegmentedControlInitialSelection(segmentedControl)
        } else if indexPath.row == 2 {
            
            cell.accessoryType = .disclosureIndicator
            
            if let savedHeight = SettingsViewModel.shared.height {
                
                switch SettingsViewModel.shared.system {
                case .Metric:
                    cell.detailTextLabel?.text = String(format: "%.2f", savedHeight.value)
                case .Imperial:
                    let savedInches = savedHeight.converted(to: .inches)
                    print(savedInches)
                    let feetFromSavedInches = CalculatorViewModel().fromInchesToFeet(height: savedInches)
                    print(feetFromSavedInches)
                    cell.detailTextLabel?.text = feetFromSavedInches
                }
                

            } else {
                cell.detailTextLabel?.text = "No height"
            }
        } else if indexPath.row == 3 {
            
            
            cell.accessoryType = .disclosureIndicator
            
            if let savedAge = SettingsViewModel.shared.age {
                cell.detailTextLabel?.text = String(savedAge)
            } else {
                cell.detailTextLabel?.text = "No age"
            }
        } else if indexPath.row == 4 {
            
            cell.accessoryType = .disclosureIndicator
            if let savedLevel = SettingsViewModel.shared.activityLevel {
                cell.detailTextLabel?.text = savedLevel.rawValue
            } else {
                cell.detailTextLabel?.text = "No activity level"
            }
        
        }
        
        return cell
    }



    
    @objc private func segmentedChaged (_ sender:UISegmentedControl) {
        
        switch sender.tag {
        case 0: //System
            print("case 0")
            let isImperial = sender.selectedSegmentIndex == 1
            if isImperial {
                SettingsViewModel.shared.system = .Imperial
            } else {
                SettingsViewModel.shared.system = .Metric
            }
            tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .fade)

        case 1: //Gender
            print("case 1")
            let isFemale = sender.selectedSegmentIndex == 1
            if isFemale {
                SettingsViewModel.shared.gender = .Female
            } else {
                SettingsViewModel.shared.gender = .Male
            }
        default:
            fatalError("Missed one! \(#function)")
        }
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row > 1 {
            print(UserStats.allCases[indexPath.row].rawValue)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        case 2:
            selectedKind = .height
            performSegue(withIdentifier: "showPopUp", sender: self)
        case 3:
            selectedKind = .age
            performSegue(withIdentifier: "showPopUp", sender: self)
        case 4:
            selectedKind = .activityLevel
            performSegue(withIdentifier: "showPopUp", sender: self)
            
        default:
            fatalError("missed one \(#function)")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPopUp" {
            let destinationVC = segue.destination as! SettingPopupViewController
            destinationVC.kind = selectedKind
            
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: updateStatsNotification, object: nil)
    }
    override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row < 2 {
            return false
        } else {
            return true
        }
    }
    
}






