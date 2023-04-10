//
//  StorageViewModel.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit
import CloudKit

struct StorageViewModel {
    
    static var shared = StorageViewModel()
    
    let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("weeklyWeightPlist")
    
    var weeklyData : WeeklyData! {
        didSet {
            printWeeklyData()
        }
    }
     func printWeeklyData () {
        weeklyData.weights.forEach { print("\($0.key) : \($0.value)")}
        print("Fat: \(weeklyData.fatPercentage?.description ?? "no fat")")
    }
    /**
     ["Sunday":Float,"Monday":Float..,"fat":Float]
     */
    mutating func save (weightEntry:(day:String,weight:Float)? = nil , fat : Float? = nil) {
        guard weightEntry != nil || fat != nil else {return}
        if let weightEntry {
            weeklyData.weights[weightEntry.day] = weightEntry.weight
            print("adding \(weightEntry) to weekly data")
        } else if let fat {
            weeklyData.fatPercentage = fat
            print("adding \(fat)% to weekly data")
        }
        saveAsPlist(weeklyData)
        weeklyData = loadPlist()
    }
    
    private func saveAsPlist (_ newData:Encodable) {
        do {
            let newData = try PropertyListEncoder().encode(newData)
            try newData.write(to: filePath!)
            print("data has been saved successfully")
        } catch {
            print("Error while \(#function) : \(error). *AKA :\(error.localizedDescription)")
        }
    }
    
    private func loadPlist () -> WeeklyData? {
        
        guard let encodedData = try? Data(contentsOf: filePath!) else {return nil}
        return try? PropertyListDecoder().decode(WeeklyData.self, from: encodedData)
    }
    
    
    func currentDateComponents () -> (today:Day,weekNum:Int) {
    
        let todayIndex = DateFormatter().calendar.component(.weekday, from: Date()) - 1
        let weekOfYear = DateFormatter().calendar.component(.weekOfYear, from: Date())
        
        //for debugging
        var n = 0 //days
        var m = -1 //weeks
//        print("Week \(weekOfYear+m)")
        if n + todayIndex > Day.allCases.count-1 {n-=7;m+=1}
        
        return (today:Day.allCases[todayIndex + n],weekNum:weekOfYear + m)
    }
    
    init() {
        //load data, check if current weekNum is matching saved weekData
        if let savedWeekData = loadPlist(), savedWeekData.weekNum == currentDateComponents().weekNum {
            //if so, continue with savedData
            weeklyData = savedWeekData
            
        } else {
            //if not initialize new week data with current week num
            weeklyData = WeeklyData(weekNum: currentDateComponents().weekNum, weights: [:])
        }
        
        
    }
    
}

struct WeeklyData : Codable {
    let weekNum : Int
    var weights : [String:Float]
    var fatPercentage : Float?
}
