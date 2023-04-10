//
//  GraphViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit
import AVFoundation
import Charts

class GraphViewController: UIViewController, ChartViewDelegate {
 
    @IBOutlet var backGroundDefaultGraph: UIImageView!
    @IBOutlet var blurView: UIVisualEffectView!
    @IBOutlet var noDataPopUp: UIView!
    @IBOutlet var popUP: UIView!
    @IBOutlet weak var popUpFirstLabel: UILabel!
    @IBOutlet weak var popUpSecondLabel: UILabel!
    @IBOutlet weak var popUpThirdLabel: UILabel!
    @IBOutlet weak var popUpFourthLabel: UILabel!
    
    var model = GraphViewModel()
    let lineChartView = LineChartView()
    var selectedEntry : Entry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        CoreDataViewModel.shared.addGradient(view: self.view)
        
        addGradient(view: view)
        
        lineChartView.delegate = self
        
//        model.chartSetup(self.view, chart: lineChartView)
        model.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        model.chartSetup(self.view, chart: lineChartView)
        model.updateChart(to: lineChartView)

        if model.entriesArray.count <= 1 && model.debugEntries.isEmpty {
            model.showNoDataPopUp(noDataPopUp, backGroundDefaultGraph, blurView, in: view)
            lineChartView.isUserInteractionEnabled = false
        } else {
            backGroundDefaultGraph.removeFromSuperview()
            model.hideNoDataPopUp(noDataPopUp, blur: blurView)
            lineChartView.isUserInteractionEnabled = true
        }
    }


    // MARK: - delegate func
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {

        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
        
        //config label with debug data
        //user model.debugArray insted of model.entriesArray
        
        if !model.entriesArray.isEmpty {
            selectedEntry = model.entriesArray[Int(entry.x - 1)]
        } else {
            let avWeight = Float(model.debugEntries[Int(entry.x)].yValue)  //for debug!
            let fat = avWeight / 4                                         //for debug!
            let weekNub = Int16(model.debugEntries[Int(entry.x)].xValue)   //for debug!
            let debugInfo = (avWeight:avWeight,fatPer:fat,weekNum:weekNub,bmi:Float.random(in: 20...24)) //for debug!
            presentPopUp(highlight, info: debugInfo)                       //for debug!
            return
        }
        let entryInfo = model.fetchEntryInfo(entry)
        
        presentPopUp(highlight, info: entryInfo)
    }
    
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        popUP.removeFromSuperview()
    }
    
    
    private func presentPopUp (_ hightLight: Highlight, info:(avWeight: Float, fatPer: Float?, weekNum: Int16,bmi:Float))  {
        
        //popUp position & size
//        let position = CGPoint(x: hightLight.xPx, y: view.frame.height * 0.2)
        let position = CGPoint(x: view.center.x, y: view.frame.height * 0.2)
        let size = CGSize(width: 180, height: 120)
        popUP.frame = .init(origin: .zero, size: size)
        popUP.center = position
        
        let fatStr = info.fatPer != nil ? String(format: "%.1f", info.fatPer!) : "-"
        
        //label config
        popUpFirstLabel.text    = info.weekNum.description
        popUpSecondLabel.text   = String(format: "%.1f", info.avWeight)
        popUpThirdLabel.text    = fatStr
        popUpFourthLabel.text   = String(format: "%.1f", info.bmi)
        model.popUpConfig(popUP)
        
        if popUpThirdLabel.text == "-" {
            popUpThirdLabel.textAlignment = .left
        }
        
        view.addSubview(popUP)
        
//        model.handleOffScreen(view,popUP)
    }



}
