import UIKit

var myInt = 0

myInt
myInt.plusOne()

let i: Int = 8
i.squared()

extension Int {
    func plusOne() -> Int {
        return self + 1
    }
}

extension BinaryInteger {
    func squared() -> Self {
        return self * self
    }
}
