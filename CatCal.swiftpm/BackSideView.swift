    import SwiftUI
    import PencilKit

    struct BackSideView: View {
        @Binding var mainDate: Date
        @State private var textInput: String = ""
        @StateObject private var canvasViewModel: CanvasViewModel
        
        
        init(mainDate: Binding<Date>) {
         
            self._mainDate = mainDate
            self._canvasViewModel = StateObject(wrappedValue: CanvasViewModel(date: mainDate))
            
          }

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
        var mainDate: Binding<Date>
        init(date: Binding<Date>) {
            // Create a dark navy color
            self.mainDate = date
            let darkNavyColor = UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0) // Adjust RGB values as needed
            
            // Set the default tool as a pencil with the dark navy color
            let pencil = PKInkingTool(.pencil, color: darkNavyColor, width: 2) // Adjust width as needed
            canvasView.tool = pencil
            loadDrawing()
        }
        
        func clearCanvas() {
               canvasView.drawing = PKDrawing()
           }
        
        func formattedDateString(from date: Date) -> String {
               let formatter = DateFormatter()
               formatter.dateFormat = "yyyyMMdd"
               return formatter.string(from: date)
           }
        func loadDrawing() {
            let formattedDate = formattedDateString(from: mainDate.wrappedValue)
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("\(formattedDate).data")
                   
            if let drawingData = try? Data(contentsOf: fileURL),
                      let drawing = try? PKDrawing(data: drawingData) {
                       canvasView.drawing = drawing
                   } else {
                       clearCanvas() // Clear canvas if no drawing is found
                   }
        }

        func saveImage(named name: String) {
            print(mainDate.wrappedValue)
            let drawingData = canvasView.drawing.dataRepresentation()
            let formattedDate = formattedDateString(from: mainDate.wrappedValue)
                   
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsDirectory.appendingPathComponent("\(formattedDate).data")
                   
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
