//
//  BoatImageView.swift
//  StreamDemo
//
//  Created by James Langdon on 12/4/19.
//  Copyright © 2019 corporatelangdon. All rights reserved.
//

import UIKit

enum BoatType: String, CaseIterable {
    case red_boat
    case green_boat
    case yellow_boat
    case pirate_boat
    case purple_boat
    case blue_boat
    
    static var random: BoatType {
        return BoatType.allCases.randomElement() ?? BoatType.red_boat
    }
}

class BoatImageView: UIImageView {
    
    let radian: CGFloat = CGFloat(Double.pi / 45)
    
    init(verticalPosition: CGFloat = 0) {
        super.init(frame: CGRect(x: 0, y: 0, width: 56, height: 58))
        image = UIImage(named: BoatType.random.rawValue)
        
        transform = CGAffineTransform(rotationAngle: -radian)
        frame.origin.x = -bounds.width
        frame.origin.y = verticalPosition
        animate()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func animate() {
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse, .beginFromCurrentState], animations: {
            self.transform = CGAffineTransform(rotationAngle: self.radian)
        }, completion: nil)
    }

}

