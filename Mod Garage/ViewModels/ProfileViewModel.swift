import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import UIKit

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""

    @Published var profilePhotoURL: String = ""
    @Published var selectedImage: UIImage? = nil

    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil

    private let db = Firestore.firestore()
    private let storage = Storage.storage()

    init() {
        Task { await loadProfile() }
    }

    func loadProfile() async {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No logged in user."
            return
        }

        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        successMessage = nil

        do {
            try? await user.reload()
            let refreshedUser = Auth.auth().currentUser

            email = refreshedUser?.email ?? ""
            profilePhotoURL = refreshedUser?.photoURL?.absoluteString ?? ""

            if let displayName = refreshedUser?.displayName, !displayName.isEmpty {
                name = displayName
            }

            let doc = try await db.collection("users").document(user.uid).getDocument()
            if let data = doc.data() {
                if let firestoreName = data["name"] as? String, !firestoreName.isEmpty {
                    name = firestoreName
                }

                if let firestorePhotoURL = data["photoURL"] as? String, !firestorePhotoURL.isEmpty {
                    profilePhotoURL = firestorePhotoURL
                }
            }
        } catch {
            errorMessage = "Failed to load profile: \(error.localizedDescription)"
        }
    }

    func updateProfile() async {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No logged in user."
            return
        }

        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        successMessage = nil

        do {
            var finalPhotoURLString = profilePhotoURL

            // Upload image first if the user picked one
            if let selectedImage {
                finalPhotoURLString = try await uploadProfileImage(selectedImage)
            }

            // Update email if changed
            if !email.isEmpty, email != user.email {
                try await user.sendEmailVerification(beforeUpdatingEmail: email)
            }

            // Update password if provided
            if !password.isEmpty {
                try await user.updatePassword(to: password)
                password = ""
            }

            // Update Firebase Auth profile
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name

            if let url = URL(string: finalPhotoURLString), !finalPhotoURLString.isEmpty {
                changeRequest.photoURL = url
            }

            try await changeRequest.commitChanges()

            // Save to Firestore as well
            try await db.collection("users").document(user.uid).setData([
                "name": name,
                "email": email,
                "photoURL": finalPhotoURLString,
                "updatedAt": FieldValue.serverTimestamp()
            ], merge: true)

            profilePhotoURL = finalPhotoURLString
            successMessage = "Profile updated"
        } catch {
            errorMessage = "Failed to update profile: \(error.localizedDescription)"
        }
    }

    private func uploadProfileImage(_ image: UIImage) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "ProfileViewModel",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user."]
            )
        }

        guard let imageData = image.jpegData(compressionQuality: 0.75) else {
            throw NSError(
                domain: "ProfileViewModel",
                code: 400,
                userInfo: [NSLocalizedDescriptionKey: "Could not process selected image."]
            )
        }

        let ref = storage.reference().child("profile_images/\(uid)/avatar.jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await ref.downloadURL()

        return downloadURL.absoluteString
    }
}
