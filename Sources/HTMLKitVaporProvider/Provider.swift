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

extension Vapor.Application {

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

extension Vapor.Request {
    
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

extension HTMLKit.View {
    
    /// Renders the view.
    ///
    /// The view does not need to be added to the view renderer.
    ///
    /// ```swift
    /// public func get(_ request: Request) throws -> EventLoopFuture<View> {
    ///     return SimpleView().render(with: Context(), for: request))
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - context:
    ///   - request:
    ///
    /// - Returns: View within the future.
    public func render(with context: Context, for request: Request) -> EventLoopFuture<Vapor.View> {
        
        return request.eventLoop.submit {
            
            do {
                
                return try request.htmlkit.render(view: Self.self, with: context)
                
            } catch Renderer.Errors.unableToFindFormula {
                
                try request.application.htmlkit.add(view: self)
                
                return try request.htmlkit.render(view: Self.self, with: context)
            }
        }
    }
    
    /// Renders the view.
    ///
    /// The view does not need to be added to the view renderer.
    ///
    /// ```swift
    /// public func get(_ request: Request) async throws -> View {
    ///     return try SimpleView().render(with: Context(), for: request))
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - context:
    ///   - request:
    ///
    /// - Returns:
    ///
    /// - Throws:
    public func render(with context: Context, for request: Request) throws -> Vapor.View {
        
        do {
            
            return try request.htmlkit.render(view: Self.self, with: context)
            
        } catch Renderer.Errors.unableToFindFormula {
            
            try request.application.htmlkit.add(view: self)
            
            return try request.htmlkit.render(view: Self.self, with: context)
        }
    }
}

extension HTMLKit.Page {
    
    /// Renders the page.
    ///
    /// The page does not need to be added to the view renderer.
    ///
    /// ```swift
    /// public func get(_ request: Request) throws -> EventLoopFuture<View> {
    ///     return SimplePage().render(for: request)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - context:
    ///   - request:
    ///
    /// - Returns:
    ///
    /// - Throws:
    public func render(for request: Request) -> EventLoopFuture<Vapor.View> {
        
        request.eventLoop.submit {
            
            do {
                
                return try request.htmlkit.render(view: Self.self)
                
            } catch Renderer.Errors.unableToFindFormula {
                
                try request.application.htmlkit.add(view: self)
                
                return try request.htmlkit.render(view: Self.self)
            }
        }
    }
    
    /// Renders the page.
    ///
    /// The page does not need to be added to the view renderer.
    ///
    /// ```swift
    /// public func get(_ request: Request) async throws -> View {
    ///     return try SimplePage().render(for: request)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - context:
    ///   - request:
    ///
    /// - Returns:
    ///
    /// - Throws:
    public func render(for request: Request) throws -> Vapor.View {
        
        do {
            
            return try request.htmlkit.render(view: Self.self)
            
        } catch Renderer.Errors.unableToFindFormula {
            
            try request.application.htmlkit.add(view: self)
            
            return try request.htmlkit.render(view: Self.self)
        }
    }
}

extension HTMLKit.Renderer {
    
    /// Renders the page.
    ///
    /// The page needs to be added to the view renderer first.
    ///
    /// ```swift
    /// public func get(_ request: Request) async throws -> Response {
    ///     return try SimplePage().render(for: request)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - context:
    ///   - request:
    ///
    /// - Returns:
    ///
    /// - Throws:
    public func render<T: HTMLKit.Page>(_ type: T.Type) throws -> Response {
        
        let page = try render(raw: type)
        
        return Response(headers: .init([("content-type", "text/html; charset=utf-8")]), body: .init(string: page))
    }
    
    /// Renders the page.
    ///
    /// The page needs to be added to the view renderer first.
    ///
    /// ```swift
    /// public func get(_ request: Request) async throws -> View {
    ///     return try SimplePage().render(for: request)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - context:
    ///   - request:
    ///
    /// - Returns:
    ///
    /// - Throws:
    public func render<T: HTMLKit.Page>(view type: T.Type) throws -> Vapor.View {
        
        let page = try render(raw: type)
        
        var buffer = ByteBufferAllocator().buffer(capacity: page.utf8.count)
        buffer.writeString(page)
        
        return Vapor.View(data: buffer)
    }
    
    /// Renders the view.
    ///
    /// The view needs to be added to the view renderer first.
    ///
    /// ```swift
    /// public func get(_ request: Request) async throws -> Response {
    ///     return try SimplePage().render(for: request)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - context:
    ///   - request:
    ///
    /// - Returns:
    ///
    /// - Throws:
    public func render<T: HTMLKit.View>(_ type: T.Type, with value: T.Context) throws -> Response {
        
        let view = try render(raw: type, with: value)
        
        return Response(headers: .init([("content-type", "text/html; charset=utf-8")]), body: .init(string: view))
    }

    /// Renders the view.
    ///
    /// The view needs to be added to the view renderer first.
    ///
    /// ```swift
    /// public func get(_ request: Request) async throws -> View {
    ///     return try SimplePage().render(for: request)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - context:
    ///   - request:
    ///
    /// - Returns:
    ///
    /// - Throws:
    public func render<T: HTMLKit.View>(view type: T.Type, with context: T.Context) throws -> Vapor.View {
        
        let view = try render(raw: type, with: context)
        
        var buffer = ByteBufferAllocator().buffer(capacity: view.utf8.count)
        buffer.writeString(view)
        
        return Vapor.View(data: buffer)
    }
}

extension HTMLKit.Renderer.Errors: DebuggableError {
    
    public var identifier: String { "HTMLRenderer.Errors" }
    
    public var reason: String { self.errorDescription ?? "" }
}
