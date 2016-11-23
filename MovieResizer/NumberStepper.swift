//
//  NumberStepper.swift
//  MovieResizer
//
//  Created by Hideko Ogawa on 11/22/16.
//  Copyright © 2016 SoraUsagi Apps. All rights reserved.
//

import Cocoa

class NumberStepper: NSView {

    @IBOutlet var textField: NSTextField!
    @IBOutlet var stepper: NSStepper!
    
    func applyValue(_ value:Int) {
        stepper?.integerValue = value
        textField?.integerValue = value
    }
}
