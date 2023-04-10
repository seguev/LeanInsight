//
//  GraphViewModel.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

// https://weeklycoding.com/mpandroidchart-documentation/

import Foundation
import Charts
import UIKit
import CoreData

struct GraphViewModel {
    
    var sets : [LineChartDataSet] = []
    var entriesArray : [Entry] = []
    var debugEntries = [(xValue:Double,yValue:Double)]()
    weak var delegate : GraphViewController?
    
    /**
     chart setup
     */
    func chartSetup (_ view:UIView, chart:LineChartView) {
        chart.rightAxis.enabled = false
        chart.xAxis.labelPosition = .bottom
        chart.leftAxis.labelPosition = .outsideChart
        chart.doubleTapToZoomEnabled = false
        chart.pinchZoomEnabled = false
        chart.dragEnabled = true
        chart.xAxis.labelFont = .systemFont(ofSize: 12)
        chart.center = view.center
        chart.leftAxis.enabled = false
        chart.xAxis.enabled = false
        chart.leftAxis.axisLineColor = .black
        chart.rightAxis.axisLineColor = .black
        chart.leftAxis.drawLabelsEnabled = false
        chart.drawMarkers = false
        chart.drawGridBackgroundEnabled = false
        chart.scaleYEnabled = false
        chart.scaleXEnabled = false
        chart.drawMarkers = false
        chart.minOffset = 0
        chart.extraTopOffset = 200
        chart.noDataText = "Not enough entries"
        chart.noDataFont = .systemFont(ofSize: 30)

        //bmi & weight are shating left graph
//        let minimumWeightOrBmi =
        
        //weight axis
        chart.leftAxis.axisMinimum = (CoreDataViewModel.shared.fetchMinAndMaxWeight() ?? (0.0,0.0)).min * 0.9
        chart.leftAxis.axisMaximum = (CoreDataViewModel.shared.fetchMinAndMaxWeight() ?? (0.0,0.0)).max
        
        //fat axis
        chart.rightAxis.axisMinimum = CoreDataViewModel.shared.fetchMinAndMaxFat().min * 0.9
        chart.rightAxis.axisMaximum = CoreDataViewModel.shared.fetchMinAndMaxFat().max * 1.1

        view.addSubview(chart)
        chart.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            chart.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            chart.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            chart.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    /**
     adds data to chartview
     - delete previous ChartData to prevent ovelap
     - load all available data from coreData
     - creates weight (line)set and fatPersentage (line)set
     - add set as a data set to chart
     - calls setData() that sets each line properties
     */
    mutating func updateChart(to chart:LineChartView) {
        sets = []
        entriesArray = []

        var weightEntriesArray : [ChartDataEntry] = []
        var fatEntriesArray : [ChartDataEntry] = []
//        var bmiEntriesArray : [ChartDataEntry] = []
        
        //create safe loaded data if exist
        if var loadedData = CoreDataViewModel.shared.loadFromCoreData(), !loadedData.isEmpty {
            loadedData.sort { $0.weekNum < $1.weekNum }
//            loadedData.forEach{print($0.bmi)} ;#warning("debugging")

            //add data from coreData to global array for us to fetch later if needed
            entriesArray.append(contentsOf: loadedData )
            
            //set starting index
            var entryIndex : Double = 0.0
            
            //for each entry, seperate fat and weight for ChartDataSets
            for entry in entriesArray {
                
                let fat = Double(entry.fatPercentage) != 0.0 ? Double(entry.fatPercentage) : nil
                let weight = Double(entry.weightAverage)
//                let bmi = Double(entry.bmi)

                entryIndex += 1
                
                //set weightEntry
                let weightChartEntry = ChartDataEntry(x: entryIndex, y: weight)
                weightEntriesArray.append(weightChartEntry) //add to local array
                
                //set fatEntry
                if let fat {
                    let fatChartEntry = ChartDataEntry(x: entryIndex, y: fat)
                    fatEntriesArray.append(fatChartEntry) //add to local array
                }
                
                
                /*
                //set bmiEntry
                //set the bmiLine close to the weight line
                let bmiChartEntry = ChartDataEntry(x: entryIndex, y: bmi * 3.3) ;#warning("maybe another solution")

                bmiEntriesArray.append(bmiChartEntry) //add to local array
                 */
            }
            
            handleSuddenFatEntries(&fatEntriesArray, totalEntriesCount: weightEntriesArray.count)
            
            //fetch from local array after beings set
            let weightSet = LineChartDataSet(entries: weightEntriesArray, label: "weight")
            let fatSet = LineChartDataSet(entries: fatEntriesArray, label: "fat%")
//            let bmiSet = LineChartDataSet(entries: bmiEntriesArray, label: "BMI")
            
            //go to next func and setup each line
            setData(set1:weightSet, set2:fatSet, chart:chart)
            
        } else {
            print("there's no available data!, using debug data?")
            useDebugData(chart, isDebug: false)
        }
    }
    
    ///Prevent mid screen single dot & mid screen initial value
    /// - Hides one entry
    /// - Inserts Y value at i==0. y:0 == y:1 .
    private func handleSuddenFatEntries (_ fatEntriesArray: inout [ChartDataEntry], totalEntriesCount:Int) {
        
        //prevent one dot in the middle of the screen
        guard fatEntriesArray.count > 2 else {
            fatEntriesArray = []
            return
        }

        
        if fatEntriesArray.count < totalEntriesCount {
            if let tmpY = fatEntriesArray.first?.y {
                fatEntriesArray.insert(ChartDataEntry(x: 1.0, y: tmpY), at: 0)
            } else {
                fatalError("WTF")
            }
            
        }
    }
    
    private mutating func useDebugData (_ chart:LineChartView, isDebug : Bool = true, entriesNum:Int = 20) {
        guard isDebug else {return}
        
        //create chartDataEntries
        var entries = [ChartDataEntry]()
        var y : Double?

        for i in 0..<entriesNum {

            if y == nil { //first entry
                y = Double(Int.random(in: 80...120))
                
            } else { //all the rest
                y! -= Double(Float.random(in: 1...4))
                
            }
            debugEntries.append((xValue: Double(i), yValue: y!))
            entries.append(ChartDataEntry(x: Double(i), y: y!))
        }

        //init lineChartData from set
        let debugSet = LineChartDataSet(entries: entries, label: "Debug Data")

        //config set
        debugSet.highlightColor = .systemYellow
        debugSet.mode = .linear
        debugSet.circleRadius = 7
        debugSet.drawFilledEnabled = true
        debugSet.fillAlpha = 0.6
//        debugSet.valueTextColor = .clear
        debugSet.valueFont = .systemFont(ofSize: 15)
        debugSet.drawHorizontalHighlightIndicatorEnabled = false
        debugSet.fillColor = .darkGray
        debugSet.colors = [NSUIColor(cgColor: UIColor.gray.cgColor)]
        debugSet.circleColors = [NSUIColor(cgColor: UIColor.lightGray.cgColor)]
        debugSet.axisDependency = .left
        
        //set chart.data as initialized data
        chart.data = LineChartData(dataSet: debugSet)
        chart.leftAxis.axisMinimum = 40
        chart.leftAxis.axisMaximum = 120
    }
    
    
    
    //2. being called from fechAllEntries()
    private mutating func setData (set1:LineChartDataSet,set2:LineChartDataSet, set3:LineChartDataSet? = nil ,chart:LineChartView) {
        //add chart data to a new set everytime func is called
        
        let c1 = UIColor(red: 0.173, green: 0.243, blue: 0.314, alpha: 1.0).cgColor
        
        let c2 = UIColor(red: 0.075, green: 0.424, blue: 0.576, alpha: 1.0).cgColor

        
        let cBackGround = UIColor(named: "secondSetBackGround")!.cgColor
        
        
        
        //weightSet
        set1.fill = LinearGradientFill(gradient: CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                                            colors: [c2,cBackGround] as CFArray,
                                                            locations: [1.0,0.0])!,
                                       angle: 90)

        set1.colors = [NSUIColor(cgColor:c2)]
        set1.circleColors = [NSUIColor(cgColor:c2)]
        set1.axisDependency = .left
/*
        let fM = DefaultValueFormatter()
        fM.decimals = 1
        fM.decimals = 6
        set1.valueFormatter = fM
  */
        sets.append(set1)
        
        //fatSet
        set2.fill = LinearGradientFill(gradient: CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                                            colors: [c1,cBackGround] as CFArray,
                                                            locations: [1.0,0.0])!,
                                       angle: 90)

        set2.colors = [NSUIColor(cgColor:c1)]
        set2.circleColors = [NSUIColor(cgColor:c1)]
        set2.axisDependency = .right
        
        sets.append(set2)
        
        /*
        if let set3 {
            //bmiSet
            set3.fill = LinearGradientFill(gradient: CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                                                colors: [c2,cBlank] as CFArray,
                                                                locations: [1.0,0.0])!,
                                           angle: 90)
            set3.colors = [NSUIColor(cgColor: c2)]
            set3.circleColors = [NSUIColor(cgColor: c2)]
            set3.axisDependency = .left
            
            sets.append(set3)
        }
        */
        sets.forEach { uniSet in
            uniSet.highlightColor = UIColor(named: "secondSetText")!
            uniSet.mode = .linear
            uniSet.circleRadius = 4
            uniSet.drawFilledEnabled = true
            uniSet.fillAlpha = 0.4
//            uniSet.valueFont = .systemFont(ofSize: 10)
            uniSet.valueTextColor = .clear
            uniSet.valueFont = .systemFont(ofSize: 15)
            
            uniSet.drawHorizontalHighlightIndicatorEnabled = false
            uniSet.drawFilledEnabled = true

        }
        //make data from global setsArray
        let newData = LineChartData(dataSets: sets)
        
//        let newData = LineChartData(dataSets: [set1,set2,set3])
        //attach data to chart
        chart.data = newData
        
    }
    

    func fetchEntryInfo (_ entry:ChartDataEntry) -> (avWeight:Float,fatPer:Float?,weekNum:Int16,bmi:Float) {
        let index = Int(entry.x)
        let selectedEntry = entriesArray[index - 1]
        let fat = selectedEntry.fatPercentage != 0.0 ? selectedEntry.fatPercentage : nil
        
        let entry = (selectedEntry.weightAverage,fat,selectedEntry.weekNum,selectedEntry.bmi)
        return entry
    }
    
    /*
    func handleOffScreen(_ view:UIView,_ popUP:UIView) {
        
        if popUP.frame.origin.x < 0 {
            popUP.frame.origin.x = 5
            
        } else if popUP.frame.maxX > view.frame.width {
            popUP.frame.origin.x = view.frame.width - popUP.frame.width - 5
        }
    }
    */
    
    /**
     Add shadow to popup
     */
    func popUpConfig(_ popUP:UIView) {
        popUP.backgroundColor = UIColor(named: "secondSetBackGround")
        popUP.layer.shadowColor = UIColor.darkGray.cgColor
        popUP.layer.shadowOffset = .init(width: 4, height: 4)
        popUP.layer.shadowRadius = 5
        popUP.layer.shadowOpacity = 0.7
        popUP.layer.cornerRadius = 10
    }
    
    func showNoDataPopUp (_ popUp:UIView,_ backgroundGraphView:UIImageView ,_ blur: UIVisualEffectView, in view:UIView) {
        
        backgroundGraphView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundGraphView)
        NSLayoutConstraint.activate([
            backgroundGraphView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            backgroundGraphView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            backgroundGraphView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            backgroundGraphView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        
        blur.effect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        blur.alpha = 0.8
        popUp.alpha = 0
        view.addSubview(blur)
        blur.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blur.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            blur.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            blur.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            blur.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        view.addSubview(popUp)
        popUp.frame = .init(x: view.center.x, y: 50, width: 200, height: 150)
        popUp.center = .init(x: view.center.x, y: view.center.y - 100 )
        
        UIView.animate(withDuration: 0.5,delay: 0.2) {
            
            popUp.alpha = 1

            popUp.backgroundColor = .systemGray6
            popUp.layer.cornerRadius = 10
            popUp.layer.shadowColor = UIColor.black.cgColor
            popUp.layer.shadowRadius = 20
            popUp.layer.shadowOffset = .init(width: 4, height: 4)
            popUp.layer.shadowOpacity = 0.5
        }

    }
    func hideNoDataPopUp (_ popUp:UIView, blur:UIVisualEffectView) {
        popUp.removeFromSuperview()
        blur.removeFromSuperview()
    }
    
    
}
