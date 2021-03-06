//
//  String+Helpers.swift
//  paymon
//
//  Created by Jogendar Singh on 07/07/18.
//  Copyright © 2018 Semen Gleym. All rights reserved.
//

import UIKit

extension String {
    
    func matches(_ regex: String) -> Bool {
        return self.range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, count) ..< count]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(count, r.lowerBound)),
                                            upper: min(count, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }


    func toHexData() -> Data? {
        var data = Data(capacity: count / 2)

        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }

        guard data.count > 0 else { return nil }

        return data
    }

    func withLeadingZero(_ count: Int) -> String {
        var string = self
        while string.count != 64 {
            string = "0" + string
        }
        return string
    }
    
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    func ltrim(_ chars: Set<Character>) -> String {
        if let index = self.index(where: {!chars.contains($0)}) {
            return String(self[index..<self.endIndex])
        } else {
            return ""
        }
    }
    
    func rtrim(_ chars: Set<Character>) -> String {
        if let index = self.reversed().index(where: {!chars.contains($0)}) {
            return String(self[self.startIndex...self.index(before: index.base)])
        } else {
            return ""
        }
    }
    
    
        
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [kCTFontAttributeName: font]
        let size = self.size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [kCTFontAttributeName: font]
        let size = self.size(withAttributes: fontAttributes as [NSAttributedString.Key : Any])
        return size.height
    }
    

}

