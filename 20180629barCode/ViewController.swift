//
//  ViewController.swift
//  20180629barCode
//
//  Created by 酒井理也 on 2018/06/29.
//  Copyright © 2018年 酒井理也. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
 //   @IBOutlet weak var previewView: UIView!
  //  @IBOutlet weak var label: UILabel!

    
    @IBOutlet weak var previewView: UIView!    
    @IBOutlet weak var label: UILabel!
    
    let detectionArea = UIView()
    var timer: Timer!
    var counter = 0
    var isDetected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セッションのインスタンス生成
        let captureSession = AVCaptureSession()
        
        // 入力（背面カメラ）
      //  let videoDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        let videoDevice = AVCaptureDevice.default(for : .video)
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice!)
        captureSession.addInput(videoInput)
        
        // 出力（ビデオデータ）
        let metadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(metadataOutput)
        
        // メタデータを検出した際のデリゲート設定
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // EAN-13コードの認識を設定
        metadataOutput.metadataObjectTypes = [.ean13, .ean8]
        
        // 検出エリアのビュー
        let x: CGFloat = 0.05
        let y: CGFloat = 0.3
        let width: CGFloat = 0.9
        let height: CGFloat = 0.2
        
        detectionArea.frame = CGRect(x: view.frame.size.width * x, y: view.frame.size.height * y, width: view.frame.size.width * width, height: view.frame.size.height * height)
        detectionArea.layer.borderColor = UIColor.red.cgColor
        detectionArea.layer.borderWidth = 3
        view.addSubview(detectionArea)
        
        // 検出エリアの設定
        metadataOutput.rectOfInterest = CGRect(x: y,y: 1-x-width,width: height,height: width)
        
        // プレビュー
        if let videoLayer = AVCaptureVideoPreviewLayer.init(session: captureSession) as Optional {
            videoLayer.frame = previewView.bounds
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            //previewView.layer.addSublayer(videoLayer)
            previewView.layer.insertSublayer(videoLayer, at:0)
        }
        
        // セッションの開始
        DispatchQueue.global(qos: .userInitiated).async {
            captureSession.startRunning()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        timer.fire()
        
        label.text = "未検出"
        
//        captureOutput(metadataOutput, didOutputMetadataObjects: metadataOutput.metadataObjectTypes, from: AVCaptureConnection.init())
    }


    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 複数のメタデータを検出できる
   //     for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            
            // EAN-13Qコードのデータかどうかの確認
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            if metadata.type == .ean13 || metadata.type == .ean8 {
                if metadata.stringValue != nil {
                    // 検出データを取得
                    counter = 0
                    if !isDetected || label.text != metadata.stringValue! {
                        isDetected = true
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate) // バイブレーション
                        label.text = metadata.stringValue!
                        detectionArea.layer.borderColor = UIColor.white.cgColor
                        detectionArea.layer.borderWidth = 5
                    }
                }
            }
        }
    }
    
    @objc func update(tm: Timer) {
        counter += 1
        print(counter)
        if 1 < counter {
            detectionArea.layer.borderColor = UIColor.red.cgColor
            detectionArea.layer.borderWidth = 3
            label.text = "未表示"
        }
    }
}

//20180630 ver1.0完成
