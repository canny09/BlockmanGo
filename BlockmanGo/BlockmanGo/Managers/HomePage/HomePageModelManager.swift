//
//  HomePageModelManager.swift
//  BlockmanGo
//
//  Created by KiBen on 2018/8/24.
//  Copyright © 2018年 SanboxOL. All rights reserved.
//

import Foundation

struct HomePageModelManager {
    
    static func verifyNickname(_ nickname: String) -> Bool {
        return nickname ~= "^[a-zA-Z0-9]{6,12}$"
    }
    
    func fetchUserProfile(completion: @escaping (BlockHTTPResult<ProfileModel, BlockHTTPError>) -> Void) {
        UserRequester.fetchUserProfile { (result) in
            self.parseProfileResult(result, completion: completion)
        }
    }
    
    func initializeProfile(nickname: String, gender: Gender, completion: @escaping (BlockHTTPResult<ProfileModel, BlockHTTPError>) -> Void) {
        UserRequester.initializeProfile(nickname: nickname, gender: gender.rawValue) { (result) in
            self.parseProfileResult(result, completion: completion)
        }
    }
    
    private func parseProfileResult(_ result: BlockHTTPResult<[String : Any], BlockHTTPError>, completion: @escaping (BlockHTTPResult<ProfileModel, BlockHTTPError>) -> Void) {
        switch result {
        case .success(let response):
            let profileModel = try! response.mapModel(ProfileModel.self)
            UserManager.shared.setProfile(profileModel)
            completion(.success(profileModel))
        case .failure(let error):
            completion(.failure(error))
        }
    }
}
