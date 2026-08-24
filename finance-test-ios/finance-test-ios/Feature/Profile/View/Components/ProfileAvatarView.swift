//
//  ProfileAvatarView.swift
//  finance-test-ios
//

import PhotosUI
import SwiftUI
import UIKit

struct ProfileAvatarView: View {
	let avatarUrl: String?
	let hasAvatar: Bool
	let isUploading: Bool
	let onImagePicked: (Data) -> Void
	let onRemoveTapped: () -> Void

	@State private var isActionSheetPresented = false
	@State private var isPhotosPickerPresented = false
	@State private var photoPickerItem: PhotosPickerItem?

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			avatarImage
			editButton
		}
		.animation(.spring(response: 0.3, dampingFraction: 0.7), value: isUploading)
		.confirmationDialog(Text("Change Photo"), isPresented: $isActionSheetPresented, titleVisibility: .visible) {
			Button("Choose Photo") { isPhotosPickerPresented = true }
			if hasAvatar {
				Button("Remove Photo", role: .destructive, action: onRemoveTapped)
			}
		}
		.photosPicker(isPresented: $isPhotosPickerPresented, selection: $photoPickerItem, matching: .images)
		.onChange(of: photoPickerItem) { _, newItem in
			guard let newItem else { return }
			Task {
				if
					let data = try? await newItem.loadTransferable(type: Data.self),
					let uploadData = Self.resizedForUpload(data)
				{
					onImagePicked(uploadData)
				}
				photoPickerItem = nil
			}
		}
	}

	private var avatarImage: some View {
		ZStack {
			ImageLoader(path: avatarUrl ?? "", width: 112, height: 112)
				.clipShape(Circle())
				.overlay(Circle().stroke(Color.white, lineWidth: 4))
				.shadow(color: .black.opacity(0.12), radius: 8, y: 4)

			if isUploading {
				Circle()
					.fill(Color.black.opacity(0.35))
					.frame(width: 112, height: 112)
					.transition(.opacity)

				ProgressView()
					.tint(.white)
					.transition(.scale.combined(with: .opacity))
			}
		}
	}

	private var editButton: some View {
		Button(action: {
			withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
				isActionSheetPresented = true
			}
		}) {
			Circle()
				.fill(Color.brandPrimary)
				.frame(width: 32, height: 32)
				.overlay(
					Image(systemName: "camera.fill")
						.font(.system(size: 14, weight: .semibold))
						.foregroundStyle(.white)
				)
				.overlay(Circle().stroke(Color.white, lineWidth: 2))
		}
		.disabled(isUploading)
		.accessibilityLabel("Edit photo")
	}

	/// Downscales/re-encodes the picked image to JPEG so it stays under the API's 2048 KB cap
	/// (`POST /auth/profile/avatar`'s `avatar` field) without relying on the user to pick a
	/// pre-sized photo.
	private static func resizedForUpload(
		_ data: Data,
		maxDimension: CGFloat = 1024,
		maxBytes: Int = 2 * 1024 * 1024
	) -> Data? {
		guard let image = UIImage(data: data) else { return nil }

		let scale = min(1, maxDimension / max(image.size.width, image.size.height))
		let targetSize = CGSize(width: image.size.width * scale, height: image.size.height * scale)
		let resizedImage = UIGraphicsImageRenderer(size: targetSize).image { _ in
			image.draw(in: CGRect(origin: .zero, size: targetSize))
		}

		var quality: CGFloat = 0.85
		var jpegData = resizedImage.jpegData(compressionQuality: quality)
		while let currentData = jpegData, currentData.count > maxBytes, quality > 0.3 {
			quality -= 0.1
			jpegData = resizedImage.jpegData(compressionQuality: quality)
		}
		return jpegData
	}
}

#Preview {
	VStack(spacing: 32) {
		ProfileAvatarView(
			avatarUrl: nil,
			hasAvatar: false,
			isUploading: false,
			onImagePicked: { _ in },
			onRemoveTapped: {}
		)

		ProfileAvatarView(
			avatarUrl: nil,
			hasAvatar: true,
			isUploading: true,
			onImagePicked: { _ in },
			onRemoveTapped: {}
		)
	}
	.padding()
}
