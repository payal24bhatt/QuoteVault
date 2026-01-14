//
//  UIView+Extension.swift
//

import Foundation
import UIKit

struct AnchoredConstraints {
    var top, leading, bottom, trailing, width, height: NSLayoutConstraint?
}

extension UIView {

    public func findViewsOfClass<T: UIView>(viewClass: T.Type) -> [T] {
        return subviews.filter({ $0.isKind(of: T.self) }) as! [T]
    }

    @discardableResult
    func anchor(top: NSLayoutYAxisAnchor?, leading: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, trailing: NSLayoutXAxisAnchor?, padding: UIEdgeInsets = .zero, size: CGSize = .zero) -> AnchoredConstraints {

        translatesAutoresizingMaskIntoConstraints = false
        var anchoredConstraints = AnchoredConstraints()

        if let top = top {
            anchoredConstraints.top = topAnchor.constraint(equalTo: top, constant: padding.top)
        }

        if let leading = leading {
            anchoredConstraints.leading = leadingAnchor.constraint(equalTo: leading, constant: padding.left)
        }

        if let bottom = bottom {
            anchoredConstraints.bottom = bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom)
        }

        if let trailing = trailing {
            anchoredConstraints.trailing = trailingAnchor.constraint(equalTo: trailing, constant: -padding.right)
        }

        if (size.width != 0) {
            anchoredConstraints.width = widthAnchor.constraint(equalToConstant: size.width)
        }

        if (size.height != 0) {
            anchoredConstraints.height = heightAnchor.constraint(equalToConstant: size.height)
        }

        [anchoredConstraints.top, anchoredConstraints.leading, anchoredConstraints.bottom, anchoredConstraints.trailing, anchoredConstraints.width, anchoredConstraints.height].forEach { $0?.isActive = true }

        return anchoredConstraints
    }

    func fillSuperview(padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewTopAnchor = superview?.topAnchor {
            topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
        }

        if let superviewBottomAnchor = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
        }

        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
        }

        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }

    func centerInSuperview(size: CGSize = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        if let superviewCenterXAnchor = superview?.centerXAnchor {
            centerXAnchor.constraint(equalTo: superviewCenterXAnchor).isActive = true
        }

        if let superviewCenterYAnchor = superview?.centerYAnchor {
            centerYAnchor.constraint(equalTo: superviewCenterYAnchor).isActive = true
        }

        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }

    func setBorder(color: UIColor, width: CGFloat = 1.0) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }

    func setCornerRadius(of: CGFloat) {
        DispatchQueue.CGCDMainThread.async {
            self.clipsToBounds = true
            self.layer.cornerRadius = of
        }
    }

    func makeRounded() {
        self.layer.cornerRadius = self.CViewHeight / 2
        self.clipsToBounds = true
    }

    func addBottomBorderView(color: UIColor) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let lineView = UIView()
        lineView.translatesAutoresizingMaskIntoConstraints = false
        lineView.backgroundColor = color
        self.addSubview(lineView)
        NSLayoutConstraint.activate([
            lineView.heightAnchor.constraint(equalToConstant: 0.8),
            lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }

    var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }

    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 1.0, height: 2.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }

    class func fromNib<T: UIView>() -> T? {

        guard let contentView = Bundle.main.loadNibNamed("\(self)", owner: self, options: nil)?.first as? T else {    // 3
            return nil
        }
        return contentView
    }

    func touchUpAnimation() {
        UIView.animate(withDuration: 0.12, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = .identity
            })
        })
    }

    func touchDownAnimation() {
        UIView.animate(withDuration: 0.12, delay: 0.0, options: [.curveEaseInOut], animations: {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: {
                self.transform = .identity
            })
        })
    }

    func startBlurLoading() {

        if let _blurView = self.viewWithTag(AssignedTags.blurView) as? UIVisualEffectView {
            _blurView.removeFromSuperview()
        }
        let blurEffect = UIBlurEffect(style: .dark)
        let visualEffect = UIVisualEffectView(effect: blurEffect)
//        visualEffect.tag = AssignedTags.blurView
        visualEffect.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(visualEffect)
        visualEffect.fillSuperview()

        let activity = UIActivityIndicatorView(style: .medium)
        activity.translatesAutoresizingMaskIntoConstraints = false
        activity.startAnimating()
        visualEffect.contentView.addSubview(activity)
        activity.centerInSuperview()
    }

    func stopBlurLoading() {
        if let _blurView = self.viewWithTag(AssignedTags.blurView) as? UIVisualEffectView {
            _blurView.removeFromSuperview()
        }
    }

    // In order to create computed properties for extensions, we need a key to
    // store and access the stored property
    fileprivate struct AssociatedObjectKeys {
        static var tapGestureRecognizer = "MediaViewerAssociatedObjectKey_mediaViewer"
    }

    fileprivate typealias Action = (() -> Void)?

    // Set our computed property type to a closure
    fileprivate var tapGestureRecognizerAction: Action? {
        get {
            let tapGestureRecognizerActionInstance = objc_getAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer) as? Action
            return tapGestureRecognizerActionInstance
        }
        set {
            if let newValue = newValue {
                // Computed properties get stored as associated objects
                objc_setAssociatedObject(self, &AssociatedObjectKeys.tapGestureRecognizer, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
            }
        }
    }

    // This is the meat of the sauce, here we create the tap gesture recognizer and
    // store the closure the user passed to us in the associated object we declared above
    public func addTapGestureRecognizer(action: (() -> Void)?) {
        self.isUserInteractionEnabled = true
        self.tapGestureRecognizerAction = action
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGestureRecognizer))
        self.addGestureRecognizer(tapGestureRecognizer)
    }

    // Every time the user taps on the UIImageView, this function gets called,
    // which triggers the closure we stored
    @objc fileprivate func handleTapGestureRecognizer(sender: UITapGestureRecognizer) {
        if let action = self.tapGestureRecognizerAction {
            action?()
        } else {
            print("no action")
        }
    }
}

extension UIView {

    func setConstraintConstant(_ constant: CGFloat, edge: NSLayoutConstraint.Attribute, ancestor: Bool) -> Bool {

        var success = false

        let arrConstraints = (ancestor ? (self.superview?.constraints)! : self.constraints) as NSArray

        if (arrConstraints.count > 0) {

            arrConstraints.enumerateObjects({ (constraint, _, _) in
                let constraint = constraint as! NSLayoutConstraint

                if ((constraint.firstItem as? NSObject == self) && (constraint.firstAttribute == edge)) ||
                    ((constraint.secondItem as? NSObject == self) && (constraint.secondAttribute == edge)) {
                    constraint.constant = constant
                    success = true
                }
            })

            self.superview?.updateLayout()
        }

        return success
    }

    func updateLayout() {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
}

extension UIView {
    
    // For setting dashed border
    func addDashedBorder(cornerRadius: CGFloat = 0.0, dashLength: Int, betweenDashesSpace: Int, borderWidth: CGFloat = 1) {

        let dashBorder = CAShapeLayer()
        dashBorder.lineWidth = borderWidth
        dashBorder.strokeColor = UIColor.gray.cgColor
        dashBorder.lineDashPattern = [dashLength, betweenDashesSpace] as [NSNumber]
        dashBorder.frame = bounds
        dashBorder.fillColor = nil
        if cornerRadius > 0 {
            dashBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: CGFloat(cornerRadius)).cgPath
        } else {
            dashBorder.path = UIBezierPath(rect: bounds).cgPath
        }
        layer.addSublayer(dashBorder)
    }

    func showMessageLabel(msg: String = "No Result Found") {

        DispatchQueue.CGCDMainThread.async {
            let label = UILabel()
            label.text = msg
            label.textColor = .gray
            label.text = msg
            label.font = UIFont.custom(name: .futuraBold, size: getAutoDimension(size: 16.0))
            label.numberOfLines = 0
            label.tag = 851
            label.textAlignment = .center
            self.addSubview(label)
            if let superView = self.superview {
                superView.layoutIfNeeded()
            }
            label.frame = self.bounds
        }
    }

    func removeMessageLabel() {
        DispatchQueue.main.async {
            for view in self.subviews where view.tag == 851 {
                view.removeFromSuperview()
            }
        }
    }
}

extension UIView {
    func alternativeCorners(_ corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11, *) {
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corners
        } else {
            var rectCorner = UIRectCorner()

            if corners.contains(.layerMinXMinYCorner) {
                rectCorner.insert(.topLeft)
            }
            if corners.contains(.layerMaxXMinYCorner) {
                rectCorner.insert(.topRight)
            }
            if corners.contains(.layerMinXMaxYCorner) {
                rectCorner.insert(.bottomLeft)
            }
            if corners.contains(.layerMaxXMaxYCorner) {
                rectCorner.insert(.bottomRight)
            }

            self.corner(byRoundingCorners: rectCorner, radii: radius)
        }
    }

    func corner(byRoundingCorners corners: UIRectCorner, radii: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.cgPath
        self.layer.mask = maskLayer
    }
}

extension UIView {

    /// This method is used to draw a shadowView for perticular UIView.
    ///
    /// - Parameters:
    ///   - color: Pass the UIColor that you want to see as shadowColor.
    ///   - shadowOffset: Pass the CGSize value for how much far you want shadowView from parentView.
    ///   - shadowRadius: Pass the CGFloat value for how much length(Blur Spreadness) you want in shadowView.

    func shadow(color:UIColor , shadowOffset:CGSize , shadowRadius:CGFloat , shadowOpacity: Float, cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowOffset =   shadowOffset
        self.layer.shadowRadius = getAutoDimension(size: shadowRadius)
    }
}

extension UIView {
    func shakeXPositionAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0]
        layer.add(animation, forKey: "shake")
    }
}

extension UIView {
    
    func applyGradient(colours: [UIColor], cornerRadius: CGFloat?, startPoint: CGPoint, endPoint: CGPoint) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        if let cornerRadius = cornerRadius {
            gradient.cornerRadius = cornerRadius
        }
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.colors = colours.map { $0.cgColor }
        self.layer.insertSublayer(gradient, at: 0)
    }
}
