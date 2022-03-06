//
//  CatView.swift
//  FurryFriends
//
//  Created by Lillian Yang on 2022-03-06.
//


import SwiftUI

struct CatView: View {
    
    // MARK: Stored properties
    
    @Environment(\.scenePhase) var scenePhase
    
    @State var currentCatImage = URL(string: "https://www.russellgordon.ca/lcs/miscellaneous/transparent-pixel.png")!
    
    @State var currentFavouriteCat: Cat = Cat(id: "", url: "https://www.russellgordon.ca/lcs/miscellaneous/transparent-pixel.png")
    
    @State var favouriteCats: [Cat] = []
    
    @State var currentCatAddedToFavourites: Bool = false
    
    
    // MARK: Computed properties
    var body: some View {
        
        VStack {
            
            RemoteImageView(fromURL: currentCatImage)
            
            Image(systemName: "heart.circle")
                .resizable()
                .foregroundColor(currentCatAddedToFavourites == true ? .red : .secondary)
                .frame(width: 40, height: 40)
                .onTapGesture {
                    
                    if currentCatAddedToFavourites == false {
                        favouriteCats.append(currentFavouriteCat)
                        
                        currentCatAddedToFavourites = true
                    }
                }
            
            Button(action: {
                Task{
                    await loadNewImage()
                }
            }, label: {
                Text("Next")
            })
                .buttonStyle(.bordered)
                .padding()
            
            
            
            HStack {
                Text("Favourite Kitties")
                    .font(.title3)
                    .bold()
                    .padding()
                Spacer()
            }
            List(favouriteCats, id: \.self) { currentFavourite in
                Text(currentFavouriteCat.url)
                
                
                Spacer()
                
            }
            
            .task {
                
                currentCatImage = URL(string: currentFavouriteCat.url)!
                
                await loadNewImage()
                
                loadFavourites()
                
            }
            
            .onChange(of: scenePhase) { newPhase in
                
                if newPhase == .inactive {
                    print("Inactive")
                } else if newPhase == .active {
                    print("Active")
                } else {
                    print("Background")
                    
                    persistFavourites()
                }
                
            }
            
            .navigationTitle("Passive Aggressive Cats")
            
        }
        
    }
    
    // MARK: Functions
    func loadNewImage() async {
        // Assemble the URL that points to the endpoint
        let url = URL(string: "https://cdn2.thecatapi.com/images/aqb.jpg")!
        
        // Define the type of data we want from the endpoint
        // Configure the request to the web site
        var request = URLRequest(url: url)
        // Ask for JSON data
        request.setValue("application/json",
                         forHTTPHeaderField: "Accept")
        
        // Start a session to interact (talk with) the endpoint
        let urlSession = URLSession.shared
        
        // Try to fetch a new joke
        // It might not work, so we use a do-catch block
        do {
            
            // Get the raw data from the endpoint
            let (data, _) = try await urlSession.data(for: request)
            
            // Attempt to decode the raw data into a Swift structure
            // Takes what is in "data" and tries to put it into "currentJoke"
            //                                 DATA TYPE TO DECODE TO
            //                                         |
            //                                         V
            currentFavouriteCat = try JSONDecoder().decode(Cat.self, from: data)
            
            currentCatImage = URL(string: currentFavouriteCat.url)!
            //force unwrapping the URL, which was an optional, telling swift that we know
            //that the URL definitely is a correct url
            
            currentCatAddedToFavourites = false
            
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the do-catch block
            // populates
            print(error)
        }
        
    }
    
    func persistFavourites() {
        
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
        
        do {
            //Create a JSON Encoder object
            let encoder = JSONEncoder()
            //Configure the encoder to "pretty print" the JSON
            encoder.outputFormatting = .prettyPrinted
            
            //Encode the list of favorites we've collected
            let data = try encoder.encode(favouriteCats)
            
            //Write the JSON to a file in the filename location we came up with
            //earlier
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
            
            //See the data that was written
            print("Saved data to the Documents directory successfully.")
            print("=========")
            print(String(data: data, encoding: .utf8)!)
            
        } catch {
            print("Unable to write list of favourites to the Documents directory")
            print("=======")
            print(error.localizedDescription)
        }
    }
    
    func loadFavourites() {
        
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
        
        do {
            //Load the raw data
            let data = try Data(contentsOf: filename)
            
            print("Saved data to the Documents directory successfully.")
            print("=========")
            print(String(data: data, encoding: .utf8)!)
            
            //NOTE: We use [Cat] since we are loading into a list (array)
            favouriteCats = try JSONDecoder().decode([Cat].self, from: data)
            
        } catch {
            
            print("Could not load the data from the sored JSON file")
            print("=====")
            print(error.localizedDescription)
        }
    }
    
    
}

struct CatView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}


