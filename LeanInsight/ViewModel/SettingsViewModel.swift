//
//  SettingsViewModel.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

struct SettingsViewModel {
    
    static var shared = SettingsViewModel()
    
    ///Height, Age, ActivityLevel != nil
    var isAllDataAvailable : Bool {
        if height != nil, age != nil && activityLevel != nil {
            return true
        } else {
            return false
        }
    }
    
    /**
        Being saved as a Float after being converted to meters
     */
    var height : Measurement<UnitLength>? {
        get {
            let height = UserDefaults.standard.float(forKey: "height")
            if height != 0 { //height is saved
                return .init(value: Double(height), unit: .meters)
            } else { //no saved height
                return nil
            }
        }
        set {
            if let newValue {
                let height = newValue.converted(to: .meters).value.decimalRound()
                UserDefaults.standard.set(Float(height), forKey: "height")
            }
        }
    }
    
    var age : Int? {
        get {
            let age = UserDefaults.standard.integer(forKey: "age")
            if age != 0 { //age is saved
                return age
            } else { //no saved age
                return nil
            }
        }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: "age")
            }
        }
    }

    /**
     Default == false (Metric)
     */
    var system : System {
        get {
            if UserDefaults.standard.bool(forKey: "isImperial") == true {
                return .Imperial
            } else {
                return .Metric
            }
        }
        set {
            UserDefaults.standard.set(newValue == .Imperial, forKey: "isImperial")
        }
    }
    
    /**
     Default == false (Male)
     */
    var gender : Gender {
        get {
            if UserDefaults.standard.bool(forKey: "isFemale") == true {
                return .Female
            } else {
                return .Male
            }
        }
        set {
            UserDefaults.standard.set(newValue == .Female, forKey: "isFemale")
        }
    }
    
    /**
     Default == false (Male)
     */
    var activityLevel : ActivityLevel? {
        get {
            if let level = UserDefaults.standard.string(forKey: "activityLevel") {
                return ActivityLevel(rawValue: level)
            } else {
                return nil
            }
        }
        set {
            if let newValue {UserDefaults.standard.set(newValue.rawValue, forKey: "activityLevel")
            }
        }
    }


    
    func cellSegmentedControl (_ items:[String]) -> UISegmentedControl {
       let segmentedControl = UISegmentedControl(items: items)
       segmentedControl.isUserInteractionEnabled = true
       segmentedControl.selectedSegmentIndex = 0
       return segmentedControl
   }
   

    func systemSegmentedControl (_ items:[String]) -> UISegmentedControl{
       let segmentedControl = UISegmentedControl(items: items)
       segmentedControl.isUserInteractionEnabled = true
       segmentedControl.selectedSegmentIndex = 0
       return UISegmentedControl()
   }
    
    func handleSegmentedControlInitialSelection (_ sg:UISegmentedControl) {
        switch sg.tag {
        case 0 : //System
            let isImperial = UserDefaults.standard.bool(forKey: "isImperial") //check if theres a saved value
            if isImperial {sg.selectedSegmentIndex = 1} //if the saved falue is female set as initial selection
            else {sg.selectedSegmentIndex = 0}
        case 1: //Gender
            let isFemale = UserDefaults.standard.bool(forKey: "isFemale")
            if isFemale {sg.selectedSegmentIndex = 1}
            else {sg.selectedSegmentIndex = 0}
        default:
            fatalError("Missed one \(#function)")
        }
    }
    func setCellConstrains (to subView:UIView, cell:UITableViewCell) {
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subView.heightAnchor.constraint(equalTo: cell.heightAnchor, multiplier: 0.7),
            subView.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            subView.widthAnchor.constraint(equalToConstant: 150),
            subView.trailingAnchor.constraint(equalTo: cell.trailingAnchor,constant: -10)
        ])
        cell.bringSubviewToFront(subView)
    }
    
}
