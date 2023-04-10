//
//  WeekViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit
import AVFoundation

let weightUpdateNotification = Notification.Name("weightUpdate")
let fatUpdateNotification = Notification.Name("fatUpdate")
let updateStatsNotification = Notification.Name("updateStats")

class WeekViewController: UIViewController , WeeklyWeightModelDelegate {
    @IBOutlet weak var stacksStackView: UIStackView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var weightButton: UIButton!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var fatButton: UIButton!
    @IBOutlet weak var fatLabel: UILabel!
    @IBOutlet weak var bmiLabel: UILabel!
    @IBOutlet weak var tdeeLabel: UILabel!
    @IBOutlet weak var classificationLabel: UILabel!
    @IBOutlet var scrollViewPopUp: UIView!
    @IBOutlet weak var recommendationLabel: UILabel!
    @IBOutlet weak var infoPopUpLabel: UILabel!
    
    var infoLabel : UILabel?
    var warningLabel : UILabel?
    var player : AVAudioPlayer!

    let userInfo = SettingsViewModel()
    let calc = CalculatorViewModel()
    let vm = WeeklyWeightViewModel()
    
    
    // MARK: - initial setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        barItemImageFallback()
        
        vm.delegate = self
        
        vm.floatingViewSetup(stacksStackView)
        
        buttonsInitialSetup()

        observersSetup()
        
        vm.updateTitleLabel(todayLabel)
        
        vm.checkIfEnoughForGraphUpdate()
        
        vm.updateProgressBar(progressBar)
        vm.scrollViewPopUpInitialSetup(popup: scrollViewPopUp, superView: view)
        updateCalculatedLabels(Notification(name: updateStatsNotification))
        
        let buttons = view.subviews.filter{$0 is UIButton}
        vm.animateViewsIn(stacksStackView.subviews,buttons: buttons)
    }
        
    private func barItemImageFallback () {
        
        if #available(iOS 16.0, *) {
            
            tabBarController?.tabBar.items![0].image = UIImage(systemName: "list.bullet.clipboard")
          
        } else {
            tabBarController?.tabBar.items![0].image = UIImage(systemName: "list.bullet.rectangle.portrait")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateWarningLabel()
    }

    
    @objc private func viewIsTouched (_ sender:UITapGestureRecognizer) {
        guard let touchedView = sender.view else {fatalError("Cant find touched view")}
        touchedView.removeFromSuperview()
        self.performSegue(withIdentifier: "toQuiz", sender: self)
    }
    
    private func updateWarningLabel () {
        
        warningLabel?.removeFromSuperview()
        
        if !SettingsViewModel.shared.isAllDataAvailable {
            
            let label = vm.warningLabel()
            label.textColor = .systemRed
            label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewIsTouched(_:))))
            view.addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
                label.widthAnchor.constraint(equalToConstant: 250),
                label.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0)
             ])
            warningLabel = label
        }
    }
    
    // MARK: - observers & notifications
    
    private func observersSetup () {
        NotificationCenter.default.addObserver(self, selector: #selector(saveNewWeight(_:)), name: weightUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fatUpdate(_:)), name: fatUpdateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateCalculatedLabels(_:)), name: updateStatsNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(removeLabel(_:))))
        progressBar.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(progressBarTapped(_:))))
        
    }
    @objc private func removeLabel (_ selector:UIGestureRecognizer) {
        infoLabel?.removeFromSuperview()
        // do more things when screen is touched ..
    }
    /**
     Being called when user sets weight .
     */
    @objc private func saveNewWeight (_ notification:Notification) {
        guard let newWeight = notification.object as? Float else {fatalError()}
        let today = StorageViewModel.shared.currentDateComponents().today.rawValue
        StorageViewModel.shared.save(weightEntry: (day: today, weight: newWeight))

        vm.checkIfEnoughForGraphUpdate()
        vm.updateTodaysWeight(weightButton)
        playCheckmarkSound()
        vm.updateProgressBar(progressBar)
        updateCalculatedLabels(Notification(name: updateStatsNotification))
    }
    /**
     userInfo keys : "fat", "class" (as in "classification")
     */
    @objc private func fatUpdate(_ notification:Notification) {
        
        let fat = notification.userInfo!["fat"] as! Double
//        let classification = notification.userInfo!["class"] as! String
        
        StorageViewModel.shared.save(fat: Float(fat))
        
        vm.checkIfEnoughForGraphUpdate()

        vm.updateTodaysFat(fatButton)
        playCheckmarkSound()
        vm.updateProgressBar(progressBar)
    }
    /**
     TDEELabel, BodyFatLabel, BMILabel.
     */
    @objc private func updateCalculatedLabels (_ notification:Notification) {

        let lastWeightAvailable = vm.fetchLastWeightAvailable()
        let mostUpdatedBodyFat = vm.fetchMostUpdatedBodyFat()
        
        let tdee = vm.TDEE(weight: lastWeightAvailable, fat: mostUpdatedBodyFat)
        let bmi = vm.updateBMILabel(weight:lastWeightAvailable)
        
        classificationLabel.text = setClassificationLabel()

        tdeeLabel.text = tdee != nil ? String(tdee!) : "-"

        bmiLabel.text = bmi != nil ? String(format: "%.1f", bmi!) : "-"

        fatLabel.text = mostUpdatedBodyFat != nil ? String(format: "%.1f", mostUpdatedBodyFat!) : "-"
        
        guard let tdee = tdee, let bmi = bmi else {
            recommendationLabel.text = "-"
            return
        }
        recommendationLabel.text =  vm.fetchCaloriesRecommendation(tdee: tdee, bmi: bmi, fat: mostUpdatedBodyFat)
    }
    /**
     Users BMI classification if fat percentage is nil, and uses fat classification if available .
     */
    // MARK: - buttons setup
    private func buttonsInitialSetup () {
        
        for button in [weightButton,fatButton] {
            vm.addShadowToButton(button!)
        }
        
        vm.updateTodaysWeight(weightButton)
        
        vm.updateTodaysFat(fatButton)
        
    }
    
// MARK: - UI interactions

    @IBAction func fatButtonPressed(_ sender: UIButton) {
        touchFeedback()
        vm.clickAnimation(fatButton) {
            self.performSegue(withIdentifier: "toFat", sender: self)
        }
        
    }

    @IBAction func todayButtonPressed(_ sender: UIButton) {
        touchFeedback()
        vm.clickAnimation(weightButton) {
            self.performSegue(withIdentifier: "toWeight", sender: self)
        }
        
    }
    
    @objc private func progressBarTapped (_ sender:UITapGestureRecognizer) {
        touchFeedback()
        let hasAtLeastOneEntry = CoreDataViewModel.shared.loadFromCoreData()!.count >= 1
        let numOfWeeklyEntries = StorageViewModel.shared.weeklyData.weights.count
        let info = InfoModel()
        
        let text = vm.chooseTextForLabel(hasAtLeastOneEntry,numOfWeeklyEntries)
        
        infoLabel?.removeFromSuperview()
        infoLabel = info.showInfoLabel(view, text: text, top: false)

    }
    
// MARK: - sound
    private func playCheckmarkSound () {
        
        let url = Bundle.main.url(forResource: "checkSound", withExtension: "wav")!
            player = try! AVAudioPlayer(contentsOf: url)
        player.volume = 0.05
            player.play()
    }

    // MARK: - info buttons
    private func setClassificationLabel () -> String {
        
        if let fatClassification = vm.fatClassification {
            return fatClassification
        } else if let bmiClassificaion = vm.bmiClassificaion {
            return bmiClassificaion
        } else {
            return "-"
        }
    }

    @IBAction func statsInfoButtonPressed(_ sender: UIButton) {
        touchFeedback()
        switch sender.tag {
        case 0:
            vm.updateInfoPopUpLabel(infoPopUpLabel, infoType: .BMIInfo)
            vm.showInfoPopUp(popup: scrollViewPopUp)
        case 1:
            vm.updateInfoPopUpLabel(infoPopUpLabel, infoType: .bodyFatInfo)
            vm.showInfoPopUp(popup: scrollViewPopUp)
        case 2:
            
            let gotFat = vm.fetchMostUpdatedBodyFat() != nil
            let isMan = SettingsViewModel.shared.gender == .Male
            
            if !gotFat {
                vm.updateInfoPopUpLabel(infoPopUpLabel, infoType: .classificationByBmi )
            } else if gotFat && isMan {
                vm.updateInfoPopUpLabel(infoPopUpLabel, infoType: .classificationForMenByFatPercentInfo )
            } else if gotFat && !isMan {
                vm.updateInfoPopUpLabel(infoPopUpLabel, infoType: .classificationForWomenByFatPercentInfo )
            } else { //gender is nil
                vm.updateInfoPopUpLabel(infoPopUpLabel, infoType: .classificationByBmi )
            }
            vm.showInfoPopUp(popup: scrollViewPopUp)
        case 3:
            vm.updateInfoPopUpLabel(infoPopUpLabel, infoType: .tdeeInfo)
            vm.showInfoPopUp(popup: scrollViewPopUp)
        case 4:
            //check if caloric deficit is needed and adjust label accordingly

            if let phase = vm.decideIfCutOrBulk() {
                switch phase {
                case .cut:
                    vm.updateInfoPopUpLabel(infoPopUpLabel, infoType: .calDefInfo )
                case .bulk:
                    vm.updateInfoPopUpLabel(infoPopUpLabel, infoType: .calPlusInfo )
                }
            } else {
                vm.updateInfoPopUpLabel(infoPopUpLabel, infoType: nil )
            }
            
            vm.showInfoPopUp(popup: scrollViewPopUp)
        default:
            fatalError()
        }
    }
    

    
    @IBAction func infoPressed(_ sender: UIBarButtonItem) {
        touchFeedback()
        infoLabel?.removeFromSuperview()
        let i = InfoModel()
        infoLabel = i.showInfoLabel(view, text: i.weeklyWeightInfo,top: false)
    }
    
}

