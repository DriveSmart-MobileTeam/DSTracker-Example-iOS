import SwiftUI

struct ContentView: View {
    @ObservedObject var service: TrackerExampleService

    var body: some View {
        NavigationView {
            UserIdentificationView(service: service)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

private struct UserIdentificationView: View {
    @ObservedObject var service: TrackerExampleService

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 22) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 220)
                    .padding(.vertical, 18)

                ExampleSection(title: "Register a new unique user identifier") {
                    TextField("Unique ID", text: $service.uniqueUserID, onCommit: service.registerUniqueUser)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    ExampleButton(title: "Register a unique user ID", action: service.registerUniqueUser)
                }

                Text("or").foregroundColor(.secondary)

                ExampleSection(title: "Setup a known DriveSmart user identifier") {
                    TextField(
                        "DriveSmart user identifier",
                        text: $service.knownTrackerUserID,
                        onCommit: service.setupKnownUser
                    )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    ExampleButton(title: "Setup with DS user ID", action: service.setupKnownUser)
                }

                Text("or").foregroundColor(.secondary)

                ExampleSection(title: "Allow DriveSmart to generate a user identifier") {
                    ExampleButton(title: "Generate a DS user ID", action: service.registerAnonymousUser)
                }

                NavigationLink(
                        destination: TripRecordingView(service: service),
                        isActive: Binding(
                            get: { service.activeTrackerUserID != nil },
                            set: { if !$0 { service.activeTrackerUserID = nil } }
                        )
                    ) {
                        EmptyView()
                    }
                    .hidden()
                }
                .padding(20)
            }
            .disabled(service.isIdentifyingUser)

            if service.isIdentifyingUser {
                Color.black.opacity(0.22).edgesIgnoringSafeArea(.all)
                VStack(spacing: 14) {
                    ActivityIndicator()
                    Text("Registering user…")
                        .font(.headline)
                }
                .padding(.horizontal, 28)
                .padding(.vertical, 22)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(14)
                .shadow(radius: 12)
            }
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationBarTitle("DSTracker Example", displayMode: .inline)
    }
}

private struct ActivityIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {}
}

private struct TripRecordingView: View {
    @ObservedObject var service: TrackerExampleService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 210)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)

                TripCard(title: "DriveSmart user") {
                    Text(service.activeTrackerUserID ?? "")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }

                TripCard(title: "Trip recording") {
                    HStack(spacing: 12) {
                        TripActionButton(
                            title: "Start trip",
                            systemImage: "location.fill",
                            color: driveSmartGreen,
                            action: service.startTrip
                        )
                        TripActionButton(
                            title: "Stop trip",
                            systemImage: "stop.fill",
                            color: .red,
                            action: service.stopTrip
                        )
                    }

                    HStack(spacing: 10) {
                        TripMetric(title: "State", value: service.tripState)
                        TripMetric(title: "GPS", value: service.gpsQuality)
                    }

                    HStack(spacing: 10) {
                        TripMetric(title: "Time", value: service.elapsedTime)
                        TripMetric(title: "Distance", value: service.distance)
                    }

                    TrackingRow(title: "Trip started", value: service.tripStart)
                }
            }
            .padding(20)
        }
        .background(Color(.systemBackground).edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Trip recording", displayMode: .inline)
        .onAppear(perform: service.prepareTripRecording)
    }
}

private let driveSmartGreen = Color(red: 0.125, green: 0.776, blue: 0.608)

private struct ExampleSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.headline).foregroundColor(Color(.darkGray))
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ExampleButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 11)
                .background(driveSmartGreen)
                .cornerRadius(6)
        }
    }
}

private struct TripCard<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title).font(.headline)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}

private struct TripActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage).font(.callout)
                Text(title).font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(color)
            .cornerRadius(12)
        }
    }
}

private struct TripMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title).font(.caption).foregroundColor(.secondary)
            Text(value.isEmpty ? "—" : value).font(.headline)
        }
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(10)
    }
}

private struct TrackingRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title).foregroundColor(.secondary)
            Spacer()
            Text(value).fontWeight(.semibold)
        }
        .padding(.vertical, 6)
    }
}
