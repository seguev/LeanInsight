//
//  Model.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//


import UIKit

enum Day : String, CaseIterable {
    case Sunday = "Sunday"
    case Monday = "Monday"
    case Tuesday = "Tuesday"
    case Wednesday = "Wednesday"
    case Thursday = "Thursday"
    case Friday = "Friday"
    case Saturday = "Saturday"
}

enum UserStats : String, CaseIterable {
    
    case System = "System"
    case Gender = "Gender"
    case Height = "Height"
    case Age = "Age"
    case ActivityLevel = "Activity Level"
}


enum System : String, CaseIterable {
    case Metric = "Metric"
    case Imperial = "Imperial"
}

enum Gender : String, CaseIterable {
    case Male = "Male"
    case Female = "Female"
}

enum ActivityLevel : String, CaseIterable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extremelyActive = "Extremely Active"
}

func average (of numArray:[Float]) -> Float {
    return numArray.reduce(0, +) / Float(numArray.count)
}

//var heights = stride(from: 1.20, to: 0.01, by: 3.01).map{Float($0)} // not accurate!

func heights () -> [Float]{
    var result = [Float]()
    
    for r in stride(from: 1.20, to: 3.00, by: Double(0.01)) {
        result.append(Float(r))
    }
    return result
}

func feet () -> [String] {
    var result = [String]()
    for i in 4..<8 {
        for j in 0...11 {
            result.append("\(i)'\(j)")
        }
    }
    return result
}
 
//let weights = stride(from: 30, to: 200.1, by: 0.1).map{Float($0)} // not accurate!

var kilograms : [Float] {
    var weights = [Float]()
    for i in stride(from: 30, to: 200, by: 0.1) {
        let weight = Float(i)
        weights.append(weight)
    }
    return weights
}
var pounds : [Float] {
    var weights = [Float]()
    for i in stride(from: 70, to: 400, by: 1) {
        let weight = Float(i)
        weights.append(weight)
    }
    return weights
}

// MARK: - Heptics
func touchFeedback (intensity:CGFloat = 1, style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.prepare()
    generator.impactOccurred(intensity: intensity)
}
func sendErrorFeedback () {
    let generator = UINotificationFeedbackGenerator()
    generator.prepare()
    generator.notificationOccurred(.error)
}

// MARK: - colors
let backgroundColor = UIColor(named: "secondSetBackGround")
let textColor = UIColor(named: "secondSetText")
let viewsColor = UIColor(named: "secondSetViews")
let buttonsColor = UIColor(named: "secondSetButtons")
/*
func weights (_ system:System) -> [Measurement<UnitMass>] {
    
    var weights = [Measurement<UnitMass>]()
    switch system {
    case .Metric:
        for i in stride(from: 30, to: 200.1, by: 0.1) {
            
            let weight : Measurement<UnitMass> = .init(value: Double(i), unit: .kilograms)
            
            weights.append(weight)
        }
        
    case .Imperial:
        for i in stride(from: 70, to: 400, by: 1) {
            
            let weight : Measurement<UnitMass> = .init(value: Double(i), unit: .pounds)
            
            weights.append(weight)
        }
    }
    
    return weights
}
*/
//let ages = stride(from: 8, to: 90, by: 1).map{Int($0)} // not accurate!

func ages () -> [Int] {
    var result = [Int]()
    for r in stride(from: 8, to: 76, by: 1) {
        result.append(r)
    }
    return result
}



enum InfoType {
    case tapeInfo
    case caliperMaleInfo
    case caliperFemaleInfo
}
enum ScrollViewInfoType {
    case BMIInfo
    case tdeeInfo
    case bodyFatInfo
    case classificationByBmi
    case classificationForMenByFatPercentInfo
    case classificationForWomenByFatPercentInfo
    case calDefInfo
    case calPlusInfo
}

enum Phase {
    case cut
    case bulk
}

enum ChangableSetting : String, CaseIterable {
    case Age = "Age"
    case Height = "Height"
    case ActivityLevel = "Activity Level"
}

// MARK: - Double & Float extentions
extension Double {
    func decimalRound (decimal n:Double = 2) -> Double {
        let m : Double = pow(10, n)
        let tmp = Int(self*m)
        return Double(tmp) / m
    }
}



// MARK: - toolBar protocol
/**
 Call addToolBar() on viewDidLoad() !!!
 */
protocol MyToolBarDelegate : UIViewController {
    func addToolBar()
    func allOfMyTextFields () -> [UITextField]
    
}

extension MyToolBarDelegate  {

    func addToolBar () {
        
         let textFields = allOfMyTextFields()
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        
        //down
        let down = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), primaryAction: UIAction(handler: { _ in
            var currentTextField : UITextField?
            for t in textFields {
                if t.isFirstResponder {currentTextField = t}
            }
            if let currentTextField {
                guard var currentIndex = textFields.firstIndex(of: currentTextField) else {fatalError("Probably forgot one of the textfields. check your textField array again.")}
                
                //guard not out of range else turn 0 again
                if currentIndex + 1 >= textFields.count {currentIndex = -1}
                textFields[currentIndex + 1].becomeFirstResponder()
//                textFields[currentIndex + 1].text = ""
            } else {print("Could not find current textfield!@#")}
        }))
        
        //up
        let up = UIBarButtonItem(image: UIImage(systemName: "chevron.up"), primaryAction: UIAction(handler: { _ in
            var currentTextField : UITextField?
            for t in textFields {
                if t.isFirstResponder {currentTextField = t}
            }
            if let currentTextField {
                guard var currentIndex = textFields.firstIndex(of: currentTextField) else {fatalError("Probably forgot one of the textfields. check your textField array again.")}
                
                //guard not out of range else turn 0 again
                if currentIndex - 1 < 0 {currentIndex = textFields.count}
                textFields[currentIndex - 1].becomeFirstResponder()
//                textFields[currentIndex - 1].text = ""
            } else {print("Could not find current textfield!@#")}
        }))
        
        let space = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(systemItem: .done, primaryAction: UIAction(handler: {_ in self.view.endEditing(true)}))
        toolbar.items = [space,up,down,done]
        
        for textField in textFields {
            textField.inputAccessoryView = toolbar
        }
    }
}

