//
//  TapeCalculatorViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

class TapeCalculatorViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var fourthTextField: UITextField!
    @IBOutlet weak var systemSegmentedControl: UISegmentedControl!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    var model = TapeCalcModel()
    var infoLabel : UILabel?
    
    var system : System = SettingsViewModel.shared.system
    
    var gender = SettingsViewModel.shared.gender
    
    let calc = CalculatorViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(screenPressed)))
        
        addToolBar()
        addGradient(view: view)
        updatePlaceHolders()
        setSegmentedControlInitialValue()
    }
    
    private func setSegmentedControlInitialValue () {
        
        systemSegmentedControl.selectedSegmentIndex = system == .Metric ? 1 : 0
        
        genderSegmentedControl.selectedSegmentIndex = gender == .Female ? 1 : 0
    }
    
    @objc private func screenPressed () {
        view.endEditing(true)
        if let infoLabel {
            infoLabel.removeFromSuperview()
        }
    }
    
    @IBAction func genderChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            setMaleLabels()
            gender = .Male
        } else if sender.selectedSegmentIndex == 1 {
            setFemaleLabels()
            gender = .Female
        }
    }
    
    @IBAction func systemChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            system = .Imperial
        case 1:
            system = .Metric
        default:
            fatalError()
        }
        updatePlaceHolders()
    }
    
    private func updatePlaceHolders () {
        firstTextField.placeholder = system == .Imperial ? "Inches" : "Centimeters"
        secondTextField.placeholder = system == .Imperial ? "Inches" : "Centimeters"
        thirdTextField.placeholder = system == .Imperial ? "Inches" : "Centimeters"
        fourthTextField.placeholder = system == .Imperial ? "Inches" : "Centimeters"
    }
    
    
    func setMaleLabels () {
        print("male has been set")
        firstLabel.text = "Hips"
        secondLabel.text = "Waist"
        thirdLabel.text = "Forearm"
        fourthLabel.text = "Wrist"
    }
    
    func setFemaleLabels () {
        firstLabel.text = "Hips"
        secondLabel.text = "Thigh"
        thirdLabel.text = "Calf"
        fourthLabel.text = "Wrist"
    }
    
    // MARK: - textField delegate funcs
    /**
     when end editing, saves data as the appropriate variable
     */
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        let unit : UnitLength = system == .Metric ? .centimeters : .inches
        
        if let availableText = textField.text, availableText != ""{
            guard let tDouble = Double(availableText) else {fatalError("this is weird")}
            
            switch textField.tag {
            case 0:
                model.hips = .init(value: tDouble, unit: unit)
            case 1:
                model.waistAndThigh = .init(value: tDouble, unit: unit)
            case 2:
                model.forarmAndCalf = .init(value: tDouble, unit: unit)
            case 3:
                model.wrist = .init(value: tDouble, unit: unit)
            default:
                print("switch statement missed a case")
            }
        }
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "." && textField.text!.contains(".") {
            return false
        }
        let isTooMuch = textField.text!.count > 2
        let delete = string == ""
        
        if isTooMuch && !delete {return false}
        return true
    }
    
    @IBAction func calculatePressed(_ sender: UIButton) {
        view.endEditing(true)
        if let safeAge = SettingsViewModel.shared.age,
           let safeHips = model.hips,
           let safeWaistOrThigh = model.waistAndThigh,
           let safeForearmOrCalf = model.forarmAndCalf,
           let safeWrist = model.wrist {
            
            if gender == .Male {
                model.fatPercentage = calc.calculateBodyFatPercentageWithTape(gender: .Male, age: safeAge, hip: safeHips, waistOrThigh: safeWaistOrThigh, calfOrForearm: safeForearmOrCalf, wrist: safeWrist)

                
            } else if gender == .Female {
                model.fatPercentage = calc.calculateBodyFatPercentageWithTape(gender: .Female, age: safeAge, hip: safeHips, waistOrThigh: safeWaistOrThigh, calfOrForearm: safeForearmOrCalf, wrist: safeWrist)
                
            }
        }
        if model.fatPercentage != nil {
            performSegue(withIdentifier: "tapeToResult", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ResultViewController
        destinationVC.result = model.fatPercentage
        destinationVC.gender = gender
    }
    
    @IBAction func infoPressed(_ sender: UIBarButtonItem) {
        let info = InfoModel()
        infoLabel?.removeFromSuperview()
        infoLabel = info.showInfoLabel(view, text: info.tapeInfo,top: true)
    }

    
}
extension TapeCalculatorViewController : MyToolBarDelegate {
    
    
    func allOfMyTextFields() -> [UITextField] {
        [firstTextField,
        secondTextField,
        thirdTextField,
        fourthTextField]
    }
    
    
}
