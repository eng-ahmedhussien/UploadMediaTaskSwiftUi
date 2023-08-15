//
//  AppAuthenticator.swift
//  NetworkLayer
//
//  Created by Mohammed Hamdi on 03/07/2022.
//

import SwiftUI
import Combine

class AppAuthenticator {
    
    //MARK: Public variables
    weak public var delegate: AuthenticatorProtocol?
    
    @Published public private(set) var authenticationState: AuthState = .empty
    
    public private(set) var userSessionData: UserSessionData? {
        get {
            return UserDefaultsHelper.standard.read(key: .auth(.userSessionData), type: UserSessionData.self)
        }
        set {
            if let value = newValue {
                UserDefaultsHelper.standard.save(value, key: .auth(.userSessionData))
            } else {
                UserDefaultsHelper.standard.delete(key: .auth(.userSessionData))
            }
        }
    }
    
    public  var userProfileData: UserProfileData? {
        get {
            return UserDefaultsHelper.standard.read(key: .auth(.userProfileData), type: UserProfileData.self)
        }
        set {
            if let value = newValue {
                UserDefaultsHelper.standard.save(value, key: .auth(.userProfileData))
            } else {
                UserDefaultsHelper.standard.delete(key: .auth(.userProfileData))
            }
        }
    }
    
    
    public private(set) var userType: UserType? {
        get {
            return UserDefaultsHelper.standard.read(key: .auth(.userType), type: UserType.self)
        }
        set {
            if let value = newValue {
                UserDefaultsHelper.standard.save(value, key: .auth(.userType))
            } else {
                UserDefaultsHelper.standard.delete(key: .auth(.userType))
            }
        }
    }
    
    //MARK: Private variables
    ///The client that handles the api calling for authentication
    private let apiClient: AuthenticationAPIProtocol = AuthenticationAPIClient()
    
    //Login Provider
    ///The Login provider object
    private var provider: LoginProvider?
    
    ///The Login Type (password - google - facebook - twitter - apple)
    private var loginProviderType: LoginProviderType? {
        get {
            return UserDefaultsHelper.standard.read(key: .auth(.loginProvider), type: LoginProviderType.self)
        }
        set {
            if let value = newValue {
                UserDefaultsHelper.standard.save(value, key: .auth(.loginProvider))
            } else {
                UserDefaultsHelper.standard.delete(key: .auth(.loginProvider))
            }
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: Initializer
    init() {
        getCurrentLoginState()
    }
    
    
    //MARK: Private Methods
    ///Loads and check the login state
    private func getCurrentLoginState() {
        if let provider = loginProviderType {
            initializeLoginProvider(provider)
        }
        
        /*
         The state of login will be determined after checking if the access token is valid or not
         If not should refresh after checking if the refersh is valid
         */
        
        if let userData = self.userSessionData , let userType = self.userType{
            authenticationState =  userType == .guest ? .client(userData) : .signedIn(userData)
        }
        else{
            authenticationState = .empty
            getClientToken()
        }
        
        
        
        //TODO: Check for access token and refresh it if required
    }
    
    ///It sets the Login provider object according to the the Login provider type
    private func initializeLoginProvider(_ providerType: LoginProviderType) {
        switch providerType {
        case .password:
            self.provider = nil
            
        case .google:
            self.provider = GoogleAuthenticator(apiClient: apiClient)
            
        case .facebook:
            self.provider = FacebookAuthenticator(apiClient: apiClient)
            
        case .twitter:
            self.provider = TwitterAuthenticator(apiClient: apiClient)
            
        case .apple:
            self.provider = AppleAuthenticator(apiClient: apiClient)
        }
        self.provider?.delegate = self
    }
    
    ///Is called to handle the data and state change for Login
    private func handleLogin(user: UserSessionData ,user_Type:UserType) {
        //TODO: Set tokens
        userSessionData = user
        userType = user_Type
        setToken(user: user)
        delegate?.didLogin()
        authenticationState =  user_Type == .guest ? .client(user) : .signedIn(user)
    }
    private func setToken(user: UserSessionData) {
        accessToken =  user.access_token
        refreshToken = user.refresh_token
    }
    
    ///Clears the data and reset the state
    private func clearData() {
        //TODO: Delete tokens on logout success
        userSessionData = nil
        userProfileData = nil
        userType = nil
        accessToken = nil
        refreshToken = nil
        loginProviderType = nil
        provider = nil
        authenticationState = .empty
        getClientToken()
        delegate?.didLogout()
    }
    
}

//MARK: Public API Methods
extension AppAuthenticator {
    
    /*
     Note:
     3rd Party integration will have its own public API
     */
    
    
    public func login(userName: String, password: String,completion: @escaping (NetworkError?) -> Void)  {
        // Will return the phone number in case of user activation
        
        
        apiClient.login(userName: userName, password: password, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.handleLogin(user: data, user_Type: .signedIn)
                completion(nil)
            case .failure(let error):
                completion(error)
                
            }
        })
        
    }
    
    public func getProfile()-> AnyPublisher<UserProfileData,NetworkError>  {
        apiClient.getProfile()
        
    }
    public func loginClient() {
        let clientId = AppConstants.ApiCallingData.apiClientId
        let clientSecret = AppConstants.ApiCallingData.apiClientSecret
        apiClient.loginGuest(userName: clientId, secret: clientSecret, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.handleLogin(user: data, user_Type: .guest)
            case .failure(let error):
                print(error.errorDescription ?? "")
                
            }
        })
    }
    
    public func verifyAnonymous(parameters: [String: Any]) -> AnyPublisher<AnonymousVerificationModel, NetworkError> {
        apiClient.verifyAnonymous(parameters: parameters)
    }
    
    public func register(data: RegisterData) -> AnyPublisher<String, NetworkError> {
        // Will return the phone number
        //TODO: Add real implementation
        Just("051111111111")
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    public func logout()  {
        
        //TODO: Call on logout success
        provider?.logout()
        clearData()
        //        //TODO: Add real implementation
        //        return Just(())
        //            .setFailureType(to: NetworkError.self)
        //            .eraseToAnyPublisher()
    }
    
    public func submitOTPUserActivation(phone: String, otp: String) -> AnyPublisher<Void, NetworkError> {
        //TODO: Add real implementation
        Just(())
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    public func forgetPasswordInitiate(phone: String) -> AnyPublisher<String, NetworkError> {
        // Will return the phone number
        //TODO: Add real implementation
        Just("051111111111")
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    public func forgetPasswordSubmitOTP(phone: String, otp: String) -> AnyPublisher<String, NetworkError> {
        // Will return the phone number
        //TODO: Add real implementation
        Just("051111111111")
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    public func forgetPasswordSubmitNewPassword(phone: String, password: String) -> AnyPublisher<Void, NetworkError> {
        //TODO: Add real implementation
        Just(())
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    public func resendOTP(phone: String) -> AnyPublisher<Void, NetworkError> {
        //TODO: Add real implementation
        Just(())
            .setFailureType(to: NetworkError.self)
            .eraseToAnyPublisher()
    }
    
    public func changePassword(oldPassword: String, newPassword: String) -> AnyPublisher<EmptyEntity, NetworkError> {
        apiClient.changePassword(oldPassword: oldPassword, newPassword: newPassword)
    }
    
    //TODO: Add parameters
    public func updateProfile(parameters: [String: Any]) -> AnyPublisher<EmptyEntity, NetworkError> {
        apiClient.updateProfile(parameters: parameters)
    }
    
    //MARK: Login External provider Methods
    public func loginWithProvider(_ providerType: LoginProviderType) {
        initializeLoginProvider(providerType)
        
        provider?.login(completion: { [weak self] result in
            switch result {
            case .success(let user):
                debugPrint("✅ Logged In successfully username: \(user.name ?? "")")
                self?.loginProviderType = providerType
                self?.handleLogin(user: user, user_Type: .signedIn)
                
            case .failure(let error):
                //TODO: Handle login error
                debugPrint("🔥🔥 Error login with external provider: \(error.localizedDescription)")
            }
        })
        
    }
    
    //MARK: Delete Account
    public func deleteAccount(password: String) -> AnyPublisher<EmptyEntity, NetworkError>{
        apiClient.DeleteAccount(password: password)
    }
    
    //MARK: deleteProfilePicture
    public func deleteProfilePicture() -> AnyPublisher<EmptyEntity, NetworkError>{
        apiClient.deleteProfilePicture()
    }
    
    //MARK: uploadMedia
    public func uploadMedia(image:UIImage) -> AnyPublisher<UploadMediaModel, NetworkError>{
        apiClient.uploadMedia( image: image)
    }
    
    //MARK: uploadProfilePicture
    public func uploadProfilePicture(format: String,image:String) -> AnyPublisher<EmptyEntity, NetworkError>{
        apiClient.uploadProfilePicture(format: format, image: image)
    }
}

//MARK: Life Cycle Methods
extension AppAuthenticator {
    func appDidFinishLaunchingWithOptions(_ application: UIApplication, _ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        FacebookAuthenticator.appDidFinishLaunchingWithOptions(application, launchOptions)
    }
    
    func appCanOpenURL(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        if GoogleAuthenticator.canOpenURL(url) {
            return true
        } else if FacebookAuthenticator.canOpenURL(app, open: url, options: options) {
            return true
        } else {
            return false
        }
    }
}


//MARK: Login Provider Delegate Methods
extension AppAuthenticator: LoginProviderDelegate {
    internal func providerDidLogout(_ provider: LoginProviderType) {
        debugPrint("Logout from external provider")
        self.provider = nil
        
        logout()
        
        
    }
}

//MARK: AccessTokenStorage
extension AppAuthenticator: AccesssTokenStorage {
    private(set) var accessToken: String? {
        get {
            return KeychainHelper.standard.read(service: .accessToken, account: .dawaa, type: String.self)
        }
        
        set {
            if let token = newValue {
                KeychainHelper.standard.save(token, service: .accessToken, account: .dawaa)
            } else {
                KeychainHelper.standard.delete(service: .accessToken, account: .dawaa)
            }
        }
    }
    
    private var refreshToken: String? {
        get {
            return KeychainHelper.standard.read(service: .refreshToken, account: .dawaa, type: String.self)
        }
        
        set {
            if let token = newValue {
                KeychainHelper.standard.save(token, service: .refreshToken, account: .dawaa)
            } else {
                KeychainHelper.standard.delete(service: .refreshToken, account: .dawaa)
            }
        }
    }
    
    internal func refreshTokenRequest(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        
        guard let userType = self.userType else{return }
        
        switch userType {
        case .signedIn:
            refreshTokenRequestLogin { Result in
                completion(Result)
            }
        case .guest:
            getClientToken { Result in
                completion(Result)
            }
        }
        
        
    }
    
    internal func refreshTokenRequestLogin(completion: @escaping (Result<Void, NetworkError>) -> Void) {
        apiClient.refreshToken(refreshToken: refreshToken ?? "") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.setToken(user: data)
                completion(.success(()))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    internal func getClientToken(completion: ((Result<Void, NetworkError>) -> Void)? = nil){
        let clientId = AppConstants.ApiCallingData.apiClientId
        let clientSecret = AppConstants.ApiCallingData.apiClientSecret
        apiClient.loginGuest(userName: clientId, secret: clientSecret, completion: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.setToken(user: data)
                if let completion = completion {
                    completion(.success(()))
                }
                
            case .failure(let error):
                print(error.errorDescription ?? "")
                if let completion = completion {
                    completion(.failure(error))
                }
                
            }
        })
    }
    
}
