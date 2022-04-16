/*
 Abstract:
 The file contains the extensions for Vapor.
 
 Authors:
 - Mats Moll (https://github.com/matsmoll)
 
 Contributors:
 - Mattes Mohr (https://github.com/mattesmohr)
 
 If you about to add something to the file, stick to the official documentation to keep the code consistent.
 */

import Vapor
import HTMLKit

extension Application {

    /// Access to the view provider.
    ///
    /// With it, it is possible to call the view provider from the Application class and use its functions at boot time.
    ///
    /// ```swift
    /// public func configure(_ app: Application) throws {
    ///    // add a view
    ///    try app.htmlkit.add(view: SimpleView())
    /// }
    /// ```
    public var htmlkit: Provider {
        
        if let shared = Provider.shared {
            return shared
        }
        
        Provider.shared = .init(app: self)
        
        return Provider.shared!
    }
}

extension Request {
    
    /// Access to the view provider.
    ///
    /// With it, it is possible to call the view renderer from the Request class and use its functions at the request.
    ///
    /// ```swift
    /// public func get(_ request: Request) throws -> EventLoopFuture<View> {
    ///    request.htmlkit.render(view: SimpleView.self, context: SimpleContext())
    /// }
    /// ```
    public var htmlkit: Renderer {
        self.application.htmlkit.renderer
    }
}
