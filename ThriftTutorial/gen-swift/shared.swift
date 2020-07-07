/**
 * Autogenerated by Thrift Compiler (0.13.0)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */

import Foundation

import Thrift


public final class SharedStruct {

  public var key: Int32

  public var value: String


  public init(key: Int32, value: String) {
    self.key = key
    self.value = value
  }

}

public protocol SharedService {

  ///
  /// - Parameters:
  ///   - key: 
  /// - Returns: SharedStruct
  /// - Throws: 
  func getStruct(key: Int32) throws -> SharedStruct

}

open class SharedServiceClient : TClient /* , SharedService */ {

}

open class SharedServiceProcessor /* SharedService */ {

  typealias ProcessorHandlerDictionary = [String: (Int32, TProtocol, TProtocol, SharedService) throws -> Void]

  public var service: SharedService

  public required init(service: SharedService) {
    self.service = service
  }

}


