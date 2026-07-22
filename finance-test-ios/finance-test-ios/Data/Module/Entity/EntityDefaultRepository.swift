//
//  EntityDefaultRepository.swift
//  IosBaseProject
//
//  Created by Arifin Firdaus on 09/02/26.
//

import CountryKit

struct EntityDefaultRepository: EntityRepository {
	func getCountries() async -> [Entity.Response.Country] {
		CountryKit().countries.map { $0.toCountry() }
	}
}

extension CountryKit.Element {
	func toCountry() -> Entity.Response.Country {
		let dialCode: String = {
			if let phoneCode {
				return "+\(phoneCode)"
			}
			return ""
		}()

		return Entity.Response.Country(
			code: iso,
			name: name,
			dialCode: dialCode,
			flagSVG: nil,
			flagPNG: nil,
			flagImage: flagImage
		)
	}
}
