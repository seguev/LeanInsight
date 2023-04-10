//
//  TapeCalculatorViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

class TapeCalculatorViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var ageLable: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    @IBOutlet weak var fifthLabel: UILabel!
    
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var fourthTextField: UITextField!
    @IBOutlet weak var fifthTextField: UITextField!
    @IBOutlet weak var systemSegmentedControl: UISegmentedControl!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    var model = TapeCalcModel()
    var infoLabel : UILabel?
    var system : System = SettingsViewModel.shared.system
    
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
        
        genderSegmentedControl.selectedSegmentIndex = SettingsViewModel.shared.gender == .Female ? 1 : 0
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
        } else if sender.selectedSegmentIndex == 1 {
            setFemaleLabels()
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
        firstTextField.placeholder = "Years"
        secondTextField.placeholder = system == .Imperial ? "Inches" : "Centimeters"
        thirdTextField.placeholder = system == .Imperial ? "Inches" : "Centimeters"
        fourthTextField.placeholder = system == .Imperial ? "Inches" : "Centimeters"
        fifthTextField.placeholder = system == .Imperial ? "Inches" : "Centimeters"
    }
    
    
    func setMaleLabels () {
        print("male has been set")
        secondLabel.text = "Hips"
        thirdLabel.text = "Waist"
        fourthLabel.text = "Forearm"
        fifthLabel.text = "Wrist"
    }
    
    func setFemaleLabels () {
        secondLabel.text = "Hips"
        thirdLabel.text = "Thigh"
        fourthLabel.text = "Calf"
        fifthLabel.text = "Wrist"
    }
    
    // MARK: - textField delegate funcs
    /**
     when end editing, saves data as the appropriate variable
     */
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        let unit : UnitLength = system == .Metric ? .centimeters : .inches
        
        if let availableText = textField.text, availableText != ""{
            guard let tDouble = Double(availableText) else {fatalError("this is weird")}
            switch textField.restorationIdentifier{
            case "1":
                model.age = Int(availableText)
            case "2":
                model.hips = .init(value: tDouble, unit: unit)
            case "3":
                model.waistAndThigh = .init(value: tDouble, unit: unit)
            case "4":
                model.forarmAndCalf = .init(value: tDouble, unit: unit)
            case "5":
                model.wrist = .init(value: tDouble, unit: unit)
            default:
                print("da fuck did you just do")
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
        if let safeAge = model.age,
           let safeHips = model.hips,
           let safeWaistOrThigh = model.waistAndThigh,
           let safeForearmOrCalf = model.forarmAndCalf,
           let safeWrist = model.wrist {
            
            if model.gender == .Male {
                model.fatPercentage = calc.calculateBodyFatPercentageWithTape(gender: .Male, age: safeAge, hip: safeHips, waistOrThigh: safeWaistOrThigh, calfOrForearm: safeForearmOrCalf, wrist: safeWrist)

                
            } else if model.gender == .Female {
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
        destinationVC.gender = model.gender
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
        fourthTextField,
        fifthTextField]
    }
    
    
}
