//
//  PreviewView.swift
//  MovieResizer
//
//  Created by Hideko Ogawa on 11/21/16.
//  Copyright © 2016 SoraUsagi Apps. All rights reserved.
//

import Cocoa

class PreviewView: NSView {
    
    private let rootLayer = CALayer()
    private let videoLayer = CALayer()
    private let overlayLayer = CALayer()

    var size:CGSize = CGSize(width: 1920, height: 1080)

    //MARK:- View Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        register(forDraggedTypes: [NSFilenamesPboardType])
        setupLayer()
    }

    private func setupLayer() {
        let size = self.frame.size
        rootLayer.frame = CGRect(origin: .zero, size: size)
        self.layer?.addSublayer(rootLayer)
        
        //video
        rootLayer.addSublayer(videoLayer)
        
        //overlay
        overlayLayer.frame = CGRect(origin: .zero, size: size)
        rootLayer.addSublayer(overlayLayer)
    }

    //MARK: Actions

    func applyEmbedVideo(_ rect:NSRect, image:CGImage?, bgColor:NSColor?) {
        updateEmbedVideoRect(rect)
        videoLayer.contents = image
        videoLayer.backgroundColor = bgColor?.cgColor
    }

    private func updateEmbedVideoRect(_ embedVideoRect:CGRect) {
        let rate = self.frame.size.width / size.width
        videoLayer.frame.origin.x = embedVideoRect.origin.x * rate
        videoLayer.frame.origin.y = embedVideoRect.origin.y * rate
        videoLayer.frame.size.width = embedVideoRect.size.width * rate
        videoLayer.frame.size.height = embedVideoRect.size.height * rate
    }

    func applyBackgroundImage(_ image: CGImage?, bgColor:NSColor?) {
        rootLayer.backgroundColor = bgColor?.cgColor
        rootLayer.contents = image
    }

    func applyOverlayImage(_ image: CGImage?) {
        overlayLayer.contents = image
    }

    //MARK: -

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {

        return .link
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {

    }

    
}
