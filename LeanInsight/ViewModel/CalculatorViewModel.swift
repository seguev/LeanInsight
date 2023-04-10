//
//  CalculatorViewModel.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import Foundation

struct CalculatorViewModel {
    
    func fromInchesToFeet (height:Measurement<UnitLength>) -> String {
        let heightInInches = height.converted(to: .inches).value
        
        let ft = Int(heightInInches / 12)
        let inc = Int(heightInInches.truncatingRemainder(dividingBy: 12).rounded())
        
        return "\(ft)'\(inc)"
    }
    
    func feetToInches (_ feet:String) -> Float {
    print("input : \(feet)")
        //get remaining inches
        let index = feet.firstIndex(of: Character("'"))!
        let startIndex = feet.index(after: index)
        let endIndex = feet.index(before: feet.endIndex)
        let inchesAfterFeet = Float(feet[startIndex...endIndex])!

        //convert inches from feet
        let justFeet = feet[feet.startIndex...feet.index(before: index)]
        let feetInches = Float(justFeet)! * 12.0
        print("feet: \(justFeet)\ninchesAfterFeet: \(feet[startIndex...endIndex])\n")
        
        return feetInches + inchesAfterFeet
    }
    
    /**
     % Body Fat = (495 / Body Density) - 450.
     */
    private func bodyDensityToFatPercentage(_ density:Double) -> Double {
        
        let r = (495.0 / density) - 450.0
        return r
    }
    
    
    
    /**
     bodyDensity = 1.10938–(0.0008267*sumOfFolds) + (0.0000016 x square of the sum of skinfolds) – (0.0002574 x age)
     */
    func calcMenBodyFat (age:Int, chest:Int, abdominal:Int, thigh: Int) -> Double {
        let chest = Double(chest)
        let abdominal = Double(abdominal)
        let thigh = Double(thigh)
        
        let sus = [chest,abdominal,thigh].reduce(0, +)
        
        let bd = 1.10938 - 0.0008267 * sus + 0.0000016 * pow(sus, 2) - 0.0002574 * Double(age)
        
//        let bd = 1.10938 + (-1*(0.0008267 * sus)) + (0.0000016 * pow(sus, 2)) + ( -1 * (0.0002574 * Double(age)!))
        
        return bodyDensityToFatPercentage(bd)
        
    }
    
    
    /**
     Body Density = 1.0994921 – (0.0009929 x sum of skinfolds) + (0.0000023 x square of the sum of skinfolds) – (0.0001392 x age)
     */
    func calcWomenBodyFat (age:Int, triceps:Int, suprailiac:Int, thigh: Int) -> Double {
        let triceps = Double(triceps)
        let suprailiac = Double(suprailiac)
        let thigh = Double(thigh)
        
        
        let sus = [triceps,suprailiac,thigh].reduce(0, +)
        
        let bd = 1.0994921 - 0.0009929 * sus + 0.0000023 * pow(sus, 2) - 0.0001392 * Double(age)
//        let bd = 1.0994921 + (-1*(0.0009929 * sus)) + (0.0000023 * pow(sus, 2)) + ( -1 * (0.0001392 * Double(age)!))

            return bodyDensityToFatPercentage(bd)

    }
    
    ///Covert Bailey Method
    func calculateBodyFatPercentageWithTape(gender: Gender, age: Int, hip: Measurement<UnitLength>, waistOrThigh: Measurement<UnitLength>, calfOrForearm: Measurement<UnitLength>, wrist: Measurement<UnitLength> ) -> Double {

        let waistOrThighCir = waistOrThigh.converted(to: .inches)
        let hipCir = hip.converted(to: .inches)
        let calfOrForearmCir = calfOrForearm.converted(to: .inches)
        let wristCir = wrist.converted(to: .inches)
   
        var fatPercentage = 0.0
        
        switch gender {
            
        case .Male:
            //            Fat% = B + 0.5A - 3C - D (for men 30 years old or younger)
            //            Fat% = B + 0.5A - 2.7C - D (for men over age 30)
            if age <= 30 {
                
                fatPercentage = waistOrThighCir.value + 0.5*hipCir.value  - 3*calfOrForearmCir.value - wristCir.value
                

            } else {
                fatPercentage = waistOrThighCir.value + 0.5*hipCir.value - 2.7*calfOrForearmCir.value - wristCir.value

            }
        case .Female:
            //            Fat% = Hips+(0.8*Thigh) - (2*Calf) - Wrist (for women 30 years old or younger)
            //            Fat% = Hips+ Thigh - (2*Calf) - Wrist (for women over age 30)
            if age <= 30 {
                fatPercentage = hipCir.value + 0.8*waistOrThighCir.value - 2*calfOrForearmCir.value - wristCir.value

            } else {
                fatPercentage = hipCir.value + waistOrThighCir.value - 2*calfOrForearmCir.value - wristCir.value

            }
        }
        
        
        
        return fatPercentage
    }

    
    /**
     Covert Bailey Method
     A) Hips, B) Thigh, C) Calf, and D) Wrist
     Fat% = Hips+(0.8*Thigh) - (2*Calf) - Wrist (for women 30 years old or younger)
     Fat% = Hips+ Thigh - (2*Calf) - Wrist (for women over age 30)
     */
//    func tapeFatCalcWomen (age: String, hips:String ,thigh:String ,calf:String ,wrist:String, system:System) -> String? {
//
//        guard let age = Double(age),let hips = Double(hips),let thigh = Double(thigh),let calf = Double(calf),let wrist = Double(wrist) else {return "CouldNotConvert"}
//
//
//        if system == .Imperial {
//
//            if age <= 30 {
//                let bodyFat = hips+(0.8*thigh) - (2*calf) - wrist
//
//                return String(format: "%.1f", bodyFat)
//
//            } else {
//                    let bodyFat = hips + thigh - (2*calf) - wrist
//                return String(format: "%.1f", bodyFat)
//            }
//        } else {
//            let metricHips : Measurement<UnitLength> = .init(value: hips, unit: .centimeters).converted(to: .inches)
//            let metricThigh : Measurement<UnitLength> = .init(value: thigh, unit: .centimeters).converted(to: .inches)
//            let metricCalf : Measurement<UnitLength> = .init(value: calf, unit: .centimeters).converted(to: .inches)
//            let metricWrist : Measurement<UnitLength> = .init(value: wrist, unit: .centimeters).converted(to: .inches)
//
//            return tapeFatCalcWomen(age: age.description, hips: metricHips.value.description, thigh: metricThigh.value.description, calf: metricCalf.value.description, wrist: metricWrist.value.description, system: .Imperial)
//
//        }
//
//    }
    /**
     A) Hips, B) Waist, C) Forearm Circumference, and D) Wrist.
     Fat% = Waist + (0.5*Hips) - (3*Forearm) - Wrist (for men 30 years old or younger)
     Fat% = Waist + (0.5*Hips) - (2.7*Forearm) - Wrist (for men over age 30)
     */
//    func tapeFatCalcMen (age:String, hips:String ,waist:String ,forearm:String ,wrist:String, system:System) -> String {
//
//        guard let age = Double(age),let hips = Double(hips),let waist = Double(waist),let forearm = Double(forearm),let wrist = Double(wrist) else {return "CouldNotConvert"}
//
//        if system == .Imperial {
//
//            if age <= 30 {
//                let bodyFat = waist + (0.5*hips) - (3*forearm) - wrist
//
//                return String(format: "%.1f", bodyFat)
//
//            } else {
//                    let bodyFat = waist + (0.5*hips) - (2.7*forearm) - wrist
//                return String(format: "%.1f", bodyFat)
//            }
//        } else {
//            let metricHips : Measurement<UnitLength> = .init(value: hips, unit: .centimeters).converted(to: .inches)
//            let metricWaist : Measurement<UnitLength> = .init(value: waist, unit: .centimeters).converted(to: .inches)
//            let metricForearm : Measurement<UnitLength> = .init(value: forearm, unit: .centimeters).converted(to: .inches)
//            let metricWrist : Measurement<UnitLength> = .init(value: wrist, unit: .centimeters).converted(to: .inches)
//
//            return tapeFatCalcMen(age: age.description, hips: metricHips.value.description, waist: metricWaist.value.description, forearm: metricForearm.value.description, wrist: metricWrist.value.description, system: .Imperial)
//
//        }
//
//
//    }
    
   
    /*
     Covert Bailey Method
     women
     A) Hips, B) Thigh, C) Calf, D) Wrist
     Fat% = A+0.8B - 2C - D (for women 30 years old or younger)
     Fat% = A+ B - 2C - D (for women over age 30)
     men
     A) Hips, B) Waist, C) Forearm Circumference, and D) Wrist.
     Fat% = B + 0.5A - 3C - D (for men 30 years old or younger)
     Fat% = B + 0.5A - 2.7C - D (for men over age 30)
     
     All measurements should be taken at their widest points and should be recorded in inches.
     */

    /**
     BMI = mass (kg) / height2 (m)
     BMI = 703 × mass (lbs) / height2 (in)
     */
    func BMICalculator (weight:Measurement<UnitMass>,height:Measurement<UnitLength>,system:System,age:Int,gender:Gender) -> Float {
        
        var BMI = Float()
        let height = system == .Metric ? height.value : height.converted(to: .inches).value
        let weight = system == .Metric ? weight.value : weight.converted(to: .pounds).value
        BMI = Float(weight) / (pow(Float(height), 2))
        
        if system == .Imperial {BMI = BMI * 703}

        let roundedBmi = Float(String(format: "%.1f", BMI))!
        
        return roundedBmi
    }
    
    
    func calculateRecommendedCalories (for phase:Phase, tdee:Int, minR:Int = 300, maxR:Int = 500) -> (min:Int,max:Int) {
        switch phase {
        case .cut:
            let min = tdee - maxR
            let max = tdee - minR
            return (min,max)
        case .bulk:
            let min = Float(tdee) * 1.1
            let max = Float(tdee) * 1.2
            return (Int(min),Int(max))
        }
    }
    
    

    
    /**
     - TDEE = 1.15 × BMR if you have a sedentary lifestyle (little to no exercise and work a desk job)
     - TDEE = 1.3 × BMR if you have a lightly active lifestyle (light exercise 1-3 hours of exercise per week)
     - TDEE = 1.5 × BMR if you have a moderately active lifestyle (moderate exercise 4-6 hours of exercise per week)
     - TDEE = 1.7 × BMR if you have a very active lifestyle (heavy exercise 7-9 hours of exercise per week)
     - TDEE = 1.9 × BMR if you have an extremely active lifestyle (10+ hours of exercise per week)
     */
    func TDEECalculator (BMR:Int,activityLevel:ActivityLevel) -> Int {

        let bmr = Float(BMR)

        switch activityLevel {
        case .sedentary:
            return Int(bmr * 1.15)
        case .lightlyActive:
            return Int(bmr * 1.3)
        case .moderatelyActive:
            return Int(bmr * 1.5)
        case .veryActive:
            return Int(bmr * 1.7)
        case .extremelyActive:
            return Int(bmr * 1.9)
        }
    }
    
    /**
     H&B formula
     Men: BMR = 88.362 + (13.397 x weight in kg) + (4.799 x height in cm) – (5.677 x age in years)
     Women: BMR = 447.593 + (9.247 x weight in kg) + (3.098 x height in cm) – (4.330 x age in years)
     */
     func calculateBMR (_ gender:Gender,_ weight:Float,_ height:Float,_ age:Int) -> Float {
        if gender == .Male {
            return 88.362 + (13.397*weight) + (4.799*height) +  (-1*(5.677*Float(age)))
        } else {
            return 447.593 + (9.247*weight) + (3.098*height) + (-1*(4.330*Float(age)))
        }
        
    }
    
    
    /**
     Mifflin-St Jeor Formula, if you don't know your body fat percent .
     - BMR = 10 * weight (kg) + 6.25 * height (cm) – 5 * age (y) + s (kcal / day)
     - where s is +5 for males and -161 for females.
     */
    func bmrByMifflinSt (weight:Measurement<UnitMass>,height:Measurement<UnitLength>,age:Int,gender:Gender,system:System) -> Int {
        
        let h = Float(height.converted(to: .centimeters).value)
        let w = Float(weight.converted(to: .kilograms).value)
        
        let s : Float = gender == .Male ? 5.0 : -161.0
        let a : Float = Float(age)
        let bmr : Float = (10 * w) + (6.25 * h) + ((-5) * a) + s
        return Int(bmr)
        
        
    }
    /**
     Katch-McArdle, if you know your body fat percent .
     */
    func bmrByKatchMcArdle (weight:Measurement<UnitMass>,fat:Float,system:System) -> Int {
        let w = Float(weight.converted(to: .kilograms).value)
        
        let LBM = (w * (100 - fat)) / 100
        let BMR = 370 + (21.6 * LBM)
        return Int(BMR)
        
    }
  
    
    func macroCalculator (calories:Int,proteinPercent:Int,fatPercent:Int,carbPercent:Int) -> (protein:Int,fat:Int,carb:Int) {
        
        let (proteinPercent,fatPercent,carbPercent) = (Float(proteinPercent),Float(fatPercent),Float(carbPercent))
        let proteinProportion = Int(Float(calories) * (proteinPercent/100.0) / 4.0)
        let fatProportion = Int(Float(calories) * (fatPercent/100.0) / 9.0)
        let carbProportion = Int(Float(calories) * (carbPercent/100.0) / 4.0)
        
        return (proteinProportion,fatProportion,carbProportion)
    }
    
    
    
}


