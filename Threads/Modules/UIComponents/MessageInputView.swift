import SwiftUI

struct MessageInputView: View {
    @Binding var text: String
    let isDisabled: Bool
    let onSend: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField("Message", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...6)
                .disabled(isDisabled)
                .onSubmit {
                    if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        onSend()
                    }
                }
            
            Button(action: onSend) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundColor(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isDisabled ? .gray : .blue)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isDisabled)
        }
        .padding()
    }
}

#Preview {
    VStack {
        MessageInputView(
            text: .constant(""),
            isDisabled: false,
            onSend: {}
        )
        
        MessageInputView(
            text: .constant("Hello world"),
            isDisabled: false,
            onSend: {}
        )
        
        MessageInputView(
            text: .constant("This is a disabled input"),
            isDisabled: true,
            onSend: {}
        )
    }
} 