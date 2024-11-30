//
//  ViewController.swift
//  Hypersonic
//
//  Created by 南朋友 on 2024/4/8.
//

import Cocoa
import OSLog
import CocoaLumberjackSwift
import Blessed
import SecureXPC
import EmbeddedPropertyList
import Authorized

class ViewController: NSViewController {
    @IBOutlet weak var install: NSButton!
    @IBOutlet weak var uninstall: NSButton!
    @IBOutlet weak var send: NSButton!
    

    func setupLogging() {
        // 创建日志目录
        let fileManager: FileManager = FileManager.default
        let directoryPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let logsDirectory = directoryPaths[0] + "/Logs"
        if !fileManager.fileExists(atPath: logsDirectory) {
            do {
                try fileManager.createDirectory(atPath: logsDirectory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating logs directory: \(error)")
            }
        }

        // 设置日志文件
        let fileLogger: DDFileLogger = DDFileLogger(logFileManager: DDLogFileManagerDefault(logsDirectory: logsDirectory))
        fileLogger.rollingFrequency = 60 * 60 * 24  // 24 hours
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7
        DDLog.add(fileLogger)

        // 设置控制台日志
        let consoleLogger = DDOSLogger.sharedInstance
        DDLog.add(consoleLogger)

        // 设置日志级别
        dynamicLogLevel = .info
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 在程序启动时调用
        setupLogging()
        

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    private func showModal(title: String, error: Error) {
        DispatchQueue.main.async {
            if let window = self.view.window {
                let alert = NSAlert()
                alert.messageText = title
                // Handler error represents an error thrown by a closure registered with the server
                if let error = error as? XPCError, case .handlerError(let handlerError) = error {
                    alert.informativeText = handlerError.localizedDescription
                } else {
                    alert.informativeText = error.localizedDescription
                }
                alert.addButton(withTitle: "OK")
                alert.beginSheetModal(for: window, completionHandler: nil)
                _ = NSApp.runModal(for: window)
            }
        }
    }
    
    
    @IBAction func install(_ sender: Any) {
        DDLogInfo("=> Install")
        do {
            // TODO：icon配置
            try PrivilegedHelperManager.shared.authorizeAndBless(message: "请求安装帮助程序，请予以通行")
        } catch AuthorizationError.canceled {
            // No user feedback needed, user canceled
            DDLogInfo("Cancel install helper tool")
        } catch {
            self.showModal(title: "Install Failed", error: error)
        }
    }
    
    
    @IBAction func uninstall(_ sender: Any) {
        DDLogInfo("=> Uninstall")
    }
    
    
    @IBAction func send(_ sender: Any) {
        DDLogInfo("=> Send")
    }
    
}

