import HTMLKitVaporProvider
import XCTVapor

final class IntegrationTests: XCTestCase {
    
    struct TestPage: Page {
        
        var body: AnyContent {
            Document(type: .html5)
            Html {
                Head {
                    Title {
                        "title"
                    }
                }
                Body {
                }
            }
        }
    }
    
    func testIntegrationBySingleton() throws {
        
        let app = Application(.testing)
        
        defer { app.shutdown() }
        
        try app.htmlkit.add(view: TestPage())
        
        app.get("test") { request -> EventLoopFuture<Vapor.View> in
            
            request.eventLoop.submit {
                return try request.htmlkit.render(view: TestPage.self)
            }
        }
        
        try app.test(.GET, "test") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(response.body.string,
                            """
                            <!DOCTYPE html>\
                            <html>\
                            <head>\
                            <title>title</title>\
                            </head>\
                            <body>\
                            </body>\
                            </html>
                            """
            )
        }
    }
    
    @available(macOS 12, *)
    func testAsyncIntegrationBySingleton() throws {
        
        let app = Application(.testing)
        
        defer { app.shutdown() }
        
        try app.htmlkit.add(view: TestPage())
        
        app.get("test") { request async throws -> Vapor.View in
            return try request.htmlkit.render(view: TestPage.self)
        }
        
        try app.test(.GET, "test") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(response.body.string,
                            """
                            <!DOCTYPE html>\
                            <html>\
                            <head>\
                            <title>title</title>\
                            </head>\
                            <body>\
                            </body>\
                            </html>
                            """
            )
        }
    }
    
    func testIntegrationByStructure() throws {
        
        let app = Application(.testing)
        
        defer { app.shutdown() }
        
        app.get("test") { request -> EventLoopFuture<Vapor.View> in
            return TestPage().render(for: request)
        }
        
        try app.test(.GET, "test") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(response.body.string,
                            """
                            <!DOCTYPE html>\
                            <html>\
                            <head>\
                            <title>title</title>\
                            </head>\
                            <body>\
                            </body>\
                            </html>
                            """
            )
        }
    }
    
    @available(macOS 12, *)
    func testAsyncIntegrationByStructure() throws {
        
        let app = Application(.testing)
        
        defer { app.shutdown() }
        
        app.get("test") { request async throws -> Vapor.View in
            return try TestPage().render(for: request)
        }
        
        try app.test(.GET, "test") { response in
            XCTAssertEqual(response.status, .ok)
            XCTAssertEqual(response.body.string,
                            """
                            <!DOCTYPE html>\
                            <html>\
                            <head>\
                            <title>title</title>\
                            </head>\
                            <body>\
                            </body>\
                            </html>
                            """
            )
        }
    }
}

extension IntegrationTests {
    
    static var allTests = [
        ("testIntegrationBySingleton", testIntegrationBySingleton),
        ("testIntegrationByStructure", testIntegrationByStructure)
    ]
}
