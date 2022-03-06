////
////  ShowAnimalImage.swift
////  FurryFriends
////
////  Created by Lillian Yang on 2022-03-05.
////
//
//import SwiftUI
//
//struct ShowAnimalImage: View {
//
//    @Binding var currentDogAddedToFavourites: Bool
//    let systemName: String
//    let favourites: [Dog] = []
//    let currentFavourite: Dog = Dog(message: "https://www.russellgordon.ca/lcs/miscellaneous/transparent-pixel.png", status: "")
//
//    var body: some View {
//
//        Image(systemName: "heart.circle")
//            .resizable()
//            .foregroundColor(currentDogAddedToFavourites == true ? .red : .secondary)
//            .frame(width: 40, height: 40)
//            .onTapGesture {
//
//                if currentDogAddedToFavourites == false {
//                    favourites.append(currentFavourite)
//
//                    currentDogAddedToFavourites = true
//                }
//
//            }
//
//            }
//    }
//
//    struct ShowAnimalImage_Previews: PreviewProvider {
//        static var previews: some View {
//            ShowAnimalImage(currentDogAddedToFavourites: .constant(false), systemName: "heart.circle")
//        }
//    }
