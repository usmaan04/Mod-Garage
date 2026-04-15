import Foundation
import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProfileViewModel()
    @EnvironmentObject private var homeViewModel: HomeViewModel
    @EnvironmentObject private var settingsViewModel: SettingsViewModel

    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                ZStack {
                    avatarView

                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Image(systemName: "pencil")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                            .foregroundStyle(Color.white)
                    }
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.redTheme)
                    )
                    .offset(x: 32, y: 36)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Name")
                        .font(.system(size: 14).weight(.medium))
                    TextField("Enter your name", text: $viewModel.name)
                        .autocorrectionDisabled()
                        .font(.system(size: 12))
                        .textInputAutocapitalization(.words)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.container)
                                .stroke(Color.containerBorder, lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.system(size: 14).weight(.medium))

                    TextField("Enter your email", text: $viewModel.email)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .font(.system(size: 12))
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.container)
                                .stroke(Color.containerBorder, lineWidth: 1)
                        )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.system(size: 14).weight(.medium))

                    SecureField("Enter a new password", text: $viewModel.password)
                        .font(.system(size: 12))
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(.vertical, 16)
                        .padding(.horizontal, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.container)
                                .stroke(Color.containerBorder, lineWidth: 1)
                        )
                }

                HStack(spacing: 12) {
                    Button {
                        Task { await viewModel.loadProfile() }
                    } label: {
                        Text("Refresh")
                    }
                    .font(.system(size: 14).weight(.semibold))
                    .foregroundStyle(Color.redTheme)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.redTheme, lineWidth: 1)
                    )
                    .disabled(viewModel.isLoading)

                    Button {
                        Task { await viewModel.updateProfile()
                            homeViewModel.fetchUserName()
                            settingsViewModel.fetchUserDetails()

                            
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Save Changes")
                        }
                    }
                    .font(.system(size: 14).weight(.semibold))
                    .foregroundStyle(Color.container)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.redTheme)
                    )
                    .disabled(viewModel.isLoading)
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 17)
            .frame(maxWidth: .infinity, alignment: .leading)
            .alert(viewModel.successMessage ?? "", isPresented: .constant(viewModel.successMessage != nil)) {
                Button("OK") { viewModel.successMessage = nil }
            } message: {
                Text(viewModel.successMessage ?? "")
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color.background)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task(id: selectedPhotoItem) {
            await loadSelectedPhoto()
        }
    }

    @ViewBuilder
    private var avatarView: some View {
        if let selectedImage = viewModel.selectedImage {
            Image(uiImage: selectedImage)
                .resizable()
                .scaledToFill()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
                .frame(maxWidth: .infinity)
        } else if let url = URL(string: viewModel.profilePhotoURL), !viewModel.profilePhotoURL.isEmpty {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    Image("profilePic")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())

                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())

                case .failure(_):
                    Image("AdaptiveLaunch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .frame(maxWidth: .infinity)
                        .clipShape(Circle())

                @unknown default:
                    Image("AdaptiveLaunch")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                }
            }
        } else {
            Image("AdaptiveLaunch")
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .clipShape(Circle())
        }
    }

    private func loadSelectedPhoto() async {
        guard let selectedPhotoItem else { return }

        do {
            if let data = try await selectedPhotoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                viewModel.selectedImage = image
            }
        } catch {
            viewModel.errorMessage = "Failed to load selected image."
        }
    }
}
