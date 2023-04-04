//
//  XCTAssertThrowsError.swift
//  
//
//  Created by Holloh, Niklas on 04.04.23.
//

import Foundation
import XCTest

/// Asserts that a given expression throws an error.
/// - Parameters:
///   - closure: The expression that is expected to throw.
///   - file: The file from which the function is called. Default is prefilled by the compiler.
///   - line: The line within the file from which the function is called. Default is prefilled by the compiler.
/// - Returns: An error, if an error was thrown. Otherwise nil.
func XCTAssertThrowsError(
    _ closure: @autoclosure () async throws -> Void,
    file: StaticString = #filePath,
    line: UInt = #line
) async -> Error? {
    do {
        try await closure()
        XCTFail("Closure did not throw", file: file, line: line)
        return nil
    } catch {
        return error
    }
}
