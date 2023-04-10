//
//  InfoModel.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

struct InfoModel {
    
     let tapeInfo = "All measurements should be taken at their widest points"
    
    /**
     - Chest: diagonal fold half the distance between anterior axillary line and the nipple.
     - Abdominal: vertical fold 2cm to the right of the navel.
     - Thigh: midpoint of the anterior side of the upper leg between the patella and top of thigh.
     */
     let caliperMaleInfo =
                                (Chest: "diagonal fold half the distance between anterior axillary line and the nipple.",
                                Abdominal: "vertical fold 2cm to the right of the navel.",
                                Thigh: "midpoint of the anterior side of the upper leg between the patella and top of thigh.")
                                
    
    /*(Chest:"diagonal fold half the distance between anterior axillary line and the nipple.",
                                  Abdominal:"vertical fold 2cm to the right of the navel.",
                                  Thigh:"midpoint of the anterior side of the upper leg between the patella and top of thigh.")
     */
    
    
/**
 - Tricep: vertical fold at the midpoint of the posterior side of tricep between shoulder and elbow with arm relaxed at the side.
 - Suprailiac: diagonal fold parallel and superior to the iliac crest.
 - Thigh: midpoint of the anterior side of the upper leg between the patella and top of thigh.
 */
     let caliperFemaleInfo =
                                 (Tricep: "vertical fold at the midpoint of the posterior side of tricep between shoulder and elbow with arm relaxed at the side.",
                                 Suprailiac: "diagonal fold parallel and superior to the iliac crest.",
                                 Thigh: "midpoint of the anterior side of the upper leg between the patella and top of thigh.")
                                
    let weeklyWeightInfo = "To track your progress, it's recommended that you record your body weight for at least four days per week and measure your body fat percentage at least once a week."
    
    let BMIInfo = "Although BMI is a widely used and useful indicator of healthy body weight, it does have its limitations. BMI is only an estimate that cannot take body composition into account. Due to a wide variety of body types as well as distribution of muscle, bone mass, and fat, BMI should be considered along with other measurements rather than being used as the sole method for determining a person's healthy body weight."
    
    
    let classificationByBMIInfo = """
                                    The World Health Organization (WHO) classifies BMI into the following categories:
                                    - Underweight: less than 18.5
                                    - Normal weight: 18.5 - 24.9
                                    - Overweight: 25 - 29.9
                                    - Obesity class I: 30 - 34.9
                                    - Obesity class II: 35 - 39.9
                                    - Obesity class III: BMI 40 or higher
                                    """
    
    let classificationByMenFatPercentInfo = """
                                            Essential Fat: 2-5%
                                            Athletes: 6-13%
                                            Fitness: 14-17%
                                            Acceptable: 18-24%
                                            Obese: 25% and above
                                            """
    
    let classificationByWomenFatPercentInfo = """
                                            Essential Fat: 10-13%
                                            Athletes: 14-20%
                                            Fitness: 21-24%
                                            Acceptable: 25-31%
                                            Obese: 32% and above
                                            """
    
    
    let tdeeInfo = "Your TDEE (Total Daily Energy Expenditure) tells you exactly how much you need to eat daily to maintain weight."
    
    let bodyFatInfo = "Body fat percentage (BFP) is a good indicator of your body composition and indicates the amount of fat you have in your body."
    
    let calDefInfo = (text:"deficits of 300–500 calories per day have been used for weight loss and are recommended by many obesity societies and guidelines.",
                      PMIDs: 31089578,30589999,29156187,25877119)
    
    let calPlusInfo = "For muscle gains to occur, a sufficient calorie surplus is required, usually 10–20% additional calories for most people. 'Dirty bulking' usually exceeds this range, thus likely contributing to sizable muscle and strength gains for most people when combined with a proper resistance training regime."
    
    
    func showInfoLabel (_ view:UIView, text:String, top:Bool) -> UILabel {
        //        let infoLabel = UILabel(frame: .init(origin: .zero, size: .init(width: 300, height: 120)))
        
        let infoLabel = UILabel()
        infoLabel.backgroundColor = textColor
        infoLabel.numberOfLines = 0
        infoLabel.layer.cornerRadius = 6
        infoLabel.alpha = 0.9
        infoLabel.textColor = backgroundColor
        infoLabel.textAlignment = .center
        infoLabel.clipsToBounds = true
        infoLabel.center = .init(x: view.center.x, y: view.center.y + 50)
        infoLabel.text = text
        infoLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(infoLabel.removeFromSuperview)))
        view.addSubview(infoLabel)
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        if top {
            NSLayoutConstraint.activate([
                infoLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                infoLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
                infoLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8)
            ])
        } else {
            NSLayoutConstraint.activate([
                infoLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
                infoLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0),
                infoLabel.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8)
            ])
        }
        animateLabelIn(infoLabel)
        
        Timer.scheduledTimer(withTimeInterval: 6, repeats: false) { _ in
            infoLabel.removeFromSuperview()
        }
        return infoLabel
    }
    
    private func animateLabelIn (_ label:UILabel) {
        label.transform = .init(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.05) {
            label.transform = .init(scaleX: 1.1, y: 1.1)
        } completion: { done in
            UIView.animate(withDuration: 0.1) {
                label.transform = .init(scaleX: 1, y: 1)
            }
        }
    }

    
    let activityLevelInfo = ["little to no exercise and work a desk job",
                             "light exercise 1-3 hours of exercise per week",
                             "moderate exercise 4-6 hours of exercise per week",
                             "heavy exercise 7-9 hours of exercise per week",
                             "10+ hours of exercise per week"]
}

