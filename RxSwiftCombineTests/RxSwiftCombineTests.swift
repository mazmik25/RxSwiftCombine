//
//  RxSwiftCombineTests.swift
//  RxSwiftCombineTests
//
//  Created by Azmi Muhammad on 28/11/20.
//

import XCTest
import Combine
import RxSwift

class RxSwiftCombineTests: XCTestCase {

  private let input = stride(from: 0, to: 10_000_000, by: 1)

  override class var defaultPerformanceMetrics: [XCTPerformanceMetric] {
    return [
      XCTPerformanceMetric("com.apple.XCTPerformanceMetric_TransientHeapAllocationsKilobytes"), .wallClockTime]
    }
  
  func testCombine() {
      measure {
        _ = Publishers.Sequence(sequence: input)
          .map { $0 * 2 }
          .filter { $0.isMultiple(of: 2) }
          .flatMap { Just($0) }
          .count()
          .sink(receiveValue: {
            print($0)
          })
        }
    }
  
  func testRxSwift() {
    measure {
      _ = Observable.from(input)
        .map { $0 * 2 }
        .filter { $0.isMultiple(of: 2) }
        .flatMap { Observable.just($0) }
        .toArray()
        .map { $0.count }
        .subscribe(onSuccess: { print($0) })
    }
  }
}
