//
//  Associate.swift
//  KListAdapter
//
//  Created by kaylla on 2020/3/2.
//  Copyright © 2020 kaylla. All rights reserved.
//

import ObjectiveC

final class Lifted<T> {
    let value: T
    init(_ x: T) {
        value = x
    }
}

private func lift<T>(_ x: T) -> Lifted<T> {
    return Lifted(x)
}

func associated<T>(to base: AnyObject,
                   key: UnsafePointer<Void?>,
                   policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN,
                   default value: () -> T) -> T {
    if let v = objc_getAssociatedObject(base, key) as? T {
        return v
    }

    if let v = objc_getAssociatedObject(base, key) as? Lifted<T> {
        return v.value
    }

    let lifted = Lifted(value())
    objc_setAssociatedObject(base, key, lifted, policy)
    return lifted.value
}

func associate<T>(to base: AnyObject,
                  key: UnsafePointer<Void?>,
                  value: T,
                  policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN) {
    if let v: AnyObject = value as AnyObject? {
        objc_setAssociatedObject(base, key, v, policy)
    } else {
        objc_setAssociatedObject(base, key, lift(value), policy)
    }
}
