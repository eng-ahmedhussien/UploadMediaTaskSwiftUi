//
//  AuthenticationRouter.swift
//  AlDwaaNewApp
//
//  Created by Mohammed Hamdi on 16/10/2022.
//
import Foundation
import UIKit

enum AuthenticationRouter {
    case login(username: String, password: String)
    case guest(username: String, key: String)
    case refreshToken(refreshToken: String)
    case loginWithApple(username: String, jwtToken: String)
    case getProfile
    case updateProfile(parameters: [String: Any])
    case verifyAnonymous(parameters: [String: Any])
    
    case changePassword(oldPassword:String,newPassword:String)
    case DeleteAccount(password:String)
    
    case DeleteProfilePicture
    case uploadMedia(image:UIImage)
    case uploadProfilePicture(format:String,image:String)
}
//TODO: Update with actual values
extension AuthenticationRouter: RouterProtocol {
    var currentLang: String {
        get {
            return LocalizationManager.shared.currentLanguage.NetworkLanguage
        }
    }
    
    var baseURL: String {
        switch self {
        default:
            return "https://stg-api.dwademo.com/"
        }
    }
    
    
    var path: String {
        switch self {
        case .login(username: let username, password: let password):
            return "authorizationserver/oauth/token?client_id=occ_mobile&client_secret=Erabia@123&grant_type=password&username=\(username)&password=\(password)"
        case .guest(username: let username, key: let key):
            return "authorizationserver/oauth/token?client_id=\(username)&client_secret=\(key)&grant_type=client_credentials"
        case .refreshToken(refreshToken: let refreshToken):
            return "authorizationserver/oauth/token?client_id=occ_mobile&client_secret=Erabia@123&grant_type=refresh_token&refresh_token=\(refreshToken)"
        case .loginWithApple:
            return ""
        case .getProfile:
            return "occ/v2/aldawaa/users/current?fields=FULL&lang=\(currentLang)"
        case .updateProfile:
            return "occ/v2/aldawaa/users/current?fields=FULL&lang=\(currentLang)"
        case .verifyAnonymous:
            return "/occ/v2/aldawaa/users/anonymous/verification?fields=DEFAULT&lang=\(currentLang)"
            
        case .changePassword(oldPassword: let oldPassword, newPassword: let newPassword):
            return "occ/v2/aldawaa/users/current/password?new=\(newPassword)&old=\(oldPassword)&lang=\(currentLang)"
        
        case .DeleteAccount(password: let password):
            return "occ/v2/aldawaa/users/current?password=\(password)&lang=\(currentLang)"
            
        case .DeleteProfilePicture:
            return "occ/v2/aldawaa/users/current/avatar&lang=\(currentLang)"
        case .uploadMedia:
            return "occ/v2/aldawaa/media?folder=images&mediaType=USERAVATAR&mime=png&lang=\(currentLang)"
        case .uploadProfilePicture:
            return "occ/v2/aldawaa/users/current/avatar"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        case .refreshToken, .loginWithApple:
            return .post
        case .guest:
            return .post
        case .getProfile:
            return  .get
        case .updateProfile:
            return .put
        case .verifyAnonymous:
            return .post
        case .changePassword:
            return.put
        case .DeleteAccount:
            return .delete
        
        case .DeleteProfilePicture:
            return .delete
        case .uploadMedia:
            return .post
        case .uploadProfilePicture:
            return .put
        }
    }
    
    var task: RouterTask {
        switch self {
        case .login:
            return .requestNoParameters
        case .refreshToken:
            return .requestNoParameters
            //                .requestParameters(parameters: ["ADD_KEY_HERE": refreshToken], encoding: .URLEncoding(.queryString))
        case .loginWithApple(let username, let jwtToken):
            return .requestParameters(parameters: ["ADD_KEY_HERE": username, "ADD_KEY_HEREE": jwtToken], encoding: .JSONEncoding())
        case .guest:
            return .requestNoParameters
        case .getProfile:
            return .requestNoParameters
        case .updateProfile(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding:.JSONEncoding())
        case .verifyAnonymous(parameters: let parameters):
            return .requestParameters(parameters: parameters, encoding:.JSONEncoding())
        case .changePassword:
            return .requestNoParameters
        case .DeleteAccount:
            return .requestNoParameters
            
        case .DeleteProfilePicture:
            return .requestNoParameters
      
           
        case .uploadMedia(image: let image):
            return .requestWithMultipart(parameters: [:], multipartParamters: .single(key: "file", image: image))
        case .uploadProfilePicture(format: let format, image: let image):
            return .requestParameters(parameters: ["url": image, "format": format], encoding: .JSONEncoding())
        }
    }
    
    var headers: HTTPHeader? {
        switch self {
        case .login:
            return nil
        case .refreshToken:
            return nil
        case .loginWithApple:
            return nil
        case .guest:
            return nil
        case .getProfile:
            return nil
        case .updateProfile:
            return nil
        case .verifyAnonymous:
            return nil
        case .changePassword:
            return nil
        case .DeleteAccount:
            return nil
        case .DeleteProfilePicture:
            return nil
        case .uploadMedia:
            return nil
        case .uploadProfilePicture:
            return nil
        }
    }
}
