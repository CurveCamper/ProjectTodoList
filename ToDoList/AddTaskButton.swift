import SwiftUI

struct AddTaskButton: View {
    @Binding var showTaskSheet: Bool
    let resetTaskFields: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                button
                Spacer()
            }
            .padding(.bottom, 16)
        }
    }
    
    private var button: some View {
        Button(action: {
            resetTaskFields()
            showTaskSheet.toggle()
        }) {
            Image(systemName: "plus")
                .resizable()
                .frame(width: 24, height: 24)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Circle())
                .shadow(radius: 2)
        }
        
    }
}
