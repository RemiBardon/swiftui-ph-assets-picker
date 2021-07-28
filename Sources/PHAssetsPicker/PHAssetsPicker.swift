//
//  PHAssetsPicker.swift
//  PHAssetsPicker
//
//  Created by Rémi Bardon on 20/07/2021.
//

import SwiftUI
import PhotosUI

#if canImport(UIKit)
@available(iOS 14, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct PHAssetsPicker: UIViewControllerRepresentable {
	
	let config: PHPickerConfiguration
	let onPick: (PHFetchResult<PHAsset>) -> Void
	
	public init(config: PHPickerConfiguration, onPick: @escaping (PHFetchResult<PHAsset>) -> Void) {
		self.config = config
		self.onPick = onPick
	}
	
	public init(
		preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
		selectionLimit: Int = 1,
		filter: PHPickerFilter? = nil,
		onPick: @escaping (PHFetchResult<PHAsset>) -> Void
	) {
		var config = PHPickerConfiguration(photoLibrary: .shared())
		config.preferredAssetRepresentationMode = preferredAssetRepresentationMode
		config.selectionLimit = selectionLimit
		config.filter = filter
		self.init(config: config, onPick: onPick)
	}
	
	@available(iOS 15, *)
	public init(
		preferredAssetRepresentationMode: PHPickerConfiguration.AssetRepresentationMode = .automatic,
		selection: PHPickerConfiguration.Selection = .default,
		selectionLimit: Int = 1,
		filter: PHPickerFilter? = nil,
		onPick: @escaping (PHFetchResult<PHAsset>) -> Void
	) {
		var config = PHPickerConfiguration(photoLibrary: .shared())
		config.preferredAssetRepresentationMode = preferredAssetRepresentationMode
		config.selection = selection
		config.selectionLimit = selectionLimit
		config.filter = filter
		self.init(config: config, onPick: onPick)
	}
	
	public func makeUIViewController(context: Context) -> PHPickerViewController {
		let controller = PHPickerViewController(configuration: config)
		controller.delegate = context.coordinator
		return controller
	}
	
	public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
	
	public func makeCoordinator() -> Coordinator {
		return Coordinator(parent: self)
	}
	
	public class Coordinator: PHPickerViewControllerDelegate {
		
		private let parent: PHAssetsPicker
		
		init(parent: PHAssetsPicker) {
			self.parent = parent
		}
		
		public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
			let assetIdentifiers = results.compactMap(\.assetIdentifier)
			let assetResults = PHAsset.fetchAssets(withLocalIdentifiers: assetIdentifiers, options: nil)
			
			DispatchQueue.main.async {
				self.parent.onPick(assetResults)
			}
		}
		
	}
}

#if DEBUG
@available(iOS 15, *)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
struct PHAssetsPicker_Previews: PreviewProvider {
	
	static private var showingSheet: State<Bool> = State(initialValue: false)
	
	static var previews: some View {
		NavigationView {
			Button("Select Image") {
				showingSheet.wrappedValue = true
			}
		}
		.sheet(isPresented: .constant(true)) {
			PHAssetsPicker(selection: .ordered) { assetResults in
				// Read images metadata
//				for i in 0..<assetResults.count {
//					let asset = assetResults[i]
//					let creationDate: Date? = asset.creationDate
//					let location: CLLocation? = asset.location
//					let coordinates: CLLocationCoordinate2D? = location.coordinate
//				}
				
				// Load images
				let targetSize = CGSize(width: 128, height: 128)
				let manager = PHCachingImageManager()
				let options = PHImageRequestOptions()
				options.deliveryMode = PHImageRequestOptionsDeliveryMode.fastFormat
				options.isSynchronous = true
				for i in 0..<assetResults.count {
					let asset = assetResults[i]
					manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (image: UIImage?, info) in
//						if let image = image {
//							DispatchQueue.main.async {
//								// Do stuff
//							}
//						} else {
//							// Read error from `info`
//						}
					}
				}
			}
			.ignoresSafeArea()
		}
	}
	
}
#endif
#else
#warning("`PHPickerViewController` is only available in UIKit")
#endif
