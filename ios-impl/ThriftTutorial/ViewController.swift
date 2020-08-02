//
//  ViewController.swift
//  ThriftTutorial
//
//  Created by Muis on 07/07/20.
//  Copyright © 2020 Muis. All rights reserved.
//

import UIKit
import Thrift
import SwiftSocket
import Darwin

final class ViewController: UIViewController {
    @IBOutlet weak var btnSend:UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var host: UITextField!
    @IBOutlet weak var port: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSend.addTarget(self, action: #selector(connect), for: .touchUpInside)
        
        do {
            let a = TSocketTransport2(hostname: "", port: 2)
            print("a", a)
        }
        print("===")
        do {
//            let a = try! TTCPClient(hostname: "0.0.0.0", port: 8989)
//            print("a2", a)
        }
    }
    
    @objc func connect() {
        host.resignFirstResponder()
        port.resignFirstResponder()
        
        connectThrift()
        // connectTCP()
    }
    
    private func connectTCP() {
        let client = TCPClient(
            address: host.text ?? "",
            port: port.text.flatMap { Int32($0) } ?? 0)
        
        switch client.connect(timeout: 10) {
        case .success:
            print("Connected!")
        case .failure(let error):
            print("Not connected!", error)
            return
        }
        
        switch client.send(string: "say something") {
        case .success:
            print("Sent!")
        case .failure(let error):
            print("Not sent!", error)
            return
        }
        
        client.close()
    }
    
    private func connectThrift() {
        textView.text = ""
        do {
            textView.textColor = .black
            
            var ttransport: TTransport
            
//            // issue only send ping then socket closed
//            ttransport = TTCPSocketTransport(
//                address: host.text ?? "",
//                port: port.text.flatMap { Int32($0) } ?? 0)
//
//            // issue during connect
//            ttransport = try TSocketTransport(
//                hostname: host.text ?? "",
//                port: port.text.flatMap { Int($0) } ?? 0)
            
            // works
            ttransport = TSocketTransport2(
                hostname: host.text ?? "",
                port: port.text.flatMap { Int32($0) } ?? 0)
            
            var tprotocol: TProtocol
            
            tprotocol = TBinaryProtocol(on: ttransport)
            
            // tprotocol = TCompactProtocol(on: ttransport)
            
            let client = CalculatorClient(inoutProtocol: tprotocol)
            try perform(client: client)
        } catch {
            textView.textColor = .red
            print(error.localizedDescription, to: &textView)
            print("\(error)", to: &textView)
        }
    }
    
    private func perform(client: CalculatorClient) throws {
        try client.ping()
        print("ping", to: &textView)
        
        let sum = try client.add(num1: 1, num2: 2)
        print("Sum: 1 + 2 = \(sum)", to: &textView)
        
        do {
            let work = Work(num1: 1, num2: 1, op: .divide)
            let result = try client.calculate(logid: 1, w: work)
            print("\(work.num1) \(work.op) \(work.num2) = \(result)", to: &textView)
        }
        
        do {
            let work = Work(num1: 15, num2: 10, op: .subtract)
            let result = try client.calculate(logid: 1, w: work)
            print("\(work.num1) \(work.op) \(work.num2) = \(result)", to: &textView)
        }
        
        print("=== Shared struct ===", to: &textView)
        
        let log = try client.getStruct(key: 1)
        print("Check log \(log.value)", to: &textView)
    }
    
    
    
    
}

extension UITextView: TextOutputStream {
    public func write(_ string: String) {
        self.insertText(string)
    }
}

final class TTCPSocketTransport: TTransport {
    private let client: TCPClient
    init(address: String, port: Int32) {
        client = TCPClient(
            address: address,
            port: port)
        
        switch client.connect(timeout: 10) {
        case .success:
            print("Connected!")
        case .failure(let error):
            print("Not connected!", error)
        }
    }
    
    private struct Sys {
      #if os(Linux)
      static let read = Glibc.read
      static let write = Glibc.write
      static let close = Glibc.close
      #else
      static let read = Darwin.read
      static let write = Darwin.write
      static let close = Darwin.close
      #endif
    }
    
    func read(size: Int) throws -> Data {
        guard let buff = client.read(size) else {
            throw NSError(
                domain: "\(self)",
                code: 1,
                userInfo: [
                    NSLocalizedFailureReasonErrorKey:"buff nil \(size)"
            ])
        }

        let data = Data(buff)
        print("READDATA", String(data: data, encoding: .ascii)!)
        return data
    }
    
    func write(data: Data) throws {
        switch client.send(data: data) {
        case .success:
            print("Sent!")
        case .failure(let error):
            print("Not sent!", error)
        }
    }
    
    func flush() throws {
        
    }
    
}

final class TSocketTransport2: TTransport {
    private let _socketDescriptor: Int32
    init(hostname: String, port: Int32) {
        _socketDescriptor = openSocket(UnsafePointer<Int8>(hostname), port)
    }
    
    deinit {
        closeSocket(_socketDescriptor)
    }
    
    public func readAll(size: Int) throws -> Data {
      var out = Data()
      while out.count < size {
        out.append(try self.read(size: size))
      }
      return out
    }
    
    public func read(size: Int) throws -> Data {
      var buff = Array<UInt8>.init(repeating: 0, count: size)
      let readBytes = Darwin.read(_socketDescriptor, &buff, size)
      
      return Data(buff[0..<readBytes])
    }
    
    public func write(data: Data) {
      var bytesToWrite = data.count
      var writeBuffer = data
      while bytesToWrite > 0 {
        let written = writeBuffer.withUnsafeBytes {
          Darwin.write(_socketDescriptor, $0, writeBuffer.count)
        }
        writeBuffer = writeBuffer.subdata(in: written ..< writeBuffer.count)
        bytesToWrite -= written
      }
    }
    
    public func flush() throws {
      // nothing to do
    }
    
    public func close() {
      shutdown(_socketDescriptor, Int32(SHUT_RDWR))
      _ = Darwin.close(_socketDescriptor)
    }
}
