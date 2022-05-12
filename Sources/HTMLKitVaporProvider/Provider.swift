/*
 Abstract:
 The file contains a view provider for Vapor.
 
 Authors:
 - Mats Moll (https://github.com/matsmoll)
 
 Contributors:
 - Mattes Mohr (https://github.com/mattesmohr)
 
 If you about to add something to the file, stick to the official documentation to keep the code consistent.
 */

import Vapor
import NIO
@_exported import HTMLKit

/// The view provider.
public class Provider: LifecycleHandler {

    public static var shared: Provider?

    /// The view renderer.
    public var renderer = Renderer()

    /// The path of the localization directory.
    public var localizationPath: String?
    
    /// The default locale for the localization.
    ///
    /// If the variable is nil, it sets the english local as default.
    public var defaultLocale: String?

    /// Creates a instance of the provider and adds to the lifecycle.
    public init(app: Application) {
        app.lifecycle.use(self)
    }

    /// Adds a page to the view renderer.
    public func add<T: HTMLKit.Page>(view: T) throws {
        try renderer.add(view: view)
    }

    /// Adds a view to the view renderer.
    public func add<T: HTMLKit.View>(view: T) throws {
        try renderer.add(view: view)
    }

    /// Registers the localization.
    public func willBoot(_ application: Application) throws {
        
        if let localizationPath = localizationPath {
            try renderer.registerLocalization(atPath: localizationPath, defaultLocale: defaultLocale ?? "en")
        }
    }
}
