//
//  UISlider+Extension.swift
//  HearingAid
//
//  Created by Subhash Khimani on 12/09/23.
//  Copyright © 2023 mind-00019. All rights reserved.
//

import UIKit

extension UISlider {
    /// addTapGesture is used to add tap gesture on UISlider
    public func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tap)
    }
    
    /// handleTap is called when tap gesture recognize on UISlider
    /// - Parameter sender: UITapGestureRecognizer type
    @objc private func handleTap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        let percent = minimumValue + Float(location.x / bounds.width) * maximumValue
        setValue(percent, animated: true)
        sendActions(for: .valueChanged)
        sendActions(for: .touchCancel)
    }
}
