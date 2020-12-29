//
//  MerchantDict.swift
//  BankTransactionParser
//
//  Created by Michael Persson on 2020-12-27.
//

import Foundation


public struct MerchantDict {
	private static let dict: Dictionary<String,String> = [
		"WILD FLOURS ARTI":"WILD FLOWER",
		"402 LD CASCADE":"LIQUOR DEPOT",
		"WAL*MART CANADA INC":"WAL-MART",
		"PARKSCAN-BACK/ARRIERE-":"PARKS CANADA",
		"BOW VALLEY COLLEGE/APP":"BOW VALLEY COLLEGE",
		"SECOND CUP -":"SECOND CUP",
		"WWW.CANADIANTIRE.CA":"CDN TIRE",
		"BOW VALLEY COLLEGE (IT":"BOW VALLEY COLLEGE",
		"AMZN Mktp":"AMAZON"
	]
	
	public static func lookup(merchant:String) -> String {
		guard let merch = dict[merchant] else {
			return merchant
		}
		return merch
	}
		
	
}
