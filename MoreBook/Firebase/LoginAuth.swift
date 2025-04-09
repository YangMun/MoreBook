import SwiftUI
import CryptoKit
import FirebaseAuth
import AuthenticationServices

class LoginAuth: ObservableObject {
    static let shared = LoginAuth()
    @Published var isLoggedIn = false
    
    private init() {}
    
    func signInWithApple() async throws {
        let nonce = randomNonceString()
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let result = try await withUnsafeThrowingContinuation { continuation in
            let delegate = SignInWithAppleDelegate(continuation: continuation, nonce: nonce)
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = delegate
            authorizationController.presentationContextProvider = delegate
            authorizationController.performRequests()
            
            // delegate를 강한 참조로 유지
            objc_setAssociatedObject(authorizationController, "delegate", delegate, .OBJC_ASSOCIATION_RETAIN)
        }
        
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: result.idToken,
            rawNonce: result.nonce
        )
        
        let authResult = try await Auth.auth().signIn(with: credential)
        DispatchQueue.main.async {
            self.isLoggedIn = true
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

class SignInWithAppleDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let continuation: UnsafeContinuation<(idToken: String, nonce: String), Error>
    private let nonce: String
    private var isCompleted = false
    
    init(continuation: UnsafeContinuation<(idToken: String, nonce: String), Error>, nonce: String) {
        self.continuation = continuation
        self.nonce = nonce
        super.init()
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if isCompleted { return }
        isCompleted = true
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let appleIDToken = appleIDCredential.identityToken else {
                continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"]))
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to serialize token string from data"]))
                return
            }
            
            continuation.resume(returning: (idTokenString, nonce))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if isCompleted { return }
        isCompleted = true
        continuation.resume(throwing: error)
    }
    
    deinit {
        if !isCompleted {
            continuation.resume(throwing: NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Authentication cancelled"]))
        }
    }
}
