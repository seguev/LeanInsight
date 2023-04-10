//
//  ResultViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

class ResultViewController: UIViewController {
    
  
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    @IBOutlet weak var categoryLabelBackground: UIView!
    /**
     is being set from previous VC
     */
    var result : Double!
    
    var gender : Gender = .Male
    
    var vm = WeeklyWeightViewModel()
//    var fatClass : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        
        if checkIfValidResult(result) {
            updateFatLabel()
            handleClassification()
        } else {
            handleWrongParameters()
        }
        
    }
    
    private func initialSetup () {
        addGradient(view: view)
        categoryLabel.clipsToBounds = true
        categoryLabelBackground.layer.cornerRadius = 15
    }
    

    
    /**
     Checks if result(String) can be converted to Float, and that the float is in range for classification.
     */
    private func checkIfValidResult (_ r : Double ) -> Bool {
        
        switch gender {
        case .Male:
            if r < 2 {return false}
        case .Female:
            if r < 10 {return false}
        }
        return true
    }
    
    private func updateFatLabel () {
        resultLabel.text = String(format: "%.1f", result)
    }
    

    
    private func handleClassification () {
            
            var classificationInfo:(classification: String, color: UIColor)!
            
            switch gender {
            case .Male:
                classificationInfo = vm.fetchFatClassification(gender: .Male, fat: result)
            case .Female:
                classificationInfo = vm.fetchFatClassification(gender: .Female, fat: result)
            }
            
            
            categoryLabelBackground.backgroundColor = classificationInfo.color
            
            categoryLabel.text = classificationInfo!.classification
//            fatClass = classificationInfo!.classification
        
    }
    
    
    
    private func handleWrongParameters () {
        categoryLabel.isHidden = true
        resultLabel.text = "Error"
        let errorAlert = UIAlertController(title: "wrong parameters", message: "Your result doesn't make sense! please enter your measurements again.", preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "Try again", style: .destructive, handler: { _ in
            self.navigationController?.popViewController(animated: true)
        }))
        present(errorAlert, animated: true)
    }
    
    @IBAction func savePressed(_ sender: UIButton) {
        guard let result = result else {return}
        
        touchFeedback()
        
        NotificationCenter.default.post(name: fatUpdateNotification, object: nil,userInfo: ["fat":result])
        NotificationCenter.default.post(name: updateStatsNotification, object: nil)
        
        navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func againPressed(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}
