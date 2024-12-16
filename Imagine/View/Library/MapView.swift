//
//  MapView.swift
//  Imagine
//
//  Created by Ryan Aparicio on 12/8/24.
//

import SwiftUI
import SwiftData
import MapKit

struct MapView: View {
    // get the logged in user
    @EnvironmentObject var authManager: AuthenticationManager

    // fetch the user Books
    @Query private var books: [Book]
    @Query private var pictures: [SavedPicture]
    
    // Map region state
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default center
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    // Annotations for the map
    @State private var mapAnnotations: [MapAnnotationItem] = []
    
    // saves selected map annotation
    @State private var selectedAnnotation: MapAnnotationItem?

    
    // get data before view loads
    init() {
        // Use a default predicate that will be dynamically updated
        _books = Query(filter: #Predicate<Book> { _ in true })
        _pictures = Query(filter: #Predicate<SavedPicture> { _ in true })
    }
    
    var body: some View {
        // Map view with annotations
        // Map view with custom annotations
        Map(coordinateRegion: $region, annotationItems: mapAnnotations) { annotation in
            MapAnnotation(coordinate: annotation.coordinate) {
                Button(action: {
                    selectedAnnotation = annotation
                }) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(annotation.subtitle == "Book" ? .blue : .green) // Different colors
                        Text(annotation.title)
                            .font(.caption)
                            .padding(5)
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(5)
                            .shadow(radius: 2)
                            .opacity((selectedAnnotation != nil && selectedAnnotation! == annotation) ? 1 : 0)                    }
                }
            }
        }
        .onAppear {
            loadAnnotations()
        }

        // Optional: Display detailed info below the map when a marker is clicked
        if let annotation = selectedAnnotation {
            VStack {
                Text("Selected Item")
                    .font(.headline)
                Text("Title: \(annotation.title)")
                Text("Type: \(annotation.subtitle)")
            }
            .padding()
        }
    }
    // FUNCTIONS
    // Computed property to filter books by current user
    private var filteredBooks: [Book] {
        guard let username = authManager.currentUser?.username else {
            return []
        }
        return books.filter { $0.username == username }
    }
    
    private var filteredPictures: [SavedPicture] {
        guard let username = authManager.currentUser?.username else {
            return []
        }
        return pictures.filter { $0.username == username }
    }
    
    // Load annotations from filtered data
    private func loadAnnotations() {
        var annotations: [MapAnnotationItem] = []

        // Add book locations
        for book in filteredBooks {
            if let coordinate = parseCoordinate(from: book.location ?? "") {
                annotations.append(MapAnnotationItem(coordinate: coordinate, title: book.title, subtitle: "Book"))
            }
        }

        // Add picture locations
        for picture in filteredPictures {
            if let coordinate = parseCoordinate(from: picture.location ?? "") {
                annotations.append(MapAnnotationItem(coordinate: coordinate, title: picture.title, subtitle: "Picture"))
            }
        }

        // Update state
        mapAnnotations = annotations

        // Optionally adjust the map region to fit all annotations
        if let firstAnnotation = annotations.first {
            region.center = firstAnnotation.coordinate
        }
    }

    /// Parse coordinates from a string (e.g., "37.7749,-122.4194")
    private func parseCoordinate(from location: String) -> CLLocationCoordinate2D? {
        let components = location.split(separator: ",").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        guard components.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: components[0], longitude: components[1])
    }
}
// Map annotation item structure
struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
    
    
    // Conform to Equatable by comparing all relevant properties
    static func == (lhs: MapAnnotationItem, rhs: MapAnnotationItem) -> Bool {
        lhs.id == rhs.id &&
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle
    }
}

#Preview {
    MapView()
        .environmentObject(AuthenticationManager())
}
