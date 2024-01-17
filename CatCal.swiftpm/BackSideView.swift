import SwiftUI
import PencilKit

struct BackSideView: View {
    @Binding var mainDate: Date
    @State private var textInput: String = ""
    @StateObject private var canvasViewModel = CanvasViewModel()

    var body: some View {
        VStack {
            // Upper part for multiline text input
            TextEditor(text: $textInput)
                .frame(minHeight: 0, maxHeight: .infinity)
                .padding() // Padding around TextEditor
                .background(Color(red: 0.95, green: 0.95, blue: 0.95)) // Background color
                .cornerRadius(10) // Rounded corners
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .onTapGesture {
                    print("text backside tapped")
                }

            // Lower part for PencilKit canvas
            PencilKitView(canvasViewModel: canvasViewModel)
                .frame(minHeight: 0, maxHeight: .infinity)
                .padding() // Padding around PencilKitView
                .background(Color(red: 0.95, green: 0.95, blue: 0.95)) // Background color
                .cornerRadius(10) // Rounded corners
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .overlay(saveButton, alignment: .topTrailing)

        }
          .background(Color(red: 0.98, green: 0.95, blue: 0.90))      
    }

    var saveButton: some View {
        Button(action: {
            canvasViewModel.saveImage(named: mainDate.formatted())
        }) {
            Image(systemName: "square.and.arrow.down")
                .padding()
                .background(Color.white)
                .clipShape(Circle())
                .shadow(radius: 10)
        }
        .padding()
    }
}

class CanvasViewModel: ObservableObject {
    let canvasView = PKCanvasView()
    func saveImage(named name: String) {
        // Functionality to capture canvas content and save to disk
        // ...
    }
    
    
}

struct PencilKitView: View {
    @ObservedObject var canvasViewModel: CanvasViewModel

    var body: some View {
        CanvasViewRepresentable(canvasView: canvasViewModel.canvasView)
          
    }
}

struct CanvasViewRepresentable: UIViewRepresentable {
    let canvasView: PKCanvasView
    
    func makeUIView(context: Context) -> PKCanvasView {
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
    }
}
