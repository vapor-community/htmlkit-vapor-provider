# HTMLKit-Vapor-Provider

A provider that makes it possible to use [HTMLKit](https://github.com/vapor-community/HTMLKit) with Vapor 4. If you are using Vapor 3, check [this](https://github.com/MatsMoll/htmlkit-vapor-3-provider) provider out.

## Getting started

### Installation

Add the packages as dependecies to your package.

```swift
/// [Package.swift]
...
dependencies: [
    ...
    ///1. Add the package
    .package(name: "HTMLKitVaporProvider", url: "https://github.com/MatsMoll/htmlkit-vapor-provider.git", from: "1.2.0")
],
.targets: [
    .target(
    ...
        dependencies: [
            ...
            /// 2. Add the product
            .product(name: "HTMLKitVaporProvider", package: "HTMLKitVaporProvider")
        ]
    ),
    ...
```

### Implementation

This will expose HTMLKit on `Request` and `Application` as shown below.

#### Preload

You can preload a layout to optimize rendering.

```swift
/// [configure.swift]

app.htmlkit.add(view: UserTemplate())
```

#### Rendering

```swift
/// [SimpleController.swift]

...
/// Returns a `Response`
try req.htmlkit.render(UserTemplate.self, with: user)

/// Returns a `View`
try req.htmlkit.render(view: UserTemplate.self, with: user)

/// Returns an `EventLoopFuture<View>` and will not require the preload
UserTemplate().render(with: user, for: req)
```

#### Localization

You can also set a localizationPath to enable `Lingo`.

```swift
/// [configure.swift]

app.htmlkit.localizationPath = "Resources/Localization"
app.htmlkit.defaultLocale = "nb"
```
