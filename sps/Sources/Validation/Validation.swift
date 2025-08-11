import Foundation

public struct ValidationResult: Codable {
    public let coveragePassed: Bool
    public let reservedBitsPassed: Bool
    public let issues: [String]
}

public enum Validator {
    public static func validate(matrixData: Data) -> ValidationResult {
        let decoder = JSONDecoder()
        guard let matrix = try? decoder.decode(Matrix.self, from: matrixData) else {
            return ValidationResult(coveragePassed: false, reservedBitsPassed: false, issues: ["Invalid matrix JSON"])
        }
        var issues: [String] = []
        let coverage = coverageAnalysis(matrix: matrix)
        issues.append(contentsOf: coverage.1)
        let reserved = reservedBitCheck(matrix: matrix)
        issues.append(contentsOf: reserved.1)
        return ValidationResult(coveragePassed: coverage.0, reservedBitsPassed: reserved.0, issues: issues)
    }

    private static func coverageAnalysis(matrix: Matrix) -> (Bool, [String]) {
        let passed = !matrix.messages.isEmpty && !matrix.terms.isEmpty
        return (passed, passed ? [] : ["Matrix missing messages or terms"])
    }

    private static func reservedBitCheck(matrix: Matrix) -> (Bool, [String]) {
        guard let bitfields = matrix.bitfields else { return (true, []) }
        var issues: [String] = []
        var passed = true
        for bf in bitfields {
            for bit in bf.bits where bit < 0 {
                passed = false
                issues.append("Bitfield \(bf.name) has reserved bit \(bit)")
            }
        }
        return (passed, issues)
    }
}

private struct Matrix: Codable {
    var messages: [MatrixEntry]
    var terms: [MatrixEntry]
    var bitfields: [BitField]?
}

private struct MatrixEntry: Codable {
    var text: String
    var page: Int
    var x: Int
    var y: Int
}

private struct BitField: Codable {
    var name: String
    var bits: [Int]
}

// © 2025 Contexter alias Benedikt Eickhoff 🛡️ All rights reserved.
