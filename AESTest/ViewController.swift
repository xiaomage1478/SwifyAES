//
//  ViewController.swift
//  AESTest
//
//  Created by 小马哥 on 2024/6/13.
//

import UIKit
import AVKit
import AVFoundation

class ViewController: UIViewController {
    
    var localURL = URL(fileURLWithPath: "")
    
    var encryptURL: URL = URL(fileURLWithPath: "")
    
    let key = SwiftyAES.randomKey
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let data = "Hello, World!".data(using: .utf8)!
        do {
            let encryptedData = try SwiftyAES.encrypt(data: data, key: key)
            
            let decryptedData = try SwiftyAES.decrypt(encryptedData: encryptedData, key: key)
            
            let text = String(data: decryptedData, encoding: .utf8)
            print(text ?? "")
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    @IBAction func playAction(_ sender: Any) {
        play()
    }
    
    @IBAction func encriptAction(_ sender: Any) {
        guard let filePath = Bundle.main.path(forResource: "test", ofType: "mp4") else {
            print("test.mp4 not found")
            return
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: filePath))
            let encryptedData = try SwiftyAES.encrypt(data: data, key: key)
            if let url = saveEncryptedDataToSandbox(data: encryptedData, filename: UUID().uuidString + ".mp4") {
                encryptURL = url
                localURL = url
                print("加密结束")
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    @IBAction func decryptAction(_ sender: Any) {
        do {
            
            let data = try Data(contentsOf: encryptURL)
            let decryptedData = try SwiftyAES.decrypt(encryptedData: data, key: key)
            if let url = saveEncryptedDataToSandbox(data: decryptedData, filename: UUID().uuidString + ".mp4") {
                localURL = url
                print("解密结束")
            }
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    // 将加密数据保存到沙盒
    func saveEncryptedDataToSandbox(data: Data, filename: String) -> URL? {
        let fileManager = FileManager.default
        guard let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        let fileURL = directory.appendingPathComponent(filename)
        do {
            try data.write(to: fileURL)
            print("Encrypted data saved to \(fileURL)")
            return fileURL
        } catch {
            print("Failed to save encrypted data: \(error)")
            return nil
        }
    }
    
    func play() {
        
        // 获取项目中的 test.mp4 文件
        let fileURL = localURL
               
        // 创建 AVPlayer
        let player = AVPlayer(url: fileURL)
               
        // 创建 AVPlayerViewController 并配置
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
               
        // 显示视频播放器
        present(playerViewController, animated: true) {
            player.play()
        }
    }
}
