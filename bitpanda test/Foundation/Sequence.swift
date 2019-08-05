//
//  Sequence.swift
//  bitpanda test
//
//  Created by Milan Horvatovic on 05/08/2019.
//  Copyright © 2019 Milan Horvatovic. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element: Equatable {
	
	public var unique: [Element] {
		return self.reduce([], { (result, element) -> [Element] in
			return result.contains(element) ? result : result + [element]
		})
	}
	
}

extension Sequence {
	
	public func unique(_ filter: (Element, Element) -> Bool) -> [Element] {
		return self.reduce([], { (results, element) -> [Element] in
			return results.filter({ return filter(element, $0) }).count > 0 ? results : results + [element]
		})
	}
	
}
