import Vapor
import NIO
@_exported import HTMLKit


extension Application {

    public var htmlkit: HTMLKit { .init() }

    public class HTMLKit {
        public var renderer = HTMLRenderer()
    }
}


extension Request {
    var htmlkit: HTMLRenderer {
        self.application.htmlkit.renderer
    }
}

///// An extension that implements most of the helper functions
extension HTMLRenderable {

    /// Renders a `StaticView` formula
    ///
    ///     try renderer.render(WelcomeView.self)
    ///
    /// - Parameter type: The view type to render
    /// - Returns: Returns a rendered view in a `Response`
    /// - Throws: If the formula do not exists, or if the rendering process fails
    public func render<T: HTMLTemplate>(_ type: T.Type, with value: T.Context) throws -> Response {
        return try Response(headers: .init([("content-type", "text/html; charset=utf-8")]), body: .init(string: render(raw: type, with: value)))
    }

    public func render<T: HTMLPage>(_ type: T.Type) throws -> Response {
        return try Response(headers: .init([("content-type", "text/html; charset=utf-8")]), body: .init(string: render(raw: type)))
    }

    public func render<T>(view type: T.Type) throws -> View where T : HTMLPage {
        let page = try render(raw: type)
        var buffer = ByteBufferAllocator().buffer(capacity: page.utf8.count)
        buffer.writeString(page)
        return View(data: buffer)
    }

    public func render<T>(view type: T.Type, with context: T.Context) throws -> View where T : HTMLTemplate {
        let page = try render(raw: type, with: context)
        var buffer = ByteBufferAllocator().buffer(capacity: page.utf8.count)
        buffer.writeString(page)
        return View(data: buffer)
    }
}

extension HTMLTemplate {
    public func render(with context: Context, for request: Request) -> EventLoopFuture<View> {
        request.eventLoop.submit {
            do {
                return try request.htmlkit.render(view: Self.self, with: context)
            } catch HTMLRenderer.Errors.unableToFindFormula {
                try request.htmlkit.add(view: self)
                return try request.htmlkit.render(view: Self.self, with: context)
            }
        }
    }
}

extension HTMLPage {
    public func render(for request: Request) -> EventLoopFuture<View> {
        request.eventLoop.submit {
            do {
                return try request.htmlkit.render(view: Self.self)
            } catch HTMLRenderer.Errors.unableToFindFormula {
                try request.htmlkit.add(view: self)
                return try request.htmlkit.render(view: Self.self)
            }
        }
    }
}
