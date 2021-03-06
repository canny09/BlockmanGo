//
//  ProfileModel.swift
//  BlockmanGo
//
//  Created by KiBen on 2018/8/24.
//  Copyright © 2018年 SanboxOL. All rights reserved.
//

import Foundation
import HandyJSON
/*
"account": "string",
"birthday": "string",
"details": "string",
"diamonds": 0,
"email": "string",
"expireDate": "string",
"golds": 0,
"nickName": "string",
"picUrl": "string",
"sex": 0,
"telephone": "string",
"hasPassword": 0,
"userId": 0,
"vip": 0
*/
final class ProfileModel: HandyJSON {
    var nickname: String = ""
    var account: String = ""
    var birthday: String = ""
    var details: String = ""
    var email: String = ""
    var portraitURL: String = ""
    var expireDate: String = ""
    var diamonds: UInt64 = 0
    var golds: UInt64 = 0
    var userID: UInt64 = 0
    var gender: Int = 1
    var telephone: String = ""
    var vip: VIP = .vip
    var hasPassword: Bool = false
    var platform: SignInPlatformEnum = .app
    
    func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.nickname <-- "nickName"
        
        mapper <<<
            self.userID <-- "userId"
        
        mapper <<<
            self.portraitURL <-- "picUrl"
        
        mapper <<<
            self.gender <-- "sex"
        
//        mapper <<<
//            self.gender <-- TransformOf<Gender, Int>(fromJSON: { sex -> Gender in
//                guard let sex = sex else {
//                    return .male
//                }
//                return Gender(rawValue: sex)!
//            }, toJSON: { gender -> Int in
//                return gender?.rawValue ?? 1
//            })
        
        mapper <<<
            self.platform <-- TransformOf<SignInPlatformEnum, String>(fromJSON: { platform -> SignInPlatformEnum in
                return SignInPlatformEnum(rawValue: platform ?? "app") ?? .app
            }, toJSON: { platform -> String in
                return platform?.rawValue ?? "app"
            })
    }
}
