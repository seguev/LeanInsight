//
//  QuizViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

class QuizViewController: UIViewController {

    @IBOutlet weak var firstContainerView: UIView!
    @IBOutlet weak var secondContainerView: UIView!
    @IBOutlet weak var thirdContainerView: UIView!
    @IBOutlet weak var firstContainerTitle: UILabel!
    @IBOutlet weak var secondContainerTitle: UILabel!
    @IBOutlet weak var thirdContainerTitle: UILabel!
    @IBOutlet weak var firstContainerLabel: UILabel!
    @IBOutlet weak var secondContainerLabel: UILabel!
    @IBOutlet weak var thirdContainerLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    var popUpKind : PopUpKind?
    
    let vm = QuizViewModel()
    
    lazy var containerViews = [firstContainerView!,secondContainerView!,thirdContainerView!]
    lazy var titles = [firstContainerTitle!,secondContainerTitle!,thirdContainerTitle!]
    lazy var containerLabels = [firstContainerLabel!,secondContainerLabel!,thirdContainerLabel!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.floatingViewSetup(containerViews)
        
        vm.initialButtonSetup(button)

        vm.titleSetup(containerLabels: titles)
         
        vm.updateValueLabel(labels: containerLabels)
        
        for label in containerLabels {
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPopUp(_:))))
            label.isUserInteractionEnabled = true
        }
         
         NotificationCenter.default.addObserver(self, selector: #selector(newValueHasBeenSet(_:)), name: settingsChangedNotification, object: nil)
    }
    
    @objc private func newValueHasBeenSet (_ notification:Notification) {
        guard let kindStr = notification.userInfo?["kind"] as? String,
              let kind = PopUpKind(rawValue: kindStr),
              let newValue = notification.userInfo?["value"] as? String
        else {fatalError("Weird kind!")}
        
        vm.setValueToLabel(kindOfValue: kind, value: newValue,labels: containerLabels)
    }
    
    /**
     Set global kind before calling this func
     */
    @objc private func showPopUp (_ sender:UITapGestureRecognizer) {
        
        if sender.view == firstContainerLabel {
            self.popUpKind = PopUpKind.allCases[0]
            performSegue(withIdentifier: "toPopUp", sender: sender)
            
        } else if sender.view == secondContainerLabel {
            self.popUpKind = PopUpKind.allCases[1]
            performSegue(withIdentifier: "toPopUp", sender: sender)
            
        } else if sender.view == thirdContainerLabel {
            self.popUpKind = PopUpKind.allCases[2]
            performSegue(withIdentifier: "toPopUp", sender: sender)
            
        } else {
            fatalError("Missed a label! \(sender.view!)")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let kind = popUpKind else {fatalError("self.popUpKind == nil!")}
        
        let selectedLabelText = ((sender as! UITapGestureRecognizer).view as! UILabel).text
        
        if segue.identifier == "toPopUp" {
            let destinationVC = segue.destination as! SettingPopupViewController
            destinationVC.kind = kind
            
            if selectedLabelText != vm.noDataString {
                destinationVC.initialValue = selectedLabelText
            }
        }
    }
    

    @IBAction func savePressed(_ sender: UIButton) {
        vm.touchAnimation(sender)
        
        updateUserDefault()

        guard SettingsViewModel.shared.isAllDataAvailable else {return}


        NotificationCenter.default.post(name: updateStatsNotification, object: nil)
        
        navigationController?.popViewController(animated: true)
    }
    
    private func updateUserDefault () {
        
        let ageString = firstContainerLabel.text!
        let heightString = secondContainerLabel.text!
        let activityString = thirdContainerLabel.text!
        SettingsViewModel.shared.age = Int(ageString)
        SettingsViewModel.shared.activityLevel = ActivityLevel(rawValue: activityString)
        
        saveHeight(heightString)

    }
    
    private func saveHeight (_ heightString:String) {
        switch SettingsViewModel.shared.system {
        case .Metric:
//            #error("fix!")
            guard let heightDouble = Double(heightString) else {
                sendErrorFeedback()
                return
            }
            
            let height = Measurement<UnitLength>.init(value: heightDouble, unit: .meters)
            SettingsViewModel.shared.height = height
        case .Imperial:
            let heightInInches = CalculatorViewModel().feetToInches(heightString)
            
            let height = Measurement<UnitLength>.init(value: Double(heightInInches), unit: .inches)
            SettingsViewModel.shared.height = height
            
        }
    }
}
