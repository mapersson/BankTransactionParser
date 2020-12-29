import Foundation

struct Transaction {
  var date: Date
  var merchant: String
  var amount: Double

  var description: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .none
    let formattedDate = dateFormatter.string(from: date)

    let numberFormatter = NumberFormatter()
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2
    let formattedAmount = numberFormatter.string(from: NSNumber(value: amount)) ?? "0.00"

    return "\(formattedDate),\(merchant),\(formattedAmount)"
  }

}
