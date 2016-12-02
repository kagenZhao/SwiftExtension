//
//  SwiftMD5.swift
//  kagen-api
//
//  Created by Kagen Zhao on 2016/11/4.
//
//

struct KZDigest {
    let digest: [UInt8]
    
    init(_ digest: [UInt8]) {
        assert(digest.count == 16)
        self.digest = digest
    }
    
    var checksum: String {
        return encodeMD5Digest(digest: digest)
    }
}

private func kz_F(_ b: UInt32, _ c: UInt32, _ d: UInt32) -> UInt32 {
    return (b & c) | ((~b) & d)
}

private func kz_G(_ b: UInt32, _ c: UInt32, _ d: UInt32) -> UInt32 {
    return (b & d) | (c & (~d))
}

private func kz_H(_ b: UInt32, _ c: UInt32, _ d: UInt32) -> UInt32 {
    return b ^ c ^ d
}

private func kz_I(_ b: UInt32, _ c: UInt32, _ d: UInt32) -> UInt32 {
    return c ^ (b | (~d))
}

private func kz_rotateLeft(x: UInt32, by: UInt32) -> UInt32 {
    return ((x << by) & 0xFFFFFFFF) | (x >> (32 - by))
}

// MARK: - Calculating a MD5 digest of bytes from bytes
func kz_md5(bytes: [UInt8]) -> KZDigest {
    // Initialization
    let s: [UInt32] = [
        7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22, 7, 12, 17, 22,
        5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20, 5,  9, 14, 20,
        4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23, 4, 11, 16, 23,
        6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21, 6, 10, 15, 21
    ]
    let K: [UInt32] = [
        0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
        0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
        0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
        0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
        0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
        0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
        0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
        0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
        0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
        0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
        0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
        0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
        0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
        0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
        0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
        0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
    ]
    
    var a0: UInt32 = 0x67452301 // A
    var b0: UInt32 = 0xefcdab89 // B
    var c0: UInt32 = 0x98badcfe // C
    var d0: UInt32 = 0x10325476 // D
    
    // Pad message with a single bit "1"
    var message = bytes
    
    let originalLength = bytes.count
    let bitLength = UInt64(originalLength * 8)
    
    message.append(0x80)
    
    // Pad message with bit "0" until message length is 64 bits fewer than 512
    repeat {
        message.append(0x0)
    } while (message.count * 8) % 512 != 448
    
    message.append(UInt8((bitLength >> 0) & 0xFF))
    message.append(UInt8((bitLength >> 8) & 0xFF))
    message.append(UInt8((bitLength >> 16) & 0xFF))
    message.append(UInt8((bitLength >> 24) & 0xFF))
    message.append(UInt8((bitLength >> 32) & 0xFF))
    message.append(UInt8((bitLength >> 40) & 0xFF))
    message.append(UInt8((bitLength >> 48) & 0xFF))
    message.append(UInt8((bitLength >> 56) & 0xFF))
    
    let newBitLength = message.count * 8
    
    assert(newBitLength % 512 == 0)
    
    // Transform
    
    let chunkLength = 512 // 512-bit
    let chunkLengthInBytes = chunkLength / 8 // 64-bytes
    let totalChunks = newBitLength / chunkLength
    
    assert(totalChunks >= 1)
    
    for chunk in 0..<totalChunks {
        let index = chunk*chunkLengthInBytes
        var chunk: [UInt8] = Array(message[index..<index+chunkLengthInBytes]) // 512-bit/64-byte chunk
        
        // break chunk into sixteen 32-bit words
        var M: [UInt32] = []
        for j in 0..<16 {
            let m0 = UInt32(chunk[4*j+0]) << 0
            let m1 = UInt32(chunk[4*j+1]) << 8
            let m2 = UInt32(chunk[4*j+2]) << 16
            let m3 = UInt32(chunk[4*j+3]) << 24
            let m = UInt32(m0 | m1 | m2 | m3)
            
            M.append(m)
        }
        
        assert(M.count == 16)
        
        var A: UInt32 = a0
        var B: UInt32 = b0
        var C: UInt32 = c0
        var D: UInt32 = d0
        
        for i in 0..<64 {
            var f: UInt32 = 0
            var g: Int = 0
            
            if i < 16 {
                f = kz_F(B, C, D)
                g = i
            } else if i >= 16 && i <= 31 {
                f = kz_G(B, C, D)
                g = ((5*i + 1) % 16)
            } else if i >= 32 && i <= 47 {
                f = kz_H(B, C, D)
                g = ((3*i + 5) % 16)
            } else if i >= 48 && i <= 63 {
                f = kz_I(B, C, D)
                g = ((7*i) % 16)
            }
            
            let dTemp = D
            D = C
            C = B
            
            let x = A &+ f &+ K[i] &+ M[g]
            let by = s[i]
            
            B = B &+ kz_rotateLeft(x: x, by: by)
            A = dTemp
        }
        
        a0 = a0 &+ A
        b0 = b0 &+ B
        c0 = c0 &+ C
        d0 = d0 &+ D
    }
    
    assert(a0 >= 0)
    assert(b0 >= 0)
    assert(c0 >= 0)
    assert(d0 >= 0)
    
    let digest0: UInt8 =   UInt8((a0 >> 0) & 0xFF)
    let digest1: UInt8 =   UInt8((a0 >> 8) & 0xFF)
    let digest2: UInt8 =   UInt8((a0 >> 16) & 0xFF)
    let digest3: UInt8 =   UInt8((a0 >> 24) & 0xFF)
    
    let digest4: UInt8 =   UInt8((b0 >> 0) & 0xFF)
    let digest5: UInt8 =   UInt8((b0 >> 8) & 0xFF)
    let digest6: UInt8 =   UInt8((b0 >> 16) & 0xFF)
    let digest7: UInt8 =   UInt8((b0 >> 24) & 0xFF)
    
    let digest8: UInt8 =   UInt8((c0 >> 0) & 0xFF)
    let digest9: UInt8 =   UInt8((c0 >> 8) & 0xFF)
    let digest10: UInt8 =  UInt8((c0 >> 16) & 0xFF)
    let digest11: UInt8 =  UInt8((c0 >> 24) & 0xFF)
    
    let digest12: UInt8 =  UInt8((d0 >> 0) & 0xFF)
    let digest13: UInt8 =  UInt8((d0 >> 8) & 0xFF)
    let digest14: UInt8 =  UInt8((d0 >> 16) & 0xFF)
    let digest15: UInt8 =  UInt8((d0 >> 24) & 0xFF)
    
    let digest = [
        digest0, digest1, digest2, digest3, digest4, digest5, digest6, digest7,
        digest8, digest9, digest10, digest11, digest12, digest13, digest14, digest15,
        ]
    
    assert(digest.count == 16)
    
    return KZDigest(digest)
}

// MARK: - Encoding a MD5 digest of bytes to a string
func encodeMD5Digest(digest: [UInt8]) -> String {
    assert(digest.count == 16)
    let str = digest.reduce("") { str, byte in
        print("str: \(str) ----------- byte: \(byte)")
        let radix = 16
        let s = String(byte, radix: radix)
        let sum = str + (byte < UInt8(radix) ? "0" : "") + s
        return sum
    }
    return str
}



