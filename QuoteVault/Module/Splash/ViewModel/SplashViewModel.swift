//
//  
//  SplashViewModel.swift
//  
//
//  Created by Payal Bhatt on 10/11/25.
//

import Foundation
import UIKit

protocol SplashViewModelDelegate: AnyObject {
    func errorOccurred(_ message: String, errorType: ErrorType, fieldType:ErrorFieldType)
}

class SplashViewModel {
    
    /// Variable(s)
    weak var delegate: SplashViewModelDelegate?
}
