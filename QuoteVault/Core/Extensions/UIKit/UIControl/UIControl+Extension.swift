//
//  UIControl+Extension.swift
//

import Foundation
import UIKit

class ClosureSleeve {
    let closure: (UIControl) -> Void

    init (_ closure: @escaping (UIControl) -> Void) {
        self.closure = closure
    }

    @objc func invoke (_ sender: UIControl) {
        closure(sender)
    }
}

extension UIControl {
    func addAction(for controlEvents: UIControl.Event, _ closure: @escaping (UIControl) -> Void) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke(_:)), for: controlEvents)
        objc_setAssociatedObject(self, "\(UUID())", sleeve, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
}
