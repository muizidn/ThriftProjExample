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
        }
    }
    
    private func connectThrift() {
        textView.text = ""
        do {
            textView.textColor = .black
            
            var ttransport: TTransport
            
            ttransport = TTCPSocketTransport(
                address: host.text ?? "",
                port: port.text.flatMap { Int32($0) } ?? 0)
            
            ttransport = try TSocketTransport(
                hostname: host.text ?? "",
                port: port.text.flatMap { Int($0) } ?? 0)
            
            // ttransport = TFramedTransport(transport: ttransport)
            
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
