//
//  File.swift
//  AESTest
//
//  Created by 小马哥 on 2024/6/13.
//

import CryptoKit
import Foundation

public enum SwiftyAES {
    public static var ivSize: Int = 12
    
    public static var randomKey: String {
        let key = SymmetricKey(size: .bits128)
        let keyData = key.withUnsafeBytes { Data(Array($0)) }
        let keyString = keyData.base64EncodedString()
        return keyString
    }
    
    public static func symmetricKey(fromBase64 base64String: String) -> SymmetricKey? {
        guard let keyData = Data(base64Encoded: base64String) else {
            return nil
        }
        return SymmetricKey(data: keyData)
    }
    
    public static func encrypt(data: Data, key: SymmetricKey) throws -> Data {
        // 使用指定的 IV 进行加密
        let iv = Data.randomBytes(count: ivSize)
        let sealedBox = try AES.GCM.seal(data, using: key, nonce: AES.GCM.Nonce(data: iv))
        var combinedData = Data()
        combinedData.append(iv)
        combinedData.append(sealedBox.ciphertext)
        combinedData.append(sealedBox.tag)
        return combinedData
    }
    
    public static func encrypt(data: Data, key: String) throws -> Data {
        // 使用指定的 IV 进行加密
        guard let k = symmetricKey(fromBase64: key) else { throw NSError(domain: "Invalid key", code: 2, userInfo: nil) }
        return try encrypt(data: data, key: k)
    }
    
    public static func decrypt(encryptedData: Data, key: String) throws -> Data {
        // 使用指定的 IV 进行解密
        guard let k = symmetricKey(fromBase64: key) else { throw NSError(domain: "Invalid key", code: 2, userInfo: nil) }
        return try decrypt(encryptedData: encryptedData, key: k)
    }
    
    public static func decrypt(encryptedData: Data, key: SymmetricKey) throws -> Data {
        // 假设加密数据格式为：Nonce | Ciphertext | Tag
        let nonceLength = ivSize // AES-GCM 推荐的 IV 长度为 12 字节
        let tagLength = 16 // AES-GCM 的 Tag 长度为 16 字节
        
        // 提取 IV
        let nonceData = encryptedData.prefix(nonceLength)
        guard let nonce = try? AES.GCM.Nonce(data: nonceData) else {
            throw NSError(domain: "Invalid nonce", code: 1, userInfo: nil)
        }
        
        // 提取 Tag
        let tagData = encryptedData.suffix(tagLength)
        
        // 提取 Ciphertext
        let ciphertextData = encryptedData.dropFirst(nonceLength).dropLast(tagLength)
        
        // 创建 SealedBox 并解密
        let sealedBox = try AES.GCM.SealedBox(nonce: nonce, ciphertext: ciphertextData, tag: tagData)
        let decryptedData = try AES.GCM.open(sealedBox, using: key)
        
        return decryptedData
    }
}

// 扩展 Data 以便于生成随机数据
public extension Data {
    static func randomBytes(count: Int) -> Data {
        var data = Data(count: count)
        _ = data.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, count, $0.baseAddress!)
        }
        return data
    }
}
