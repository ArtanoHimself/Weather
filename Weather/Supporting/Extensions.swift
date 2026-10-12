
import Foundation
import UIKit

extension Int {
    var weatherSymbolName: String {
        switch self {
        case 200...232: return "cloud.bolt.fill"
        case 300...321: return "cloud.drizzle.fill"
        case 500...531: return "cloud.rain.fill"
        case 600...622: return "cloud.snow.fill"
        case 701...781: return "cloud.fog.fill"
        case 800: return "sun.max.fill"
        case 801, 802: return "cloud.sun.fill"
        case 803, 804: return "cloud.fill"
        default: return "cloud.fill"
        }
    }
    
    var weatherPaletteColors: [UIColor] {
        switch self {
        case 200...232: return [.white, .systemYellow]
        case 300...321: return [.white, .systemYellow]
        case 500...531: return [.white, .systemYellow]
        case 600...622: return [.white, .systemYellow]
        case 701...781: return [.white, .white]
        case 800: return [.systemYellow]
        case 801, 802: return [.white, .systemYellow]
        case 803, 804: return [.white]
        default: return [.white]
        }
    }
}
