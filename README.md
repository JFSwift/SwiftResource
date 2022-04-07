### 学习[组件化资源文件管理方案](http://gonghonglou.com/2020/05/14/pod-resource/)后的总结

## 起因

组件化之前，所有代码、资源文件都在主工程中，其中大量图片资源，不可避免就会出现命名冲突问题。一般情况下，我们需要一份严谨的命名规范，比如根据模块进行划分添加前缀，来避免命名冲突。

公司采用组件化方案，但是未对资源文件进行拆分，都放在主工程中，维护组件和项目非常痛苦。我们将主工程资源文件拆分到对应的Pod，交由组件自己管理。这样将资源文件拆分到各个Pod，使职责划分更加合理，减少外部依赖，方便独立运行。

## CocoaPods提供的功能

CocoaPods提供的有`use_frameworks`、`static_framework`、`resource`、`resource_bundles` 这些功能的选择，以及将其中一些功能组合使用之后资源文件的最终存储路径的不同，导致使用者对图片文件、字体文件、本地化文件、其他各种文件的种种处理方式不明所以。

## 组合场景下的资源文件存储路径

`use_frameworks!`、`static_framework`、`resource_bundles`、`resources` 的不同组合使用，会导致资源文件的最终存放路径不同，以下是各种场景下的路径总结：

```
# use_frameworks! 动态库
# static_framework 静态库 podspec文件中不声明，默认为false
# resource_budles 生成独立的bundle
# resources 不生成独立的bundle，放置在.app根目录
# ---------------------------------------------------------------------------
use_frameworks! 
	static_framework = false
		resource_bundles: .app/Frameworks/pod_name.framework/pod_name.bundle/.
		resources: .app/Frameworks/pod_name.framework/.
	static_framework = true
		resource_bundles: .app/pod_name.bundle/.
		resources: .app/.

# use_frameworks!
	static_framework = false
		resource_bundles: .app/pod_name.bundle/.
		resources: .app/.
	static_framework = true
		resource_bundles: .app/pod_name.bundle/.
		resources: .app/.
```



（.app/. 代表的是 main bundle）

不同路径下的图片取值方式及差别可以参考这篇文章：[CocoaPods的资源管理和Asset Catalog优化](https://dreampiggy.com/2018/11/26/CocoaPods%E7%9A%84%E8%B5%84%E6%BA%90%E7%AE%A1%E7%90%86%E5%92%8CAsset%20Catalog%E4%BC%98%E5%8C%96/)
需要注意的是，当 Pod 中的 `.xcassets` 类型资源文件最终存储在 main bundle 的话会和主工程的 `.xcassets` 文件冲突，编译会报错：

> error: Multiple commands produce ‘/Users/gonghonglou/Library/Developer/Xcode/DerivedData/HoloResource-giqfnwiluvssbzbyvuhpkrjoewvd/Build/Products/Debug-iphonesimulator/HoloResource_Example.app/Assets.car’:
> \1) Target ‘HoloResource_Example’ (project ‘HoloResource’) has compile command with input ‘/Users/gonghonglou/holo/HoloResource/Example/HoloResource/Images.xcassets’
> \2) That command depends on command in Target ‘HoloResource_Example’ (project ‘HoloResource’): script phase “[CP] Copy Pods Resources”

解决方法，在 Podfile 里添加：

```
install! 'cocoapods', :disable_input_output_paths => true
```

### Tip： resource+不使用use_frameworks! +assets时会编译失败，因为工程只会生成一份`Assets.car`文件

> **Showing All Messages**
>
> 2022-03-26 20:42:51.046 ibtoold[25007:9169669] Launching AssetCatalogSimulatorAgent using native architecture.
>
> /* com.apple.actool.errors */
>
> : error: There are multiple stickers icon set or app icon set instances named "AppIcon".

题外话：Xcode 10 之后引入了新的编译系统，导致 Pod 里有代码改动的话无法及时编译进工程，解决方案也是上述方法。

参考：[Build System Release Notes for Xcode 10](https://developer.apple.com/documentation/xcode_release_notes/xcode_10_release_notes/build_system_release_notes_for_xcode_10?language=objc)

## 资源处理实践

### 图片 UIImage

```swift
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
```



每个组件调用 `UIImage.resource.loadImage(name: "图片名", bundleName: "组件名")` 就可以访问自己 bundle 里的图片了。

这里提到的四个路径做了优先级处理：

1. 首先访问的是静态库 + `resource_bundles` 的路径
2. 其次访问的是使用 `use_frameworks!` + `resource_bundles` 的动态库路径
3. 再次访问的是使用 `use_frameworks!` + `resources` 的动态库路径
4. 最后是 main bundle 路径

**最推荐也是最合理的配置方式当然是第一种，提供静态库，使用 `resource_bundles` 存储资源文件。**

### 路径 Bundle

既然图片可以通过这种方式封装，那么参照这种思路将 bundle 封装一个基础方法，有了统一的 bundle 调用方法，其他资源文件的访问就简单的多了。

```swift
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
```
## 使用

![image.png](https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/310cf6e4c88643438c5fadbf6fb6e3d6~tplv-k3u1fbpfcp-watermark.image?)

```swift
// module_a图片名 ModuleA资源名，一般为组件名
let imagea = UIImage.resource.loadImage(name: "module_a", bundleName: "ModuleA")
```
#### [实践Demo链接](https://github.com/JFSwift/SwiftResource)

## 感谢

#### [组件化资源文件管理方案](http://gonghonglou.com/2020/05/14/pod-resource/)