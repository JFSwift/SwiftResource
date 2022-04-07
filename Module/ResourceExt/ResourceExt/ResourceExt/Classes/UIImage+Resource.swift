//
//  UIImage+Resource.swift
//  Pods-TestResource_Example
//
//  Created by JoFox on 2022/3/26.
//

import UIKit

/*
 use_frameworks!
     static_framework = false：
         resource_bundles: .app/Frameworks/pod_name.framework/pod_name.bundle/.
         resources: .app/Frameworks/pod_name.framework/.
     static_framework = true：
         resource_bundles: .app/pod_name.bundle/.
         resources: .app/.

 ------------------------------------------------------------------------------------
 
 # 不使用 use_frameworks!
 # use_frameworks!
     static_framework = false：
         resource_bundles: .app/pod_name.bundle/.
         resources: .app/.
     static_framework = true：
         resource_bundles: .app/pod_name.bundle/.
         resources: .app/.
 */

public extension Resource where Base: UIImage {

    /// 加载图片资源
    /// - Parameters:
    ///   - name: 图片名
    ///   - bundleName: s.resource_bundles中设置的名字 一般为组件名
    /// - Returns: description
    static func loadImage(name: String, bundleName: String) -> UIImage? {
        /// 静态库+独立bundle
        var image = loadImage1(name: name, in: bundleName)
        if image == nil {
            /// 动态库+独立bundle
            image = loadImage2(name: name, in: bundleName)
        }
        if image == nil {
            /// 动态库+非独立bundle
            image = loadImage3(name: name, in: bundleName)
        }
        if image == nil {
            // 根目录 .app/
            image = loadImage4(name: name, in: bundleName)
        }
        return image
    }
    
    /// 加载  .app/pod_name.bundle/.
    /// - Parameters:
    ///   - name: 图片名
    ///   - bundleName: 组件名
    /// - Returns: description
    fileprivate static func loadImage1(name: String, in bundleName: String) -> UIImage? {
        let pathComponent = "/\(bundleName).bundle"
        return commonLoadImage(name: name, in: pathComponent)
    }

    /// 加载  .app/Frameworks/pod_name.framework/pod_name.bundle/.
    /// - Parameters:
    ///   - name: 图片名
    ///   - bundleName: 组件名
    /// - Returns: description
    fileprivate static func loadImage2(name: String, in bundleName: String) -> UIImage? {
        let pathComponent = "/Frameworks/\(bundleName).framework/\(bundleName).bundle"
        return commonLoadImage(name: name, in: pathComponent)
    }

    /// 加载.app/Frameworks/pod_name.framework/.
    /// - Parameters:
    ///   - name: 图片名
    ///   - bundleName: 组件名
    /// - Returns: description
    fileprivate static func loadImage3(name: String, in bundleName: String) -> UIImage? {
        let pathComponent = "/Frameworks/\(bundleName).framework"
        return commonLoadImage(name: name, in: pathComponent)
    }

    /// 加载.app/
    /// - Parameters:
    ///   - name: 图片名
    ///   - bundleName: 组件名
    /// - Returns: description
    fileprivate static func loadImage4(name: String, in bundleName: String) -> UIImage? {
        return UIImage(named: name)
    }

    fileprivate static func commonLoadImage(name: String, in pathComponent: String) -> UIImage? {
        guard let resourcePath: String = Bundle.main.resourcePath else { return nil }
        let bundlePath = resourcePath + pathComponent
        let bundle = Bundle(path: bundlePath)
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }

}
