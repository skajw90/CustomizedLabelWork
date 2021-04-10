//
//  JWTextAttribution.swift
//
//  Created by Jiwon Nam on 2020/10/30.
//

import UIKit
/// Customize Any attribute here for use label in purpose
///
/// <n/> new line,
///
/// <b></b> bold,
///
/// <pp></pp> purple bolded #A199FF
///
/// <bl></bl> blue bolded #76A7FF
///
/// <p></p> pink bolded #FF9E91
///
/// <r></r> red bolded #FE5D54
///
/// <g></g> green, #69E0A5
///
/// <gb></gb> green bolded, #69E0A5
///
/// <cbu></cbu> colored bolded underline , 밑줄:#69E0A5, 1dp
///
/// <BU></BU>, bolded underline :#69E0A5, 1dp
///
/// <u></u>, underlining
///
/// <bgpp></bgpp> background purpple
///
/// <bgp></bgp> background pink
///
/// <bgb></bgb> background blue
///
/// <bgg></bgg> background green
///
///  case n, b, purple, blue, pink, c, cb, cbu, bu, u, bgpp, bgp, bgb, bgg, l
enum AttributionCase: String, CaseIterable {
    case b = "bold"
    case purple = "purple"
    case blue = "blue"
    case pink = "pink"
    case c = "color"
    case cb = "color_bold"
    case cbu = "color_bold_underline"
    case bu = "bold_underline"
    case u = "underline"
    case bgpp = "background_purple"
    case bgp = "background_pink"
    case bgb = "background_blue"
    case bgg = "background_green"
    case l = "link"
    case r = "red"
    
    var code: String {
        switch self {
        case .b: return "<b>"
        case .purple: return "<pp>"
        case .blue: return "<bl>"
        case .pink: return "<p>"
        case .c: return "<g>"
        case .cb: return "<cb>"
        case .cbu: return "<cbu>"
        case .bu: return "<bu>"
        case .u: return "<u>"
        case .bgpp: return "<bgpp>"
        case .bgp: return "<bgp>"
        case .bgb: return "<bgb>"
        case .bgg: return "<bgg>"
        case .l: return "<l>"
        case .r: return "<r>"
        }
    }
    
    var textForm: (from: String, to: String) {
        switch self {
        case .b: return (from: "<b>", to: "</b>")
        case .purple: return (from: "<pp>", to: "</pp>")
        case .blue: return (from: "<bl>", to: "</bl>")
        case .pink: return (from: "<p>", to: "</p>")
        case .c: return (from: "<g>", to: "</g>")
        case .cb: return (from: "<cb>", to: "</cb>")
        case .cbu: return (from: "<cbu>", to: "</cbu>")
        case .bu: return (from: "<bu>", to: "</bu>")
        case .u: return (from: "<u>", to: "</u>")
        case .bgpp: return (from: "<bgpp>", to: "</bgpp>")
        case .bgp: return (from: "<bgp>", to: "</bgp>")
        case .bgb: return (from: "<bgb>", to: "</bgb>")
        case .bgg: return (from: "<bgg>", to: "</bgg>")
        case .l: return (from: "<l>", to: "</l>")
        case .r: return (from: "<r>", to: "</r>")
        }
    }
    
    var textColor: UIColor? {
        switch self {
        case .purple: return UIColor.SampleColors.purple
        case .blue: return UIColor.SampleColors.sub
        case .pink: return UIColor.SampleColors.sub_1
        case .c, .cb: return UIColor.SampleColors.main
        case .bgpp, .bgp, .bgb, .bgg: return UIColor.SampleColors.white
        case .r: return UIColor.SampleColors.red
        default: return nil
        }
    }
    var textBold: Bool {
        switch self {
        case .c, .u, .l: return false
        default: return true
        }
    }
    
    var underlineColor: (width: CGFloat, color: UIColor?)? {
        switch self {
        case .u, .l: return (width: 1, color: self.textColor)
        case .cbu, .bu: return (width: 7, color: UIColor.SampleColors.main)
        default: return nil
        }
    }
    
    var textBackgroundColor: UIColor? {
        switch self {
        case .bgp: return UIColor.SampleColors.sub_1
        case .bgpp: return UIColor.SampleColors.purple
        case .bgb: return UIColor.SampleColors.sub
        case .bgg: return UIColor.SampleColors.main
        default: return nil
        }
    }
    
    static func getAttributionByCode(code: String) -> AttributionCase? {
        for attribution in AttributionCase.allCases {
            if (attribution.textForm.from == code || attribution.textForm.to == code) { return attribution }
        }
        return nil
    }
}
