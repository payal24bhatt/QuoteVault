//
//  UIImage+Extension.swift
//

import Foundation
import UIKit

extension UIImageView {
    
    func loadGif(name: String, completion:(() -> Void)?) {
        
        DispatchQueue.global().async {
            
            if let image = UIImage.gif(name: name, completion: completion) {
                
                DispatchQueue.main.async { [weak self] in
                    
                    guard let `self` = self else {
                        return
                    }
                    self.image = image
                }
            }
        }
    }
}

extension UIImage {

    var cropRatio: CGFloat {
        let widthRatio = CGFloat(self.size.width / self.size.height)
        return widthRatio
    }

    func toResizedData() -> Data? {
        if let resized = self.resizeImageTo(scaledToWidth: 800.0) {
            return resized.jpegData(compressionQuality: 1.0)
        }
        return self.jpegData(compressionQuality: 0.9)
    }

    func toData() -> Data? {
        return self.jpegData(compressionQuality: 1.0)
    }

    func resizeImageTo(scaledToWidth: CGFloat) -> UIImage? {
        let oldWidth = self.size.width
        if oldWidth < scaledToWidth {
            return self
        }
        let scaleFactor = scaledToWidth / oldWidth

        let newHeight = self.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor

        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        self.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    var data: Data? {
        return self.jpegData(compressionQuality: 1.0)
    }

    func tint(with color: UIColor) -> UIImage {
        var image = withRenderingMode(.alwaysTemplate)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.set()

        image.draw(in: CGRect(origin: .zero, size: size))
        image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIImage {

    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!

        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!

        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)

        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
}
extension UIImage {
    
    /// manage the background of delete icon
    /// - Parameter color: background color of a delete icon
    /// - Returns: UIImage
    func addBackgroundCircle(_ color: UIColor?) -> UIImage? {

        let circleDiameter = max(size.width * 2, size.height * 2)
        let circleRadius = circleDiameter * 0.5
        let circleSize = CGSize(width: circleDiameter, height: circleDiameter)
        let circleFrame = CGRect(x: 0, y: 0, width: circleSize.width, height: circleSize.height)
        let imageFrame = CGRect(x: circleRadius - (size.width * 0.5), y: circleRadius - (size.height * 0.5), width: size.width, height: size.height)

        let view = UIView(frame: circleFrame)
        view.backgroundColor = color ?? .systemRed
        view.layer.cornerRadius = circleDiameter * 0.5

        UIGraphicsBeginImageContextWithOptions(circleSize, false, UIScreen.main.scale)

        let renderer = UIGraphicsImageRenderer(size: circleSize)
        let circleImage = renderer.image { ctx in
            view.drawHierarchy(in: circleFrame, afterScreenUpdates: true)
        }

        circleImage.draw(in: circleFrame, blendMode: .normal, alpha: 1.0)
        draw(in: imageFrame, blendMode: .normal, alpha: 1.0)

        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }
}

extension UIImage {
    // Resize an image to a target size
    func resizeImage(targetSize: CGSize) -> UIImage {
        let newSize = self.size.resizedView(to: targetSize)
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension CGSize {
    /// resizedView is used to resize view as per image ratio
    /// - Parameter availableSize: CGSize type
    /// - Returns: CGSize type
    func resizedView(to availableSize: CGSize) -> CGSize {
        guard self.width > 0 && self.height > 0 else { return CGSize.zero }
        
        if self.width <= availableSize.width && self.height <= availableSize.height {
            return self // Return original image without resizing
        }
        
        let widthRatio = availableSize.width / self.width
        let heightRatio = availableSize.height / self.height
        let scaleFactor = min(widthRatio, heightRatio)
                
        let scaledWidth = self.width * scaleFactor
        let scaledHeight = self.height * scaleFactor
        
        return CGSize(width: scaledWidth.roundedToPlace(0), height: scaledHeight.roundedToPlace(0))
    }
}
