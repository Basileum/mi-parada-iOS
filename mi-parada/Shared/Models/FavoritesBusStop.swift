//
//  FavoritesBusStop.swift
//  mi-parada
//
//  Created by Basile on 19/07/2025.
//


struct FavoritesBusStop : Identifiable, Codable, Hashable{
    let stop: BusStop
    let busLines: Set<BusLine>
    
    var id: Int {
        stop.id
    }
}
