//
//  FurryFriendsApp.swift
//  FurryFriends
//
//  Created by Russell Gordon on 2022-02-26.
//

import SwiftUI

@main
struct FurryFriendsApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                TabView{
                    DogView()
                        .tabItem {
                            Text("🐶")
                            Text("Dog")
                        }
                    
                    CatView()
                        .tabItem {
                            Text("🐱")
                            Text("Cat")
                        }
                
                    
                }
            }
        }
    }
}
