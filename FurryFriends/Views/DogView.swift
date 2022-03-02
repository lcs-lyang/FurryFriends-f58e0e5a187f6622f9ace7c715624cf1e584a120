//
//  ContentView.swift
//  FurryFriends
//
//  Created by Russell Gordon on 2022-02-26.
//

import SwiftUI

struct ContentView: View {
    
    // MARK: Stored properties
    
    
    // Address for main image
    // Starts as a transparent pixel – until an address for an animal's image is set
    @State var currentImage = URL(string: "https://www.russellgordon.ca/lcs/miscellaneous/transparent-pixel.png")!
    
    //message is the link of the image
    @State var currentFavourite: Dog = Dog(message: "https://www.russellgordon.ca/lcs/miscellaneous/transparent-pixel.png", status: "")
    
    @State var favourites: [Dog] = []
    
    @State var currentDogAddedToFavourites: Bool = false
    
    // MARK: Computed properties
    var body: some View {
        
        VStack {
            
            // Shows the main image
            RemoteImageView(fromURL: currentImage)
            
            Image(systemName: "heart.circle")
                .resizable()
                .foregroundColor(currentDogAddedToFavourites == true ? .red : .secondary)
                .frame(width: 40, height: 40)
                .onTapGesture {
                    
                    if currentDogAddedToFavourites == false {
                        favourites.append(currentFavourite)
                        
                        currentDogAddedToFavourites = true
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
                Text("Favourite Doggies")
                    .font(.title3)
                    .bold()
                    .padding()
                Spacer()
            }
            List(favourites, id: \.self) { currentFavourite in
                Text(currentFavourite.message)
                
            
                
                Spacer()
                
            }
            // Runs once when the app is opened
            .task {
                
                currentImage = URL(string: currentFavourite.message)!
                
                await loadNewImage()
                
                loadFavourites()
                
            }
            .navigationTitle("Doggies")
            
        }
        
    }
    
    // MARK: Functions
    func loadNewImage() async {
        // Assemble the URL that points to the endpoint
        let url = URL(string: "https://dog.ceo/api/breeds/image/random")!
        
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
            currentFavourite = try JSONDecoder().decode(Dog.self, from: data)
            
            // Replaces the transparent pixel image with an actual image of an animal
            // Adjust according to your preference ☺️
            currentImage = URL(string: currentFavourite.message)!
            //force unwrapping the URL, which was an optional, telling swift that we know
            //that the URL definitely is a correct url
            
            // Reset the flag that racks whether the current joke
            //is a favorite
            currentDogAddedToFavourites = false
            
            
        } catch {
            print("Could not retrieve or decode the JSON from endpoint.")
            // Print the contents of the "error" constant that the do-catch block
            // populates
            print(error)
        }
        
    }
    
    func persistFavourites() {
        
        //Get a location under which to save the data
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
        
        //try to encode the data in ou list of favorites to JSON
        do {
            //Create a JSON Encoder object
            let encoder = JSONEncoder()
            //Configure the encoder to "pretty print" the JSON
            encoder.outputFormatting = .prettyPrinted
            
            //Encode the list of favorites we've collected
            let data = try encoder.encode(favourites)
            
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
        
        //Get a location under which to save the data
        let filename = getDocumentsDirectory().appendingPathComponent(savedFavouritesLabel)
        print(filename)
        
        //Attempt to load the data
        do {
            //Load the raw data
            let data = try Data(contentsOf: filename)
            
            //See the data that was read
            print("Saved data to the Documents directory successfully.")
            print("=========")
            print(String(data: data, encoding: .utf8)!)
            
            //Decode the JSON into Swift native data structures
            //NOTE: We use [DadJoke] since we are loading into a list (array)
            favourites = try JSONDecoder().decode([Dog].self, from: data)
            
        } catch {
            //What went wrong?
            print("Could not load the data from the sored JSON file")
            print("=====")
            print(error.localizedDescription)
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView()
        }
    }
}

