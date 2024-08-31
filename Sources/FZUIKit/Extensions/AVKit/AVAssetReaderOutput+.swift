//
//  AVAssetReaderOutput+.swift
//  
//
//  Created by Florian Zand on 31.08.24.
//

#if os(macOS) || os(iOS) || os(tvOS)
import AVFoundation

extension AVAssetReaderOutput {
    func sampleBuffers() -> [CMSampleBuffer] {
        var sampleBuffers: [CMSampleBuffer] = []
        while let sampleBuffer = copyNextSampleBuffer() {
            sampleBuffers.append(sampleBuffer)
        }
        return sampleBuffers
    }
    
    func imageBuffers() -> [CVImageBuffer] {
        sampleBuffers().compactMap({ CMSampleBufferGetImageBuffer($0) })
    }
}
#endif
