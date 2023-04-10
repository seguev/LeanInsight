//
//  WeightViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

let newEntryNotification = Notification.Name("newEntry")

class WeightViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {


    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var agePicker: UIPickerView!
    
    let model = WeeklyWeightViewModel()
    
    var chosenWeight : Float!
    
    var releventArray : [Float] {
        return SettingsViewModel.shared.system == .Metric ? kilograms : pounds
    }

    
    var titlesArray : [String] {
        switch SettingsViewModel.shared.system {
        case .Metric:
            return kilograms.map{$0.description+" kg"}
        case .Imperial:
            return pounds.map{$0.description+" lbs"}
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addGradient(view: view)
        title = StorageViewModel.shared.currentDateComponents().today.rawValue
        dayLabel.text = title
        
        self.sheetPresentationController?.detents = [.medium()]
        
        selectSavedValueIfAvailable()
        
    }
    
    /**
     - check for each option and fetch most updated weight
     - look for the most recent weight inside the relevent weight array
     - if not set default index - half of the relevent array size
     - set picker.selectedRow as the index if found
     - set chosen weight global var as the Float/Int found for the initial value selected in case the user doesnt scroll
     */
    private func selectSavedValueIfAvailable () {

        print(StorageViewModel.shared.weeklyData.weights)
        let system = SettingsViewModel.shared.system
                
        let releventArray = system == .Metric ? kilograms : pounds
        let unit : UnitMass = system == .Metric ? .kilograms : .pounds
        
        guard let weight = lastAvailableWeight(),
              let i = releventArray.firstIndex(of: Float(weight.converted(to: unit).value.rounded())) else {
            
            let middleIndex = releventArray.count/3
            preselectRow(middleIndex)
            chosenWeight = releventArray[middleIndex]
            return
        }
        preselectRow(i)
        
        chosenWeight = releventArray[i]
        
        /*
        if let savedWeight = StorageViewModel.shared.weeklyData.weights[todayString],
           let i = weights(system).firstIndex(of: .init(value: Double(savedWeight), unit: unit)) {
            
            agePicker.selectRow(i, inComponent: 0, animated: true)
            chosenWeight = Float(weights(system)[i].value)
            
        } else if let minWeight = StorageViewModel.shared.weeklyData.weights.values.min(),
                  let i = weights(system).firstIndex(of: .init(value: Double(minWeight), unit: unit)) {
            agePicker.selectRow(i, inComponent: 0, animated: true)
            chosenWeight = Float(weights(system)[i].value)
            
        } else if let minEver = CoreDataViewModel.shared.fetchMinAndMaxWeight()?.min,
                  let roundedWeight = Float(String(format: "%.1f", minEver)),
                  let i = weights(system).firstIndex(of: .init(value: Double(roundedWeight), unit: unit)) {
            
            agePicker.selectRow(i, inComponent: 0, animated: true)
            chosenWeight = Float(weights(system)[i].value)
        } else {
            let half = agePicker.numberOfRows(inComponent: 0) / 2
            agePicker.selectRow(half, inComponent: 0, animated: true)
            chosenWeight = Float(weights(system)[half].value)
        }
        */
        
    }
    
    private func lastAvailableWeight () -> Measurement<UnitMass>? {
        let today = StorageViewModel.shared.currentDateComponents().today.rawValue
        var result : Double!
        
        if let todayWeight = StorageViewModel.shared.weeklyData.weights[today] {
            result = Double(todayWeight)

        } else if !StorageViewModel.shared.weeklyData.weights.isEmpty {
            let thisWeekWeights = StorageViewModel.shared.weeklyData.weights.map{$0.value}
            let thisWeekAverage = average(of: thisWeekWeights)
            result = Double(thisWeekAverage)
            
        } else if let averageWeightEver = CoreDataViewModel.shared.fetchAverageWeight() {
            result = Double(averageWeightEver)
            
        } else {
            return nil
        }
        return .init(value: result, unit: .kilograms)
        
    }
    
    private func preselectRow (_ row:Int) {
        agePicker.selectRow(row, inComponent: 0, animated: true)
    }
    
    
    @IBAction func savePressed(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: updateStatsNotification, object: nil)
        NotificationCenter.default.post(name: weightUpdateNotification, object: chosenWeight)

        self.dismiss(animated: true)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        titlesArray.count
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        chosenWeight = releventArray[row]
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let format = SettingsViewModel.shared.system == .Metric ? "%.1f" : "%.0f"
        let s = SettingsViewModel.shared.system == .Metric ? "kg" : "lbs"
        
        return String(format: format, releventArray[row])+" "+s
    }
    
    
}

