//
//  TapeCalcModel.swift
//  LeanInsight
//
//  Created by segev perets on 10/04/2023.
//

import Foundation

struct TapeCalcModel {
    
    var age : Int?
    var hips : Measurement<UnitLength>?
    var waistAndThigh : Measurement<UnitLength>?
    var forarmAndCalf : Measurement<UnitLength>?
    var wrist: Measurement<UnitLength>?
    var fatPercentage: Double?
    var gender : Gender = .Male
    
    
}
