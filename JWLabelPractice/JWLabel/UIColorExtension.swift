//
//  UIColorExtension.swift
//
//  Created by Jiwon Nam on 2021/03/22.
//

import UIKit

/// Color Extensions
extension UIColor {
    
    struct SampleColors {
        /// Color Code  #69E0A5
        static var main: UIColor { return UIColor(hex: "#69E0A5") }
        /// Color Code #5DD89B
        static var main_2: UIColor { return UIColor(hex: "#5DD89B") }
        /// Color Code #76A7FF
        static var sub: UIColor { return UIColor(hex: "#76A7FF") }
        /// Color Code #FF9E91
        static var sub_1: UIColor { return UIColor(hex: "#FF9E91") }
        /// Color Code #759FEC
        static var sub_2: UIColor { return UIColor(hex: "#759FEC") }
        /// Color Code #FF3B30
        static var sub_3: UIColor { return UIColor(hex: "#FF3B30") }
        /// Color Code #3E70F2
        static var graph: UIColor { return UIColor(hex: "#3E70F2") }
        /// Color Code #FFFFFF
        static var white: UIColor { return UIColor(hex: "#FFFFFF") }
        /// Color Code #F5F5F5
        static var gray_0: UIColor { return UIColor(hex: "#F5F5F5") }
        /// Color Code #E7E7E7
        static var gray_1: UIColor { return UIColor(hex: "#E7E7E7") }
        /// Color Code #D0D0D0
        static var gray_2: UIColor { return UIColor(hex: "#D0D0D0") }
        /// Color Code #9F9F9F
        static var gray_3: UIColor { return UIColor(hex: "#9F9F9F") }
        /// Color Code #797979
        static var gray_4: UIColor { return UIColor(hex: "#797979") }
        ///  Color Code #F9F9F9
        static var gray_5: UIColor { return UIColor(hex: "#F9F9F9") }
        /// Color Code #F6F6F6
        static var gray_6: UIColor { return UIColor(hex: "#F6F6F6") }
        /// Color Code #C4C4C4
        static var gray_7: UIColor { return UIColor(hex: "#C4C4C4") }
        /// Color Code #DDDDDD
        static var gray_8: UIColor { return UIColor(hex: "#DDDDDD") }
        /// Color Code #E5E5E5
        static var gray_9: UIColor { return UIColor(hex: "#E5E5E5") }
        /// Color Code #ECECEC
        static var gray_10: UIColor { return UIColor(hex: "#ECECEC") }
        /// Color Code #BABABA
        static var gray_11: UIColor { return UIColor(hex: "#BABABA") }
        /// Color Code #636363
        static var gray_list: UIColor { return UIColor(hex: "#636363") }
        /// Color Code #497CFF
        static var text_link: UIColor { return UIColor(hex: "#497CFF") }
        /// Color Code #D6D6D6
        static var gray_side: UIColor { return UIColor(hex: "#D6D6D6") }
        /// Color Code #FE5D54
        static var red: UIColor { return UIColor(hex: "#FE5D54") }
        /// Color Code #A199FF
        static var purple: UIColor { return UIColor(hex: "#A199FF") }
        /// Color Code #333333
        static var description_black: UIColor { return UIColor(hex: "#333333") }
        /// Color Code #FE5D54
        static var like: UIColor { return UIColor(hex: "#FE5D54") }
        /// Color Code #494949 -> ios #343434
        static var black: UIColor { return UIColor(hex: "#343434") }
        /// Color Code #222222
        static var black_2: UIColor { return UIColor(hex: "#222222") }
        /// Color Code #424242
        static var black_3: UIColor { return UIColor(hex: "#424242") }
        /// Color Code #FFAB9F
        static var pink: UIColor { return UIColor(hex: "#FFAB9F") }
        /// Color Code #F05951
        static var light_red: UIColor { return UIColor(hex: "#F05951")}
    }
    
    
    /// Conveinence initializer with hex num
    /// - Parameter hex: hex num as string
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 1.0

        let length = hexSanitized.count

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            self.init()
            return
        }

        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0

        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0

        } else {
            self.init()
            return
        }

        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
