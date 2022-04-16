import Vapor
import NIO
@_exported import HTMLKit

/// The provider is  for
///
///
public class Provider: LifecycleHandler {

    public static var shared: Provider?

    public var renderer = Renderer()

    public var localizationPath: String?
    
    public var defaultLocale: String?

    public init(app: Application) {
        app.lifecycle.use(self)
    }

    public func add<T: HTMLKit.Page>(view: T) throws {
        try renderer.add(view: view)
    }

    public func add<T: HTMLKit.View>(view: T) throws {
        try renderer.add(view: view)
    }

    public func willBoot(_ application: Application) throws {
        
        if let localizationPath = localizationPath {
            try renderer.registerLocalization(atPath: localizationPath, defaultLocale: defaultLocale ?? "en")
        }
    }
}

extension Vapor.Application {

    public var htmlkit: Provider {
        
        if let shared = Provider.shared {
            return shared
        }
        
        Provider.shared = .init(app: self)
        
        return Provider.shared!
    }
}

extension Vapor.Request {
    
    public var htmlkit: Renderer {
        self.application.htmlkit.renderer
    }
}

extension HTMLKit.View {
    
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
    
    public func render<T: HTMLKit.Page>(_ type: T.Type) throws -> Response {
        
        let page = try render(raw: type)
        
        return Response(headers: .init([("content-type", "text/html; charset=utf-8")]), body: .init(string: page))
    }
    
    public func render<T: HTMLKit.View>(_ type: T.Type, with value: T.Context) throws -> Response {
        
        let view = try render(raw: type, with: value)
        
        return Response(headers: .init([("content-type", "text/html; charset=utf-8")]), body: .init(string: view))
    }

    public func render<T: HTMLKit.Page>(view type: T.Type) throws -> Vapor.View {
        
        let page = try render(raw: type)
        
        var buffer = ByteBufferAllocator().buffer(capacity: page.utf8.count)
        buffer.writeString(page)
        
        return Vapor.View(data: buffer)
    }

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
