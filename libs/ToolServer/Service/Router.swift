import Foundation

public struct Router {
    public var handlers: Handlers

    public init(handlers: Handlers = Handlers()) {
        self.handlers = handlers
    }

    public func route(_ request: HTTPRequest) async throws -> HTTPResponse {
        switch (request.method, request.path) {
        case ("POST", "/ffmpeg"):
            let body = try? JSONDecoder().decode(ToolRequest.self, from: request.body)
            return try await handlers.runffmpeg(request, body: body)
        case ("POST", "/exiftool"):
            let body = try? JSONDecoder().decode(ToolRequest.self, from: request.body)
            return try await handlers.runexiftool(request, body: body)
        case ("POST", "/imagemagick"):
            let body = try? JSONDecoder().decode(ToolRequest.self, from: request.body)
            return try await handlers.runimagemagick(request, body: body)
        case ("POST", "/pdf/scan"):
            let body = try? JSONDecoder().decode(ScanRequest.self, from: request.body)
            return try await handlers.pdfscan(request, body: body)
        case ("POST", "/pandoc"):
            let body = try? JSONDecoder().decode(ToolRequest.self, from: request.body)
            return try await handlers.runpandoc(request, body: body)
        case ("POST", "/pdf/export-matrix"):
            let body = try? JSONDecoder().decode(ExportMatrixRequest.self, from: request.body)
            return try await handlers.pdfexportmatrix(request, body: body)
        case ("POST", "/libplist"):
            let body = try? JSONDecoder().decode(ToolRequest.self, from: request.body)
            return try await handlers.runlibplist(request, body: body)
        case ("POST", "/pdf/query"):
            let body = try? JSONDecoder().decode(QueryRequest.self, from: request.body)
            return try await handlers.pdfquery(request, body: body)
        case ("POST", "/pdf/index/validate"):
            let body = try? JSONDecoder().decode(Index.self, from: request.body)
            return try await handlers.pdfindexvalidate(request, body: body)
        default:
            return HTTPResponse(status: 404)
        }
    }
}
// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
