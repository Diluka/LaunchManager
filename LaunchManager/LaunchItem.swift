//
//  LaunchItem.swift
//  LaunchManager
//
//  Created by Yesheng Liang on 12/9/24.
//

import Foundation
import SwiftData

@Model
final class LaunchItem {
    var label: String
    var command: String
    var runAtLoad: Bool = true
    var keepAlive: Bool = false
    var workingDirectory: String = ""
    var startInterval: Int?
    var active: Bool = false
    var needsUpdate: Bool = true
    
    var createdAt: Date
    
    init(label: String, command: String) {
        self.label = label
        self.command = command
        self.createdAt = Date()
    }
    
    convenience init() {
        self.init(label: "", command: "")
    }
}

extension LaunchItem {
    func plistPath() -> URL {
        let libraryDirectory = try! FileManager.default.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let launchAgentsFolder = libraryDirectory.appendingPathComponent("LaunchAgents")
        return launchAgentsFolder.appendingPathComponent("\(label).plist")
    }
    
    func exportAsPlist() -> String {
        var plistString = ""
        plistString += "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        plistString += "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n"
        plistString += "<plist version=\"1.0\">\n"
        plistString += "<dict>\n"
        plistString += "    <key>Label</key>\n"
        plistString += "    <string>\(label)</string>\n"
        
        let arguments = command.components(separatedBy: .whitespaces)
        if arguments.count > 1 {
            plistString += "    <key>ProgramArguments</key>\n"
            plistString += "    <array>\n"
            for argument in arguments {
                plistString += "        <string>\(argument)</string>\n"
            }
            plistString += "    </array>\n"
        } else {
            plistString += "    <key>Program</key>\n"
            plistString += "    <string>\(command)</string>\n"
        }
        
        if !workingDirectory.isEmpty {
            plistString += "    <key>WorkingDirectory</key>\n"
            plistString += "    <string>\(workingDirectory)</string>\n"
        }
        
        if let startInterval = startInterval {
            plistString += "    <key>StartInterval</key>\n"
            plistString += "    <integer>\(startInterval)</integer>\n"
        }
        
        if runAtLoad {
            plistString += "    <key>RunAtLoad</key>\n"
            plistString += "    <true/>\n"
        }
        
        if keepAlive {
            plistString += "    <key>KeepAlive</key>\n"
            plistString += "    <true/>\n"
        }
        
        // TODO: Add other entries
        
        plistString += "</dict>\n"
        plistString += "</plist>\n"
        
        return plistString
    }
    
    func activate() throws {
        let plistString = exportAsPlist()
        let plistFile = plistPath()
        try plistString.write(to: plistFile, atomically: true, encoding: .utf8)
        active = true
    }
    
    func deactivate() throws {
        let plistFile = plistPath()
        try FileManager.default.removeItem(at: plistFile)
        active = false
    }
    
    var valid: Bool {
        return !label.isEmpty && !command.isEmpty
    }
}
