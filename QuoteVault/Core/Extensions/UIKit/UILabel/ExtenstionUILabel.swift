//
//  ExtenstionUILabel.swift
//  Atm
//
//  Created by Apple on 30/09/24.
//
import Foundation
import UIKit

/// This class is used to add the gesture recognizer on a specific range of a label
class RangeGestureRecognizer: UITapGestureRecognizer {
    var stringRange: String? // Store a single string range
    var function: ((String) -> Void)? // Update the function to accept the string range
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer, and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText ?? NSAttributedString())
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}


extension UILabel {
    struct AssociatedKeys {
        static var rangeGestureKey = "rangeGestureKey".hashValue

    }
    
    // Store all gestures added to this label
    private var rangeGestures: [RangeGestureRecognizer] {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.rangeGestureKey) as? [RangeGestureRecognizer] ?? []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.rangeGestureKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addRangeGesture(stringRange: String, function: @escaping (String) -> Void) {
        self.isUserInteractionEnabled = true
        
        // Create a new gesture recognizer
        let tapGesture = RangeGestureRecognizer(target: self, action: #selector(tappedOnLabel(_:)))
        tapGesture.stringRange = stringRange
        tapGesture.function = function
        
        // Add the gesture to the label
        self.addGestureRecognizer(tapGesture)
        
        // Store the gesture in the rangeGestures array
        var existingGestures = rangeGestures
        existingGestures.append(tapGesture)
        rangeGestures = existingGestures
    }
    
    @objc private func tappedOnLabel(_ gesture: RangeGestureRecognizer) {
        guard let text = self.text else { return }
        
        // Check all registered gestures
        for gesture in rangeGestures {
            if let stringRange = gesture.stringRange {
                let range = (text as NSString).range(of: stringRange)
                
                // Check if the tap location is within the specified range
                if gesture.didTapAttributedTextInLabel(label: self, inRange: range) {
                    gesture.function?(stringRange) // Pass the tapped string range to the function
                    return // Exit after the first matching gesture
                }
            }
        }
    }
}

