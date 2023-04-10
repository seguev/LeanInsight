//
//  QuizViewModel.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

struct QuizViewModel {
    
    let noDataString : String = "Set"
    
    func floatingViewSetup (_ views:[UIView]) {
        for view in views {
            view.layer.shadowOpacity = 0.4
            view.layer.shadowOffset = .init(width: 2, height: 2)
            view.layer.shadowRadius = 4
            view.backgroundColor = viewsColor
            view.layer.cornerRadius = 5
        }
        
    }
    
    func setLabelWithNoVal (_ label:UILabel) {
        label.text = noDataString //should match VC.prepare String
        label.layer.shadowOffset = .init(width: 2, height: 2)
        label.layer.shadowOpacity = 0.5
        label.textColor = .systemRed
    }
    
    func initialButtonSetup (_ button:UIButton) {
        button.configuration?.background.cornerRadius = 15
        button.tintColor = backgroundColor
        button.configuration?.background.backgroundColor = buttonsColor
        button.layer.shadowOpacity = 0.4
        button.layer.shadowOffset = .init(width: 2, height: 2)
        button.layer.shadowRadius = 4
    }
    
    func updateValueLabel (labels:[UILabel]) {
        let userInfo = SettingsViewModel.shared
        
        if let age = userInfo.age {
            labels[0].text = String(age)
        } else {
            setLabelWithNoVal(labels[0])
        }
        if let height = userInfo.height {
            switch userInfo.system {
            case .Metric:
                labels[1].text = String(format: "%.2f", height.value)
            case .Imperial:
                let imperialHeight = height.converted(to: .feet).description
                labels[1].text = imperialHeight
            }
        } else {
            setLabelWithNoVal(labels[1])
        }
        if let activityLevel = userInfo.activityLevel {
            labels[2].text = activityLevel.rawValue
        } else {
            setLabelWithNoVal(labels[2])
        }
        
        
    }
    
    func setValueToLabel (kindOfValue:PopUpKind, value:String, labels:[UILabel]) {
        
        let updatedLabel : UILabel!
        switch kindOfValue {
        case .age:
            updatedLabel = labels[0]
        case .height:
            updatedLabel = labels[1]
        case .activityLevel:
            updatedLabel = labels[2]
        }
        updatedLabel.text = value
        updatedLabel.layer.shadowOpacity = 0
        updatedLabel.textColor = textColor
    }
    
    func titleSetup (containerLabels:[UILabel]) {
        
        for i in 0..<containerLabels.count {
            containerLabels[i].text = ChangableSetting.allCases[i].rawValue
        }
    }
    
    func touchAnimation (_ button:UIButton) {
        let touch = UIImpactFeedbackGenerator()
        touch.prepare()
        touch.impactOccurred(intensity: 0.5)
        let previousSetup = button.layer.shadowOffset
        UIView.animate(withDuration: 0.2) {
            button.layer.shadowOffset = .init(width: 1, height: 1)
        } completion: { done in
            UIView.animate(withDuration: 0.2) {
                button.layer.shadowOffset = previousSetup
            }
        }
    }
    
    
    
    
}
