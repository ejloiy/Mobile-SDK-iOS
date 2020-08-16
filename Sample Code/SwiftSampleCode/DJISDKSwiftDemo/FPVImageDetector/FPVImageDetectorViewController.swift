//
//  FPVImageDetectorViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Dennis Baldwin on 8/16/20.
//  Copyright © 2020 DJI. All rights reserved.
//

import UIKit

class FPVImageDetectorViewController: UIViewController, VideoFrameProcessor, DJIVideoFeedListener {
    
    @IBOutlet weak var fpvView: UIView!
    
    let detector = CIDetector(
                 ofType: CIDetectorTypeQRCode,
                 context: nil,
                 options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
    )!
    
    var boundingBox: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupVideoPreviewer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.resetVideoPreview()
    }
    
    private func setupVideoPreviewer() {
       
        // So we can try and grab video frames
        DJIVideoPreviewer.instance().enableHardwareDecode = true
        DJIVideoPreviewer.instance()?.registFrameProcessor(self)
        
        DJIVideoPreviewer.instance().setView(self.fpvView)
        let product = DJISDKManager.product();
        
        //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
        if ((product?.model == DJIAircraftModelNameA3)
            || (product?.model == DJIAircraftModelNameN3)
            || (product?.model == DJIAircraftModelNameMatrice600)
            || (product?.model == DJIAircraftModelNameMatrice600Pro)){
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.add(self, with: nil)
        }else{
            DJISDKManager.videoFeeder()?.primaryVideoFeed.add(self, with: nil)
        }
        DJIVideoPreviewer.instance().start()
    }
    
    private func resetVideoPreview() {
        DJIVideoPreviewer.instance().unSetView()
        let product = DJISDKManager.product();
        
        //Use "SecondaryVideoFeed" if the DJI Product is A3, N3, Matrice 600, or Matrice 600 Pro, otherwise, use "primaryVideoFeed".
        if ((product?.model == DJIAircraftModelNameA3)
            || (product?.model == DJIAircraftModelNameN3)
            || (product?.model == DJIAircraftModelNameMatrice600)
            || (product?.model == DJIAircraftModelNameMatrice600Pro)){
            DJISDKManager.videoFeeder()?.secondaryVideoFeed.remove(self)
        }else{
            DJISDKManager.videoFeeder()?.primaryVideoFeed.remove(self)
        }
    }
    
    // DJIVideoFeedListener delegate method - this is what displays the video in the fpvView
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData rawData: Data) {
        let videoData = rawData as NSData
        let videoBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.length)
        videoData.getBytes(videoBuffer, length: videoData.length)
        DJIVideoPreviewer.instance().push(videoBuffer, length: Int32(videoData.length))
    }
    
    // VideoFrameProcessor delegate methods
    // This handles processing the video frames for detecting objects
    func videoProcessFrame(_ frame: UnsafeMutablePointer<VideoFrameYUV>!) {
        
        guard let pb = createPixelBuffer(fromFrame: frame.pointee) else {
            return
        }
        
        // Process asychronously
        DispatchQueue.global().async {
            
            //self.semaphore.wait()
            
            let image = CIImage(cvPixelBuffer: pb)
            
            let codes = self.detector.features(in: image) as? [CIQRCodeFeature]
            
            let transformScale = CGAffineTransform(scaleX: 1, y: -1)
            let transform = transformScale.translatedBy(x: 0, y: -image.extent.height)
            
            for code in codes! {
                
                var bounds = code.bounds.applying(transform)
                let fpvViewSize = self.fpvView.bounds.size
                let scale = min(fpvViewSize.width / image.extent.width, fpvViewSize.height / image.extent.height)
                
                let dx = (fpvViewSize.width - image.extent.width * scale) / 2
                let dy = (fpvViewSize.height - image.extent.height * scale) / 2
                
                bounds.applying(CGAffineTransform(scaleX: scale, y: scale))
                bounds.origin.x += dx
                bounds.origin.y += dy
                
                self.drawObjectBoundaries(bounds: bounds)
            }
            
            //self.semaphore.signal()
        }
    }
    
    func videoProcessorEnabled() -> Bool {
        return true
    }
    // End VideoFrameProcessor delegate methods
    
    // Draw
    private func drawObjectBoundaries(bounds: CGRect) {
        DispatchQueue.main.async {
            print("Bounds are \(bounds)")
            self.boundingBox = UIView(frame: bounds)
            self.boundingBox?.layer.borderColor = UIColor.green.cgColor
            self.boundingBox?.layer.borderWidth = 2
            self.boundingBox?.backgroundColor = UIColor.clear
            self.fpvView.addSubview(self.boundingBox!)
        }
    }
    
    // From here: https://stackoverflow.com/questions/58392433/change-buffer-format-of-djivideopreviewer
    private func createPixelBuffer(fromFrame frame: VideoFrameYUV) -> CVPixelBuffer? {
        var initialPixelBuffer: CVPixelBuffer?
        let _: CVReturn = CVPixelBufferCreate(kCFAllocatorDefault, Int(frame.width), Int(frame.height), kCVPixelFormatType_32BGRA, nil, &initialPixelBuffer)
        
        guard let pixelBuffer = initialPixelBuffer, CVPixelBufferLockBaseAddress(pixelBuffer, []) == kCVReturnSuccess
            else {
                return nil
        }
        
        let yPlaneWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 0)
        let yPlaneHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 0)
        
        let uPlaneWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 1)
        let uPlaneHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1)
        
        let vPlaneWidth = CVPixelBufferGetWidthOfPlane(pixelBuffer, 2)
        let vPlaneHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 2)
        
        let yDestination = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0)
        memcpy(yDestination, frame.luma, yPlaneWidth * yPlaneHeight)
        
        let uDestination = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1)
        memcpy(uDestination, frame.chromaB, uPlaneWidth * uPlaneHeight)
        
        let vDestination = CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 2)
        memcpy(vDestination, frame.chromaR, vPlaneWidth * vPlaneHeight)
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, [])
        
        return pixelBuffer
    }
    

}
