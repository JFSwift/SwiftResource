//
//  Bundle+Resource.swift
//  TestResource
//
//  Created by JoFox on 2022/3/26.
//

import UIKit

public extension Resource where Base: Bundle {

    /// 加载图片资源
    /// - Parameters:
    ///   - name: 图片名
    ///   - bundleName: s.resource_bundles中设置的名字 一般为组件名
    /// - Returns: description
    static func loadBundle(in bundleName: String) -> Bundle? {
        var image = loadBundle1(in: bundleName)
        if image == nil {
            image = loadBundle2(in: bundleName)
        }
        if image == nil {
            image = loadBundle3(in: bundleName)
        }
        if image == nil {
            image = loadBundle4(in: bundleName)
        }
        return image
    }

    /// 加载  .app/pod_name.bundle/.
    /// - Parameters:
    ///   - name: 图片名
    ///   - bundleName: 组件名
    /// - Returns: description
    fileprivate static func loadBundle1(in bundleName: String) -> Bundle? {
        let pathComponent = "/\(bundleName).bundle"
        return commonLoadBundle(in: pathComponent)
    }

    /// 加载  .app/Frameworks/pod_name.framework/pod_name.bundle/.
    /// - Parameters:
    ///   - name: 图片名
    ///   - bundleName: 组件名
    /// - Returns: description
    fileprivate static func loadBundle2(in bundleName: String) -> Bundle? {
        let pathComponent = "/Frameworks/\(bundleName).framework/\(bundleName).bundle"
        return commonLoadBundle(in: pathComponent)
    }

    /// 加载.app/Frameworks/pod_name.framework/.
    /// - Parameters:
    ///   - name: 图片名
    ///   - bundleName: 组件名
    /// - Returns: description
    fileprivate static func loadBundle3(in bundleName: String) -> Bundle? {
        let pathComponent = "/Frameworks/\(bundleName).framework"
        return commonLoadBundle(in: pathComponent)
    }

    /// 加载.app/
    /// - Parameters:
    ///   - name: 图片名
    ///   - bundleName: 组件名
    /// - Returns: description
    fileprivate static func loadBundle4(in bundleName: String) -> Bundle? {
        return Bundle.main
    }

    fileprivate static func commonLoadBundle(in pathComponent: String) -> Bundle? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        let bundlePath = resourcePath + pathComponent
        let bundle = Bundle(path: bundlePath)
        return bundle
    }

}
