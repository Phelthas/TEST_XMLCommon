//
//  TestTakePhotoViewController.swift
//  Instagram_ouj
//
//  Created by luxiaoming on 16/2/19.
//  Copyright © 2016年 com.ouj. All rights reserved.
//

import UIKit
import AVFoundation

private var myContext = 0

class TestTakePhotoViewController: UIViewController {

    @IBOutlet weak var takePhotoView: UIView!
    @IBOutlet weak var cameraChangeButton: UIButton!
    @IBOutlet weak var flashButton: UIButton!
    
    let stillImageOutput = AVCaptureStillImageOutput()
    var session = AVCaptureSession()
    var backCameraDevice: AVCaptureDevice?
    var frontCameraDevice: AVCaptureDevice?
    var isBackCamera: Bool = true
    var previewLayer: AVCaptureVideoPreviewLayer!
    var flashMode: AVCaptureDevice.FlashMode = AVCaptureDevice.FlashMode.auto
    var authorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
    }
    
    var currentCameraDevice: AVCaptureDevice? {
        if self.isBackCamera {
            return self.backCameraDevice
        } else {
            return self.frontCameraDevice
        }
    }
    
    
    
    deinit {
        self.stillImageOutput.removeObserver(self, forKeyPath: "capturingStillImage")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTakePhotoView()
        setupCamera()
 
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = takePhotoView.bounds
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext && keyPath == "capturingStillImage" {
            if let dict = change,
            let value = dict[NSKeyValueChangeKey.newKey] as? Bool, value == true {
                self.stopSession()
            } else {
                self.startSession()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }

}

// MARK: - PrivateMethod
extension TestTakePhotoViewController {
    
    fileprivate func setupTakePhotoView() {
        takePhotoView.isUserInteractionEnabled = true
        let changeFocusGesture = UITapGestureRecognizer(target: self, action: #selector(TestTakePhotoViewController.handleChangeFocusGesture(_:)))
        takePhotoView.addGestureRecognizer(changeFocusGesture)
    }
    
    fileprivate func setupCamera() {
        self.stillImageOutput.addObserver(self, forKeyPath: "capturingStillImage", options: .new, context: &myContext)
        
        
        switch authorizationStatus {
        case.notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted {
                    self.configureCamera()
                } else {
                    self.showErrorAlertView()
                }
            })
        case.authorized:
            self.configureCamera()
        default:
            self.showErrorAlertView()
        }
    }
    
    fileprivate func configureCamera() {
        session.sessionPreset = AVCaptureSession.Preset.photo
        let availableCameraArray = AVCaptureDevice.devices(for: AVMediaType.video)
        for tempDevice in availableCameraArray {
            if tempDevice.position == .back {
                backCameraDevice = tempDevice
            } else if tempDevice.position == .front {
                frontCameraDevice = tempDevice
            }
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        if let tempLayer = previewLayer {
            tempLayer.frame = self.takePhotoView.bounds
            tempLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.takePhotoView.layer.addSublayer(tempLayer)
        }
        
        if session.canAddOutput(self.stillImageOutput) {
            session.addOutput(self.stillImageOutput)
        }
        
        do {
            for tempInput in session.inputs { //貌似不这么先删一遍就加不进去
                session.removeInput(tempInput)
            }
            
            let cameraInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: self.currentCameraDevice!)
            if session.canAddInput(cameraInput) {
                session.addInput(cameraInput)
            } else {
                NSLog("error")
            }
            
            if let tempDevice = self.currentCameraDevice {
                try tempDevice.lockForConfiguration()
                if tempDevice.hasFlash {
                    tempDevice.flashMode = self.flashMode
                }
                if tempDevice.isFocusModeSupported(.autoFocus) {
                    tempDevice.focusMode = .autoFocus
                }
                if tempDevice.isWhiteBalanceModeSupported(.autoWhiteBalance) {
                    tempDevice.whiteBalanceMode = .autoWhiteBalance
                }
                tempDevice.unlockForConfiguration()
                
            }
            
        } catch {
            NSLog("")
        }
        
        self.startSession()
    }
    
    fileprivate func showErrorAlertView() {
        let alert = UIAlertView(title: "提醒", message: "未授权应用使用相机，请前往设置内打开相机权限", delegate: nil, cancelButtonTitle: "确定")
        alert.show()
    }
    
    fileprivate func startSession() { //如果有需要，可能需要另开线程来做
        if authorizationStatus == .authorized {
            session.startRunning()
        }
    }
    
    fileprivate func stopSession() { //如果有需要，可能需要另开线程来做
        if authorizationStatus == .authorized {
            session.stopRunning()
        }
    }
}

// MARK: - Action
extension TestTakePhotoViewController {
    
    @objc func image(_ image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        NSLog("error is \(didFinishSavingWithError)")
    }

    
    
    
    @IBAction func handleTakePhotoButtonTapped(_ sender: UIButton) {
        guard let connection = self.stillImageOutput.connection(with: AVMediaType.video) else { return }
        self.stillImageOutput.captureStillImageAsynchronously(from: connection) { [unowned self] (imageDataSampleBuffer, error) -> Void in
            if error == nil {
                // 如果使用 session .Photo 预设，或者在设备输出设置中明确进行了设置,就能获得已经压缩为JPEG的数据
                if let imageDataSampleBuffer = imageDataSampleBuffer,
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer),
                    let image = UIImage(data: imageData) {
                    // 样本缓冲区也包含元数据
                    // let metadata:NSDictionary = CMCopyDictionaryOfAttachments(nil, imageDataSampleBuffer, CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))!
                    
                    //注意这个image还是摄像头拍下来时的分辨率，并不是你设置的layer大小的，如果还需要剪裁，就剪裁之后在保存
                    UIImageWriteToSavedPhotosAlbum(image, self, #selector(TestTakePhotoViewController.image(_:didFinishSavingWithError:contextInfo:)), nil)
                }
                
            } else {
                NSLog("error while capturing still image: \(error)")
            }
            
        }
        
        
    }
    
    @IBAction func handleChangeCameraButtonTapped(_ sender: UIButton) {
        self.isBackCamera = !self.isBackCamera
        self.configureCamera()
    }
    
    @IBAction func handleFlashButtonTapped(_ sender: UIButton) {
        if let currentCameraDevice = currentCameraDevice {
            if currentCameraDevice.hasFlash == true {
                try! currentCameraDevice.lockForConfiguration()
                if currentCameraDevice.flashMode == .off {
                    currentCameraDevice.flashMode = .on;
                    
                } else if currentCameraDevice.flashMode == .on {
                    currentCameraDevice.flashMode = .auto;
                    
                } else if currentCameraDevice.flashMode == .auto {
                    currentCameraDevice.flashMode = .off;
                    
                }
                currentCameraDevice.unlockForConfiguration()
            }
        }
        
    }
    
    @IBAction func handleBackButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) { () -> Void in
            
        }
    }
    
    @IBAction func handleChangeFocusGesture(_ sender: UITapGestureRecognizer) {
        let pointInPreview = sender.location(in: sender.view)
        if let tempLayer = self.previewLayer {
            let pointInCamera = tempLayer.captureDevicePointConverted(fromLayerPoint: pointInPreview)
            if let currentCameraDevice = currentCameraDevice {
                try! currentCameraDevice.lockForConfiguration()
                if currentCameraDevice.isFocusPointOfInterestSupported == true {
                    currentCameraDevice.focusPointOfInterest = pointInCamera
                    currentCameraDevice.focusMode = .autoFocus
                }
                if currentCameraDevice.isExposureModeSupported(.autoExpose) {
                    if currentCameraDevice.isExposurePointOfInterestSupported == true {
                        currentCameraDevice.exposurePointOfInterest = pointInCamera
                        currentCameraDevice.exposureMode = .autoExpose
                    }
                }
                currentCameraDevice.unlockForConfiguration()
            }
        
        }

    }
    
}

