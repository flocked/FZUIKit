//
//  FinderFileProgress.swift
//  FZExtensions
//
//  Created by Florian Zand on 20.02.23.
//

#if os(macOS)
import AppKit
import FZSwiftUtils

public class FinderFileProgress {
    internal let progress: Progress
    internal var dateStarted: Date
    internal var cancelObserver: NSKeyValueObservation?
    internal var pauseObserver: NSKeyValueObservation?

    /**
     The url of the file.
     */
    public let url: URL

    /**
     Creates a finder file progress.

     - Parameters url: The url of the file.
     - Parameters fileSize: The size of the file.
     - Parameters kind: The kind of the process.

     - Returns The finder file progress.
     */
    public init(url: URL, fileSize: DataSize, kind: ProgressKind) {
        self.url = url
        progress = .file(url: url, kind: kind.operationKind, fileSize: fileSize)
        state = .executing
        dateStarted = Date()
        isCancellable = false

        pauseObserver = progress.observe(\.isPaused, changeHandler: { [weak self] _, value in
            guard let self = self else { return }
            if self.state != .finished, let isPaused = value.newValue {
                self.state = (isPaused == true) ? .paused : .executing
            }
        })

        cancelObserver = progress.observe(\.isCancelled, changeHandler: { [weak self] _, value in
            guard let self = self else { return }
            if self.state != .finished, let isCancelled = value.newValue {
                self.state = (isCancelled == true) ? .cancelled : .executing
            }
        })

        progress.publish()
    }

    /**
     The state of the progress.
     */
    public fileprivate(set) var state: State {
        didSet {
            if state != oldValue {
                stateHandler?(state)
            }
        }
    }

    /**
     A handler that gets called whenever the state changes.
     */
    public var stateHandler: ((State) -> Void)?

    /**
     The total size of the file.
     */
    public var fileSize: DataSize {
        get { DataSize(Int(progress.totalUnitCount)) }
        set { progress.totalUnitCount = Int64(newValue.bytes)
            if fileSize > completed && state == .finished {
                state = .executing
            }
        }
    }

    /**
     Updates the progress by checking the current size of the file at the url.
      */
    public func updateComleted() {
        if let fileSize = url.resources.fileSize {
            completed = fileSize
        }
    }

    /**
     The progress of the process.
     */
    public var completed: DataSize {
        get { DataSize(Int(progress.completedUnitCount)) }
        set {
            if state == .executing || state == .finished {
                progress.completedUnitCount = Int64(newValue.bytes).clamped(max: progress.totalUnitCount)
                progress.updateEstimatedTimeRemaining(dateStarted: dateStarted)
                if self.completed >= fileSize {
                    state = .finished
                } else {
                    state = .executing
                }
            }
        }
    }

    /**
     The estimated time remaining for completion of the process.
     */
    public fileprivate(set) var estimatedTimeRemaining: TimeDuration? {
        get { if let estimatedTimeRemaining = progress.estimatedTimeRemaining {
            return TimeDuration(estimatedTimeRemaining)
        }
        return nil
        }
        set { progress.estimatedTimeRemaining = newValue?.seconds }
    }

    /**
     A Boolean value that indicates whether the progress is cancellable.
     */
    public var isCancellable: Bool {
        get { progress.isCancellable }
        set { progress.isCancellable = newValue }
    }

    /**
     A Boolean value that indicates whether the progress is pausable.
     */
    public var isPausable: Bool {
        get { progress.isPausable }
        set { progress.isPausable = newValue }
    }

    /**
     Finishes the process.

     Finishes the process sets it's progress to the total file size.
     */
    public func finish() {
        if state != .finished {
            completed = fileSize
            state = .finished
        }
    }

    /**
     Pauses the process.

     The process get's paused if it's pausable and not finished.
     */
    public func pause() {
        if state != .finished, isPausable {
            progress.pause()
            state = .finished
        }
    }

    /**
     Resumes the process.

     The process get's resumed if it isn't finished.
     */
    public func resume() {
        if state != .finished {
            progress.resume()
            dateStarted = Date()
            state = .executing
        }
    }

    /**
     Cancelles the process.

     The process get's cancelled if it's cancellable and not finished.
     */
    public func cancel() {
        if state != .finished, isCancellable {
            state = .cancelled
            progress.cancel()
        }
    }

    deinit {
        // self.isCancellable = true
        //  progress.cancel()
    }

    /// The state of an finder file progress.
    public enum State: String {
        /// The progress is executing.
        case executing = "isExecuting"
        /// The progress is executing.
        case finished = "isFinished"
        /// The progress is finished.
        case cancelled = "isCancelled"
        /// The progress is paused.
        case paused = "isPaused"
    }

    /// The type of an finder file progress.
    public enum ProgressKind {
        /// The progress is tracking the copying of a file.
        case copying
        /// The progress is tracking file decompression after a download.
        case decompressingAfterDownloading
        /// The progress is tracking a file download operation.
        case downloading
        /// The progress is tracking a file upload operation.
        case uploading
        //// The progress is tracking the receipt of a file
        case receiving
        internal var operationKind: Progress.FileOperationKind {
            switch self {
            case .copying: return .copying
            case .decompressingAfterDownloading: return .decompressingAfterDownloading
            case .downloading: return .downloading
            case .uploading: return .uploading
            case .receiving: return .receiving
            }
        }
    }
}

#endif
