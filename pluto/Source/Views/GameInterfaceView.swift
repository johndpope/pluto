//
// Created by John Sparks on 7/30/15.
// Copyright (c) 2015 John Sparks. All rights reserved.
//

import Foundation
import UIKit


public class GameInterfaceView : UIView {

    let forwardButton : UIImageView
    let backButton : UIImageView
    let buttonSize: CGSize

    public override init(frame: CGRect) {

        let forwardImage = UIImage(named: "right_arrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let backImage = UIImage(named: "left_arrow")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

        buttonSize = forwardImage!.size

        forwardButton = UIImageView(image: forwardImage)
        forwardButton.tintColor = UIColor.whiteColor()

        backButton = UIImageView(image: backImage)
        backButton.tintColor = UIColor.whiteColor()


        super.init(frame: frame)

        addSubview(forwardButton)
        addSubview(backButton)
    }


    public override func layoutSubviews() {

        let margin:CGFloat = 10.0
        let y = frame.size.height - buttonSize.height - margin
        let backX:CGFloat = 10.0
        let forwardX = frame.size.width - buttonSize.width - margin

        let backOrigin = CGPoint(x: backX, y: y)
        let forwardOrigin = CGPoint(x: forwardX, y: y)

        backButton.frame = CGRect(origin: backOrigin, size: buttonSize)
        forwardButton.frame = CGRect(origin: forwardOrigin, size: buttonSize)

        super.layoutSubviews()
    }

    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}