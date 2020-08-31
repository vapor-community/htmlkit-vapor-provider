# HTMLKit-Vapor-Provider

A provider that makes it possible to use [HTMLKit](https://github.com/vapor-community/HTMLKit) with Vapor 4.
If you are using Vapor 3, check [this](https://github.com/MatsMoll/htmlkit-vapor-3-provider) provider out

## Usage

Add this as a dependencies in your `Package.swift` file.
```swift
.package(url: "https://github.com/MatsMoll/htmlkit-vapor-provider.git", from: "1.0.0-beta.4")
...
// And remember to add HTMLKitVaporProvider to your target
.target(
    name: "YourProject",
    dependencies: [
        "HTMLKitVaporProvider",
        // or
        .product(name: "HTMLKitVaporProvider", package: "HTMLKitVaporProvider")
    ])
```

This will expose a `htmlkit` variable on `Request` and `Application` as shown below.
```swift
app.htmlkit.add(view: UserTemplate())
...
try req.htmlkit.render(UserTemplate.self, with: user) // Returns a `Response`
// or
try req.htmlkit.render(view: UserTemplate.self, with: user) // Returns a `View`
// or
UserTemplate().render(with: user, for: req) // Returns an `EventLoopFuture<View>` and will not require `app.htmlkit.add(view: ...)`
```
You can also set a localizationPath to enable `Lingo`.
```swift
app.htmlkit.localizationPath = "Resources/Localization"
```
