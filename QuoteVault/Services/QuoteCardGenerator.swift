//
//  QuoteCardGenerator.swift
//  QuoteVault
//
//  Created by Payal Bhatt on 13/01/26.
//

import UIKit

enum QuoteCardStyle {
    case minimal
    case gradient
    case elegant
}

class QuoteCardGenerator {
    
    static func generateCard(quote: Quote, style: QuoteCardStyle = .minimal) -> UIImage? {
        let cardSize = CGSize(width: 800, height: 1000)
        
        UIGraphicsBeginImageContextWithOptions(cardSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        switch style {
        case .minimal:
            drawMinimalStyle(context: context, quote: quote, size: cardSize)
        case .gradient:
            drawGradientStyle(context: context, quote: quote, size: cardSize)
        case .elegant:
            drawElegantStyle(context: context, quote: quote, size: cardSize)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    private static func drawMinimalStyle(context: CGContext, quote: Quote, size: CGSize) {
        // White background
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Quote text
        let quoteFont = UIFont.systemFont(ofSize: 32, weight: .regular)
        let authorFont = UIFont.systemFont(ofSize: 24, weight: .medium)
        
        let quoteText = "\"\(quote.text)\""
        let authorText = "- \(quote.author)"
        
        let quoteAttributes: [NSAttributedString.Key: Any] = [
            .font: quoteFont,
            .foregroundColor: UIColor.black
        ]
        
        let authorAttributes: [NSAttributedString.Key: Any] = [
            .font: authorFont,
            .foregroundColor: UIColor.gray
        ]
        
        let quoteRect = quoteText.boundingRect(
            with: CGSize(width: size.width - 120, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: quoteAttributes,
            context: nil
        )
        
        let authorRect = authorText.boundingRect(
            with: CGSize(width: size.width - 120, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: authorAttributes,
            context: nil
        )
        
        let totalHeight = quoteRect.height + 40 + authorRect.height
        let startY = (size.height - totalHeight) / 2
        
        quoteText.draw(
            at: CGPoint(x: 60, y: startY),
            withAttributes: quoteAttributes
        )
        
        authorText.draw(
            at: CGPoint(x: 60, y: startY + quoteRect.height + 40),
            withAttributes: authorAttributes
        )
    }
    
    private static func drawGradientStyle(context: CGContext, quote: Quote, size: CGSize) {
        // Gradient background
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = [
            UIColor.systemTeal.cgColor,
            UIColor.systemBlue.cgColor
        ]
        
        guard let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: nil) else {
            return
        }
        
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: 0, y: size.height),
            options: []
        )
        
        // Quote text (white)
        let quoteFont = UIFont.systemFont(ofSize: 36, weight: .semibold)
        let authorFont = UIFont.systemFont(ofSize: 28, weight: .medium)
        
        let quoteText = "\"\(quote.text)\""
        let authorText = "- \(quote.author)"
        
        let quoteAttributes: [NSAttributedString.Key: Any] = [
            .font: quoteFont,
            .foregroundColor: UIColor.white
        ]
        
        let authorAttributes: [NSAttributedString.Key: Any] = [
            .font: authorFont,
            .foregroundColor: UIColor.white.withAlphaComponent(0.9)
        ]
        
        let quoteRect = quoteText.boundingRect(
            with: CGSize(width: size.width - 120, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: quoteAttributes,
            context: nil
        )
        
        let authorRect = authorText.boundingRect(
            with: CGSize(width: size.width - 120, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: authorAttributes,
            context: nil
        )
        
        let totalHeight = quoteRect.height + 50 + authorRect.height
        let startY = (size.height - totalHeight) / 2
        
        quoteText.draw(
            at: CGPoint(x: 60, y: startY),
            withAttributes: quoteAttributes
        )
        
        authorText.draw(
            at: CGPoint(x: 60, y: startY + quoteRect.height + 50),
            withAttributes: authorAttributes
        )
    }
    
    private static func drawElegantStyle(context: CGContext, quote: Quote, size: CGSize) {
        // Cream/beige background
        context.setFillColor(UIColor(red: 0.98, green: 0.96, blue: 0.92, alpha: 1.0).cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        // Decorative border
        context.setStrokeColor(UIColor(red: 0.8, green: 0.7, blue: 0.6, alpha: 1.0).cgColor)
        context.setLineWidth(4)
        context.stroke(CGRect(x: 40, y: 40, width: size.width - 80, height: size.height - 80))
        
        // Quote text (serif-like)
        let quoteFont = UIFont(name: "Times New Roman", size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .regular)
        let authorFont = UIFont(name: "Times New Roman", size: 26) ?? UIFont.systemFont(ofSize: 26, weight: .medium)
        
        let quoteText = "\"\(quote.text)\""
        let authorText = "- \(quote.author)"
        
        let quoteAttributes: [NSAttributedString.Key: Any] = [
            .font: quoteFont,
            .foregroundColor: UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0)
        ]
        
        let authorAttributes: [NSAttributedString.Key: Any] = [
            .font: authorFont,
            .foregroundColor: UIColor(red: 0.5, green: 0.4, blue: 0.3, alpha: 1.0)
        ]
        
        let quoteRect = quoteText.boundingRect(
            with: CGSize(width: size.width - 160, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: quoteAttributes,
            context: nil
        )
        
        let authorRect = authorText.boundingRect(
            with: CGSize(width: size.width - 160, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: authorAttributes,
            context: nil
        )
        
        let totalHeight = quoteRect.height + 60 + authorRect.height
        let startY = (size.height - totalHeight) / 2
        
        quoteText.draw(
            at: CGPoint(x: 80, y: startY),
            withAttributes: quoteAttributes
        )
        
        authorText.draw(
            at: CGPoint(x: 80, y: startY + quoteRect.height + 60),
            withAttributes: authorAttributes
        )
    }
    
    static func saveToPhotos(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
}

extension String {
    func boundingRect(with size: CGSize, options: NSStringDrawingOptions, attributes: [NSAttributedString.Key: Any]?, context: NSStringDrawingContext?) -> CGRect {
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        return attributedString.boundingRect(with: size, options: options, context: context)
    }
    
    func draw(at point: CGPoint, withAttributes attributes: [NSAttributedString.Key: Any]?) {
        let attributedString = NSAttributedString(string: self, attributes: attributes)
        attributedString.draw(at: point)
    }
}

