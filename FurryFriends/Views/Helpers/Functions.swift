//
//  Functions.swift
//  FurryFriends
//
//  Created by Lillian Yang on 2022-03-01.
//

import Foundation

//Return the location of the documents directory for this app
func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    //Return the first path
    return paths[0]
}


//Define a filename (label) that we will write the data to in
//the directory
let savedFavouritesLabel = "saveFavourites"
