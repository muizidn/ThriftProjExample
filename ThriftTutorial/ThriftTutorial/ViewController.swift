//
//  ViewController.swift
//  ThriftTutorial
//
//  Created by Muis on 07/07/20.
//  Copyright © 2020 Muis. All rights reserved.
//

import UIKit
import Thrift

class ViewController: UIViewController {
    @IBOutlet weak var btnSend:UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnSend.addTarget(self, action: #selector(sendThrift), for: .touchUpInside)
    }

    @objc private func sendThrift() {
        textView.text = ""
        do {
            textView.textColor = .black
            
            let ttransport = try TSocketTransport(hostname: "localhost", port: 9090)
            let tprotocol = TBinaryProtocol(on: ttransport)
            
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
