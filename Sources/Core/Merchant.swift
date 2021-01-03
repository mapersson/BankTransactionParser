//
//  MerchantDict.swift
//  BankTransactionParser
//
//  Created by Michael Persson on 2020-12-27.
//

import Foundation

public struct Merchant {
  private static let dict: [String: String] = [
    "WILD FLOURS ARTI": "WILD FLOWER",
    "402 LD CASCADE": "LIQUOR DEPOT",
    "WAL*MART CANADA INC": "WAL-MART",
    "PARKSCAN-BACK/ARRIERE-": "PARKS CANADA",
    "BOW VALLEY COLLEGE/APP": "BOW VALLEY COLLEGE",
    "SECOND CUP -": "SECOND CUP",
    "WWW.CANADIANTIRE.CA": "CDN TIRE",
    "BOW VALLEY COLLEGE (IT": "BOW VALLEY COLLEGE",
    "AMZN Mktp": "AMAZON",
    "Credit Card": "TANGERINE",
    "BANFF AVENUE LIQUOR ST": "BANFF AVENUE LIQUOR",
    "FUNKY LITTLE THRIFT ST": "FUNKY LITTLE THRIFT",
    "RUNDLE UNITED THRI": "RUNDLE UNITED THRIFT",
    "CROSSWAY COMMUNITY THR": "CROSSWAY COMMUNITY THRIFT",
    "VALLEY BUILDING MATERI": "HOME HARDWARE",
    "STANDISH HOME HARDWARE": "HOME HARDWARE",
    "SHELL EP C81334": "SHELL",
    "22161 MACS CONV. STORE": "CIRCLE K",
    "MOUNTAIN EQUIPMENT CO-": "MOUNTAIN EQUIPMENT CO-OP",
  ]

  private static func lookup(merchant: String) -> String {
    guard let merch = dict[merchant] else {
      return merchant
    }
    return merch
  }

  private static func clean(_ string: String) -> String {
    let trailingPatrn = #"(( #)[ 0-9]+[\s\w]*|[-\d ]*|[0-9]* [\*\w]*) [\S]*$"#
    let trailingRegex = try! NSRegularExpression(
      pattern: trailingPatrn, options: .anchorsMatchLines)
    var stringRange = NSRange(location: 0, length: string.utf8.count)
    let substitutionString = #""#
    let trailingRemoved = trailingRegex.stringByReplacingMatches(
      in: string, range: stringRange, withTemplate: substitutionString)

    let leadingPatrn = #"[\w ]*(?> \*)|(#\d*)"#
    let leadingRegex = try! NSRegularExpression(
      pattern: leadingPatrn, options: .anchorsMatchLines)
    stringRange = NSRange(location: 0, length: trailingRemoved.utf8.count)
    let leadingRemoved = leadingRegex.stringByReplacingMatches(
      in: trailingRemoved, range: stringRange, withTemplate: substitutionString)

    let dupLocPatrn = #"^([\w ]+) (- )?(BANFF|CANMORE|DEAD MAN'?S)"#
    let dupLocRegex = try! NSRegularExpression(pattern: dupLocPatrn, options: .anchorsMatchLines)
    let dupLocRange = NSRange(location: 0, length: leadingRemoved.utf8.count)
    let dupLocSubstString = #"$1"#
    let final = dupLocRegex.stringByReplacingMatches(
      in: leadingRemoved, range: dupLocRange, withTemplate: dupLocSubstString)
    return final.trimmingCharacters(in: .whitespaces)
  }

  let name: String

  public init(from string: String) {

    let cleanedName = Merchant.clean(string)
    name = Merchant.lookup(merchant: cleanedName)

  }

}
