import Foundation

class OrdinaryLeastSquares {
    func calculateParameter(xMatrix:Matrix, yMatrix: Matrix) -> Matrix {
        let xTransponMatrix = xMatrix.transpose()
        let xAndXtransMatrix = xTransponMatrix <*> xMatrix
        let xAndXtransReverseMatrix = xAndXtransMatrix.inverse()
        let tmp = xAndXtransReverseMatrix <*> xAndXtransMatrix
        let xAndXtransReverseAndXTransponMatrix = xAndXtransReverseMatrix <*> xTransponMatrix
        let xAndXtransReverseAndXTransponAndYMatrix =  xAndXtransReverseAndXTransponMatrix <*> yMatrix
        return xAndXtransReverseAndXTransponAndYMatrix
    }
    
    func calculateD(xMatrix:Matrix) -> Matrix {
        let xTransponMatrix = xMatrix.transpose()
        let xAndXtransMatrix = xTransponMatrix <*> xMatrix
        var arr = [[Double]]()
        for i in 0 ..< xAndXtransMatrix.rows {
            arr.append([xAndXtransMatrix.array[i][i]])
        }
        let d = Matrix(arr)
        return d
    }
    
    func calculateDerivation(xMatrix:Matrix, yreg_y2: [Double]) -> Matrix {
        var der = [[Double]]()
        
        let d = calculateD(xMatrix: xMatrix)
        
        let v = (yreg_y2.count - d.rows - 1)
        var s2 = 0.0
        yreg_y2.forEach {
            s2 += $0
        }
        s2 /= Double(v)
        
        let p = 0.05
        let tkr = Quantil.StudentQuantil(p: p, v: Double(v))

        for i in 0 ..< d.rows {
            der.append([tkr * sqrt(d.grid[i] * s2)])
        }
        return Matrix(der)
    }
    
    func resultParam(xMatrix:Matrix, yreg_y2: [Double], b: [Double]) -> [Double] {
        let d = calculateD(xMatrix: xMatrix)
        
        let v = (yreg_y2.count - d.rows - 1)
        var s2 = 0.0
        yreg_y2.forEach {
            s2 += $0
        }
        s2 /= Double(v)
        
        var t = [Double]()
        for i in 0 ..< b.count {
            t.append(abs(b[i]) / sqrt(d.grid[i] * s2))
        }
        
        return t
    }
}
