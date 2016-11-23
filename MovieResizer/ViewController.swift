//
//  ViewController.swift
//  MovieResizer
//
//  Created by Hideko Ogawa on 11/21/16.
//  Copyright © 2016 SoraUsagi Apps. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, MovieWriterDelegate {

    @IBOutlet weak var previewBox: PreviewView!

    @IBOutlet weak var movieColorWell: NSColorWell!
    @IBOutlet weak var moviePathText: NSTextField!
    @IBOutlet weak var movieXText: NumberStepper!
    @IBOutlet weak var movieYText: NumberStepper!
    @IBOutlet weak var movieWText: NumberStepper!
    @IBOutlet weak var movieHText: NumberStepper!
    
    @IBOutlet weak var bgColorWell: NSColorWell!
    @IBOutlet weak var bgImagePathText: NSTextField!
    @IBOutlet weak var overlayImagePathText: NSTextField!

    @IBOutlet weak var outputTypeSegment: NSSegmentedControl!
    @IBOutlet weak var outputFPSSegment: NSSegmentedControl!
    
    @IBOutlet weak var outputDirText: NSTextField!
    @IBOutlet weak var button: NSButton!
    @IBOutlet weak var statusText: NSTextField!
    @IBOutlet weak var progressBar: NSProgressIndicator!

    private var writer = MovieWriter()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        writer.delegate = self
        statusText.stringValue = ""
        outputDirText.stringValue = "\(NSHomeDirectory())/Desktop/MovieResizer/"
        moviePathText.stringValue = SettingModel.shared.movieFilePath
        movieColorWell.color = SettingModel.shared.movieBGColor
        bgColorWell.color = SettingModel.shared.layerBGColor
        
        let rect = SettingModel.shared.embedMovieRect
        movieXText.applyValue(Int(rect.origin.x))
        movieYText.applyValue(Int(rect.origin.y))
        movieWText.applyValue(Int(rect.size.width))
        movieHText.applyValue(Int(rect.size.height))
        previewBox.applyEmbedVideo(embedVideoRect(), image: nil, bgColor: movieColorWell.color)
 
        let bgPath = SettingModel.shared.backgroundFilePath
        bgImagePathText.stringValue = bgPath
        previewBox.applyBackgroundImage(createImage(bgPath), bgColor: bgColorWell.color)
        
        let overlayPath = SettingModel.shared.overlayFilePath
        overlayImagePathText.stringValue = overlayPath
        previewBox.applyOverlayImage(createImage(overlayPath))
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    private func createImage(_ filePath: String?) -> CGImage? {
        guard let path = filePath else { return nil }
        if path.isEmpty { return nil }
        if let image = NSImage(contentsOfFile: path) {
            let rep = NSBitmapImageRep(data: image.tiffRepresentation!)
            return rep?.cgImage
        }
        return nil
    }

    //MARK: Actions

    @IBAction func create(_ sender: Any) {
        let moviePath = moviePathText.stringValue
        if !FileManager.default.fileExists(atPath: moviePath) {
            print("movie not found")
            let alert = NSAlert()
            alert.messageText = "movie not found"
            alert.runModal()
            return
        }
        
        let fileType = ExportFileType.all[outputTypeSegment.selectedSegment]
        let output = outputPath("movie." + fileType.ext)
        let size = previewBox.size
        
        //root
        let rootLayer = CALayer()
        rootLayer.frame = CGRect(origin: .zero, size: size)
        rootLayer.backgroundColor = bgColorWell.color.cgColor
        rootLayer.contents = createImage(bgImagePathText.stringValue)
        
        //video
        let videoLayer = CALayer()
        videoLayer.frame = embedVideoRect()
        videoLayer.backgroundColor = movieColorWell.color.cgColor
        rootLayer.addSublayer(videoLayer)
        
        //overlay
        if let image = createImage(overlayImagePathText.stringValue) {
            let overlay = CALayer()
            overlay.frame = CGRect(origin: .zero, size: size)
            overlay.contents = image
            rootLayer.addSublayer(overlay)
        }
        
        let fps = outputFPSSegment.selectedSegment == 0 ? 30 : 60
        statusText.stringValue = "Creating..."
        button.isEnabled = false
        writer.exportMovie(moviePath: moviePath, outputPath: output, fileType: fileType, fps: fps, videoLayer: videoLayer, rootLayer: rootLayer)
    }

    @IBAction func chooseMovieFile(_ sender: Any) {
        chooseFilePath(fileTypes: ["mov","mp4"], completionHandler: { (path: String) in
            self.moviePathText.stringValue = path
            SettingModel.shared.movieFilePath = path
        })
    }

    @IBAction func chooseBackgroundImage(_ sender: Any) {
        chooseFilePath(fileTypes: ["png","jpg", "jpeg"], completionHandler: { (path: String) in
            self.updateBackgroundImage(path)
        })
    }
    
    @IBAction func clearBackgroundImage(_ sender: Any) {
        updateBackgroundImage("")
    }

    private func updateBackgroundImage(_ path:String) {
        bgImagePathText.stringValue = path
        SettingModel.shared.backgroundFilePath = path
        previewBox.applyBackgroundImage(createImage(path), bgColor: bgColorWell.color)
    }

    @IBAction func chooseOverlayImage(_ sender: Any) {
        chooseFilePath(fileTypes: ["png","jpg", "jpeg"], completionHandler: { (path: String) in
            self.updateOverlayImage(path)
        })
    }
    
    @IBAction func clearOverlayImage(_ sender: Any) {
        updateOverlayImage("")
    }

    @IBAction func didSetMovieBGColor(_ sender: Any) {
        SettingModel.shared.movieBGColor = movieColorWell.color
    }

    @IBAction func didSetBackBGColor(_ sender: Any) {
        SettingModel.shared.layerBGColor = bgColorWell.color
        previewBox.applyBackgroundImage(createImage(bgImagePathText.stringValue), bgColor: bgColorWell.color)
    }

    private func updateOverlayImage(_ path:String) {
        overlayImagePathText.stringValue = path
        SettingModel.shared.overlayFilePath = path
        previewBox.applyOverlayImage(createImage(path))
    }

    @IBAction func applyMovieProperty(_ sender: Any) {
        previewBox.applyEmbedVideo(embedVideoRect(), image: embedVideoImage(), bgColor: movieColorWell.color)
    }

    private func embedVideoRect() -> CGRect {
        var rect = CGRect(x: movieXText.stepper.integerValue,
                      y: movieYText.stepper.integerValue,
                      width: movieWText.stepper.integerValue,
                      height: movieHText.stepper.integerValue)
        rect.origin.y = previewBox.size.height - rect.origin.y - rect.size.height
        return rect
    }

    private func embedVideoImage() -> CGImage? {
        let moviePath = moviePathText.stringValue
        if !FileManager.default.fileExists(atPath: moviePath) { return nil }
        let movieURL = URL(fileURLWithPath: moviePath)
        let asset = AVURLAsset(url: movieURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore = kCMTimeZero
        generator.requestedTimeToleranceAfter = kCMTimeZero
        let time = CMTimeMake(0, 60)
        guard let imageRef = try? generator.copyCGImage(at: time, actualTime: nil) else { return nil }
        guard let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first else { return nil }
        let image = NSImage(cgImage: imageRef, size: assetTrack.naturalSize)
        let rep = NSBitmapImageRep(data: image.tiffRepresentation!)
        return rep?.cgImage
    }

    private func chooseFilePath(fileTypes:[String], completionHandler handler: @escaping (String) -> Swift.Void) {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedFileTypes = fileTypes
        panel.beginSheetModal(for: self.view.window!, completionHandler: { (num: Int) -> Void in
            if num == NSModalResponseOK {
                if let path = panel.url?.path {
                    handler(path)
                }
            } else {
                NSLog("Canceled")
            }
        })
    }

    //MARK: -

    
    private func outputPath(_ fileName:String) -> String {
        let outputDir = outputDirText.stringValue
        let fm = FileManager.default
        if !fm.fileExists(atPath: outputDir) {
            try! fm.createDirectory(atPath: outputDir, withIntermediateDirectories: true, attributes: nil)
        }
        let outputPath = outputDir + "/" + fileName
        if fm.fileExists(atPath: outputPath) {
            try! fm.removeItem(atPath: outputPath)
        }
        return outputPath
    }
    
    //MARK:- MovieWriterDelegate implements

    func didFinishExport(status:AVAssetExportSessionStatus, error:Error?) {
        statusText.stringValue = self.statusString(status)
        button.isEnabled = true
        if let e = error {
            print(e)
            showErrorMessage(error: e)
        }
    }

    func exportProgress(_ progress:Float) {
        progressBar.doubleValue = Double(progress * 100)
    }

    private func showErrorMessage(error:Error) {
        let alert = NSAlert()
        alert.messageText = error.localizedDescription
        alert.runModal()
    }
    
    private func statusString(_ status:AVAssetExportSessionStatus) -> String {
        switch status {
        case .waiting:
            return "waiting"
        case .cancelled:
            return "cancelled"
        case .completed:
            return "completed"
        case .exporting:
            return "exporting"
        case .failed:
            return "failed"
        default:
            return "unknown"
        }
    }
}

enum ExportFileType: Int {
    case mov = 0
    case mp4 = 1
    
    static let all:[ExportFileType] = [mov, mp4]
    
    var fileType:String {
        switch self {
        case .mov:
            return AVFileTypeQuickTimeMovie
        case .mp4:
            return AVFileTypeMPEG4
        }
    }
    
    var ext:String {
        switch self {
        case .mov:
            return "mov"
        case .mp4:
            return "mp4"
        }
    }
}

