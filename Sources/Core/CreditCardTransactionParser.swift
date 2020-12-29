import ArgumentParser

import Foundation

public struct CreditCardTransactionParser: ParsableCommand {
  @Argument(help: "Location of file")
  var fileLocation: String

  public mutating func run() throws {
    guard let raw = readFile(at: self.fileLocation) else {
      throw ExitCode.failure
    }
    var trans = splitTransactionsFrom(string: raw)
    print(trans)
    trans.removeFirst(2)
    let transa = transactionsFrom(array: trans)
    for tr in transa {
      print(tr.description)

    }
  }

  public init() {
  }

  func readFile(at: String) -> String? {
    do {
      let rawString = try String(contentsOf: URL(fileURLWithPath: fileLocation))
      return rawString
    } catch {
      print(error.localizedDescription)
      return nil
    }

  }

  func splitTransactionsFrom(string: String) -> [String] {
    let transactions = string.components(separatedBy: .newlines).filter({ !$0.isEmpty })
    return transactions
  }

  func transactionsFrom(array: [String]) -> [Transaction] {
    var allTrans = [Transaction]()
    var output = ""
    for trans in array {
      let components = trans.components(separatedBy: ",")
      let date = parseDate(from: components.first!)
      let amount = parseAmount(from: components.last!)
      let merchant = parseMerchant(from: components[2])
      let tr = Transaction(date: date!, merchant: merchant, amount: amount!)
      print(tr.description)
      output = output + tr.description + "\n"
      allTrans.append(tr)
    }
    write(transations: output, to: "myLocation")
    return allTrans
  }

  /**
 Parses the date information from the provided string.
 - Parameter date:  A string that contains the date information
 - Returns: A Date instance that contains the correct day, month and year. If there is an error parsing the string, nil is returned.
 - Precondition: The date string is in the format `M-d-yyyy`.
 */
  public func parseDate(from date: String) -> Date? {

    guard !date.isEmpty else { return nil }

    let trimmedDate = date.trimmingCharacters(in: .whitespaces)

    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "M-d-yyyy"

    var returnDate = dateFormatter.date(from: trimmedDate)
    #if DEBUG
      returnDate = Date()
    #endif
    return returnDate

  }

  /// Parses the transaction amout from the provided string
  /// - Parameter string: A string representing the transaction amount.
  /// - Returns: A Double instance that contains the transaction amount. If there is a parsing error, nil is returned
  func parseAmount(from string: String) -> Double? {
    guard !string.isEmpty else {
      return nil
    }
    //		TODO: Add error handling in the event the string can not be parsed.
    let trimmed = string.trimmingCharacters(in: .whitespaces)
    return Double(trimmed)
  }

  func parseMerchant(from merchant: String) -> String {
    let trailingPatrn = #"([ #][ 0-9]+[\s\w]*|[-\d ]*|[\*\w]*) [\S]*$"#
    let trailingRegex = try! NSRegularExpression(
      pattern: trailingPatrn, options: .anchorsMatchLines)
    let stringRange = NSRange(location: 0, length: merchant.utf16.count)
    let substitutionString = #""#
    let trailingRemoved = trailingRegex.stringByReplacingMatches(
      in: merchant, range: stringRange, withTemplate: substitutionString)

    let dupLocPatrn = #"^([\w ]+) (BANFF|CANMORE|DEAD MANS)"#
    let dupLocRegex = try! NSRegularExpression(pattern: dupLocPatrn, options: .anchorsMatchLines)
    let dupLocRange = NSRange(location: 0, length: trailingRemoved.utf16.count)
    let dupLocSubstString = #"$1"#
    var final = dupLocRegex.stringByReplacingMatches(
      in: trailingRemoved, range: dupLocRange, withTemplate: dupLocSubstString)
    final = final.trimmingCharacters(in: .whitespaces)
    return MerchantDict.lookup(merchant: final)
  }

  func write(transations: String, to location: String) {
    let filename = getDocumentsDirectory().appendingPathComponent("transactions.csv")

    do {
      try transations.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
    } catch {
      // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
    }
  }

  func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
  }

  enum CCTPErrors: Error {
    case fileNotFound
    case fileNotRead
  }
}

extension NSRegularExpression {
  convenience init(_ pattern: String) {
    do {
      try self.init(pattern: pattern)
    } catch {
      preconditionFailure("Illegal regular expression: \(pattern).")
    }
  }
}

extension NSRegularExpression {
  func matches(_ string: String) -> Bool {
    let range = NSRange(location: 0, length: string.utf16.count)
    return firstMatch(in: string, options: [], range: range) != nil
  }
}
