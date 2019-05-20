import Foundation

class ArrayHelper {
    static func findMin(array: [FileModel], iParam: Int) -> Double {
        var min = array.first!.parameters[iParam]
        for elem in array {
            if elem.parameters[iParam] < min {
                min = elem.parameters[iParam]
            }
        }
        return min
    }
    
    static func findMax(array: [FileModel], iParam: Int) -> Double {
        var max = array.first!.parameters[iParam]
        for elem in array {
            if elem.parameters[iParam] > max {
                max = elem.parameters[iParam]
            }
        }
        return max
    }
    
    static func findDx(array: [FileModel], iParam: Int) -> Double {
        var result = 0.0
        let min = ArrayHelper.findMin(array: array, iParam: iParam)
        let max = ArrayHelper.findMax(array: array, iParam: iParam)
        result = max - min
        result /= Double(array[iParam].parameters.count)
        return result
    }
    
    static func findAv(array: [FileModel], iParam: Int) -> Double {
        var result = 0.0
        for elem in array {
            result += elem.parameters[iParam]
        }
        result /= Double(array.count)
        return result
    }
    
    static func findAvPlus(array: [FileModel], iParam: Int) -> Double {
        var result = 0.0
        let min = ArrayHelper.findMin(array: array, iParam: iParam)
        let max = ArrayHelper.findMax(array: array, iParam: iParam)
        result = max + min
        result /= Double(array[iParam].parameters.count)
        return result
    }
    
    static func findAv(array: [Double]) -> Double {
        var result = 0.0
        for elem in array {
            result += elem
        }
        result /= Double(array.count)
        return result
    }
    
    static func findVarience(array: [Double]) -> Double {
        var result = 0.0
        let yAv = ArrayHelper.findAv(array: array)
        for elem in array {
            result += pow(elem - yAv, 2.0)
        }
        result /= Double(array.count - 1)
        return result
    }
}
