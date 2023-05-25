//
//  AdReward.swift
//  
//
//  Created by Koliush Dmitry on 18.02.2023.
//

import Foundation

public struct AdReward: Equatable {
    let amount: Int
    let type: String

    public init(amount: Int, type: String) {
        self.amount = amount
        self.type = type
    }
}
