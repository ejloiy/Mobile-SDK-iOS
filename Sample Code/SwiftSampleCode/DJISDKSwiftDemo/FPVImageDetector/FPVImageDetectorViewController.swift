//
//  FPVImageDetectorViewController.swift
//  DJISDKSwiftDemo
//
//  Created by Dennis Baldwin on 8/16/20.
//  Copyright © 2020 DJI. All rights reserved.
//

import UIKit

class FPVImageDetectorViewController: UIViewController, VideoFrameProcessor, DJIVideoFeedListener {
    
    
    let detector = CIDetector(
                 ofType: CIDetectorTypeQRCode,
                 context: nil,
                 options: [CIDetectorAccuracy: CIDetectorAccuracyHigh]
    )!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    private func setupVideoPreviewer() {
       
        // So we can try and grab video frames
        DJIVideoPreviewer.instance().enableHardwareDecode = true
        DJIVideoPreviewer.instance()?.registFrameProcessor(self)
        
        //DJIVideoPreviewer.instance().setView(self.fpvView)
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
    
    // DJIVideoFeedListener delegate method
    func videoFeed(_ videoFeed: DJIVideoFeed, didUpdateVideoData rawData: Data) {
        let videoData = rawData as NSData
        let videoBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: videoData.length)
        videoData.getBytes(videoBuffer, length: videoData.length)
        DJIVideoPreviewer.instance().push(videoBuffer, length: Int32(videoData.length))
    }
    
    // VideoFrameProcessor delegate methods
    func videoProcessFrame(_ frame: UnsafeMutablePointer<VideoFrameYUV>!) {
        
        guard let pb = createPixelBuffer(fromFrame: frame.pointee) else {
            return
        }
        
        DispatchQueue.global().async {
            
            //self.semaphore.wait()
            
            let image = CIImage(cvPixelBuffer: pb)
            
            let codes = self.detector.features(in: image, options: [CIDetectorTypeQRCode: true]) as? [CIQRCodeFeature]
            
            if let code = codes?.first {
                print("Found code at \(code.bounds)")
            }
            
            //print("going")
            
            //self.semaphore.signal()
        }
    }
    
    func videoProcessorEnabled() -> Bool {
        return true
    }
    // End VideoFrameProcessor delegate methods
    
    // From here: https://stackoverflow.com/questions/58392433/change-buffer-format-of-djivideopreviewer
    func createPixelBuffer(fromFrame frame: VideoFrameYUV) -> CVPixelBuffer? {
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
