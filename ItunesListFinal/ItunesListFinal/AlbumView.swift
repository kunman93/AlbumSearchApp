//
//  AlbumView.swift
//  ItunesListFinal
//
//  Created by Manu Kunnumpurathu on 13.05.22.
//

import SwiftUI
import Foundation

/*
 AlbumList holds the value of results attribute in stones.json
 or from the json retrieved from the url
 */
struct AlbumList : Decodable { //Note the
    // should have the same name as the json attribut, in this example results
    var results : [Album]
}

// results attribute in stones.json is an array of "albums"
struct Album : Identifiable, Decodable {
    // accessing collectionName attribute
    var collectionId : Int
    var collectionName : String
    var artistName : String
    var artworkUrl100: String
    
    // this is required!!
    var id : String {
        get {
            return UUID().uuidString
        }
    }
}

// Each album cell has an image, collectionName and artistName
struct AlbumCellView : View {
    @State var album : Album
    
    var body: some View{
        NavigationLink(destination: AlbumDetailView(collectionId: album.collectionId)){
            HStack{
                // loading image from url
                AsyncImage(url: URL(string: album.artworkUrl100)){
                    image in image.resizable()
                // show a progressView while the image is loading
                } placeholder: {
                    ProgressView()
                }.frame(width: 70, height: 70)
                VStack{
                    HStack{
                        Text(album.collectionName).bold()
                        Spacer()
                    }
                    HStack{
                        Text(album.artistName).font(.system(size: 12))
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct AlbumView: View {
    // use this @State and an empty array when you want to use onAppear
    @State var albumList : AlbumList = AlbumList(results: [Album]())
    @State var artistName : String = ""
    
    var body: some View {
        /* VStack is important here, when using NavigationView
           which is implemented in ContentView */
        VStack{
            TextField("Artist name", text: $artistName, onEditingChanged: {t in},
            onCommit: {
                // Option 2: loading json from Url, you need to define Task and await
                Task {
                     await albumList = loadJsonFromUrl()
                }
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding().accessibility(hint: Text("Artist name"))
            
            //albumList is accepted because it is identifiable
            List(albumList.results) { album in
                AlbumCellView(album: album)
            }.listStyle(PlainListStyle()).onAppear(perform: {
                // Option 1: loading Json from file
                // albumList = loadJsonFromFile()
                
                // Option 2: loading json from Url, you need to define Task and await
                Task {
                     await albumList = loadJsonFromUrl()
                }
                print("Data loaded")
            }).refreshable {
                Task {
                     await albumList = loadJsonFromUrl()
                }
                print("Refreshed data")
            }
        }
    }
    
    func loadJsonFromUrl() async -> AlbumList {
        do {
            let data = try await download()
            let decoder = JSONDecoder()
            return try decoder.decode(AlbumList.self, from: data)
        } catch {
            fatalError("Couldn't load file from server")
        }
    }
    
    func download() async throws -> Data {
        let url = URL(string: "https://itunes.apple.com/search?term=" + artistName + "&entity=album")
        let urlRequest = URLRequest(url: url!)
        let (data, response) =
            try await URLSession.shared.data(for: urlRequest)
        //optional: check response
        print(response)
        return data
    }
    
    func loadJsonFromFile() -> AlbumList {
        do {
            //read the file. Note that you can also use a url later
            let file = Bundle.main.url(forResource: "stones",
               withExtension: "json")
            //create a data instance
            let data = try Data(contentsOf: file!)
            let decoder = JSONDecoder()
            //and decode it to Person
            return try decoder.decode(AlbumList.self, from: data)
        } catch {
            fatalError("Couldn't load file from main bundle:\n\(error)")
        }
    }
}
