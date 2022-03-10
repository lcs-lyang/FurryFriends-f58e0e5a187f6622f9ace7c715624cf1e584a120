//
//  CatAndDog.swift
//  FurryFriends
//
//  Created by Lillian Yang on 2022-03-09.
//

import SwiftUI

struct CatAndDog: View {
    
    @Environment(\.scenePhase) var scenePhase
    // Address for main image
    // Starts as a transparent pixel – until an address for an animal's image is set
    
    @State var currentAddedToFavourites: Bool = false
    
    //Dog
    @State var currentDogImage = URL(string: "https://www.russellgordon.ca/lcs/miscellaneous/transparent-pixel.png")!
    
    //message is the link of the image
    @State var currentFavouriteDog: Dog = Dog(message: "https://www.russellgordon.ca/lcs/miscellaneous/transparent-pixel.png", status: "")
    
    @State var favouriteDogs: [Dog] = []
    
    //Cat
    @State var currentCatImage = URL(string: "https://cdn2.thecatapi.com/images/4ip.gif")!
    
    @State var currentFavouriteCat: Cat = Cat(id: "", url: "https://cdn2.thecatapi.com/images/4ip.gif")
    
    @State var favouriteCats: [Cat] = []
    
    var body: some View {
        VStack {
            
            HStack{
                // Shows the main image
                RemoteImageView(fromURL: currentDogImage)
                RemoteImageView(fromURL: currentCatImage)
                
                VStack{
                    ShowAnimalImage(currentAddedToFavourites: $currentAddedToFavourites)
                        .onTapGesture {
                            
                            if currentAddedToFavourites == false {
                                favouriteDogs.append(currentFavouriteDog)
                                
                                currentAddedToFavourites = true
                            }
                        }
                    Button(action: {
                        Task{
                            await loadNewDogImage()
                        }
                    }, label: {
                        Text("Next")
                    })
                        .buttonStyle(.bordered)
                        .padding()
                }
                
                VStack{
                    ShowAnimalImage(currentAddedToFavourites: $currentAddedToFavourites)
                        .onTapGesture {
                            
                            if currentAddedToFavourites == false {
                                favouriteCats.append(currentFavouriteCat)
                                
                                currentAddedToFavourites = true
                            }
                        }
                    
                    Button(action: {
                        Task{
                            await loadNewCatImage()
                        }
                    }, label: {
                        Text("Next")
                    })
                        .buttonStyle(.bordered)
                        .padding()
                }
            }
            
            
            HStack {
                Text("Favourites")
                    .font(.title3)
                    .bold()
                    .padding()
                Spacer()
            }
            
            HStack{
                List(favouriteDogs, id: \.self) { currentFavourite in
                    Text(currentFavouriteDog.message)
                    
                    List(favouriteCats, id: \.self) { currentFavourite in
                        Text(currentFavouriteCat.url)
                        
                    }
                    Spacer()
                    
                }
                // Runs once when the app is opened
                .task {
                    
                    currentDogImage = URL(string: currentFavouriteDog.message)!
                    await loadNewDogImage()
                    loadDogFavourites()
                    
                    currentCatImage = URL(string: currentCatImage.url)!
                    await loadCatFavourites()
                    loadCatFavourites()
                }
                
                .onChange(of: scenePhase) { newPhase in
                    
                    if newPhase == .inactive {
                        print("Inactive")
                    } else if newPhase == .active {
                        print("Active")
                    } else {
                        print("Background")
                        
                        //Permanentky save the list of tasks
                        persistCatFavourites()
                        persistDogFavourites()
                    }
                    
                }
                
                .navigationTitle("Cats and Dogs")
                
            }
            
        }
    }
        // MARK: Functions
        //Cat
        func loadNewCatImage() async {
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
                currentFavouriteDog = try JSONDecoder().decode(Dog.self, from: data)
                
                // Replaces the transparent pixel image with an actual image of an animal
                // Adjust according to your preference ☺️
                currentDogImage = URL(string: currentFavouriteDog.message)!
                //force unwrapping the URL, which was an optional, telling swift that we know
                //that the URL definitely is a correct url
                
                // Reset the flag that racks whether the current joke
                //is a favorite
                currentAddedToFavourites = false
                
                
            } catch {
                print("Could not retrieve or decode the JSON from endpoint.")
                // Print the contents of the "error" constant that the do-catch block
                // populates
                print(error)
            }
            
        }
        
        func persistCatFavourites() {
            
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
                let data = try encoder.encode(favouriteDogs)
                
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
        
        func loadCatFavourites() {
            
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
                favouriteDogs = try JSONDecoder().decode([Dog].self, from: data)
                
            } catch {
                //What went wrong?
                print("Could not load the data from the sored JSON file")
                print("=====")
                print(error.localizedDescription)
            }
        }
        
        //Dog
        func loadNewDogImage() async {
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
                currentFavouriteDog = try JSONDecoder().decode(Dog.self, from: data)
                
                // Replaces the transparent pixel image with an actual image of an animal
                // Adjust according to your preference ☺️
                currentDogImage = URL(string: currentFavouriteDog.message)!
                //force unwrapping the URL, which was an optional, telling swift that we know
                //that the URL definitely is a correct url
                
                // Reset the flag that racks whether the current joke
                //is a favorite
                currentAddedToFavourites = false
                
                
            } catch {
                print("Could not retrieve or decode the JSON from endpoint.")
                // Print the contents of the "error" constant that the do-catch block
                // populates
                print(error)
            }
            
        }
        
        func persistDogFavourites() {
            
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
                let data = try encoder.encode(favouriteDogs)
                
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
        
        func loadDogFavourites() {
            
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
                favouriteDogs = try JSONDecoder().decode([Dog].self, from: data)
                
            } catch {
                //What went wrong?
                print("Could not load the data from the sored JSON file")
                print("=====")
                print(error.localizedDescription)
            }
        }
        
    }
    
    
    struct CatAndDog_Previews: PreviewProvider {
        static var previews: some View {
            CatAndDog()
        }
    }
