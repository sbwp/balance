//
//  DatabaseObject.swift
//  Balance
//
//  Created by Sabrina Bea on 6/5/24.
//

import Foundation

protocol DatabaseObject: Codable, Identifiable {
    var id: UUID { get }
}
