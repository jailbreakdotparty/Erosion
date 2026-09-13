//
//  WriteHelpers.swift
//  Erosion
//
//  Created by lunginspector on 8/18/26.
//

import Foundation

func writeFileTemp(_ data: Data, to url: URL) -> (Bool, String) {
    do {
        let tempURL = url.deletingLastPathComponent().appendingPathComponent(".\(url.lastPathComponent).\(UUID().uuidString).tmp")
        
        try data.write(to: tempURL, options: [.withoutOverwriting])
        defer { try? fm.removeItem(at: tempURL) }
        
        if fm.fileExists(atPath: url.path) {
            let _ = try fm.replaceItemAt(url, withItemAt: tempURL)
        } else {
            try fm.moveItem(at: tempURL, to: url)
        }
        
        return (true, "succeeded")
    } catch {
        print("[!] failed to write mobilegestalt: \(error)")
        return (false, error.localizedDescription)
    }
}

func writeFileAtomically(_ data: Data, to url: URL) -> (Bool, String) {
    guard let og = try? Data(contentsOf: url) else {
        return (false, "failed to get original file data!")
    }

    let fd = url.path.withCString {
        open($0, O_RDWR | O_CLOEXEC | O_NOFOLLOW)
    }
    guard fd >= 0 else {
        return (false, fileWriteErr.open(errno: errno).localizedDescription)
    }
    defer {
        close(fd)
    }

    do {
        guard ftruncate(fd, 0) == 0 else {
            return (false, fileWriteErr.truncate(errno: errno).localizedDescription)
        }
        try writeAll(fd, data)
        guard fsync(fd) == 0 else {
            return (false, fileWriteErr.sync(errno: errno).localizedDescription)
        }
        guard lseek(fd, 0, SEEK_SET) >= 0 else {
            return (false, fileWriteErr.verificationFailed.localizedDescription)
        }
        let verify = try readAll(fd)
        guard verify == data else {
            return (false, fileWriteErr.verificationFailed.localizedDescription)
        }
    } catch {
        if ftruncate(fd, 0) == 0,
           lseek(fd, 0, SEEK_SET) >= 0 {
            _ = try? writeAll(fd, og)
            _ = fsync(fd)
        }
        return (false, error.localizedDescription)
    }
    return (true, "succeeded")
}

private enum fileWriteErr: Error {
    case open(errno: Int32)
    case truncate(errno: Int32)
    case write(errno: Int32)
    case sync(errno: Int32)
    case rollback(errno: Int32)
    case verificationFailed
}

private func readAll(_ fd: Int32) throws -> Data {
    var res = Data()
    var buf = [UInt8](repeating: 0, count: 64 * 1024)

    while true {
        let count = buf.withUnsafeMutableBytes { rawBuffer in
            read(fd, rawBuffer.baseAddress, rawBuffer.count)
        }
        if count > 0 {
            res.append(buf, count: count)
            continue
        }
        if count == 0 {
            return res
        }
        if errno == EINTR {
            continue
        }
        throw fileWriteErr.verificationFailed
    }
}

private func writeAll(_ fd: Int32, _ data: Data) throws {
    guard !data.isEmpty else { return }

    try data.withUnsafeBytes { rawBuffer in
        guard let base = rawBuffer.baseAddress else {
            throw fileWriteErr.write(errno: EFAULT)
        }

        var offset = 0
        while offset < data.count {
            let res = write(
                fd,
                base.advanced(by: offset),
                data.count - offset
            )
            if res > 0 {
                offset += res
                continue
            }
            if res < 0 && errno == EINTR {
                continue
            }
            throw fileWriteErr.write(errno: errno)
        }
    }
}
