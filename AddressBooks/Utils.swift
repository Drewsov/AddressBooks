//
//  Utils.swift
//  Imenno.ru
//
//  Created by Drew on 24/11/14.
//  Copyright (c) 2014 Andrey Toropov. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit


extension UIFont {
    func bold() -> UIFont {
        let descriptor = self.fontDescriptor().fontDescriptorWithSymbolicTraits(UIFontDescriptorSymbolicTraits.TraitBold)
        return UIFont(descriptor: descriptor!, size: 0)
    }
}

extension String {
    func exec (str: String) -> Array<String> {
        var err : NSError?
        let regex = NSRegularExpression(pattern: self, options: NSRegularExpressionOptions(0), error: &err)
        if (err != nil) {
            return Array<String>()
        }
        let nsstr = str as NSString
        let all = NSRange(location: 0, length: nsstr.length)
        var matches : Array<String> = Array<String>()
        regex?.enumerateMatchesInString(str, options: NSMatchingOptions(0), range: all) {
            (result : NSTextCheckingResult!, _, _) in
            matches.append(nsstr.substringWithRange(result.range))
        }
        return matches
    }
    
    // Works in Xcode but not Playgrounds because of a bug with .insert()
    // https://gist.github.com/sketchytech/bb63b23b78c0ea58c363
    
    mutating func insertString(string:String,ind:Int) {
        var insertIndex = advance(self.startIndex, ind, self.endIndex)
        for c in string {
            self.insert(c, atIndex: insertIndex)
            insertIndex = advance(insertIndex, 1)
        }
    }
    
    // new replace method using replaceRange (replaces all instances of string)
    mutating func replace(string:String, replacement:String) {
        
        
        let ranges = self.rangesOfString(string)
        // if the string isn't found return unchanged string
        
        
        for r in ranges {
            self.replaceRange(r, with: replacement)
        }
    }
    
    // Swift pure containsString
    
    func containsString(findStr:String) -> Bool {
        var arr = [Range<String.Index>]()
        var startInd = self.startIndex
        var i = 0
        // test first of all whether the string is likely to appear at all
        if contains(self, first(findStr)!) {
            startInd = find(self,first(findStr)!)!
        }
        else {
            return false
        }
        // set starting point for search based on the finding of the first character
        i = distance(self.startIndex, startInd)
        while i<=count(self)-count(findStr) {
            if self[advance(self.startIndex, i)..<advance(self.startIndex, i+count(findStr))] == findStr {
                arr.append(Range(start:advance(self.startIndex, i),end:advance(self.startIndex, i+count(findStr))))
                return true
            }
            i++
        }
        return false
    }
    
    
    // pure Swift - removeAtIndex no longer required, since the addition of following methods to String type
    // mutating func removeAtIndex(i: String.Index) -> Character
    // mutating func removeRange(subRange: Range<String.Index>)
    // mutating func removeAll(keepCapacity: Bool = default)
    
    
    // insert() method written in pure Swift, overloads the new String type method of the same name
    
    func insert(string:String,ind:Int) -> String {
        
        var insertIndex = advance(self.startIndex, ind, self.endIndex)
        var returnString = toString(self)
        for c in string {
            returnString.insert(c, atIndex: insertIndex)
            insertIndex = advance(insertIndex, 1)
        }
        return returnString
    }
    
    // rangesOfString: written in pure Swift (no Cocoa)
    func rangesOfString(findStr:String) -> [Range<String.Index>] {
        var arr = [Range<String.Index>]()
        var startInd = self.startIndex
        // check first that the first character of search string exists
        if contains(self, first(findStr)!) {
            // if so set this as the place to start searching
            startInd = find(self,first(findStr)!)!
        }
        else {
            // if not return empty array
            return arr
        }
        var i = distance(self.startIndex, startInd)
        while i<=count(self)-count(findStr) {
            if self[advance(self.startIndex, i)..<advance(self.startIndex, i+count(findStr))] == findStr {
                arr.append(Range(start:advance(self.startIndex, i),end:advance(self.startIndex, i+count(findStr))))
                i = i+count(findStr)-1
                // check again for first occurrence of character (this reduces number of times loop will run
                if contains(self[advance(self.startIndex, i)..<self.endIndex], first(findStr)!) {
                    // if so set this as the place to start searching
                    i = distance(self.startIndex,find(self[advance(self.startIndex, i)..<self.endIndex],first(findStr)!)!) + i
                    count(findStr)
                }
                else {
                    return arr
                }
                
            }
            i++
        }
        return arr
    }
    
    
    func stringByReplacingOccurrencesOfString(string:String, replacement:String) -> String {
        
        // get ranges first using rangesOfString: method, then glue together the string using ranges of existing string and old string
        
        let ranges = self.rangesOfString(string)
        // if the string isn't found return unchanged string
        if ranges.isEmpty {
            return self
        }
        // using toString to make a copy so that self isn't altered
        var newString = toString(self)
        for r in ranges {
            newString.replaceRange(r, with: replacement)
        }
        return newString
    }
    
    // Added String splitting methods that return arrays (Pure Swift)
    func splitStringByCharacters() -> [Character] {
        return map(self){return $0}
    }
    
    
    
    func splitStringByLines() -> [String] {
        return split(self, maxSplit: 0, allowEmptySlices: false, isSeparator: {contains("\u{2028}\n\r", $0)})
            //split(self, {contains("\u{2028}\n\r", $0)}, allowEmptySlices: false)
    }
    
    func splitStringByWords() -> [String] {
        return split(self, maxSplit: 0, allowEmptySlices: false, isSeparator: {contains(" .,!:;()[]{}<>?\"'\u{2028}\u{2029}\n\r", $0)})
            // split(self, {contains(" .,!:;()[]{}<>?\"'\u{2028}\u{2029}\n\r", $0)}, allowEmptySlices: false)
    }
    
    func splitStringByParagraphs() -> [String] {
        return split(self, maxSplit: 0, allowEmptySlices: false, isSeparator: {contains("\u{2029}\n\r", $0)})
          //  split(self, {contains("\u{2029}\n\r", $0)}, allowEmptySlices: false)
    }
 
    func splitsStringByParagraphs() -> [String] {
        var arr = [String]()
        self.enumerateSubstringsInRange(Range(start: self.startIndex, end: self.endIndex), options: NSStringEnumerationOptions.ByParagraphs, { (substring, substringRange, enclosingRange, bool) -> () in arr.append(substring)})
        return arr
    }
    
    func splitsStringByCharacters() -> [String] {
        var arr = [String]()
        self.enumerateSubstringsInRange(Range(start: self.startIndex, end: self.endIndex), options: NSStringEnumerationOptions.ByComposedCharacterSequences, { (substring, substringRange, enclosingRange, bool) -> () in arr.append(substring)})
        return arr
    }
    
    func splitsStringBySentences() -> [String] {
        var arr = [String]()
        self.enumerateSubstringsInRange(Range(start: self.startIndex, end: self.endIndex), options: NSStringEnumerationOptions.BySentences, { (substring, substringRange, enclosingRange, bool) -> () in arr.append(substring)})
        return arr
    }
    
    func splitsStringByLines() -> [String] {
        var arr = [String]()
        self.enumerateSubstringsInRange(Range(start: self.startIndex, end: self.endIndex), options: NSStringEnumerationOptions.ByLines, { (substring, substringRange, enclosingRange, bool) -> () in arr.append(substring)})
        return arr
    }

    
    func splitStringBySentences() -> [String] {
        let arr:[Character] = ["\u{2026}",".","?", "!"]
        var startInd = self.startIndex
        var strArr = [String]()
        for b in enumerate(self) {
            for a in arr {
                if a == b.element {
                    
                    var endInd = advance(self.startIndex,b.index,self.endIndex)
                    
                    //TODO: add method to allow for multiple punctuation at end of sentence, e.g. ??? or !!!
                    
                    var str = self[startInd...endInd]
                    
                    // removes initial spaces and returns from sentence
                    if contains(" \u{2028}\u{2029}\n\r",first(str)!)  {
                        str = dropFirst(str)
                    }
                    strArr.append(str)
                    startInd = advance(endInd,1,self.endIndex)
                    
                }
                
            }
            
        }
        return strArr
        
    }
    
    // added regexMatchesInString to remove reliance on NSRegularExpression
    func regexMatchesInString(regexString:String) -> [String] {
        var arr = [String]()
        var rang = Range(start: self.startIndex, end: self.endIndex)
        var foundRange:Range<String.Index>?
        
        do
        {
            foundRange = self.rangeOfString(regexString, options: NSStringCompareOptions.RegularExpressionSearch, range: rang, locale: nil)
            
            if let a = foundRange {
                arr.append(self.substringWithRange(a))
                rang.startIndex = a.endIndex
            }
        }
            while foundRange != nil
        return arr
    }
    var length: Int {
        get {
            return count(self)
        }
    }
    
    
    
    
    
    subscript (i: Int) -> Character
        {
        get {
            let index = advance(startIndex, i)
            return self[index]
        }
    }
    
    subscript (r: Range<Int>) -> String
        {
        get {
            let startIndex = advance(self.startIndex, r.startIndex)
            let endIndex = advance(self.startIndex, r.endIndex - 1)
            
            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func subString(startIndex: Int, length: Int) -> String
    {
        var start = advance(self.startIndex, startIndex)
        var end = advance(self.startIndex, startIndex + length)
        return self.substringWithRange(Range<String.Index>(start: start, end: end))
    }
    
    func indexOf(target: String) -> Int
    {
        var range = self.rangeOfString(target)
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func indexOf(target: String, startIndex: Int) -> Int
    {
        var startRange = advance(self.startIndex, startIndex)
        
        var range = self.rangeOfString(target, options: NSStringCompareOptions.LiteralSearch, range: Range<String.Index>(start: startRange, end: self.endIndex))
        
        if let range = range {
            return distance(self.startIndex, range.startIndex)
        } else {
            return -1
        }
    }
    
    func lastIndexOf(target: String) -> Int
    {
        var index = -1
        var stepIndex = self.indexOf(target)
        while stepIndex > -1
        {
            index = stepIndex
            if stepIndex + target.length < self.length {
                stepIndex = indexOf(target, startIndex: stepIndex + target.length)
            } else {
                stepIndex = -1
            }
        }
        return index
    }
    
    // Updated isMatch to remove reliance on NSRegularExpression
    func isMatch(regex: String, options: NSStringCompareOptions?) -> Bool
    {
        
        let match = self.rangeOfString(regex, options: options ?? nil, range: Range(start: self.startIndex, end: self.endIndex), locale: nil)
        return match != nil ? true : false
    }
    
    // getMatches updated to remove reliance on NSRegularExpression
    func getMatches(regex: String, options: NSStringCompareOptions?) -> [Range<String.Index>] {
        var arr = [Range<String.Index>]()
        var rang = Range(start: self.startIndex, end: self.endIndex)
        var foundRange:Range<String.Index>?
        
        do
        {
            foundRange = self.rangeOfString(regex, options: options ?? nil, range: rang, locale: nil)
            
            if let a = foundRange {
                arr.append(a)
                rang.startIndex = foundRange!.endIndex
            }
        }
            while foundRange != nil
        return arr
    }
    
    private var vowels: [String]
        {
            
            return ["a", "e", "i", "o", "u"]
            
    }
    
    private var consonants: [String]
        {
            
            return ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"]
            
    }
    
    func pluralize(count: Int) -> String
    {
        if count == 1 {
            return self
        } else {
            var lastChar = self.subString(self.length - 1, length: 1)
            var secondToLastChar = self.subString(self.length - 2, length: 1)
            var prefix = "", suffix = ""
            
            if lastChar.lowercaseString == "y" && vowels.filter({x in x == secondToLastChar}).count == 0 {
                prefix = self[0...self.length - 1]
                suffix = "ies"
            } else if lastChar.lowercaseString == "s" || (lastChar.lowercaseString == "o" && consonants.filter({x in x == secondToLastChar}).count > 0) {
                prefix = self[0...self.length]
                suffix = "es"
            } else {
                prefix = self[0...self.length]
                suffix = "s"
            }
            
            return prefix + (lastChar != lastChar.uppercaseString ? suffix : suffix.uppercaseString)
        }
    }
    
    // for fun, not sure whether this has a practical application

}

    
    func uniq<S : SequenceType, T : Hashable where S.Generator.Element == T>(source: S) -> [T] {
        var buffer = [T]()
        var added = Set<T>()
        for elem in source {
            if !added.contains(elem) {
                buffer.append(elem)
                added.insert(elem)
            }
        }
        return buffer
    }


class Regex {
    let internalExpression: NSRegularExpression
    let pattern: String
    
    init(_ pattern: String) {
        self.pattern = pattern
        var error: NSError?
        self.internalExpression = NSRegularExpression(pattern: pattern, options: .CaseInsensitive, error: &error)!
    }
    
    func test(input: String) -> Bool {
        let matches = self.internalExpression.matchesInString(input, options: nil, range:NSMakeRange(0, count(input)))
        return matches.count > 0
    }
    func substring(input: String) -> String {
        let outString  = self.internalExpression.stringByReplacingMatchesInString(input, options: nil, range: NSMakeRange(0, count(input)), withTemplate: "")
        return outString
    }
}

class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)).takeRetainedValue()
        }
        
        var flags: SCNetworkReachabilityFlags = 0
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == 0 {
            return false
        }
        
        let isReachable = (flags & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection) ? true : false
    }
    
}
extension NSShadow {
    class func titleTextShadow() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(hue: 0, saturation: 0, brightness: 0, alpha: 0.3)
        shadow.shadowOffset = CGSize(width: 0, height: 2)
        shadow.shadowBlurRadius = 3.0
        return shadow
    }
    
    class func descriptionTextShadow() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0.0, alpha: 0.3)
        shadow.shadowOffset = CGSize(width: 0, height: 1)
        shadow.shadowBlurRadius = 3.0
        return shadow
    }
    class func  TextShadow() -> NSShadow {
        let shadow = NSShadow()
        shadow.shadowColor = UIColor(white: 0.0, alpha: 0.0)
        shadow.shadowOffset = CGSize(width: 0, height: 0)
        shadow.shadowBlurRadius = 0.0
        return shadow
    }
}
extension NSParagraphStyle {
    class func justifiedParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Justified
        return paragraphStyle.copy() as! NSParagraphStyle
    }
    class func  NaturalParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Natural
        return paragraphStyle.copy() as! NSParagraphStyle
    }
    class func  LeftParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Left
        return paragraphStyle.copy() as! NSParagraphStyle
    }
    class func  RightParagraphStyle() -> NSParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Right
        return paragraphStyle.copy() as! NSParagraphStyle
    }
}


let textFont       = UIFont(name: "Lato-Black",   size: 15.0)!
let LatoBlack14    = UIFont(name: "Lato-Black",   size: 14.0)!
let LabelFont      = UIFont(name: "Lato-Regular", size: 15)!
let textLabelFont  = UIFont(name: "Lato-Regular", size: 14.0)!
let likesLabelFont = UIFont(name: "Lato-Regular", size: 12.0)!
let dateLabelFont  = UIFont(name: "Lato-Thin", size: 10.0)!

let wcolor:UIColor     = UIColor(red: (210.0/255.0), green:(210.0/255.0), blue: (210.0/255.0), alpha: 1.0)
let LabelColor:UIColor = UIColor(red: (100.0/255.0), green:(100.0/255.0), blue: (100.0/255.0), alpha: 1.0)
let color:UIColor      = UIColor(red: (235.0/255.0), green:(235.0/255.0), blue: (241.0/255.0), alpha: 1)
let defaultBlueColor:UIColor      = UIColor(red: (0.0/255.0), green:(122.0/255.0), blue: (255.0/255.0), alpha: 1)
let defaultGreenColor:UIColor      = UIColor(red: (41.0/255.0), green:(1195.0/255.0), blue: (50.0/255.0), alpha: 1)
let defaultGrayColor:UIColor      = UIColor(red: (189.0/255.0), green:(189.0/255.0), blue: (195.0/255.0), alpha: 1)
let defaultDarkGrayColor:UIColor      = UIColor(red: (191.0/255.0), green:(191.0/255.0), blue: (191.0/255.0), alpha: 1)





let placeHolderText = "Написать пост    ..."

let LatoRegular  = "Lato-Regular"
let LatoSemiBold = "Lato-Semibold"

let imennoBlack:UIColor = UIColor.blackColor()
let oaklandPostBlue:UIColor = UIColor(red: 115.0/255.0, green: 148.0/255.0, blue: 175.0/255.0, alpha: 1.0)
let feedParserDidFailErrorCode = 0
let networkDidFailErrorCode = 1


public func centeredParagraphStyle() -> NSMutableParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.alignment = .Center

    return style
}

public func leftParagraphStyle() -> NSMutableParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.alignment = .Left
    return style
}
private func lineSpacingParagraphStyle() -> NSMutableParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.lineSpacing = 0.25
    return style
}

private let titleheading    =    [
    NSFontAttributeName:   UIFont.systemFontOfSize(14, weight: 1),
    NSShadowAttributeName: NSShadow.descriptionTextShadow(),
    NSForegroundColorAttributeName: imennoBlack,
    NSBackgroundColorAttributeName: UIColor.clearColor(),
    NSParagraphStyleAttributeName: NSParagraphStyle.justifiedParagraphStyle()]

private let heading    = [NSFontAttributeName: UIFont(name: "Lato-Semibold", size: CGFloat(20.0))!,NSForegroundColorAttributeName: oaklandPostBlue,NSParagraphStyleAttributeName: centeredParagraphStyle()]
private let subheading = [NSFontAttributeName: UIFont(name: "Lato-Semibold", size: CGFloat(18.0))!,NSForegroundColorAttributeName: oaklandPostBlue]

private let text:[NSObject: AnyObject] = [
    NSFontAttributeName: UIFont(name: LatoRegular, size: CGFloat(16.0))!,
    NSParagraphStyleAttributeName: lineSpacingParagraphStyle()
]

// MARK: Helpers

// An ordered array of (style, text) tuples.
typealias Component = (attributes: [NSObject: AnyObject], string: NSString)

private let extraSpace: Component = (text, "")

private func contentFromComponents(components: [Component]) -> NSAttributedString {
    var attributedString = NSMutableAttributedString()
    
    for component in components {
        let substring = NSMutableAttributedString(string: "\(component.string)\n\n", attributes: component.attributes)
        attributedString.appendAttributedString(substring)
    }
    
    return attributedString
}


extension String {
    var capitalizeIt:String {
        var result = Array(self)
        if !isEmpty { result[0] = Character(String(result.first!).uppercaseString) }
        return String(result)
    }
    var capitalizeFirst:String {
        var result = self
        result.replaceRange(startIndex...startIndex, with: String(self[startIndex]).capitalizedString)
        return result
    }
    
}

class Utils {

    func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        var textColor: UIColor = UIColor.whiteSmokeColor(alpha: 1.0)    // UIColor.redDevilColor(alpha: 1.0)
        var textFont:  UIFont  = UIFont.systemFontOfSize(14, weight: 0) // UIFont(name: "Helvetica Bold", size: 12)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
            NSParagraphStyleAttributeName: centeredParagraphStyle(),
        ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        var rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        rect.origin.y = rect.origin.y + ((rect.size.height - textFont.pointSize) / 2.5);
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        var newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
        
    }
    
    func mask(maskView:UIView) -> UIView {
        maskView.backgroundColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:0.5)
        return maskView
    }
    
    func mask(frame:CGRect) -> UIView {
        var maskView = UIView(frame:frame)
        maskView.backgroundColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:0.2)
        return maskView
    }
    
    func heightForView(cellLabel:UILabel) -> CGFloat{
        let label:UILabel = cellLabel
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.sizeToFit()
        return label.frame.size.height*1;
    }
    
    func check( inString:String, matches:String ) ->AnyObject{
        let outString:AnyObject   =  matches.exec(inString)
        return outString
    }
    ////////////////////////////////////
    func onePixelImageWithColor(color : UIColor) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        var context = CGBitmapContextCreate(nil, 1, 1, 8, 0, colorSpace, bitmapInfo)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, 1, 1))
        let image = UIImage(CGImage: CGBitmapContextCreateImage(context))
        return image!
    }
    
    
    func morePixelImageWithColor(color : UIColor,frame: CGRect) -> UIImage {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(CGImageAlphaInfo.PremultipliedLast.rawValue)
        var context = CGBitmapContextCreate(nil,Int(CGRectGetWidth(frame)), Int(CGRectGetHeight(frame)), 8, 0, colorSpace, bitmapInfo)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, frame)
        let image = UIImage(CGImage: CGBitmapContextCreateImage(context))
        return image!
    }
    
    func imageWithColor(image:UIImage,color:UIColor)-> UIImage
    {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale);
        let context:CGContextRef = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, image.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal);
        let rect:CGRect = CGRectMake(0, 0, image.size.width, image.size.height);
        CGContextClipToMask(context, rect, image.CGImage);
        color.setFill();
        CGContextFillRect(context, rect);
        let newImage:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    
    
    func parseURLParams(query : NSString?) -> NSDictionary {
        var params : NSMutableDictionary = NSMutableDictionary()
        if query != nil{
            var pairs : NSArray = query!.componentsSeparatedByString("&")            
            var kv : NSArray = NSArray()
            for pair in pairs{
                kv = pair.componentsSeparatedByString("=")
                var val : NSString =    kv[1].stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                params = ["\(kv[0])" : "\(val)"]
                return params
            }
        }
        params = ["post_id" : "nil"]
        return params
    }
    
    //////////////////////////
    
    func darkerColorForColor(color: UIColor) -> UIColor {
        
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        
        if color.getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: max(r - 0.2, 0.0), green: max(g - 0.2, 0.0), blue: max(b - 0.2, 0.0), alpha: a)
        }
        
        return UIColor()
    }
    
    func lighterColorForColor(color: UIColor) -> UIColor {
        
        var r:CGFloat = 0, g:CGFloat = 0, b:CGFloat = 0, a:CGFloat = 0
        
        if color.getRed(&r, green: &g, blue: &b, alpha: &a){
            return UIColor(red: min(r + 0.2, 1.0), green: min(g + 0.2, 1.0), blue: min(b + 0.2, 1.0), alpha: a)
        }
        
        return UIColor()
    }
    
    //////////////////////////
    
    
    func shakeView (viewToShake:UIView) {
        let  t:CGFloat = 2.0;
        let  translateRight:CGAffineTransform  = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0, t);
        let  translateLeft:CGAffineTransform   = CGAffineTransformTranslate(CGAffineTransformIdentity, 0.0,-t);
        viewToShake.transform = translateLeft;
        UIView.animateWithDuration(0.07, animations: {
            UIView.setAnimationRepeatCount(2.0)
            viewToShake.transform = translateRight;
            }, completion: {
                (value: Bool) in
                UIView.animateWithDuration(0.05, animations: {
                    UIView.setAnimationRepeatCount(2.0)
                    viewToShake.transform = CGAffineTransformIdentity;
                    }, completion: {
                        (value: Bool) in
                })
                
                
        })
    }
    
    func shakeViewSide (viewToShake:UIView) {
        let  t:CGFloat = 2.0;
        let  translateRight:CGAffineTransform  = CGAffineTransformTranslate(CGAffineTransformIdentity, t, 0.0);
        let  translateLeft:CGAffineTransform   = CGAffineTransformTranslate(CGAffineTransformIdentity, -t, 0.0);
        viewToShake.transform = translateLeft;
        UIView.animateWithDuration(0.07, animations: {
            UIView.setAnimationRepeatCount(2.0)
            viewToShake.transform = translateRight;
            }, completion: {
                (value: Bool) in
                UIView.animateWithDuration(0.05, animations: {
                    UIView.setAnimationRepeatCount(2.0)
                    viewToShake.transform = CGAffineTransformIdentity;
                    }, completion: {
                        (value: Bool) in
                })
                
                
        })
    }
    
    
    func getLabelImage(imageNamed:String,x:CGFloat,y:CGFloat,selector:Selector,target: AnyObject = ":") -> UIView!
    {
        let image     = UIImage(named: imageNamed)
        let imageview = UIImageView(image:image) //  Utils().imageWithColor(image!, color: UIColor.blueColor()))
        let labelView = UIView(frame:CGRectMake(0,0,imageview.frame.size.width,imageview.frame.size.height))
        labelView.center = CGPoint(x: x,y: y)
      
        if selector != nil   {
            let tapGesture = UITapGestureRecognizer(target: target, action: selector)
            tapGesture.numberOfTapsRequired = 1
            labelView.addGestureRecognizer(tapGesture)
            let pan = UIPanGestureRecognizer(target: target, action: selector)
            labelView.addGestureRecognizer(pan)}
        
        labelView.addSubview(imageview)
        return labelView
    }

    func getLabel(LabelText:String,LabelFont:UIFont,LabelColor:UIColor,frame:CGRect,selector:Selector,target: AnyObject = ":") -> UIView!
    {
        let labelView = UIView(frame:frame)
        let label = UILabel(frame:frame)
        label.font =  LabelFont
        label.textColor = LabelColor
        label.text = LabelText
        if selector != nil   {
            let tapGesture = UITapGestureRecognizer(target: target, action: selector)
            tapGesture.numberOfTapsRequired = 1
            labelView.addGestureRecognizer(tapGesture)
            let pan = UIPanGestureRecognizer(target: target, action: selector)
            labelView.addGestureRecognizer(pan)}
        if LabelText != "" {
            labelView.addSubview(label)}
        return labelView
    }
    
    func getView(backgroundColor:UIColor,frame:CGRect,selector:Selector,target: AnyObject = ":") -> UIView!
    {
        var labelView = UIView(frame:frame)
        labelView.backgroundColor = backgroundColor
        if selector != nil   {
            let tapGesture = UITapGestureRecognizer(target: target, action: selector)
            tapGesture.numberOfTapsRequired = 1
            labelView.addGestureRecognizer(tapGesture)
            let pan = UIPanGestureRecognizer(target: target, action: selector)
            labelView.addGestureRecognizer(pan)}
        return labelView
    }
    
    func getView(label:UILabel,frame:CGRect,selector:Selector) -> UIView!
    {
        let labelView = UIView(frame:frame)
        if selector != nil   {
            let tapGesture = UITapGestureRecognizer(target: self, action: selector)
            tapGesture.numberOfTapsRequired = 1
            labelView.addGestureRecognizer(tapGesture) }
        labelView.addSubview(label)
        return labelView
    }
    
    func getButton(button:UIButton,frame:CGRect,selector:Selector) ->UIView! {
        let buttonView = UIView(frame:frame)
            button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        buttonView.addSubview(button)
        return buttonView
    }
    
    func getLabelImageWithColor(imageNamed:String,x:CGFloat,y:CGFloat,selector:Selector,color:UIColor,target: AnyObject = ":") -> UIView!
    {
        var tapSelector : Selector = selector
        let tapGesture = UITapGestureRecognizer(target: target, action: tapSelector)
        tapGesture.numberOfTapsRequired = 1
        let image     = UIImage(named: imageNamed)
        let imageview = UIImageView(image:  Utils().imageWithColor(image!, color: color))
        let labelView = UIView(frame:CGRectMake(0,0,imageview.frame.size.width,imageview.frame.size.height))
        labelView.center = CGPoint(x: x,y: y)
        labelView.addGestureRecognizer(tapGesture)
        labelView.addSubview(imageview)
        return labelView
    }
    
    func getButtonView(title:String,image:UIImage,frame:CGRect,selector:Selector) -> UIView! {
         var buttonView:UIView = UIView(frame:frame)
         var Button:UIButton   =  UIButton.buttonWithType(UIButtonType.System) as! UIButton
             Button.frame = frame
        Button.addTarget(self, action: selector, forControlEvents: .TouchUpInside  )

             Button.setImage(image, forState: UIControlState.Normal)
             Button.setTitle(title, forState: UIControlState.Normal)
             Button.autoresizesSubviews = true
        Button.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleLeftMargin
        Button.addTarget(self, action: selector, forControlEvents: .TouchUpInside  )
        buttonView.addSubview(Button)
    return buttonView
  }
    
    func getButtonToolbar(btitle:String,bimage:UIImage,select:Selector) -> UIBarButtonItem {
        var buttonView:UIView = UIView(frame:CGRectMake(0,0,50,20))
        var Button:UIButton   = UIButton.buttonWithType(UIButtonType.System) as! UIButton
        Button.frame = CGRectMake(0,0,50,20)
        Button.setImage(bimage, forState: UIControlState.Normal)
        Button.setTitle(btitle, forState: UIControlState.Normal)
        Button.setTitleColor(defaultBlueColor, forState: UIControlState.Normal)
        Button.titleLabel?.font   = UIFont.systemFontOfSize(7)
        Button.titleLabel?.lineBreakMode  = NSLineBreakMode.ByWordWrapping
        Button.titleLabel?.textAlignment  = NSTextAlignment.Center
        Button.autoresizesSubviews = true
        Button.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleTopMargin  // | UIViewAutoresizing.FlexibleLeftMargin
       // BaseUrls().AlignTextAndImageOfButton(Button, space: 2.0)
        Button.addTarget(self, action: select, forControlEvents: .TouchUpInside  )
        buttonView.addSubview(Button)
        let barButtonItem = UIBarButtonItem(customView: buttonView)
        return barButtonItem
    }
    
    func badge(label:UILabel, count:String) -> UILabel {
         let imageView   = UIImageView(frame: CGRectMake(0, 0, 20, 20))
         imageView.image = self.imageWithColor(UIImage(named: "circle")!, color: UIColor.candyAppleRedColor(alpha: 0.8))
         label.addSubview(imageView)
        label.text = count
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(10, weight: 1)
        //label.backgroundColor = UIColor.candyAppleRedColor(alpha: 0.8)
        label.textColor = UIColor.whiteSmokeColor(alpha: 1.0)
        label.layer.borderColor = UIColor.blackBeanColor(alpha: 0.5).CGColor
        label.layer.borderWidth = 0.0
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }
    
    func badge(label:UILabel, count:NSNumber) -> UILabel {
        label.text = "\(count)"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(11, weight: 0)
        label.backgroundColor = UIColor.candyAppleRedColor(alpha: 0.8)
        label.textColor = UIColor.whiteSmokeColor(alpha: 1.0)
        label.layer.borderColor = UIColor.blackBeanColor(alpha: 0.5).CGColor
        label.layer.borderWidth = 0.0
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }
    
    func sbadge(label:UILabel, text:String, font:UIFont, backgroundColor:UIColor = UIColor.grayCrayolaColor(alpha: 0.8), textColor: UIColor = UIColor.whiteSmokeColor(alpha: 1.0)) -> UILabel {
        label.text = text
        label.textAlignment = NSTextAlignment.Center
        label.font = font // UIFont.systemFontOfSize(10, weight: 1)
        label.backgroundColor = backgroundColor
        label.textColor = textColor
        label.layer.borderColor = UIColor.blackBeanColor(alpha: 0.5).CGColor
        label.layer.borderWidth = 0.0
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }
    
    
    func badge(count:NSNumber) ->UILabel {
        var label:UILabel = UILabel(frame: CGRectMake(30,-10, 20, 20))
        label.removeFromSuperview()
        //if count > 0 {
            label = Utils().badge(label, count: count)
          //  prnln("<--\(count)-->")
       // }
        return label;
    }
    
    func badge(count:String) ->UILabel {
        var label:UILabel = UILabel(frame: CGRectMake(30,-10, 20, 20))
        label.removeFromSuperview()
        //if count > 0 {
        label = Utils().badge(label, count: count)
        //  prnln("<--\(count)-->")
        // }
        return label;
    }
}

@objc
protocol ResizeDelegate {
    optional func ResizeImageTo(image: UIImage, size: CGSize) -> UIImage
}

class Resize {
    //////////////////////////
    
    func RBSquareImage(image: UIImage) -> UIImage {
        var originalWidth :CGFloat = image.size.width
        var originalHeight:CGFloat = image.size.height
        
        var edge: CGFloat = 0
     
        if originalWidth > originalHeight {
            edge = originalHeight
        } else {
            edge = originalWidth
        }
        var posX = (originalWidth  - edge) / 2.0
        var posY = (originalHeight - edge) / 2.0
        var cropSquare = CGRectMake(posX, posY, edge, edge)
        var imageRef = CGImageCreateWithImageInRect(image.CGImage, cropSquare);
    
        let retImage:UIImage = UIImage(CGImage: imageRef, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)!
   
        return retImage;
    }
    
    func RBResizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func ResizeImageTo(image: UIImage, size: CGSize) -> UIImage {
        return Resize().RBResizeImage(Resize().RBSquareImage(image), targetSize: size)
    }
    //////////////////////////
    func imageResize(imageView:UIImageView,image:UIImage, size:CGSize)-> UIImage{
        return self.imageResize(imageView,image:image, targetSize: size)
    }
    
    func imageResize(imageView:UIImageView,image:UIImage, targetSize:CGSize)-> UIImage{
        
        let hasAlpha = false
        var scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        let size = image.size
         ////////////////////////////////////////////////
        let widthRatio  = imageView.bounds.size.width /  size.width
        let heightRatio = imageView.bounds.size.height / size.height
        scale = min(widthRatio, heightRatio);
        
        let imageWidth  = scale * size.width;
        let imageHeight = scale * size.height;
        let newSize: CGSize = CGSizeMake(imageWidth,  imageWidth)
      
        UIGraphicsBeginImageContextWithOptions(newSize, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: newSize))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage
    }
    
    
    
}

////////////////////
func initSize() {
    width   = UIScreen.mainScreen().applicationFrame.size.width
    height  = UIScreen.mainScreen().applicationFrame.size.height
    originY = UIScreen.mainScreen().applicationFrame.origin.y
    originX = UIScreen.mainScreen().applicationFrame.origin.x
    bounds  = UIScreen.mainScreen().bounds
  //  prnln (" \(width) x \(height) : originY:\(originY) originX:\(originX) :\(bounds.width) x \(bounds.height)" );
}
///////////////////////
var isLoaded:Bool = false
var width :CGFloat = 0;
var height:CGFloat = 0;
var originY   :CGFloat = 0;
var originX   :CGFloat = 0;
var bounds :CGRect = CGRectMake(0, 0, width, height)
///////////////////////
var BaseUrlDB:String = ""

func quicksort_swift(inout a:[CInt], start:Int, end:Int) {
    if (end - start < 2){
        return
    }
    var p = a[start + (end - start)/2]
    var l = start
    var r = end - 1
    while (l <= r){
        if (a[l] < p){
            l += 1
            continue
        }
        if (a[r] > p){
            r -= 1
            continue
        }
        var t = a[l]
        a[l] = a[r]
        a[r] = t
        l += 1
        r -= 1
    }
    quicksort_swift(&a, start, r + 1)
    quicksort_swift(&a, r + 1, end)
}


var Timestamp: String {
get {
    return "\(NSDate().timeIntervalSince1970 * 1000)"
}
}

