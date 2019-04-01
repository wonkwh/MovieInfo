//
//  MovieViewModel.swift
//  MovieInfo
//
//  Created by wonkwh on 01/04/2019.
//  Copyright © 2019 Alfian Losari. All rights reserved.
//

import Foundation

struct MovieViewModel {
    private var movie: Movie
    private let dateFormatter: DateFormatter = {
        $0.dateStyle = .medium
        $0.timeStyle = .none
        return $0
    }(DateFormatter())
    
    var title: String {
        return movie.title
    }
    
    var overview: String {
        return movie.overview
    }
    
    var releaseDate: String {
        return dateFormatter.string(from: movie.releaseDate)
    }
    
    var ratingText: String {
        let rating = Int(movie.voteAverage)
        let ratingText = (0..<rating).reduce("") { (acc, _) -> String in
            return acc + "⭐️"
        }
        return ratingText
    }

    var posterURL: URL {
        return movie.posterURL
    }
    
    init(movie: Movie) {
        self.movie = movie
    }
}

