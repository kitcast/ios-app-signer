//
//  FilePicker.swift
//  Kitcast Builder
//
//  Created by Alex Pawlowski on 11/24/17.
//  Copyright © 2017 Kitcast. All rights reserved.
//

import Foundation
import AppKit

class FilePicker: NSObject {
    //private let pathSubject = BehaviorSubject<Path?>(value: nil)
    private let defaults = UserDefaults.standard
    
    @IBInspectable var key: String = ""
    @IBInspectable var `extension`: String = ""
    @IBInspectable var `default`: String? = nil
    @IBInspectable var isDirectory: Bool = false
    
    @IBOutlet weak var field: NSTextField! {
        didSet {
            let defaultURL = `default`
                .map(NSString.init)
                .map { $0.expandingTildeInPath }
                .map { URL(fileURLWithPath: $0, isDirectory: isDirectory) }
            opened(url: defaults.url(forKey: key.filepickerEncoded) ?? defaultURL)
        }
    }
    
    @IBOutlet weak var button: NSButton! {
        didSet {
            button.target = self
            button.action = #selector(open)
        }
    }
    
    //lazy var path: Observable<Path?> = self.pathSubject.asObservable()
    
    var url: URL?
    
    @objc private func open() {
        let panel = NSOpenPanel()
        
        panel.canChooseFiles = !isDirectory
        panel.canChooseDirectories = isDirectory
        panel.allowsMultipleSelection = false
        panel.allowedFileTypes = [`extension`]
        
        guard let window = button.window
            else { return }
        
        panel.beginSheetModal(for: window) { [weak self] response in
            guard let strongSelf = self, response == .OK
                else { return }
            
            strongSelf.opened(url: panel.urls.first)
        }
    }
    
    private func opened(url: URL?) {
        print(url, url?.standardizedFileURL, url?.standardized, url?.prettied)
        self.url = url
        let url = url.map { $0.standardized }
        defaults.set(url, forKey: key.filepickerEncoded)
        field.stringValue = url.map { $0.prettied } ?? ""
    }
}

fileprivate extension String {
    var filepickerEncoded: String {
        return "filepicker_\(self)"
    }
}
