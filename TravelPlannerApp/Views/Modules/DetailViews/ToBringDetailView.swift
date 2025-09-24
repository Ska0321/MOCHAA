import SwiftUI
import Foundation

struct ToBringDetailView: View {
    @Binding var data: ToBringData
    @State private var newItemName = ""
    @State private var newItemCategory = "general"
    
    private let categories = ["general", "clothing", "electronics", "toiletries", "documents", "medications", "entertainment", "other"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Title Section
            VStack(alignment: .leading, spacing: 12) {
                Text("To Bring List")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                TextField("List Title", text: $data.title)
                    .font(.title3)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                    )
            }
            
            // Add new item section
            VStack(alignment: .leading, spacing: 12) {
                Text("Add New Item")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                HStack(spacing: 12) {
                    TextField("Item name", text: $newItemName)
                        .font(.body)
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                        )
                    
                    Picker("Category", selection: $newItemCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.capitalized)
                                .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.body)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                    )
                    
                    Button(action: addNewItem) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                    .disabled(newItemName.isEmpty)
                }
            }
            
            // Items list
            if !data.items.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Items (\(data.items.count))")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    ForEach(data.items) { item in
                        ToBringItemRow(
                            item: Binding(
                                get: { item },
                                set: { _ in }
                            ),
                            onToggle: { toggleItem(item) },
                            onDelete: { deleteItem(item) }
                        )
                    }
                }
            }
            
            // Notes section
            VStack(alignment: .leading, spacing: 12) {
                Text("Notes")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                TextField("Additional notes...", text: $data.notes, axis: .vertical)
                    .font(.body)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                    )
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func addNewItem() {
        let trimmedName = newItemName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        
        let newItem = ToBringItem(
            name: trimmedName,
            category: newItemCategory
        )
        
        data.items.append(newItem)
        newItemName = ""
        newItemCategory = "general"
    }
    
    private func toggleItem(_ item: ToBringItem) {
        if let index = data.items.firstIndex(where: { $0.id == item.id }) {
            data.items[index].isChecked.toggle()
        }
    }
    
    private func deleteItem(_ item: ToBringItem) {
        data.items.removeAll { $0.id == item.id }
    }
}

struct ToBringItemRow: View {
    @Binding var item: ToBringItem
    let onToggle: () -> Void
    let onDelete: () -> Void
    @State private var showingEditSheet = false
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(item.isChecked ? .green : .gray)
            }
            .buttonStyle(PlainButtonStyle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(item.isChecked ? .secondary : .primary)
                    .strikethrough(item.isChecked)
                
                Text(item.category.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 8) {
                Button(action: {
                    showingEditSheet = true
                }) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16))
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .sheet(isPresented: $showingEditSheet) {
            ToBringItemEditView(item: $item)
        }
    }
}

struct ToBringItemEditView: View {
    @Binding var item: ToBringItem
    @Environment(\.dismiss) var dismiss
    @State private var editedName: String
    @State private var editedCategory: String
    @State private var editedNotes: String
    
    private let categories = ["general", "clothing", "electronics", "toiletries", "documents", "medications", "entertainment", "other"]
    
    init(item: Binding<ToBringItem>) {
        self._item = item
        self._editedName = State(initialValue: item.wrappedValue.name)
        self._editedCategory = State(initialValue: item.wrappedValue.category)
        self._editedNotes = State(initialValue: item.wrappedValue.notes)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Item Name")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("Item name", text: $editedName)
                        .font(.body)
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Category")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Picker("Category", selection: $editedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category.capitalized)
                                .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .font(.body)
                    .padding(16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Notes")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    TextField("Additional notes...", text: $editedNotes, axis: .vertical)
                        .font(.body)
                        .padding(16)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding(20)
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        item.name = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
                        item.category = editedCategory
                        item.notes = editedNotes.trimmingCharacters(in: .whitespacesAndNewlines)
                        dismiss()
                    }
                    .disabled(editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ToBringDetailView(data: .constant(ToBringData(
        title: "Paris Packing List",
        items: [
            ToBringItem(name: "Passport", isChecked: true, category: "documents"),
            ToBringItem(name: "Camera", isChecked: false, category: "electronics"),
            ToBringItem(name: "Sunglasses", isChecked: false, category: "general")
        ],
        notes: "Don't forget to check weather forecast"
    )))
}