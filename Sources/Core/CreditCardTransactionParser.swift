import ArgumentParser

import Foundation

import SwiftCSV

public struct CreditCardTransactionParser: ParsableCommand {
  @Argument(help: "Location of file")
  var fileLocation: String

  public mutating func run() throws {
    guard let rawString = readFile(at: self.fileLocation) else {
      throw ExitCode.failure
    }

    var transactions = [TangTransaction]()
    for row in rawString.namedRows {
      transactions.append(TangTransaction(from: row))
    }
    var output = ""
    for tr in transactions {
      print(tr.description)
      output = output + tr.description + "\n"
    }
    #if !DEBUG
      write(transations: output, to: "transactions.csv")
    #endif
  }

  public init() {
  }

  func readFile(at: String) -> CSV? {
    do {
      let csvFile: CSV = try CSV(url: URL(fileURLWithPath: fileLocation))
      return csvFile
      // let rawString = try String(contentsOf: URL(fileURLWithPath: fileLocation))
      // return rawString
    }  // catch parseError as CSVParseError {
    //   print("error")
    //   return nil
    // }
    catch {
      print(error.localizedDescription)
      return nil
    }
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

}
