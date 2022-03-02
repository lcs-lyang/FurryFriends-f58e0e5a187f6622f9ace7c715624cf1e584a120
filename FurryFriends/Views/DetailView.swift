//
//  DetailView.swift
//  FurryFriends
//
//  Created by Lillian Yang on 2022-03-02.
//

import SwiftUI

struct DetailView: View {
    
    //MARK: Stored Properties
    
    @State var inputNote = ""
    
    //MARK: Computed Properties
    
    var body: some View {
        
        VStack {
            TextField("Type here", text: $inputNote)
                .padding()
            Spacer()
        }
        .navigationTitle("Doggy Notes")
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
        DetailView()
        }
    }
}
