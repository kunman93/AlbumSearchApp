//
//  ContentView.swift
//  ItunesListFinal
//
//  Created by Manu Kunnumpurathu on 13.05.22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            AlbumView()
            .navigationTitle("Albums")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
