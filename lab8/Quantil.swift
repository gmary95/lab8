import Foundation

class Quantil
{
    private static let Up = 1.96
    private static let Normal_C0 = 2.515517
    private static let Normal_C1 = 0.802853
    private static let Normal_C2 = 0.010328
    private static let Normal_D0 = 1.432788
    private static let Normal_D1 = 0.1892659
    private static let Normal_D2 = 0.001308
    
    public static func FisherQuantil(p: Double, v1: Double, v2: Double) -> Double {
        let sigma1 = 1.0 / v1 + 1.0 / v2
        let sigma2 = 1.0 / v1 - 1.0 / v2
        let z = Double(Up) * sqrt(Double(sigma1) / 2.0) - Double(1.0) / 6.0 * sigma2 * (Up * Up + 2.0) +
            sqrt(Double(sigma1) / 2.0) * (Double(sigma1) / 24.0 * (Up * Up + 3.0 * Up) + (1.0 / 72.0) * ((sigma2 * sigma2) / sigma1) * (pow(Up, 3.0) + 11.0 * Up)) -
            (Double((sigma2 * sigma1)) / 120.0) * (pow(Up, 4.0) + 9.0 * Up * Up + 8.0) +
            (pow(sigma2, 3) / (3240.0 * sigma1)) * (3.0 * pow(Up, 4) + 7.0 * Up * Up - 16.0) +
            sqrt(Double(sigma1) / 2.0) * (((pow(sigma1, 2) / 1920.0) * (pow(Up, 5) + 20.0 * Up * Up * Up + 15.0 * Up)) +
                (pow(sigma2, 4) / 2880.0) * (pow(Up, 5) + 44.0 * Up * Up * Up + 183.0 * Up) +
                (pow(sigma2, 4) / (155520.0 * sigma1 * sigma1)) * (9.0 * pow(Up, 5) - 284.0 * Up * Up * Up - 1513.0 * Up))
        return pow(M_E, 2.0 * z)
    }
    
    public static func NormalQuantil(p: Double) -> Double {
        var result = 0.0
        var a, t: Double
        
        if (p > 0.5) {
            a = 1.0 - p
        } else {
            a = p
        }
        
        t = sqrt(-2.0 * log(a))
        
        result = t - ((Normal_C0 + (Normal_C1 * t) + (Normal_C2 * t * t)) / (1 + (Normal_D0 * t) + (Normal_D1 * t * t) + (Normal_D2 * t * t * t)))
        
        if (!(p > 0.5)) {
            result = result * (-1.0)
        }
        
        return result
    }
    
    public static func PirsonQuantil(p: Double, v: Double) -> Double {
        var result = 0.0
        var up: Double
        
        up = Up //NormalQuantil(p: p)
        let a = 2.0 / (9.0 * v)
        
        result = v * pow(1.0 - a + (up * sqrt(a)), 3.0)
        
        return result
    }
    
    public static func StudentQuantil(p: Double, v: Double) -> Double {
        var result: Double
        var up: Double
        
        up = Up
        
        result = up + ((1.0 / v) * StudentG1(up: up)) +
            ((1.0 / pow(v, 2)) * StudentG2(up: up)) +
            ((1.0 / pow(v, 3)) * StudentG3(up: up)) +
            ((1.0 / pow(v, 4)) * StudentG4(up: up))
        
        return result
    }
    
    
    private static func StudentG1(up: Double) -> Double {
        var result: Double
        
        result = (1.0 / 4.0) * (pow(up, 3) + up)
        
        return result
    }
    
    private static func StudentG2(up: Double) -> Double {
        var result: Double
        
        result = (1.0 / 96.0) * ((5.0 * pow(up, 5)) + (16.0 * pow(up, 3)) + (3.0 * up))
        
        return result
    }
    
    private static func StudentG3(up: Double) -> Double {
        var result: Double
        
        result = (1.0 / 384.0) * ((3.0 * pow(up, 7)) + (19.0 * pow(up, 5)) + (17.0 * pow(up, 3)) - (15.0 * up))
        
        return result
    }
    
    private static func StudentG4(up: Double) -> Double {
        var result: Double
        
        result = (1.0 / 92160.0) * ((79.0 * pow(up, 9)) + (779.0 * pow(up, 7)) + (1482.0 * pow(up, 5)) - (1920.0 * pow(up, 3)) - (945.0 * up))
        
        return result
    }
}

