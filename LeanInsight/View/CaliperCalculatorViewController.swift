//
//  CaliperCalculatorViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

class CaliperCalculatorViewController: UIViewController, UITextFieldDelegate, MyToolBarDelegate {

    
    @IBOutlet weak var firstLabel: UILabel!
    @IBOutlet weak var secondLabel: UILabel!
    @IBOutlet weak var thirdLabel: UILabel!
    @IBOutlet weak var fourthLabel: UILabel!
    @IBOutlet weak var firstTextField: UITextField!
    @IBOutlet weak var secondTextField: UITextField!
    @IBOutlet weak var thirdTextField: UITextField!
    @IBOutlet weak var fourthTextField: UITextField!
    
    var model = CaliperCalcModel()
    var infoLabel : UILabel?
    let calc = CalculatorViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        addToolBar()
//        toolBalSetup(textFields: [firstTextField,secondTextField ,thirdTextField ,fourthTextField])
        
        addGradient(view: view)
        
        closeTextFieldsWhenTappedAround()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideLabel)))
    }
    
    func allOfMyTextFields() -> [UITextField] {
        [firstTextField,
         secondTextField,
         thirdTextField,
         fourthTextField]
    }
    
    /* replaces with protocol
    private func toolBalSetup (textFields : [UITextField]) {
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        //items
        let first = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), style: .plain, target: self, action: #selector(goToPreviousTextField(_:)))
        let second = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .plain, target: self, action: #selector(goToNextTextField(_:)))
        let third = UIBarButtonItem(systemItem: .flexibleSpace)
        let fourth = UIBarButtonItem(systemItem: .done, primaryAction: UIAction(handler: {_ in self.view.endEditing(true)}))
        toolbar.items = [first,second,third,fourth]
        
        
        for textField in textFields {
            textField.inputAccessoryView = toolbar
        }
    }
    @objc private func goToNextTextField (_ sender:UIBarButtonItem) {
        
        if firstTextField.isFirstResponder {
            secondTextField.becomeFirstResponder()
            secondTextField.text = ""
        } else if secondTextField.isFirstResponder {
            thirdTextField.becomeFirstResponder()
            thirdTextField.text = ""
        } else if thirdTextField.isFirstResponder {
            fourthTextField.becomeFirstResponder()
            fourthTextField.text = ""
        } else if fourthTextField.isFirstResponder {
            firstTextField.becomeFirstResponder()
            firstTextField.text = ""
        }
    }
    @objc private func goToPreviousTextField (_ sender:UIBarButtonItem) {
        if firstTextField.isFirstResponder {
            fourthTextField.becomeFirstResponder()
            fourthTextField.text = ""
        } else if secondTextField.isFirstResponder {
            firstTextField.becomeFirstResponder()
            firstTextField.text = ""
        } else if thirdTextField.isFirstResponder {
            secondTextField.becomeFirstResponder()
            secondTextField.text = ""
        } else if fourthTextField.isFirstResponder {
            thirdTextField.becomeFirstResponder()
            thirdTextField.text = ""
        }
    }
    */
    
    @objc func hideLabel () {
        view.endEditing(true)
        if let infoLabel {
            infoLabel.removeFromSuperview()
        }
    }
    func changeLabelsToMale () {
        firstLabel.text = "Age"
        secondLabel.text = "Chest"
        thirdLabel.text = "Abdominal"
        fourthLabel.text = "Mid thigh"
        
    }
    
    func changeLabelsToFemale () {
        firstLabel.text = "Age"
        secondLabel.text = "Triceps"
        thirdLabel.text = "Suprailiac"
        fourthLabel.text = "Mid thigh"
        
    }
    
    
    /**
     toggle male and female
     - male index is 0
     - female index is 1
     */
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            changeLabelsToMale()
            model.gender = .Male
        } else if sender.selectedSegmentIndex == 1 {
            changeLabelsToFemale()
            model.gender = .Female
        }
    }
    
    
    
    
    private func closeTextFieldsWhenTappedAround () {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
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
            switch textField.restorationIdentifier{
            case "1":
                model.age = tInt
            case "2":
                model.genderUniqueFold = tInt
            case "3":
                model.abdominalFold = tInt
            case "4":
                model.thighFold = tInt
                
            default:
                print("da fuck did you just do")
            }
        }
        return true
    }
    
    
    @IBAction func calculatePressed(_ sender: UIButton) {
        view.endEditing(true) //end editing for all textfields and save values
        
        if let safeAge = model.age,
           let safeGenderUniqueFold = model.genderUniqueFold,
           let safeAbdominalFold = model.abdominalFold,
           let safeThighFold = model.thighFold {
            
            if model.gender == .Male {
                model.fatPercentage = calc.calcMenBodyFat(age: safeAge,
                                                          chest: safeGenderUniqueFold,
                                                          abdominal: safeAbdominalFold,
                                                          thigh: safeThighFold
                )
            } else if model.gender == .Female {
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
        destinationVC.gender = model.gender
    }
    
    
    @IBAction func infoPressed(_ sender: UIButton) {
        let info = InfoModel()
        if let infoLabel {infoLabel.removeFromSuperview()}
        
        switch sender.tag {
        case 0:
            if model.gender == .Male {
                infoLabel = info.showInfoLabel(view, text: info.caliperMaleInfo.Chest,top: true)
            } else if model.gender == .Female {
                infoLabel = info.showInfoLabel(view, text: info.caliperFemaleInfo.Tricep,top: true)
            }
        case 1:
            if model.gender == .Male {
                infoLabel = info.showInfoLabel(view, text: info.caliperMaleInfo.Abdominal,top: true)
            } else if model.gender == .Female {
                infoLabel = info.showInfoLabel(view, text: info.caliperFemaleInfo.Suprailiac,top: true)
            }
        case 2:
            if model.gender == .Male {
                infoLabel = info.showInfoLabel(view, text: info.caliperMaleInfo.Thigh,top: true)
            } else if model.gender == .Female {
                infoLabel = info.showInfoLabel(view, text: info.caliperFemaleInfo.Thigh,top: true)
            }
        default:
            fatalError()
        }
    }
    
    
    
}





