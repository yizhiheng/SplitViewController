//
//  ViewController.swift
//  Psychologist
//
//  Created by Zhiheng Yi on 2015-05-31.
//  Copyright (c) 2015 Zhiheng Yi. All rights reserved.
//

import UIKit

class PsychologistViewController: UIViewController {
    
    @IBAction func nothing(sender: UIButton) {
        //用code来执行segue!
        performSegueWithIdentifier("nothing", sender: sender)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //注意,重写的这个函数是这个UIStroyBoard里的所有Segue都会调用的函数
        //但是当用代码执行的适合,sender会不同!!!
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let hvc = destination as? HappinessViewController {
            if let identifier = segue.identifier {
                switch identifier {
                case "sad": hvc.happiness = 0
                case "happy": hvc.happiness = 100
                case "nothing": hvc.happiness = 25
                default: hvc.happiness = 50
                }
            }
        }
    }
}

