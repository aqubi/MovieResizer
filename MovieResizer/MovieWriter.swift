//
//  MovieWriter.swift
//  MovieResizer
//
//  Created by Hideko Ogawa on 11/21/16.
//  Copyright © 2016 SoraUsagi Apps. All rights reserved.
//

import Cocoa
import AVFoundation

protocol MovieWriterDelegate {
    func didFinishExport(status:AVAssetExportSessionStatus, error:Error?)
    func exportProgress(_ progress:Float)
}

class MovieWriter: NSObject {

    var delegate:MovieWriterDelegate?
    private var progressTimer: Timer?
    private var exportSession: AVAssetExportSession?

    func exportMovie(moviePath:String, outputPath:String, fileType:ExportFileType, fps:Int, videoLayer:CALayer, rootLayer:CALayer) {

        let composition = AVMutableComposition()
        let videoComposition = AVMutableVideoComposition()
        
        let tool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: rootLayer)
        videoComposition.animationTool = tool
        
        let asset = AVURLAsset(url: URL(fileURLWithPath: moviePath), options:nil)
        let assetTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first!
        
        let videoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: 0)
        let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        let movieSize = assetTrack.naturalSize
        var transform = assetTrack.preferredTransform
        let scaleW = rootLayer.frame.size.width / movieSize.width
        let scaleH = rootLayer.frame.size.height / movieSize.height
        transform = transform.scaledBy(x: scaleW, y: scaleH)
        layer.setTransform(transform, at: kCMTimeZero)
        
        let movieRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        try! videoTrack.insertTimeRange(movieRange, of: assetTrack, at: CMTime(seconds: 0, preferredTimescale: assetTrack.naturalTimeScale))
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        instruction.layerInstructions = [layer]
        videoComposition.instructions = [instruction]
        videoComposition.frameDuration = CMTime(value: 1, timescale: CMTimeScale(fps))
        videoComposition.renderSize = rootLayer.frame.size
        
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)!
        exportSession.outputFileType = fileType.fileType
        exportSession.outputURL = URL(fileURLWithPath: outputPath)
        exportSession.videoComposition = videoComposition
        self.exportSession = exportSession
        let timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(MovieWriter.updateTimer), userInfo: nil, repeats: true)
        
        exportSession.exportAsynchronously(completionHandler: {
            timer.invalidate()
            self.progressTimer = nil
            DispatchQueue.main.async {
                self.delegate?.didFinishExport(status: exportSession.status, error: exportSession.error)
            }
        })
    }

    func updateTimer() {
        if let session = exportSession {
            DispatchQueue.main.async {
                self.delegate?.exportProgress(session.progress)
            }
        }
    }
}
