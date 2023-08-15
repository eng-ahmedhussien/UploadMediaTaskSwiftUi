//
//  UserProfileVM.swift
//  AlDwaaNewApp
//
//  Created by Eslam ALi on 11/07/2023.
//

import Foundation
import Combine
import SwiftUI


class UserProfileVM:ObservableObject {
    
    let authenticator: AppAuthenticator
    @Published var userProfileData:UserProfileData?
    
    
    // for Change password view
    @Published var TF_currentPassword: TextFieldData = TextFieldData()
    @Published var TF_newPaswword: TextFieldData = TextFieldData()
    @Published var TF_confirmNewPaswword: TextFieldData = TextFieldData()
    @Published var changePassword_State:ButtonState = .disabled
    @Published var shouldDismissChangePassword = false
    @Published var TF_Password: TextFieldData = TextFieldData()
    
    
    
    // for update Infor view
    @Published var TF_UP_FirstName: TextFieldData = TextFieldData()
    @Published var TF_UP_LastName: TextFieldData = TextFieldData()
    @Published var DropDown_UP_gender: DropDownData = DropDownData<AuthDropDown>(dataArray: [AuthDropDown(name:"Male", type: "MALE"),AuthDropDown(name: "Female", type: "FEMALE")])
    @Published var BTN_UP_Save_State:ButtonState = .disabled
    
    private var cancellables = Set<AnyCancellable>()
    
    
    
    init(authenticator: AppAuthenticator) {
        self.authenticator = authenticator
        addSubScriber()
        
    }
    
    func addSubScriber(){
        self.authenticator.$authenticationState
            .sink { state in
                switch state {
                case .signedIn(_):
                    self.getUserProfileData()
                    
                case .client(_),.empty:
                    break;
                }
            }
            .store(in: &cancellables)
        
        // change password validation input
        $TF_currentPassword
            .combineLatest($TF_newPaswword,$TF_confirmNewPaswword)
            .map(inputValidation)
            .sink { [weak self] validation in
                self?.changePassword_State = validation ? .normal : .disabled
            }
            .store(in: &cancellables)
        
        $TF_Password
            .map(passwordValidation)
            .sink { [weak self] validation in
                self?.changePassword_State = validation ? .normal : .disabled
            }
            .store(in: &cancellables)
        
    }
    
    
    func handleCompletionError(completion:Subscribers.Completion<NetworkError>){
        AppManager.shared.hideAppLoadingView()
        switch completion {
        case .finished:
            break
        case .failure(let error):
            self.showAppMessage( error.backendErrorModel?.errors?.first?.message ?? "", appearance: .toast(.error))
            
        }
    }
    
    
}


//MARK: get profile
extension UserProfileVM{
    
    func getUserProfileData(){
        authenticator.getProfile()
            .sink(receiveCompletion: handleCompletionError, receiveValue: { [weak self] userData in
                AppManager.shared.hideAppLoadingView()
                self?.userProfileData = userData
                self?.authenticator.userProfileData = userData
            })
            .store(in: &cancellables)
    }
  
}


//MARK: update profile


//MARK: Change Password
extension UserProfileVM{
    
    private func inputValidation(oldPassword:TextFieldData,newPasword:TextFieldData,confirmPasword:TextFieldData)->Bool{
        return oldPassword.isValid && newPasword.isValid && confirmPasword.isValid ? true : false
    }
    
    private func passwordValidation(Password:TextFieldData)->Bool{
        return Password.isValid ? true : false
    }
    
    func changePassword(){
        AppManager.shared.showAppLoadingView()
        authenticator.changePassword(oldPassword: TF_currentPassword.text, newPassword: TF_newPaswword.text)
            .sink(
                receiveCompletion: handleCompletionError,
                receiveValue: { [weak self] _ in
                    AppManager.shared.hideAppLoadingView()
                    self?.showAppMessage("password changed successfully", appearance: .toast(.success))
                    self?.clearData()
                    self?.shouldDismissChangePassword = true
                    
                })
            .store(in: &cancellables)
    }
    
    func clearData(){
        TF_currentPassword = TextFieldData()
        TF_newPaswword = TextFieldData()
        TF_confirmNewPaswword = TextFieldData()
       
        
    }
    
}


//MARK: Delete Account
//MARK: Update Info
extension UserProfileVM{
    func deleteAccount(password:String){
        authenticator.deleteAccount(password: password)
            .receive(on:DispatchQueue.main)
            .sink(
                receiveCompletion:handleCompletionError,
                receiveValue: { [weak self] responss in
                    print(responss)
                    self?.authenticator.logout()
                }
            )
            .store(in: &cancellables)
        // AppManager.shared.showAppLoadingView()
    }
    func setUserDataUpdateView(){
        
        
        TF_UP_FirstName.text = userProfileData?.firstName ?? ""
        TF_UP_LastName.text = userProfileData?.lastName ?? ""
        if userProfileData?.gender?.code ?? "MALE" == "MALE"{
            DropDown_UP_gender.selection = AuthDropDown(name:"Male", type: "MALE")
        }else {
            DropDown_UP_gender.selection = AuthDropDown(name: "Female", type: "FEMALE")
        }
        BTN_UP_Save_State = .normal 
       
    }
    
    func updateUserProfileData(){
        AppManager.shared.showAppLoadingView()
        let parm:[String:Any] = [
            "firstName": TF_UP_FirstName.text,
               "gender": [
                "code": DropDown_UP_gender.selection?.type ?? "MALE"
             ],
            "dateOfBirth": userProfileData?.dateOfBirth ?? "",
             "lastName":  TF_UP_LastName.text
        ]
        authenticator.updateProfile(parameters: parm)
            .sink(receiveCompletion: handleCompletionError, receiveValue: { [weak self] userData in
                print(userData)
                self?.getUserProfileData()
                self?.showAppMessage("Personal information has been updated successfully", appearance: .toast(.success))
            })
            .store(in: &cancellables)
    }
    
    
}

//MARK: DeleteProfilePicture
extension UserProfileVM{
    func deleteProfilePicture(){
        AppManager.shared.showAppLoadingView()
        authenticator.deleteProfilePicture()
            .receive(on:DispatchQueue.main)
            .sink(
                receiveCompletion:handleCompletionError,
                receiveValue: { [weak self] reponse in
             AppManager.shared.hideAppLoadingView()
                    self?.getUserProfileData()
                }
            )
            .store(in: &cancellables)
    }
}

//MARK: uploadMedia & uploadProfilePicture
extension UserProfileVM{
    func uploadMedia(image: UIImage){
        AppManager.shared.showAppLoadingView()
        authenticator.uploadMedia(image: image)
            .receive(on:DispatchQueue.main)
            .sink(
                receiveCompletion:handleCompletionError,
                receiveValue: { [weak self] response in
                    guard let image = response.url, let format = response.mime else {return}
                        self?.uploadProfilePicture(format: format, image: image)
                }
            )
            .store(in: &cancellables)
    }
    
    func uploadProfilePicture(format:String,image: String){
        authenticator.uploadProfilePicture(format: format, image: image)
            .receive(on:DispatchQueue.main)
            .sink(
                receiveCompletion:handleCompletionError,
                receiveValue: { [weak self] reponse in
                    self?.getUserProfileData()
                }
            )
            .store(in: &cancellables)
    }
    
    
}
