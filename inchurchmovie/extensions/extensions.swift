//
//  extensions.swift
//  inchurchmovie
//
//  Created by João Flavio Cardoso de Freitas Souza on 24/06/25.
//

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var seen = Set<Element>()
        return reduce(into: []) { result, element in
            if seen.insert(element).inserted {
                result.append(element)
            }
        }
    }
}
