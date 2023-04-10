//
//  WeeklyWeightViewModel.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

protocol WeeklyWeightModelDelegate : UIViewController {

    //viewDidLoad functions..
    
    
}
extension WeeklyWeightModelDelegate {
    
    //default execution of viewDidLoad funcs..
    
}

class WeeklyWeightViewModel {

    weak var delegate : WeeklyWeightModelDelegate?

    var isFatChecked : Bool {
        get {
            return StorageViewModel.shared.weeklyData.fatPercentage != nil
        }
    }
    
    var fatClassification : String? {
        get {
            if let fat = fetchMostUpdatedBodyFat() {
                let gender = SettingsViewModel.shared.gender
                return fetchFatClassification(gender: gender, fat: Double(fat)).classification
            } else {
                return nil
            }
        }
    }
    
    var bmiClassificaion : String? {
        get {
            
            if let age = SettingsViewModel.shared.age,
               let height = SettingsViewModel.shared.height,
               let weight = fetchLastWeightAvailable() {
                
                let gender = SettingsViewModel.shared.gender
                let system = SettingsViewModel.shared.system
                
                let bmi = CalculatorViewModel().BMICalculator(weight: weight, height: height, system: system, age: age, gender: gender)
                
                return bmiClassification(bmi: bmi, age: age, gender: gender)
                
            } else {
                return nil
            }

        }
    }
    
    /*
    var today : Day {
        let df = DateFormatter()
        df.locale = .init(components: .init(languageCode: .english))
        df.dateFormat = "EEEE"
        let today = df.string(from: Date())
        guard let todayDay = Day(rawValue: today) else {fatalError()}
        return todayDay
    }
    */

    // MARK: - popUp funcs
    
    func scrollViewPopUpInitialSetup(popup:UIView,superView:UIView) {
        popup.layer.cornerRadius = 10
        popup.layer.shadowOpacity = 0.5
        popup.layer.shadowOffset = .init(width: 3, height: 3)
        popup.layer.cornerRadius = 5
        popup.layer.shadowColor = UIColor.darkGray.cgColor
        superView.addSubview(popup)
        popup.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popup.widthAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.widthAnchor, multiplier: 0.8),
            popup.centerXAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.centerYAnchor)
        ])
        popup.transform = .init(scaleX: 0, y: 0)
        popup.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hidePopUp(_:))))
    }
    
    @objc func hidePopUp (_ sender:UIGestureRecognizer) {
        guard let popup = sender.view else {return}
        UIView.animate(withDuration: 0.2) {
            popup.transform = .init(scaleX: 0.01, y: 0.01)
        } completion: { _ in
            popup.transform = .init(scaleX: 0.0, y: 0.0)
        }
    }
    
    func showInfoPopUp (popup:UIView) {
        let wasHidden = popup.layer.affineTransform() == CGAffineTransform(a: 0.0, b: 0.0, c: 0.0, d: 0.0, tx: 0.0, ty: 0.0)
        guard wasHidden else {return}
        
        popup.transform = .init(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.2) {
            popup.transform = .init(scaleX: 1.2, y: 1.2)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                popup.transform = .init(scaleX: 1, y: 1)
            }
        }
    }
    
    func updateInfoPopUpLabel (_ label:UILabel ,infoType:ScrollViewInfoType?) {
        let info = InfoModel()
        switch infoType {
        case .BMIInfo:
            label.text = info.BMIInfo
        case .tdeeInfo:
            label.text = info.tdeeInfo
        case .bodyFatInfo:
            label.text = info.bodyFatInfo
        case .classificationByBmi:
            label.text = info.classificationByBMIInfo
        case .classificationForMenByFatPercentInfo:
            label.text = info.classificationByMenFatPercentInfo
        case .classificationForWomenByFatPercentInfo:
            label.text = info.classificationByWomenFatPercentInfo
        case .calDefInfo:
            label.text = info.calDefInfo.text
        case .calPlusInfo:
            label.text = info.calPlusInfo
        default :
            label.text = "-"
        }
    }
    
    // MARK: - Stats handling funcs
    
    /**
     Uses Katch formula if fat percent is available, or miffin if isn't .
     return "-" if theres not enough data .
     */
     func TDEE(weight:Measurement<UnitMass>?,fat:Float?) -> Int? {
        
         guard let weight = weight,
               let activityLevel = SettingsViewModel.shared.activityLevel else {return nil}
        let calc = CalculatorViewModel()
         
        if let availableFat = fat {
            
            let bmr = calc.bmrByKatchMcArdle(weight: weight, fat: availableFat, system: SettingsViewModel.shared.system)
            let tdee = calc.TDEECalculator(BMR: bmr, activityLevel: activityLevel)
            return tdee
            
        } else if let age = SettingsViewModel.shared.age,
                  let height = SettingsViewModel.shared.height {
            
            let bmr = calc.bmrByMifflinSt(weight: weight, height: height, age: age, gender: SettingsViewModel.shared.gender, system: SettingsViewModel.shared.system)
            let tdee = calc.TDEECalculator(BMR: bmr, activityLevel: activityLevel)
            return tdee
            
        } else {
            return nil
        }
    }
    
    /**
     Calculates the recommended calories intake
     */
    func fetchCaloriesRecommendation (tdee:Int,bmi:Float?,fat:Float?) -> String {
        guard bmi != nil || fat != nil else {return "-"}
        guard let phase = decideIfCutOrBulk() else {return "-"}
        
        let calc = CalculatorViewModel()

        var recommendedCal : (min: Int, max: Int)?
        switch phase {
        case .cut:
            recommendedCal = calc.calculateRecommendedCalories(for: .cut, tdee: tdee)
        case .bulk:
            recommendedCal = calc.calculateRecommendedCalories(for: .bulk, tdee: tdee)
        }
        
        return "\(recommendedCal!.min) - \(recommendedCal!.max)"
    }
    
    func fetchWeeklyFat() -> String {
       if let lastFatMeasurement = StorageViewModel.shared.weeklyData.fatPercentage {
           return "\(lastFatMeasurement)%"
       } else {
           return "-"
       }
   }
    
    func updateBMILabel(weight:Measurement<UnitMass>?) -> Float? {
        
        guard let w = weight,
              let h = SettingsViewModel.shared.height,
              let a = SettingsViewModel.shared.age
        else {
            return nil
        }
        
        let system = SettingsViewModel.shared.system
        let gender = SettingsViewModel.shared.gender
        let calc = CalculatorViewModel()
        
        let bmi = calc.BMICalculator(weight: w, height: h, system: system, age: a, gender: gender)
        
        return bmi
    }
    

    
    // MARK: - Fat & Weight updates
    
    func updateTodaysWeight (_ weightButton:UIButton) {
        
        let today = StorageViewModel.shared.currentDateComponents().today.rawValue
        let todayIsDone = StorageViewModel.shared.weeklyData.weights.keys.contains(today)
  
        if todayIsDone {
            
            
//            let newWeight = StorageViewModel.shared.weeklyData.weights[today]!
//            replaceButtonWithNum(weightButton,n: newWeight)
            checkBox(weightButton)
        }
    }
    
    func updateTodaysFat (_ fatButton:UIButton) {
       let gotWeeklyFatMeasurements = StorageViewModel.shared.weeklyData.fatPercentage != nil
       
       if gotWeeklyFatMeasurements {
            
//           let fat = StorageViewModel.shared.weeklyData.fatPercentage!
//           replaceButtonWithNum(fatButton, n: fat)
           checkBox(fatButton)
       }
   }
    
    /*
    func replaceButtonWithNum (_ button:UIButton, n:Float) {
        button.configuration?.background.backgroundColor = #colorLiteral(red: 0.9250000119, green: 0.9010000229, blue: 1, alpha: 1)
        button.layer.shadowOpacity = 0
        let label = UILabel(frame: button.frame)
        label.transform = .init(scaleX: 1.5, y: 1.5)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.minimumScaleFactor = 0.1
        label.text = String(format: "%.1f", n)
        label.textColor = #colorLiteral(red: 0.2431372549, green: 0.3294117647, blue: 0.6745098039, alpha: 1)
        label.font = .init(name: "Marker Felt Thin", size: 20)
        if let superView = button.superview {
            superView.addSubview(label)
        }
    }
*/
    
    func checkIfEnoughForGraphUpdate () {
        guard SettingsViewModel.shared.isAllDataAvailable else {return}
        let userHeight = Float(SettingsViewModel.shared.height!.value)
        
        let updatedStorageData = StorageViewModel.shared.weeklyData!
        let entriesCount = updatedStorageData.weights.count
//        let isFatAvailable = updatedStorageData.fatPercentage != nil
        
        let isEnough = entriesCount >= 4 //&& isFatAvailable
        
        if isEnough {
            let averageWeight = (updatedStorageData.weights.map{$0.value}.reduce(0, +))/Float(entriesCount)
            let currentWeekNum = StorageViewModel.shared.currentDateComponents().weekNum
            let averageBmi = averageWeight / (pow(userHeight, 2))

            CoreDataViewModel.shared.saveToCoreData(averageWeight,averageBmi, fatPercentage: updatedStorageData.fatPercentage, weekNum: currentWeekNum)
        }
        
        
    }
    
    /**
     - looks for today's weight, if not..
     - uses this week's average, if isn't available..
     - uses last entry's average weight , if isn't available..
     - returns nil
     */
    func fetchLastWeightAvailable () -> Measurement<UnitMass>? {
        
        //today
        let todaysKey = StorageViewModel.shared.currentDateComponents().today.rawValue
        if let todayWeight = StorageViewModel.shared.weeklyData.weights[todaysKey] {
            let savedWeightInKg = Measurement<UnitMass>.init(value: Double(todayWeight), unit: .kilograms)
            return savedWeightInKg
            
            //this week
        } else if !StorageViewModel.shared.weeklyData.weights.isEmpty {
            let lastSavedWeightThisWeek = StorageViewModel.shared.weeklyData.weights.map({$0.value})
            let average = average(of: lastSavedWeightThisWeek)
            let averageInKg = Measurement<UnitMass>.init(value: Double(average), unit: .kilograms)
            return averageInKg
            
            //sometime
        } else if let otherWeeksAverageWeight = CoreDataViewModel.shared.loadFromCoreData()?.last?.weightAverage {
            let averageInKg = Measurement<UnitMass>.init(value: Double(otherWeeksAverageWeight), unit: .kilograms)
            return averageInKg
            
        } else {
            return nil
        }
    }
    
    func fetchMostUpdatedBodyFat () -> Float? {
        if let weeklyFat = StorageViewModel.shared.weeklyData.fatPercentage {
            return weeklyFat
        } else if let lastMeasuredFat = CoreDataViewModel.shared.loadFromCoreData()?.last?.fatPercentage {
            guard lastMeasuredFat != 0.0 else {return nil}
            return lastMeasuredFat
        } else {
            return nil
        }
    }
    
    func fetchPlaceHolder (_ day:String) -> String {
         
        if let lastWeight = StorageViewModel.shared.weeklyData.weights[day] {
            return String(format: "%.0f", lastWeight)+"kg"
        } else {
            return "Enter your current weight"
        }
    }
    
    func updateTitleLabel (_ todayLabel:UILabel) {
        let today = StorageViewModel.shared.currentDateComponents().today.rawValue
        todayLabel.text = today
     }
    
/*
    func checkIfGotStatsAndMakeClickable (label:UILabel, complition: () -> Void = {}) {
        let gotStats = SettingsViewModel.shared.age != nil && SettingsViewModel.shared.height != nil && SettingsViewModel.shared.activityLevel != nil
       
       if !gotStats {
           label.text = "set your stats"
           label.shadowColor = .systemGray4
           label.shadowOffset = .init(width: 2, height: 2)
           label.font = .init(name: "Futura", size: 20)
           label.textColor = .systemRed
           label.isUserInteractionEnabled = true
       } else {
           label.textColor = #colorLiteral(red: 0.2431372549, green: 0.3294117647, blue: 0.6745098039, alpha: 1)
           label.font = .init(name: "Marker Felt Thin", size: 30)
           label.shadowColor = .clear
           label.isUserInteractionEnabled = false
       }
   }
    */
    
    // MARK: - Views animations and initial setup
    
    func animateTouchedView (_ touchedView:UIView, complition: @escaping () -> Void) {
        let currentShadowOffset = touchedView.layer.shadowOffset
        UIView.animate(withDuration: 0.1) {
            touchedView.layer.shadowOffset = .init(width: 0, height: 0)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                touchedView.layer.shadowOffset = currentShadowOffset
            } completion: { _ in
                complition()
            }
        }
    }

    func clickAnimation (_ button:UIButton, complition: @escaping () -> Void = {}) {
        guard !button.isHidden else {return}
        
        let currentShadowOffset = button.layer.shadowOffset
        UIView.animate(withDuration: 0.1) {
            button.layer.shadowOffset = .init(width: 0, height: 0)
        } completion: { _ in
            UIView.animate(withDuration: 0.1) {
                button.layer.shadowOffset = currentShadowOffset
            } completion: { _ in
                complition()
            }
        }
    }
    
    func floatingViewSetup (_ view:UIView) {
        for subView in view.subviews.filter({$0.subviews.count > 0}) {
            subView.layer.shadowOpacity = 0.3
            subView.layer.shadowOffset = .init(width: 2, height: 2)
            subView.layer.shadowRadius = 3

            subView.backgroundColor = UIColor(named: "secondSetViews")
//            subView.backgroundColor = #colorLiteral(red: 0.9250000119, green: 0.9010000229, blue: 1, alpha: 1)
            subView.layer.cornerRadius = 10
        }
        
    }
    
    /**
     Animates views one after another
     - Parameters:
       - views: Views that are being animated
       - delay: The first delay and the daley between each animation
       - buttons: The buttons that the views contain, only pass once on viewDidLoad()
     */
    func animateViewsIn (_ views:[UIView],delay:Double = 0.3,buttons:[UIView]? = nil) {
        if let buttons {buttons.forEach{$0.alpha = 0}} // set buttons alpha on start
        
         for i in 0..<views.count {
             views[i].transform = .init(scaleX: 1.1, y: 1.1)
             views[i].alpha = 0
             
             Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { _ in //delay for whole animation
                 
                 if let buttons {  self.animateViewsIn(buttons,buttons: nil) } //this runs once when buttons != nil
                 
                 UIView.animate(withDuration: TimeInterval(delay), delay: Double(i)*delay) {
                     views[i].alpha = 1
                     views[i].transform = .init(scaleX: 1, y: 1)
                 }
             }
         }
    }
    
    /**
     Called from checkIfTodayIsDone()
     */
    func updateProgressBar (_ progressBar:UIProgressView) {
        let entries  = Float(StorageViewModel.shared.weeklyData.weights.count)
        /*if StorageViewModel.shared.weeklyData.fatPercentage != nil {
            entries += 1.0
        }*/
        UIView.animate(withDuration: 4) {
            progressBar.setProgress(entries/4, animated: true)
        }
    }
    
    func chooseTextForLabel(_ hasAtLeastOneEntry: Bool, _ numOfWeeklyEntries: Int) -> String {
        
        if hasAtLeastOneEntry {
            // User's second week or later
            
            if 4 - numOfWeeklyEntries > 0 {
                return "\(4 - numOfWeeklyEntries) more weight entries left this week."
            } else {
                return "Great job! You've completed all of your weight entries for this week."
            }
            
        } else {
            // User's first week
            
            if 4 - numOfWeeklyEntries >= 0 {
                return "\(4 - numOfWeeklyEntries) more weight entries left this week. Don't forget to record your weight regularly!"
            } else {
                return "You've recorded all of your weight entries for this week. Keep it up for one more week and you'll be able to see your progress on the graph!"
            }
        }
    }
    
    
    // MARK: - classification funcs
    

    private func bmiClassification (bmi:Float,age:Int,gender:Gender) -> String {
        
        if age > 65 {
            switch bmi {
            case ..<22:
                return "Thinness"
            case 22..<27:
                return "normal"
            case 27..<30:
                return "Overweight"
            case 30...:
                return "Obese"
            default:
                return ""
            }
        } else if age < 19 {
            if gender == .Male {
                return boyBMICalc(age, bmi)
            } else {
                return girlBMICalc(age, bmi)
            }
            
        } else {
            switch bmi {
            case ..<16:
                return "Severe Thinness"
            case 16..<17:
                return "Moderate Thinness"
            case 17..<18.5:
                return "Mild Thinness"
            case 18.5..<25:
                return "Normal"
            case 25..<30:
                return "Overweight"
            case 30..<35:
                return "Obese Class I"
            case 35..<40:
                return "Obese Class II"
            case 40...:
                return "Obese Class III"
            default:
                return ""
            }
        }
        
    }
    
//http://www.netogreen.co.il/pages206.aspx
    private func boyBMICalc (_ age:Int, _ bmi:Float) -> String {
        switch age {
        case 8:
            switch bmi {
            case ..<13.8:
                return "Thinness"
            case 13.8..<18:
                return "Normal"
            case 18..<20:
                return "Overweight"
            case 20...:
                return "Obese"
            default:
                return ""
            }
        case 9:
            switch bmi {
            case ..<14.0:
                return "Thinness"
            case 14.0..<18.5:
                return "Normal"
            case 18.5..<21:
                return "Overweight"
            case 21.1...:
                return "Obese"
            default:
                return ""
            }
        case 10:
            switch bmi {
            case ..<14.2:
                return "Thinness"
            case 14.2..<19.4:
                return "Normal"
            case 19.4..<22.1:
                return "Overweight"
            case 22.2...:
                return "Obese"
            default:
                return ""
            }
        case 11:
            switch bmi {
            case ..<14.5:
                return "Thinness"
            case 14.5..<20.2:
                return "Normal"
            case 20.2..<23.1:
                return "Overweight"
            case 23.2...:
                return "Obese"
            default:
                return ""
            }
        case 12:
            switch bmi {
            case ..<15.0:
                return "Thinness"
            case 15.0..<21.0:
                return "Normal"
            case 21.0..<24.1:
                return "Overweight"
            case 24.2...:
                return "Obese"
            default:
                return ""
            }
        case 13:
            switch bmi {
            case ..<15.4:
                return "Thinness"
            case 15.4..<22.0:
                return "Normal"
            case 22.0..<25.1:
                return "Overweight"
            case 25.2...:
                return "Obese"
            default:
                return ""
            }
        case 14:
            switch bmi {
            case ..<16.0:
                return "Thinness"
            case 16.0..<23.0:
                return "Normal"
            case 23.0..<26.0:
                return "Overweight"
            case 26.1...:
                return "Obese"
            default:
                return ""
            }
        case 15:
            switch bmi {
            case ..<17.4:
                return "Thinness"
            case 17.3..<23.5:
                return "Normal"
            case 23.5..<26.8:
                return "Overweight"
            case 26.9...:
                return "Obese"
            default:
                return ""
            }
        case 16:
            switch bmi {
            case ..<17.5:
                return "Thinness"
            case 17.4..<24.2:
                return "Normal"
            case 24.2..<27.5:
                return "Overweight"
            case 27.6...:
                return "Obese"
            default:
                return ""
            }
        case 17:
                switch bmi {
                case ..<17.9:
                    return "Thinness"
                case 17.9..<25.0:
                    return "normal"
                case 24.9..<28.2:
                    return "Overweight"
                case 25.1...:
                    return "Obese"
                default:
                    return ""
                }
            case 18:
                switch bmi {
                case ..<18.5:
                    return "Thinness"
                case 18.5..<25.7:
                    return "normal"
                case 25.7..<29:
                    return "Overweight"
                case 25.9...:
                    return "Obese"
                default:
                    return ""
                }
            default:
                return "boy has no age!"
            }
        
    }
    
    private func girlBMICalc (_ age:Int, _ bmi:Float) -> String {
        switch age {
        case 8:
            switch bmi {
            case ..<13.5:
                return "Thinness"
            case 13.5..<18.3:
                return "normal"
            case 18.3..<20.7:
                return "Overweight"
            case 20.8...:
                return "Obese"
            default:
                return ""
            }
            
        case 9:
            switch bmi {
            case ..<13.8:
                return "Thinness"
            case 13.8..<19.0:
                return "normal"
            case 19.0..<21.8:
                return "Overweight"
            case 21.9...:
                return "Obese"
            default:
                return ""
            }
            
            
        case 10:
            switch bmi {
            case ..<14.00:
                return "Thinness"
            case 14.0..<20.0:
                return "normal"
            case 20.0..<23:
                return "Overweight"
            case 23.1...:
                return "Obese"
            default:
                return ""
            }
            
        case 11:
            switch bmi {
            case ..<14.4:
                return "Thinness"
            case 14.4..<20.8:
                return "normal"
            case 20.8..<24:
                return "Overweight"
            case 24.1...:
                return "Obese"
            default:
                return ""
            }
            
        case 12:
            switch bmi {
            case ..<14.8:
                return "Thinness"
            case 14.8..<21.9:
                return "normal"
            case 21.9..<25.1:
                return "Overweight"
            case 25.2...:
                return "Obese"
            default:
                return ""
            }
            
        case 13:
            switch bmi {
            case ..<15.2:
                return "Thinness"
            case 15.2..<22.7:
                return "normal"
            case 22.7..<26.2:
                return "Overweight"
            case 26.3...:
                return "Obese"
            default:
                return ""
            }
            
        case 14:
            switch bmi {
            case ..<15.9:
                return "Thinness"
            case 15.9..<23.5:
                return "normal"
            case 23.5..<27.2:
                return "Overweight"
            case 27.3...:
                return "Obese"
            default:
                return ""
            }
            
        case 15:
            switch bmi {
            case ..<17.2:
                return "Thinness"
            case 17.1..<24.0:
                return "normal"
            case 24.0..<28.1:
                return "Overweight"
            case 28.2...:
                return "Obese"
            default:
                return ""
            }
            
        case 16:
            switch bmi {
            case ..<17.9:
                return "Thinness"
            case 17.8..<24.6:
                return "normal"
            case 24.6..<28.4:
                return "Overweight"
            case 28.5...:
                return "Obese"
            default:
                return ""
            }
            
        case 17:
            switch bmi {
            case ..<17.9:
                return "Thinness"
            case 17.8..<25.2:
                return "normal"
            case 25.2..<29.6:
                return "Overweight"
            case 29.7...:
                return "Obese"
            default:
                return ""
            }
            
        case 18:
            switch bmi {
            case ..<18.5:
                return "Thinness"
            case 18.4..<25.7:
                return "normal"
            case 25.7..<30.4:
                return "Overweight"
            case 30.5...:
                return "Obese"
            default:
                return ""
            }
        default :
            return "girl as no age!"
        }
        
    }
    
    func fetchFatClassification(gender:Gender,fat:Double) -> (classification:String,color:UIColor) {
        switch gender {
        case .Male:
            switch fat {
            case 2..<6:
                return ("Essential Fat",.systemGreen)
            case 6..<14:
                return ("Typical Athletes",.systemBlue)
            case 14..<18:
                return ("Fitness",.systemYellow)
            case 18..<26:
                return ("Acceptable",.systemOrange)
            case 26...:
                return ("Obese",.systemRed)
            default:
                return ("none",.darkGray)
            }
        case .Female:
            switch fat {
            case 10..<14:
                return ("Essential Fat",.systemGreen)
            case 14..<21:
                return ("Typical Athletes",.systemBlue)
            case 21..<25:
                return ("Fitness",.systemYellow)
            case 25..<32:
                return ("Acceptable",.systemOrange)
            case 32...:
                return ("Obese",.systemRed)
            default:
                return ("none",.darkGray)
            }
        }
   }
    
    /**
     Return nil if bmi or fat precent aren't available
     */
    func decideIfCutOrBulk () -> Phase? {
        
        let system = SettingsViewModel.shared.system
        let gender = SettingsViewModel.shared.gender
        
        let fat = fetchMostUpdatedBodyFat()
        let weight = fetchLastWeightAvailable()
        
        if let fat {
            
            switch gender {
            case .Male:
                return fat < 14 ? .bulk : .cut
            case .Female:
                return fat > 20 ? .cut : .bulk
            }
            
        } else if let weight,
                  let height = SettingsViewModel.shared.height,
                  let age = SettingsViewModel.shared.age {
            
            let bmi = CalculatorViewModel().BMICalculator(weight: weight, height: height, system: system, age: age, gender: gender)
            
            return bmi < 19 ? .bulk : .cut

        } else {
            return nil
        }
    }
    
    // MARK: - edit buttons & views
    
    func addShadowToButton (_ button:UIButton) {
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = .init(width: 2, height: 2)
        button.layer.shadowOpacity = 0.8
    }
    
    func checkBox (_ button:UIButton) {
        button.configuration?.background.image = UIImage(systemName: "checkmark")
        button.tintColor = UIColor(named: "secondSetText")
    }
    
    func warningLabel () -> UILabel {
        let label = UILabel()
        label.backgroundColor = .white
        label.textColor = UIColor(named: "secondSetText")
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "Please set your age, weight, gender and activity level."
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    init(delegate: WeeklyWeightModelDelegate? = nil) {
        self.delegate = delegate
    }

    
}


