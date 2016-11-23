//
//  SettingModel.swift
//  MovieResizer
//
//  Created by Hideko Ogawa on 11/23/16.
//  Copyright © 2016 SoraUsagi Apps. All rights reserved.
//

import Cocoa

class SettingModel: NSObject {

    static let shared = SettingModel()

    private override init() {
        super.init()
        var settingDefault:[String:Any] = [:]
        settingDefault["exportSizeW"] = 1920
        settingDefault["exportSizeH"] = 1080
        settingDefault["embedMovieRectX"] = 1192
        settingDefault["embedMovieRectY"] = 278
        settingDefault["embedMovieRectW"] = 418
        settingDefault["embedMovieRectH"] = 522
        UserDefaults.standard.register(defaults: settingDefault)
    }
    
    var exportSize:CGSize {
        set(value) {
            UserDefaults.standard.set(value.width, forKey: "exportSizeW")
            UserDefaults.standard.set(value.height, forKey: "exportSizeH")
            UserDefaults.standard.synchronize()
        }
        get {
            let w = UserDefaults.standard.integer(forKey: "exportSizeW")
            let h = UserDefaults.standard.integer(forKey: "exportSizeH")
            return CGSize(width: w, height: h)
        }
    }

    var backgroundFilePath: String {
        set(value) {
            UserDefaults.standard.set(value, forKey: "backgroundFilePath")
            UserDefaults.standard.synchronize()
        }
        get {
            if let v = UserDefaults.standard.object(forKey: "backgroundFilePath") as? String {
                return v
            } else {
                return ""
            }
        }
    }

    var overlayFilePath: String {
        set(value) {
            UserDefaults.standard.set(value, forKey: "overlayFilePath")
            UserDefaults.standard.synchronize()
        }
        get {
            if let v = UserDefaults.standard.object(forKey: "overlayFilePath") as? String {
                return v
            } else {
                return ""
            }
        }
    }

    var movieFilePath: String {
        set(value) {
            UserDefaults.standard.set(value, forKey: "movieFilePath")
            UserDefaults.standard.synchronize()
        }
        get {
            if let v = UserDefaults.standard.object(forKey: "movieFilePath") as? String {
                return v
            } else {
                return ""
            }
        }
    }

    var embedMovieRect: CGRect {
        set(value) {
            UserDefaults.standard.set(value.origin.x, forKey: "embedMovieRectX")
            UserDefaults.standard.set(value.origin.y, forKey: "embedMovieRectY")
            UserDefaults.standard.set(value.size.width, forKey: "embedMovieRectW")
            UserDefaults.standard.set(value.size.height, forKey: "embedMovieRectH")
            UserDefaults.standard.synchronize()
        }
        get {
            let x = UserDefaults.standard.integer(forKey: "embedMovieRectX")
            let y = UserDefaults.standard.integer(forKey: "embedMovieRectY")
            let w = UserDefaults.standard.integer(forKey: "embedMovieRectW")
            let h = UserDefaults.standard.integer(forKey: "embedMovieRectH")
            return CGRect(x: x, y: y, width: w, height: h)
        }
    }

    var movieBGColor: NSColor {
        set (value) {
            let data = NSKeyedArchiver.archivedData(withRootObject: value)
            UserDefaults.standard.set(data, forKey: "movieBGColor")
            UserDefaults.standard.synchronize()
        }
        get {
            if let data = UserDefaults.standard.object(forKey: "movieBGColor") as? Data {
                if let v = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSColor {
                    return v
                }
            }
            return NSColor.black
        }
    }

    var layerBGColor: NSColor {
        set (value) {
            let data = NSKeyedArchiver.archivedData(withRootObject: value)
            UserDefaults.standard.set(data, forKey: "layerBGColor")
            UserDefaults.standard.synchronize()
        }
        get {
            if let data = UserDefaults.standard.object(forKey: "layerBGColor") as? Data {
                if let v = NSKeyedUnarchiver.unarchiveObject(with: data) as? NSColor {
                    return v
                }
            }
            return NSColor.white
        }
    }
}
