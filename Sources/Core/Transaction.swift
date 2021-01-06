import Foundation
import Money

private struct Transaction {
  var date: Date
  var merchant: Merchant
  var amount: Decimal

  var description: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    let formattedDate = dateFormatter.string(from: date)

    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2
    let formattedAmount = numberFormatter.string(from: amount as NSNumber) ?? "0.00"

    return "\(formattedDate),\(merchant.name),\(formattedAmount)"
  }

}

struct TangTransaction: BankTransaction {
  static var currency = CAD.self
  private let _transaction: Transaction
  private enum colNames: String {
    case date = "Transaction date"
    case merchantName = "Name"
    case amount = "Amount"
  }
  var date: Date {
    return _transaction.date
  }
  var merchant: String {
    return _transaction.merchant.name
  }

  var amount: Value {
    let value = Money<CAD>(_transaction.amount)
    return value
  }

  var description: String {
    _transaction.description
  }

  init(from dict: [String: String]) {
    let _date = parseDate(from: dict[colNames.date.rawValue]!) ?? Date()
    let _merchant = Merchant(from: dict[colNames.merchantName.rawValue]!)
    let _amount = parseAmount(from: dict[colNames.amount.rawValue]!) ?? 0.0
    _transaction = Transaction(date: _date, merchant: _merchant, amount: _amount)
  }
}

/// Parses the date information from the provided string.
/// - Parameter date:  A string that contains the date information
/// - Returns: A Date instance that contains the correct day, month and year. If there is an error parsing the string, nil is returned.
/// - Precondition: The date string is in the format `M-d-yyyy`.
private func parseDate(from date: String) -> Date? {

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
private func parseAmount(from string: String) -> Decimal? {
  guard !string.isEmpty else {
    return nil
  }
  let trimmed = string.trimmingCharacters(in: .whitespaces)
  return Decimal(Double(trimmed)!)
}

protocol BankTransaction {
  var date: Date { get }
  var merchant: String { get }
  var amount: Value { get }
  var description: String { get }

  init(from dict: [String: String])

}

protocol Value {
  var amount: Decimal { get }
  var currency: CurrencyType.Type { get }
}

extension Money: Value {}

