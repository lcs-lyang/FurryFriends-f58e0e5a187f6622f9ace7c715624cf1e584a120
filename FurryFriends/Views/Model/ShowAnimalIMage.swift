//
//  ShowAnimalImage.swift
//  FurryFriends
//
//  Created by Lillian Yang on 2022-03-05.
//

import SwiftUI

struct ShowAnimalImage: View {

    @Binding var currentAddedToFavourites: Bool

    var body: some View {

        Image(systemName: "heart.circle")
            .resizable()
            .foregroundColor(currentAddedToFavourites == true ? .red : .secondary)
            .frame(width: 40, height: 40)

            }
    }

    struct ShowAnimalImage_Previews: PreviewProvider {
        static var previews: some View {
            ShowAnimalImage(currentAddedToFavourites: .constant(false))
        }
    }
