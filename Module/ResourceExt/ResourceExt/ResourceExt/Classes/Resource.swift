//
//  Resource.swift
//  TestResource
//
//  Created by JoFox on 2022/3/26.
//

public struct Resource<Base> {

    public var base: Base

    public init(_ base: Base) {
        self.base = base
    }

}

/// 兼容协议
public protocol ResourceCompatible {

}

extension ResourceCompatible {

    public var resource: Resource<Self> {
        Resource(self)
    }

    public static var resource: Resource<Self>.Type {
        Resource<Self>.self
    }

}

import class Foundation.NSObject

extension NSObject: ResourceCompatible { }
