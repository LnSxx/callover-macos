//
//  ValidatorProtocol.swift
//  CalloverDesktop
//
//  Created by Leonid  on 21.04.26.
//

import Foundation

protocol ValidatorProtocol {
    associatedtype Value
    static func validate(_ value: Value) -> Result<Void, ValidationError>
}
