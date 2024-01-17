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
    init() {
        // Create a dark navy color
        let darkNavyColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0) // Adjust RGB values as needed
        
        // Set the default tool as a pencil with the dark navy color
        let pencil = PKInkingTool(.pencil, color: darkNavyColor, width: 2) // Adjust width as needed
        canvasView.tool = pencil
        loadDrawing()
    }
    func loadDrawing() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("savedDrawing.data")
        
        if let drawingData = try? Data(contentsOf: fileURL),
           let drawing = try? PKDrawing(data: drawingData) {
            canvasView.drawing = drawing
        }
    }

    func saveImage(named name: String) {
        let drawingData = canvasView.drawing.dataRepresentation()
        
        // Define the URL for saving the file
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsDirectory.appendingPathComponent("savedDrawing.data")
        
        // Write the data to the file
        do {
            try drawingData.write(to: fileURL)
        } catch {
            print("Unable to save drawing:", error.localizedDescription)
        }
    
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
