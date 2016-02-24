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
    var flashMode: AVCaptureFlashMode = AVCaptureFlashMode.Auto
    var authorizationStatus: AVAuthorizationStatus {
        return AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(animated: Bool) {
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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &myContext && keyPath == "capturingStillImage" {
            if let dict = change,
            let value = dict["new"] as? Bool where value == true {
                self.stopSession()
            } else {
                self.startSession()
            }
        } else {
            super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
        }
    }

}

// MARK: - PrivateMethod
extension TestTakePhotoViewController {
    
    private func setupTakePhotoView() {
        takePhotoView.userInteractionEnabled = true
        let changeFocusGesture = UITapGestureRecognizer(target: self, action: "handleChangeFocusGesture:")
        takePhotoView.addGestureRecognizer(changeFocusGesture)
    }
    
    private func setupCamera() {
        self.stillImageOutput.addObserver(self, forKeyPath: "capturingStillImage", options: .New, context: &myContext)
        
        
        switch authorizationStatus {
        case.NotDetermined:
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted: Bool) -> Void in
                if granted {
                    self.configureCamera()
                } else {
                    self.showErrorAlertView()
                }
            })
        case.Authorized:
            self.configureCamera()
        default:
            self.showErrorAlertView()
        }
    }
    
    private func configureCamera() {
        session.sessionPreset = AVCaptureSessionPresetPhoto
        let availableCameraArray = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for tempDevice in availableCameraArray as! [AVCaptureDevice] {
            if tempDevice.position == .Back {
                backCameraDevice = tempDevice
            } else if tempDevice.position == .Front {
                frontCameraDevice = tempDevice
            }
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        if let tempLayer = previewLayer {
            tempLayer.frame = self.takePhotoView.bounds
            tempLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.takePhotoView.layer.addSublayer(tempLayer)
        }
        
        if session.canAddOutput(self.stillImageOutput) {
            session.addOutput(self.stillImageOutput)
        }
        
        do {
            for tempInput in session.inputs as! [AVCaptureInput] { //貌似不这么先删一遍就加不进去
                session.removeInput(tempInput)
            }
            
            let cameraInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: self.currentCameraDevice)
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
                if tempDevice.isFocusModeSupported(.AutoFocus) {
                    tempDevice.focusMode = .AutoFocus
                }
                if tempDevice.isWhiteBalanceModeSupported(.AutoWhiteBalance) {
                    tempDevice.whiteBalanceMode = .AutoWhiteBalance
                }
                tempDevice.unlockForConfiguration()
                
            }
            
        } catch {
            NSLog("")
        }
        
        self.startSession()
    }
    
    private func showErrorAlertView() {
        let alert = UIAlertView(title: "提醒", message: "未授权应用使用相机，请前往设置内打开相机权限", delegate: nil, cancelButtonTitle: "确定")
        alert.show()
    }
    
    private func startSession() { //如果有需要，可能需要另开线程来做
        if authorizationStatus == .Authorized {
            session.startRunning()
        }
    }
    
    private func stopSession() { //如果有需要，可能需要另开线程来做
        if authorizationStatus == .Authorized {
            session.stopRunning()
        }
    }
}

// MARK: - Action
extension TestTakePhotoViewController {
    
    func image(image: UIImage, didFinishSavingWithError: NSError?, contextInfo: AnyObject) {
        NSLog("error is \(didFinishSavingWithError)")
    }

    
    
    
    @IBAction func handleTakePhotoButtonTapped(sender: UIButton) {
        let connection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection) { [unowned self] (imageDataSampleBuffer: CMSampleBuffer!, error) -> Void in
            if error == nil {
                // 如果使用 session .Photo 预设，或者在设备输出设置中明确进行了设置,就能获得已经压缩为JPEG的数据
                let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                // 样本缓冲区也包含元数据
                // let metadata:NSDictionary = CMCopyDictionaryOfAttachments(nil, imageDataSampleBuffer, CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))!
                if let image = UIImage(data: imageData) {
                    //注意这个image还是摄像头拍下来时的分辨率，并不是你设置的layer大小的，如果还需要剪裁，就剪裁之后在保存
                    UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
                }
            } else {
                NSLog("error while capturing still image: \(error)")
            }
            
        }
        
        
    }
    
    @IBAction func handleChangeCameraButtonTapped(sender: UIButton) {
        self.isBackCamera = !self.isBackCamera
        self.configureCamera()
    }
    
    @IBAction func handleFlashButtonTapped(sender: UIButton) {
        if let currentCameraDevice = currentCameraDevice {
            if currentCameraDevice.hasFlash == true {
                try! currentCameraDevice.lockForConfiguration()
                if currentCameraDevice.flashMode == .Off {
                    currentCameraDevice.flashMode = .On;
                    
                } else if currentCameraDevice.flashMode == .On {
                    currentCameraDevice.flashMode = .Auto;
                    
                } else if currentCameraDevice.flashMode == .Auto {
                    currentCameraDevice.flashMode = .Off;
                    
                }
                currentCameraDevice.unlockForConfiguration()
            }
        }
        
    }
    
    @IBAction func handleBackButtonTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction func handleChangeFocusGesture(sender: UITapGestureRecognizer) {
        let pointInPreview = sender.locationInView(sender.view)
        if let tempLayer = self.previewLayer {
            let pointInCamera = tempLayer.captureDevicePointOfInterestForPoint(pointInPreview)
            if let currentCameraDevice = currentCameraDevice {
                try! currentCameraDevice.lockForConfiguration()
                if currentCameraDevice.focusPointOfInterestSupported == true {
                    currentCameraDevice.focusPointOfInterest = pointInCamera
                    currentCameraDevice.focusMode = .AutoFocus
                }
                if currentCameraDevice.isExposureModeSupported(.AutoExpose) {
                    if currentCameraDevice.exposurePointOfInterestSupported == true {
                        currentCameraDevice.exposurePointOfInterest = pointInCamera
                        currentCameraDevice.exposureMode = .AutoExpose
                    }
                }
                currentCameraDevice.unlockForConfiguration()
            }
        
        }

    }
    
}

