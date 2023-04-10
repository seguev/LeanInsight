//
//  LeanInsightTests.swift
//  LeanInsightTests
//
//  Created by segev perets on 10/04/2023.
//

import XCTest
@testable import LeanInsight

final class LeanInsightTests: XCTestCase {
    var calc : CalculatorViewModel?
    
    override func setUpWithError() throws {
        calc = CalculatorViewModel()
    }

    override func tearDownWithError() throws {
        calc = nil
    }
    
    
    func testAverage () {
        let array = [5,6,3,8,3,6,9,4,3].map{Float($0)}
        let average = average(of: array)
        XCTAssertEqual(average, 5.2,accuracy: 0.1)
    }
//https://bodyfatpercentage.net

    func testCalculateBodyFatPercentageWithTape_metric_menOver30() {
        
        let age = 35
        let hip = Measurement<UnitLength>(value: 100, unit: .centimeters)
        let wrist = Measurement<UnitLength>(value: 18, unit: .centimeters)
        let waistOrThigh = Measurement<UnitLength>(value: 85, unit: .centimeters)
        let calfOrForearm = Measurement<UnitLength>(value: 30, unit: .centimeters)
        
        
        let expectedR = 14.17
        // fill in the expected result manually
        
        let r = calc!.calculateBodyFatPercentageWithTape(gender: .Male, age: age, hip: hip, waistOrThigh: waistOrThigh, calfOrForearm: calfOrForearm, wrist: wrist)
        XCTAssertEqual(r, expectedR, accuracy: 1)
    }

    func testCalculateBodyFatPercentageWithTape_metric_menBelow30() {
        
        let age = 25
        let hip = Measurement<UnitLength>(value: 90, unit: .centimeters)
        let wrist = Measurement<UnitLength>(value: 15, unit: .centimeters)
        let waistOrThigh = Measurement<UnitLength>(value: 75, unit: .centimeters)
        let calfOrForearm = Measurement<UnitLength>(value: 25, unit: .centimeters)

        let expectedR = 11.81
        // fill in the expected result manually
        
        let r = calc!.calculateBodyFatPercentageWithTape(gender: .Male, age: age, hip: hip, waistOrThigh: waistOrThigh, calfOrForearm: calfOrForearm, wrist: wrist)
        XCTAssertEqual(r, expectedR, accuracy: 1)
    }

    func testCalculateBodyFatPercentageWithTape_metric_womenOver30() {
        
        let age = 40
        let hip = Measurement<UnitLength>(value: 105, unit: .centimeters)
        let waistOrThigh = Measurement<UnitLength>(value: 85, unit: .centimeters)
        let calfOrForearm = Measurement<UnitLength>(value: 30, unit: .centimeters)
        let wrist = Measurement<UnitLength>(value: 16, unit: .centimeters)
        
        let expectedR = 44.88
        // fill in the expected result manually
        
        let r = calc!.calculateBodyFatPercentageWithTape(gender: .Female, age: age, hip: hip, waistOrThigh: waistOrThigh, calfOrForearm: calfOrForearm, wrist: wrist)
        XCTAssertEqual(r, expectedR, accuracy: 1)
    }

    func testCalculateBodyFatPercentageWithTape_metric_womenBelow30() {
        
        let age = 25
        let hip = Measurement<UnitLength>(value: 95, unit: .centimeters)
        let waistOrThigh = Measurement<UnitLength>(value: 70, unit: .centimeters)
        let calfOrForearm = Measurement<UnitLength>(value: 24, unit: .centimeters)
        let wrist = Measurement<UnitLength>(value: 14, unit: .centimeters)
        let r = calc!.calculateBodyFatPercentageWithTape(gender: .Female, age: age, hip: hip, waistOrThigh: waistOrThigh, calfOrForearm: calfOrForearm, wrist: wrist)
        
        let expectedR = 35.04
        
        XCTAssertEqual(r, expectedR, accuracy: 1)
        
    }
    func testCalculateBodyFatPercentageWithTapeImperial1() {
            let gender = Gender.Male
            let age = 35
            let hip = Measurement<UnitLength>(value: 39, unit: .inches)
            let waistOrThigh = Measurement<UnitLength>(value: 36, unit: .inches)
            let calfOrForearm = Measurement<UnitLength>(value: 14, unit: .inches)
            let wrist = Measurement<UnitLength>(value: 6.5, unit: .inches)
            
        let expectedR = 11.2
            
            let r = calc!.calculateBodyFatPercentageWithTape(gender: gender, age: age, hip: hip, waistOrThigh: waistOrThigh, calfOrForearm: calfOrForearm, wrist: wrist)
            XCTAssertEqual(r, expectedR, accuracy: 1)
        }
    
    func testCalculateBodyFatPercentageWithTapeImperial2() {
            let gender = Gender.Male
            let age = 25
            let hip = Measurement<UnitLength>(value: 40, unit: .inches)
            let waistOrThigh = Measurement<UnitLength>(value: 34, unit: .inches)
            let calfOrForearm = Measurement<UnitLength>(value: 12, unit: .inches)
            let wrist = Measurement<UnitLength>(value: 6, unit: .inches)
            
        let expectedR = 12.0
            
            let r = calc!.calculateBodyFatPercentageWithTape(gender: gender, age: age, hip: hip, waistOrThigh: waistOrThigh, calfOrForearm: calfOrForearm, wrist: wrist)
            XCTAssertEqual(r, expectedR, accuracy: 1)
        }
    
    func testCalculateBodyFatPercentageWithTapeImperial3() {
            let gender = Gender.Female
            let age = 45
            let hip = Measurement<UnitLength>(value: 45, unit: .inches)
            let waistOrThigh = Measurement<UnitLength>(value: 36, unit: .inches)
            let calfOrForearm = Measurement<UnitLength>(value: 14, unit: .inches)
            let wrist = Measurement<UnitLength>(value: 6, unit: .inches)
            
        let expectedR = 47.0
            
            let r = calc!.calculateBodyFatPercentageWithTape(gender: gender, age: age, hip: hip, waistOrThigh: waistOrThigh, calfOrForearm: calfOrForearm, wrist: wrist)
            XCTAssertEqual(r, expectedR, accuracy: 1)
        }
    
    func testCalculateBodyFatPercentageWithTapeImperial4() {
            let gender = Gender.Female
            let age = 25
            let hip = Measurement<UnitLength>(value: 42, unit: .inches)
            let waistOrThigh = Measurement<UnitLength>(value: 30, unit: .inches)
            let calfOrForearm = Measurement<UnitLength>(value: 11, unit: .inches)
            let wrist = Measurement<UnitLength>(value: 5.5, unit: .inches)
            
        let expectedR = 38.5
            
        let r = calc!.calculateBodyFatPercentageWithTape(gender: gender, age: age, hip: hip, waistOrThigh: waistOrThigh, calfOrForearm: calfOrForearm, wrist: wrist)
        XCTAssertEqual(expectedR, r, accuracy: 1)
    }

    func testCalcMenBodyFat()  {
        let age = 30
        let chest = 40
        let abdominal = 30
        let thigh = 25
        let result = calc!.calcMenBodyFat(age: age, chest: chest, abdominal: abdominal, thigh: thigh)
        XCTAssertEqual(result, 27.08, accuracy: 0.1, "Failed to calculate body fat percentage for men")

        let age2 = 50
        let chest2 = 45
        let abdominal2 = 35
        let thigh2 = 28
        let result2 =  calc!.calcMenBodyFat(age: age2, chest: chest2, abdominal: abdominal2, thigh: thigh2)
        XCTAssertEqual(result2, 32.51, accuracy: 0.1, "Failed to calculate body fat percentage for men")
    }

    func testCalcWomenBodyFat()  {
        let age = 30
        let triceps = 20
        let suprailiac = 25
        let thigh = 18
        let result =  calc!.calcWomenBodyFat(age: age, triceps: triceps, suprailiac: suprailiac, thigh: thigh)
        XCTAssertEqual(result, 25.1, accuracy: 0.1, "Failed to calculate body fat percentage for women")

        let age2 = 50
        let triceps2 = 25
        let suprailiac2 = 35
        let thigh2 = 20
        let result2 =  calc!.calcWomenBodyFat(age: age2, triceps: triceps2, suprailiac: suprailiac2, thigh: thigh2)
        XCTAssertEqual(result2, 31.6, accuracy: 0.1, "Failed to calculate body fat percentage for women")
    }

    
    
    

        func testMacroCalculator1() {
        let r = calc!.macroCalculator(calories: 1960, proteinPercent: 40, fatPercent: 40, carbPercent: 20)
        let Rprotein = r.protein
        let Rfat = r.fat
        let Rcarb = r.carb
        XCTAssertEqual(Rprotein, 196)
        XCTAssertEqual(Rfat, 87)
        XCTAssertEqual(Rcarb, 98)
        
    }
    func testMacroCalculator2() {
        let r = calc!.macroCalculator(calories: 2227, proteinPercent: 30, fatPercent: 20, carbPercent: 50)
        let Rprotein = r.protein
        let Rfat = r.fat
        let Rcarb = r.carb
            XCTAssertEqual(Rprotein, 167)
            XCTAssertEqual(Rfat, 49)
            XCTAssertEqual(Rcarb, 278)
    }
    
    // MARK: - metric, Mifflin St. Jeor
    //bmr first formula - man
    func testBmrFirstFormulaMan () {
        let weight = Measurement<UnitMass>.init(value: 70, unit: .kilograms)
        let height = Measurement<UnitLength>.init(value: 1.80, unit: .meters)
        let age = 30
        let gender = Gender.Male
        let bmr = calc!.bmrByMifflinSt(weight: weight, height: height, age: age, gender: gender, system: .Metric)
        XCTAssertEqual(bmr, 1681, accuracy: 5)
    }

    func testMyTdeeByMiffin () {
        let weight = Measurement<UnitMass>.init(value: 68, unit: UnitMass.kilograms)
        let height = Measurement<UnitLength>.init(value: 1.69, unit: UnitLength.meters)
        let age = 27
        let gender = Gender.Male
        let bmr = calc!.bmrByMifflinSt(weight: weight, height: height, age: age, gender: gender, system: .Metric)
        let tdee = calc!.TDEECalculator(BMR: bmr, activityLevel: .sedentary)
        XCTAssertEqual(tdee, 1850, accuracy: 5)
    }

    //bmr first formula - woman
    func testBmrFirstFormulaWoman () {
        let weight = Measurement<UnitMass>.init(value: 52, unit: UnitMass.kilograms)
        let height = Measurement<UnitLength>.init(value: 1.58, unit: UnitLength.meters)
        let age = 19
        let gender = Gender.Female
        let bmr = calc!.bmrByMifflinSt(weight: weight, height: height, age: age, gender: gender, system: .Metric)
        XCTAssertEqual(bmr, 1252, accuracy: 5)
    }

    //tdee first formula - man
    func testTdeeFirstFormulaMan () {
        let weight = Measurement<UnitMass>.init(value: 100, unit: UnitMass.kilograms)
        let height = Measurement<UnitLength>.init(value: 1.85, unit: UnitLength.meters)
        let age = 40
        let gender = Gender.Male
        let bmr = calc!.bmrByMifflinSt(weight: weight, height: height, age: age, gender: gender, system: .Metric)
        XCTAssertEqual(bmr, 1963, accuracy: 5)
        let tdee1 = calc!.TDEECalculator(BMR: bmr, activityLevel: .sedentary)
        let tdee2 = calc!.TDEECalculator(BMR: bmr, activityLevel: .lightlyActive)
        let tdee3 = calc!.TDEECalculator(BMR: bmr, activityLevel: .moderatelyActive)
        let tdee4 = calc!.TDEECalculator(BMR: bmr, activityLevel: .veryActive)
        let tdee5 = calc!.TDEECalculator(BMR: bmr, activityLevel: .extremelyActive)
        XCTAssertEqual(tdee1, 2257, accuracy: 5)
        XCTAssertEqual(tdee2, 2552, accuracy: 5)
        XCTAssertEqual(tdee3, 2945, accuracy: 5)
        XCTAssertEqual(tdee4, 3337, accuracy: 5)
        XCTAssertEqual(tdee5, 3730, accuracy: 5)
    }


    
    
    
}
