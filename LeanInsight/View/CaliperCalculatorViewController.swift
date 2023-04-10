//
//  CaliperCalculatorViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

class CaliperCalculatorViewController: UIViewController, UITextFieldDelegate, MyToolBarDelegate {

    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    
    var model = CaliperCalcModel()
    var infoLabel : UILabel?
    let calc = CalculatorViewModel()
    
    var gender = SettingsViewModel.shared.gender
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        addToolBar()
//        toolBalSetup(textFields: [firstTextField,secondTextField ,thirdTextField ,fourthTextField])
        
        addGradient(view: view)
        
        closeTextFieldsWhenTappedAround()
        
        setSegmentedControlInitialValue()
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideLabel)))
    }
    
    private func setSegmentedControlInitialValue () {
                
        genderSegmentedControl.selectedSegmentIndex = gender == .Female ? 1 : 0
    }
    
    private func closeTextFieldsWhenTappedAround () {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
    }
    // MARK: - textField funcs
    func allOfMyTextFields() -> [UITextField] {
        [firstTextField,
         secondTextField,
         thirdTextField]
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
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        if let availableText = textField.text, availableText != "" {
            guard let tInt = Int(availableText) else {fatalError("this is weird")}
            
            switch textField.tag {

            case 0:
                model.genderUniqueFold = tInt
            case 1:
                model.abdominalFold = tInt
            case 2:
                model.thighFold = tInt
                
            default:
                print("switch statement missed a case")
            }
        }
        return true
    }

    
    @objc func hideLabel () {
        view.endEditing(true)
        if let infoLabel {
            infoLabel.removeFromSuperview()
        }
    }
    
    func changeLabelsToMale () {
        firstLabel.text = "Chest"
        secondLabel.text = "Abdominal"
        thirdLabel.text = "Mid thigh"
        
    }
    
    func changeLabelsToFemale () {
        firstLabel.text = "Triceps"
        secondLabel.text = "Suprailiac"
        thirdLabel.text = "Mid thigh"
        
    }
    
    
    /**
     toggle male and female
     - male index is 0
     - female index is 1
     */
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            changeLabelsToMale()
            gender = .Male
        } else if sender.selectedSegmentIndex == 1 {
            changeLabelsToFemale()
            gender = .Female
        }
    }
    


    
    @IBAction func calculatePressed(_ sender: UIButton) {
        view.endEditing(true) //end editing for all textfields and save values
        
        if let safeAge = SettingsViewModel.shared.age,
           let safeGenderUniqueFold = model.genderUniqueFold,
           let safeAbdominalFold = model.abdominalFold,
           let safeThighFold = model.thighFold {
            
            if gender == .Male {
                model.fatPercentage = calc.calcMenBodyFat(age: safeAge,
                                                          chest: safeGenderUniqueFold,
                                                          abdominal: safeAbdominalFold,
                                                          thigh: safeThighFold
                )
            } else if gender == .Female {
                model.fatPercentage = calc.calcWomenBodyFat(age: safeAge,
                                                            triceps: safeGenderUniqueFold,
                                                            suprailiac: safeAbdominalFold,
                                                            thigh: safeThighFold
                )
            }
        }
        
        if model.fatPercentage != nil {
            performSegue(withIdentifier: "caliperToResult", sender: self)
        } else {
            print("fatPercentage is nil! \(model.fatPercentage ?? 0.0)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! ResultViewController
        destinationVC.result = model.fatPercentage
        destinationVC.gender = gender
    }
    
    
    @IBAction func infoPressed(_ sender: UIButton) {
        let info = InfoModel()
        if let infoLabel {infoLabel.removeFromSuperview()}
        
        switch sender.tag {
        case 0:
            if gender == .Male {
                infoLabel = info.showInfoLabel(view, text: info.caliperMaleInfo.Chest,top: true)
            } else if gender == .Female {
                infoLabel = info.showInfoLabel(view, text: info.caliperFemaleInfo.Tricep,top: true)
            }
        case 1:
            if gender == .Male {
                infoLabel = info.showInfoLabel(view, text: info.caliperMaleInfo.Abdominal,top: true)
            } else if gender == .Female {
                infoLabel = info.showInfoLabel(view, text: info.caliperFemaleInfo.Suprailiac,top: true)
            }
        case 2:
            if gender == .Male {
                infoLabel = info.showInfoLabel(view, text: info.caliperMaleInfo.Thigh,top: true)
            } else if gender == .Female {
                infoLabel = info.showInfoLabel(view, text: info.caliperFemaleInfo.Thigh,top: true)
            }
        default:
            fatalError()
        }
    }
    
    
    
}





