//
//  DispatchQueue+Extension.swift
//  V_Me
//
//  Created by Hiral Jotaniya on 09/12/22.
//

import Foundation

extension DispatchQueue {
    static let CGCDMainThread = DispatchQueue.main
    static let CGCDBackgroundThread = DispatchQueue.global(qos: .background)
    static let GCDBackgroundThreadUtility  = DispatchQueue.global(qos: DispatchQoS.QoSClass.utility)
    static let GCDBackgroundThreadDefault  = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
    static let GCDBackgroundThreadUserInitiated  = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated)
    static let GCDBackgroundThreadUserInteractive  = DispatchQueue.global(qos: DispatchQoS.QoSClass.userInteractive)
    static let GCDBackgroundThreadUnspecified  = DispatchQueue.global(qos: DispatchQoS.QoSClass.unspecified)
}
