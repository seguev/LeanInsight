//
//  MainViewController.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import UIKit

class MainViewController: UIViewController  {
  
    @IBOutlet weak var caliperButton: UIButton!
    @IBOutlet weak var tapeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        addGradient(view: view)
//        makeButtonRound(tapeButton)
//        makeButtonRound(caliperButton)
        
        addBlur(to: tapeButton)
        addBlur(to: caliperButton)
    }
    

    
    private func addBlur (to button:UIButton) {
        
        //add blur to view
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterialDark))
        blur.alpha = 0.4
        blur.frame = view.frame
        blur.isUserInteractionEnabled = false
        view.addSubview(blur)
        
        button.insertSubview(blur, at: 1)
        button.layer.masksToBounds = true
        button.configuration?.cornerStyle = .fixed
        button.layer.cornerRadius = 80

    }
    
    
    @IBAction func calcWithCaliper(_ sender: UIButton) {
     touchFeedback()
        performSegue(withIdentifier: "toCaliper", sender: self)
        
    }
    
    @IBAction func calcWithTape(_ sender: UIButton) {
        touchFeedback()
        performSegue(withIdentifier: "toTape", sender: self)
        
    }


    
}
