//
//  CoreDataViewModel.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import Foundation
import UIKit
import CoreData

class CoreDataViewModel {
    static let shared = CoreDataViewModel()
    
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func saveToCoreData (_ weightAverage:Float?,_ bmi:Float?, fatPercentage:Float?, weekNum:Int) {
        //fech all objects with current weekNum, if available update them
        //if no objects has been found, initialize new one
        let weekNum = Int16(weekNum)
        
        if let currentWeekEntry = fetchCurrentWeekEntry(weekNum) {
            if let fatPercentage {
                currentWeekEntry.fatPercentage = fatPercentage
            }
            if let weightAverage {
                currentWeekEntry.weightAverage = weightAverage
            }
            if let bmi {
                currentWeekEntry.bmi = bmi
            }
            do {
                try context.save()
            } catch {
                print("Error while \(#function) : \(error). *AKA :\(error.localizedDescription)")
            }
        } else {
            //current week does not have any corresponding entries
            let newEntry = Entry(context: context)
            newEntry.weekNum = weekNum
            if let fatPercentage {
                newEntry.fatPercentage = fatPercentage
            }
            if let weightAverage {
                newEntry.weightAverage = weightAverage
            }
            if let bmi {
                newEntry.bmi = bmi
            }
            do {
                try context.save()
            } catch {
                print("Error while \(#function) : \(error). *AKA :\(error.localizedDescription)")
            }        }
    }
    

    
    func fetchCurrentWeekEntry (_ weekNum:Int16) -> Entry? {
        let predicate = NSPredicate(format: "weekNum == %i", weekNum)
        guard let matchingEntries = loadFromCoreData(with: predicate), matchingEntries.count != 0 else {return nil}
        if matchingEntries.count > 1 {fatalError("(!!!) Found \(matchingEntries.count) weeks with n:\(weekNum)")}
        return matchingEntries[0]
    }
    
    func loadFromCoreData (with predicate:NSPredicate? = nil) -> [Entry]? {
        let request = NSFetchRequest<Entry>(entityName: "Entry")
        
        if let pred = predicate {
            request.predicate = pred
        }
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error while \(#function) : \(error). *AKA :\(error.localizedDescription)")
            
        }
            return nil
    }
    
    func deleteFromCoreData (_ entry:Entry) {
        do {
            context.delete(entry)
            try context.save()
            print("New entry has been saved!")
        } catch {
            print("Saving Failed! : \(error)")
        }
    }
    
    func fetchMinAndMaxBmi () -> (min:Double, max:Double)? {
        
        let request = NSFetchRequest<Entry>(entityName: "Entry")
        request.predicate = NSPredicate(format: "bmi LIKE %@", "*")
        var allBMIs = [Double]()
        
        do {
            let BMIs = try context.fetch(request)
            for entry in BMIs {
                allBMIs.append(Double(entry.bmi))
            }
            
            guard !allBMIs.isEmpty, let max = allBMIs.max(), let min = allBMIs.min() else { return nil }
            
            return (min:min, max:max)
            
        } catch {
            print("Error while \(#function) : \(error). *AKA :\(error.localizedDescription)")
            return nil
        }
    }
    
    
    
    
    func fetchMinAndMaxWeight () -> (min:Double, max:Double)? {
        
        let request = NSFetchRequest<Entry>(entityName: "Entry")
        request.predicate = NSPredicate(format: "weightAverage LIKE %@", "*")
        var allWeights = [Double]()
        
        do {
            let weights = try context.fetch(request)
            for weight in weights {
                allWeights.append(Double(weight.weightAverage))
            }
            
            guard !allWeights.isEmpty, let max = allWeights.max(), let min = allWeights.min() else { return nil }
            
            return (min:min, max:max)
            
        } catch {
            print("Error while \(#function) : \(error). *AKA :\(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchAverageWeight () -> Float? {
        let request = NSFetchRequest<Entry>(entityName: "Entry")
        request.predicate = .init(format: "weightAverage LIKE %@ ", "*")
        if let entriesWithWeight = try? context.fetch(request) {
            let entriesWeight = entriesWithWeight.map{$0.weightAverage}
            return average(of: entriesWeight)
        } else {
            return nil
        }
    }
    
    func fetchMinAndMaxFat () -> (min:Double, max:Double) {
        
        let request = NSFetchRequest<Entry>(entityName: "Entry")
        request.predicate = NSPredicate(format: "fatPercentage LIKE %@", "*")
        var allFats = [Double]()
        
        do {
            let allEntries = try context.fetch(request)
            for e in allEntries {
                allFats.append(Double(e.fatPercentage))
            }
            
            guard let max = allFats.max(), let min = allFats.min() else { return (0.0,0.0) }
            
            return (min:min, max:max)
            
        } catch {
            print("Error while \(#function) : \(error). *AKA :\(error.localizedDescription)")
            return (0.0,0.0)
        }
    }
    
    
    
    
}


func makeButtonRound (_ button:UIButton) {
    button.layer.cornerRadius = 10
    button.clipsToBounds = true
    let layer = CAGradientLayer()
    layer.frame = button.bounds
    let colors = [#colorLiteral(red: 0.2431372549, green: 0.3294117647, blue: 0.6745098039, alpha: 1).cgColor, #colorLiteral(red: 0.3960784314, green: 0.3647058824, blue: 0.7333333333, alpha: 1).cgColor]
    layer.colors = colors
    button.layer.insertSublayer(layer, at: 0)
}

func addGradient (colors : [UIColor] = [#colorLiteral(red: 0.9254901961, green: 0.901304543, blue: 1, alpha: 1), #colorLiteral(red: 0.9254901961, green: 0.9490196078, blue: 1, alpha: 1)], view:UIView) {
    let layer = CAGradientLayer()
    let colors = colors
    layer.colors = colors
    layer.transform = CATransform3DMakeRotation(CGFloat.pi, 0, 0, 1)
    layer.frame = view.frame
    view.layer.insertSublayer(layer, at: 0)
    
}
