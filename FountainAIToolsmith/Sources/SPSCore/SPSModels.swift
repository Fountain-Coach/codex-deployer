import Foundation

// MARK: - Core SPS Data Models

public struct IndexDoc: Codable {
    public var id: String
    public var fileName: String
    public var size: Int
    public var sha256: String?
    public var pages: [IndexPage]
    
    public init(id: String, fileName: String, size: Int, sha256: String? = nil, pages: [IndexPage] = []) {
        self.id = id
        self.fileName = fileName
        self.size = size
        self.sha256 = sha256
        self.pages = pages
    }
}

public struct TextLine: Codable {
    public var text: String
    public var x: Double
    public var y: Double
    public var width: Double
    public var height: Double
    public var hyphenated: Bool?
    
    public init(text: String, x: Double, y: Double, width: Double, height: Double, hyphenated: Bool? = nil) {
        self.text = text
        self.x = x
        self.y = y
        self.width = width
        self.height = height
        self.hyphenated = hyphenated
    }
}

public struct IndexPage: Codable {
    public var number: Int
    public var text: String
    public var lines: [TextLine]
    public var words: [TextLine]?
    
    public init(number: Int, text: String, lines: [TextLine] = [], words: [TextLine]? = nil) {
        self.number = number
        self.text = text
        self.lines = lines
        self.words = words
    }
}

public struct IndexRoot: Codable {
    public var documents: [IndexDoc]
    
    public init(documents: [IndexDoc] = []) {
        self.documents = documents
    }
}

// MARK: - Matrix Export Models

public struct MatrixEntry: Codable {
    public var text: String
    public var page: Int
    public var x: Int
    public var y: Int
    
    public init(text: String, page: Int, x: Int, y: Int) {
        self.text = text
        self.page = page
        self.x = x
        self.y = y
    }
}

public struct BitField: Codable {
    public var name: String
    public var bits: [Int]
    
    public init(name: String, bits: [Int]) {
        self.name = name
        self.bits = bits
    }
}

public struct RangeSpec: Codable {
    public var field: String
    public var min: Int
    public var max: Int
    
    public init(field: String, min: Int, max: Int) {
        self.field = field
        self.min = min
        self.max = max
    }
}

public struct EnumCase: Codable {
    public var name: String
    public var value: Int
    
    public init(name: String, value: Int) {
        self.name = name
        self.value = value
    }
}

public struct EnumSpec: Codable {
    public var field: String
    public var cases: [EnumCase]
    
    public init(field: String, cases: [EnumCase]) {
        self.field = field
        self.cases = cases
    }
}

public struct Matrix: Codable {
    public var schemaVersion: String
    public var messages: [MatrixEntry]
    public var terms: [MatrixEntry]
    public var bitfields: [BitField]?
    public var ranges: [RangeSpec]?
    public var enums: [EnumSpec]?
    
    public init(schemaVersion: String = "2.0", messages: [MatrixEntry] = [], terms: [MatrixEntry] = [], bitfields: [BitField]? = nil, ranges: [RangeSpec]? = nil, enums: [EnumSpec]? = nil) {
        self.schemaVersion = schemaVersion
        self.messages = messages
        self.terms = terms
        self.bitfields = bitfields
        self.ranges = ranges
        self.enums = enums
    }
}

// MARK: - Request/Response Models

public struct ScanRequest: Codable {
    public var inputs: [String]
    public var includeText: Bool
    public var sha256: Bool
    
    public init(inputs: [String], includeText: Bool = false, sha256: Bool = false) {
        self.inputs = inputs
        self.includeText = includeText
        self.sha256 = sha256
    }
}

public struct ValidationResult: Codable {
    public var ok: Bool
    public var issues: [String]
    
    public init(ok: Bool, issues: [String] = []) {
        self.ok = ok
        self.issues = issues
    }
}

public struct QueryRequest: Codable {
    public var index: IndexRoot
    public var q: String
    public var pageRange: String?
    
    public init(index: IndexRoot, q: String, pageRange: String? = nil) {
        self.index = index
        self.q = q
        self.pageRange = pageRange
    }
}

public struct QueryHit: Codable {
    public var docId: String
    public var page: Int
    public var snippet: String
    
    public init(docId: String, page: Int, snippet: String) {
        self.docId = docId
        self.page = page
        self.snippet = snippet
    }
}

public struct QueryResponse: Codable {
    public var hits: [QueryHit]
    
    public init(hits: [QueryHit] = []) {
        self.hits = hits
    }
}

public struct ExportMatrixRequest: Codable {
    public var index: IndexRoot
    public var bitfields: Bool
    public var ranges: Bool
    public var enums: Bool
    
    public init(index: IndexRoot, bitfields: Bool = false, ranges: Bool = false, enums: Bool = false) {
        self.index = index
        self.bitfields = bitfields
        self.ranges = ranges
        self.enums = enums
    }
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.