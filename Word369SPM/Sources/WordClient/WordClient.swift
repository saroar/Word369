//
//  WordClient.swift
//  
//
//  Created by Saroar Khandoker on 01.12.2021.
//

import Foundation
import HTTPRequestKit
import Combine
import SharedModels

public struct WordClient {
    public typealias WordFetchHandler = (_ from: String, _ to: String) -> AnyPublisher<[Word], HTTPRequest.HRError>
    public typealias WordCreateHandler = (Word) -> AnyPublisher<Word, HTTPRequest.HRError>

    public let words: WordFetchHandler
    public let create: WordCreateHandler

    public init(
        words: @escaping WordFetchHandler,
        create: @escaping WordCreateHandler
    ) {
        self.words = words
        self.create = create
    }
}

extension WordClient {
  public static var live = Self(
    words: { from, to in
      let builder: HTTPRequest = .build(
        baseURL: URL(string: "https://word.justcal.me/api/words/language?fromLanguage=\(from)&toLanguage=\(to)")!,
        method: .get,
        authType: .none,
        path: "",
        contentType: .json,
        dataType: .none
      )

      return builder.send(scheduler: RunLoop.main)
        .catch { (error: HTTPRequest.HRError) -> AnyPublisher<[Word], HTTPRequest.HRError> in
          Fail(error: error).eraseToAnyPublisher()
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    },

    create: { word in
      let builder: HTTPRequest = .build(
        baseURL: URL(string: "http://localhost:7070/api/words")!,
        method: .post,
        authType: .none,
        path: "",
        contentType: .json,
        dataType: .encodable(input: word)
      )

      return builder.send(scheduler: RunLoop.main)
      .catch { (error: HTTPRequest.HRError) -> AnyPublisher<Word, HTTPRequest.HRError> in
        Fail(error: error).eraseToAnyPublisher()
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
    }
  )
}

extension WordClient {
  public static let empty = Self(
    words: { from, to in 
        Just([Word(englishWord: "", englishDefinition: "", user: .demo)])
        .setFailureType(to: HTTPRequest.HRError.self)
        .eraseToAnyPublisher()
    },
    create: { _ in
        Just(Word(englishWord: "", englishDefinition: "", user: .demo))
        .setFailureType(to: HTTPRequest.HRError.self)
        .eraseToAnyPublisher()
    }
  )
}
