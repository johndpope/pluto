//
// Created by John Sparks on 7/30/15.
// Copyright (c) 2015 John Sparks. All rights reserved.
//

import Foundation

public  func logInterval(block:() -> String){
    let interval = 0.2
    print(block())
    let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(interval * Double(NSEC_PER_SEC)))
    dispatch_after(delay, dispatch_get_main_queue()) {
        logInterval(block)
    }
}
