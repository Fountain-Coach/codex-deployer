import Foundation

public struct Handlers {
    public init() {}
    public func runffmpeg(_ request: HTTPRequest, body: ToolRequest?) async throws -> HTTPResponse {
        return HTTPResponse(status: 501, headers: ["Content-Type": "text/plain"], body: Data("not implemented".utf8))
    }
    public func runexiftool(_ request: HTTPRequest, body: ToolRequest?) async throws -> HTTPResponse {
        return HTTPResponse(status: 501, headers: ["Content-Type": "text/plain"], body: Data("not implemented".utf8))
    }
    public func runimagemagick(_ request: HTTPRequest, body: ToolRequest?) async throws -> HTTPResponse {
        return HTTPResponse(status: 501, headers: ["Content-Type": "text/plain"], body: Data("not implemented".utf8))
    }
    public func pdfscan(_ request: HTTPRequest, body: ScanRequest?) async throws -> HTTPResponse {
        return HTTPResponse(status: 501, headers: ["Content-Type": "text/plain"], body: Data("not implemented".utf8))
    }
    public func runpandoc(_ request: HTTPRequest, body: ToolRequest?) async throws -> HTTPResponse {
        return HTTPResponse(status: 501, headers: ["Content-Type": "text/plain"], body: Data("not implemented".utf8))
    }
    public func pdfexportmatrix(_ request: HTTPRequest, body: ExportMatrixRequest?) async throws -> HTTPResponse {
        return HTTPResponse(status: 501, headers: ["Content-Type": "text/plain"], body: Data("not implemented".utf8))
    }
    public func runlibplist(_ request: HTTPRequest, body: ToolRequest?) async throws -> HTTPResponse {
        return HTTPResponse(status: 501, headers: ["Content-Type": "text/plain"], body: Data("not implemented".utf8))
    }
    public func pdfquery(_ request: HTTPRequest, body: QueryRequest?) async throws -> HTTPResponse {
        return HTTPResponse(status: 501, headers: ["Content-Type": "text/plain"], body: Data("not implemented".utf8))
    }
    public func pdfindexvalidate(_ request: HTTPRequest, body: Index?) async throws -> HTTPResponse {
        return HTTPResponse(status: 501, headers: ["Content-Type": "text/plain"], body: Data("not implemented".utf8))
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
