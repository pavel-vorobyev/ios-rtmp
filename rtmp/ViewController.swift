//
//  ViewController.swift
//  rtmp
//
//  Created by Pavel Vorobyev on 19/11/2018.
//  Copyright © 2018 Pavel Vorobyev. All rights reserved.
//

import HaishinKit
import UIKit
import AVFoundation
import Photos
import VideoToolbox

class ViewController: UIViewController {
    
    var rtmpConnection: RTMPConnection = RTMPConnection()
    var rtmpStream: RTMPStream!
    var sharedObject: RTMPSharedObject!
    var currentEffect: VisualEffect?
    var currentPosition: AVCaptureDevice.Position = .back
    
    @IBOutlet weak var cameraContainer: UIView!
    
    var hkView: HKView!
    
    let sampleRate: Double = 44_100

    override func viewDidLoad() {
        super.viewDidLoad()
        
        rtmpStream = RTMPStream(connection: rtmpConnection)
        rtmpStream.syncOrientation = true
        rtmpStream.captureSettings = [
            "sessionPreset": AVCaptureSession.Preset.hd1280x720.rawValue,
            "continuousAutofocus": true,
            "continuousExposure": true
        ]
        rtmpStream.videoSettings = [
            "width": 720,
            "height": 1280,
            "bitrate": 1220000
        ]
        rtmpStream.audioSettings = [
            "sampleRate": sampleRate
        ]
        
        //rtmpStream.mixer.recorder.delegate = ExampleRecorderDelegate()
        
        hkView = HKView(frame: view.bounds)
        hkView.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraContainer.addSubview(hkView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        rtmpStream.attachAudio(AVCaptureDevice.default(for: .audio)) { error in
            //logger.warn(error.description)
        }
        rtmpStream.attachCamera(DeviceUtil.device(withPosition: currentPosition)) { error in
            //logger.warn(error.description)
        }
        
        hkView.attachStream(rtmpStream)
        rtmpConnection.connect("rtmp://maflic.ru:1935/live/")
        rtmpStream.publish("a")
    }
    
    class ExampleRecorderDelegate: DefaultAVMixerRecorderDelegate {
        override func didFinishWriting(_ recorder: AVMixerRecorder) {
            guard let writer: AVAssetWriter = recorder.writer else { return }
            PHPhotoLibrary.shared().performChanges({() -> Void in
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: writer.outputURL)
            }, completionHandler: { (_, error) -> Void in
                do {
                    try FileManager.default.removeItem(at: writer.outputURL)
                } catch let error {
                    print(error)
                }
            })
        }
    }
    
}

