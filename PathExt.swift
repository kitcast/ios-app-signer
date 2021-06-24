//
//  PathExt.swift
//  Kitcast Builder
//
//  Created by Alex Pawlowski on 11/25/17.
//  Copyright © 2017 Kitcast. All rights reserved.
//

import Foundation

extension URL {
    var prettied: String {
        return NSString(string: path).abbreviatingWithTildeInPath
    }
}
