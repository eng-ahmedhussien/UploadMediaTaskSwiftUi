//
//  AuthenticationAPIClient.swift
//  AlDwaaNewApp
//
//  Created by Mohammed Hamdi on 16/10/2022.
//

import Foundation
import Combine
import UIKit

protocol AuthenticationAPIProtocol {
    func login(userName: String, password: String,completion: @escaping (Result<UserSessionData, NetworkError>) -> Void)
    func verifyAnonymous(parameters: [String: Any])-> AnyPublisher<AnonymousVerificationModel, NetworkError>
    func refreshToken(refreshToken: String, completion: @escaping (Result<UserSessionData, NetworkError>) -> Void)
    func loginWithApple(username: String, jwtToken: String, completion: @escaping (Result<UserSessionData, NetworkError>) -> Void)
    func loginGuest(userName: String, secret: String, completion: @escaping (Result<UserSessionData, NetworkError>) -> Void)
    func loginGuestSink(userName: String, secret: String) -> AnyPublisher<UserSessionData, NetworkError>
    func getProfile()-> AnyPublisher<UserProfileData, NetworkError>
    func updateProfile(parameters: [String: Any])-> AnyPublisher<EmptyEntity, NetworkError>
    func changePassword(oldPassword:String, newPassword:String)-> AnyPublisher<EmptyEntity, NetworkError>
    func DeleteAccount(password: String) ->AnyPublisher<EmptyEntity,NetworkError>
    func deleteProfilePicture()-> AnyPublisher<EmptyEntity, NetworkError>
    func uploadMedia(image:UIImage) -> AnyPublisher<UploadMediaModel, NetworkError>
    func uploadProfilePicture(format:String,image:String) -> AnyPublisher<EmptyEntity, NetworkError>
    
}

class AuthenticationAPIClient: APIClient<AuthenticationRouter>, AuthenticationAPIProtocol {
    func verifyAnonymous(parameters: [String : Any]) -> AnyPublisher<AnonymousVerificationModel, NetworkError> {
        request(target: .verifyAnonymous(parameters: parameters), responseClass:AnonymousVerificationModel.self , authenticationType: .withAuth)
    }
    func changePassword(oldPassword: String, newPassword: String) -> AnyPublisher<EmptyEntity, NetworkError> {
        request(target: .changePassword(oldPassword: oldPassword, newPassword: newPassword), responseClass:EmptyEntity.self , authenticationType: .withAuth)
    }
    
    
    func updateProfile(parameters: [String : Any]) -> AnyPublisher<EmptyEntity, NetworkError> {
        request(target: .updateProfile(parameters: parameters), responseClass:EmptyEntity.self , authenticationType: .withAuth)
    }
    
    
    func getProfile()-> AnyPublisher<UserProfileData, NetworkError> {
        
        request(target: .getProfile, responseClass: UserProfileData.self, authenticationType: .withAuth)
       
    }
    
    func loginGuestSink(userName username: String, secret: String) -> AnyPublisher<UserSessionData, NetworkError> {
        request(target: .guest(username: username, key: secret), responseClass: UserSessionData.self, authenticationType: .noAuth)
    }
    
    func loginGuest(userName: String, secret: String, completion: @escaping (Result<UserSessionData, NetworkError>) -> Void) {
         
        request(target: .guest(username: userName, key: secret), responseClass: UserSessionData.self, authenticationType: .noAuth, completion: completion)
    }
    
    
    //TODO: Add the correct response model
    func login(userName: String, password: String, completion: @escaping (Result<UserSessionData, NetworkError>) -> Void) {
        request(target: .login(username: userName, password: password), responseClass: UserSessionData.self, authenticationType: .noAuth,completion: completion)
    }
    
    func refreshToken(refreshToken: String, completion: @escaping (Result<UserSessionData, NetworkError>) -> Void) {
        request(target: .refreshToken(refreshToken: refreshToken), responseClass: UserSessionData.self, authenticationType: .noAuth, completion: completion)
    }
    
    func loginWithApple(username: String, jwtToken: String, completion: @escaping (Result<UserSessionData, NetworkError>) -> Void) {
        request(target: .loginWithApple(username: username, jwtToken: jwtToken), responseClass: UserSessionData.self, authenticationType: .noAuth, completion: completion)
    }
    
    func DeleteAccount(password: String) -> AnyPublisher<EmptyEntity, NetworkError> {
        request(target: .DeleteAccount(password: password), responseClass: EmptyEntity.self, authenticationType: .withAuth)
    }
    
    func deleteProfilePicture()-> AnyPublisher<EmptyEntity, NetworkError>{
        request(target: .DeleteProfilePicture, responseClass: EmptyEntity.self, authenticationType: .withAuth)
    }
    
    func uploadMedia(image: UIImage) -> AnyPublisher<UploadMediaModel, NetworkError> {
        multipartRequest(target: .uploadMedia(image: image), responseClass: UploadMediaModel.self, authenticationType: .withAuth) { per in
            print(per)
        }
    }
    
    func uploadProfilePicture(format: String, image: String) -> AnyPublisher<EmptyEntity, NetworkError> {
        request(target: .uploadProfilePicture(format: format, image: image), responseClass: EmptyEntity.self, authenticationType: .withAuth)
    }
}
