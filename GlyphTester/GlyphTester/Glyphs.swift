//
//  Glyphs.swift
//  GlyphTester
//
//  Created by Aaron Madlon-Kay on 10/25/16.
//  Copyright © 2016 Aaron Madlon-Kay. All rights reserved.
//

import Foundation
import UIKit

class Glyphs {
    
    static let UnicodeMax = 0x10ffff
    static let AllUnicode = 0...UnicodeMax
    static let Surrogates = 0xd800...0xdfff
    
    static let OutFileName = "ios\(UIDevice.current.systemVersion)-glyphs.txt"
    
    static func compileData(progress: (Int, Int) -> Void) -> URL {
        let docsdir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        try! FileManager.default.createDirectory(at: docsdir, withIntermediateDirectories: true, attributes: nil)
        let outfile = docsdir.appendingPathComponent(OutFileName)
        FileManager.default.createFile(atPath: outfile.path, contents: nil, attributes: nil)
        let handle = try! FileHandle(forWritingTo: outfile)
        handle.truncateFile(atOffset: 0)
        
        let start = Date()

        AllUnicode.lazy.filter { !Surrogates.contains($0) }.forEach { c in
            autoreleasepool {
                let line = getLineForCodePoint(c)
                let data = line.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                handle.write(data)
                if (c % 1000 == 0) {
                    handle.synchronizeFile()
                    progress(c, UnicodeMax)
                }
            }
        }
        
        handle.closeFile()
        
        let end = Date().timeIntervalSince(start)
        print("Processing time: \(end.rounded()) s")
        print("Output file: \(outfile)")
        return outfile
    }
    
    enum CodePointNamingError: Error {
        case nameUnavailable(String)
    }
    
    static func getLineForCodePoint(_ codePoint: Int) -> String {
        let label: String
        do {
            let (glyphName, fontName) = try getNameForCodePoint(codePoint)
            label = "\(glyphName) \(fontName)"
        } catch CodePointNamingError.nameUnavailable(let msg) {
            label = "(\(msg))"
        } catch {
            // Impossible
            label = "(Error)"
        }
        return String(format: "U+%06x \(label)\n", codePoint)
    }
    
    static func getNameForCodePoint(_ codePoint: Int) throws -> (String, String) {
        guard let scalar = UnicodeScalar(codePoint) else {
            throw CodePointNamingError.nameUnavailable("failed to get Unicode scalar")
        }
        let string = String(Character(scalar))
        let text = NSTextStorage(attributedString: NSAttributedString(string: string))
        let layoutManager = NSLayoutManager()
        text.addLayoutManager(layoutManager)
        guard layoutManager.isValidGlyphIndex(0) else {
            throw CodePointNamingError.nameUnavailable("invalid glyph index")
        }
        let glyph = layoutManager.glyph(at: 0)
        let attr = text.attribute(.font, at: 0, longestEffectiveRange: nil, in: NSMakeRange(0, 1))
        guard let font = attr as? UIFont else {
            throw CodePointNamingError.nameUnavailable("failed to get font")
        }
        guard let cgfnt = CGFont(font.fontName as CFString) else {
            throw CodePointNamingError.nameUnavailable("failed to get CGFont")
        }
        guard let name = cgfnt.name(for: glyph) else {
            throw CodePointNamingError.nameUnavailable("failed to get glyph name")
        }
        //print(name)
        return (name as String, font.fontName)
    }
    
}
