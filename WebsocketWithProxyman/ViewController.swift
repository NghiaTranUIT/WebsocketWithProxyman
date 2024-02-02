//
//  ViewController.swift
//  WebsocketWithProxyman
//
//  Created by Nghia Tran on 02/02/2024.
//

import UIKit

final class ViewController: UIViewController, URLSessionWebSocketDelegate {

    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var sendMessageBtn: UIButton!
    @IBOutlet weak var statusLbl: UILabel!

    private var count = 0
    private var isConnected = false {
        didSet {
            startBtn.isEnabled = !isConnected
            sendMessageBtn.isEnabled = isConnected
            statusLbl.text = "Status: \(isConnected ? "Connected ✅" : "Not Connect")"
        }
    }

    private lazy var session: URLSession = {
        return URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }()
    private lazy var webSocketTask: URLSessionWebSocketTask = {
        return session.webSocketTask(with: URL(string: "wss://ws.postman-echo.com/raw")!)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.isConnected = false
    }

    @IBAction func startConnectionBtnOnTap(_ sender: Any) {
        webSocketTask.resume()
        listen()
    }

    @IBAction func sendWSBtnOnTap(_ sender: Any) {
        send(text: "Hello World from Proxyman: Count = \(count)")

        count += 1
    }

    func listen()  {
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received: \(text)")
                case .data(let data):
                    print("Received: Raw Data: \(data.count)")
                @unknown default:
                    fatalError()
                }

                self.listen()
            }
        }
    }

    func send(text: String) {
        webSocketTask.send(URLSessionWebSocketTask.Message.string(text)) { error in
            if let error = error {
                print(error)
            }
        }
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol _protocol: String?) {
        print("didOpenWithProtocol = \(_protocol)")
        self.isConnected = true
    }

    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Closed: \(closeCode)")
        self.isConnected = false
    }
}

