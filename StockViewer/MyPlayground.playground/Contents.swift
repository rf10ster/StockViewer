//: Playground - noun: a place where people can play

import UIKit

var str = "EURUSD"
let separatorIndex = str.index(str.startIndex, offsetBy:Int(str.characters.count/2))
str.substring(to: separatorIndex)
str.substring(from: separatorIndex)


