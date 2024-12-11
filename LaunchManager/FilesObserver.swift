//
//  FilesObserver.swift
//  LaunchManager
//
//  Created by Yesheng Liang on 12/10/24.
//

import Foundation

class FilesObserver {
    private init() {}
    static let shared = FilesObserver()
    
    private var files = Set<String>()
    private var timer: Timer?
    
    func add(path: String) {
        files.insert(path)
    }
    
    func remove(path: String) {
        files.remove(path)
    }
    
    func set(files: [String]) {
        self.files = Set(files)
    }
    
    func startObserving() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.checkFiles()
        }
    }
    
    func stopObserving() {
        timer?.invalidate()
    }
    
    private func checkFiles() {
        for file in files {
            if !FileManager.default.fileExists(atPath: file) {
                NotificationCenter.default.post(name: .fileRemoved, object: file)
                remove(path: file)
            }
        }
    }
}

extension NSNotification.Name {
    static let fileRemoved = Notification.Name("fileRemoved")
}
