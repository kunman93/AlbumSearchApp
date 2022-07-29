//
//  AlbumDetailView.swift
//  ItunesListFinal
//
//  Created by Manu Kunnumpurathu on 13.05.22.
//

import SwiftUI
import Foundation

/*
 SongList holds the value of results from the json retrieved from the url
 */
struct SongList : Decodable {
    // should have the same name as the json attribut, in this example results
    var results : [Song]
}

// results attribute is an array of "songs"
struct Song : Identifiable, Decodable {
    // accessing trackName and other attribute... need to make optional because of the inconsistent json
    var trackNumber: Int?
    var trackName: String?
    var trackTimeMillis: Int?
    
    // converting trackTimeMillis to minutes and seconds
    var trackTime : String {
        get {
            let seconds = (Int) (trackTimeMillis! / 1000) % 60
            let minutes = (Int) (trackTimeMillis! / (1000*60)) % 60
            
            return String(minutes) + ":" + String(format: "%02d", seconds)
        }
    }
    
    
    // this is required!!
    var id : String {
        get {
            return UUID().uuidString
        }
    }
}

// Each album cell has an image, collectionName and artistName
struct SongCellView : View {
    @State var song : Song
    
    var body: some View{
        HStack(alignment: .top){
            Text(String(song.trackNumber!))
            Text(song.trackName!)
            Spacer()
            Text(song.trackTime)
        }
    }
}

struct AlbumDetailView : View {
    @State var songList : SongList = SongList(results: [Song]())
    @State var collectionId : Int
    
    var body : some View {
        VStack{
            //albumList is accepted because it is identifiable
            List(songList.results) { song in
                if song.trackNumber != nil && song.trackName != nil {
                    SongCellView(song: song)
                }
            }.listStyle(PlainListStyle()).onAppear(perform: {
                // Option 1: loading Json from file
                //songList = loadJsonFromFile()
                
                // Option 2: loading json from Url, you need to define Task and await
                Task {
                     await songList = loadJsonFromUrl()
                }
                print("Data loaded")
            }).refreshable {
                // Option 1: loading Json from file
                // songList = loadJsonFromFile()
                
                // Option 2: loading json from Url, you need to define Task and await
                Task {
                     await songList = loadJsonFromUrl()
                }
                print("Refreshed data")
            }
        }
    }
    
    func loadJsonFromUrl() async -> SongList {
        do {
            let data = try await download()
            let decoder = JSONDecoder()
            return try decoder.decode(SongList.self, from: data)
        } catch {
            fatalError("Couldn't load file from server")
        }
    }
    
    func download() async throws -> Data {
        let url = URL(string: "https://itunes.apple.com/lookup?id=" + String(collectionId) + "&entity=song")
        let urlRequest = URLRequest(url: url!)
        let (data, response) =
            try await URLSession.shared.data(for: urlRequest)
        //optional: check response
        print(response)
        return data
    }
    
    func loadJsonFromFile() -> SongList {
        do {
            //read the file. Note that you can also use a url later
            let file = Bundle.main.url(forResource: "songs",
               withExtension: "json")
            //create a data instance
            let data = try Data(contentsOf: file!)
            let decoder = JSONDecoder()
            //and decode it to Person
            return try decoder.decode(SongList.self, from: data)
        } catch {
            fatalError("Couldn't load file from main bundle:\n\(error)")
        }
    }
}
