import SwiftUI

struct ActivityDetailView: View {
    @Binding var data: ActivityData
    @FocusState private var focusedField: ActivityField?
    
    enum ActivityField {
        case startDate, name, location, address, startTime, endTime, cost, notes, bookingReference
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Activity Information")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        DatePicker("Date", selection: $data.startDate, displayedComponents: .date)
                            .padding()
                            .background(focusedField == .startDate ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                            .focused($focusedField, equals: .startDate)
                        
                        TextField("Activity Name", text: $data.name)
                            .padding()
                            .background(focusedField == .name ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                            .focused($focusedField, equals: .name)
                            .placeholder(when: data.name.isEmpty) {
                                Text("e.g., Museum Visit").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        TextField("Location", text: $data.location)
                            .padding()
                            .background(focusedField == .location ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                            .focused($focusedField, equals: .location)
                            .placeholder(when: data.location.isEmpty) {
                                Text("e.g., Louvre Museum").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        TextField("Detailed Address", text: $data.address)
                            .padding()
                            .background(focusedField == .address ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .address)
                            .placeholder(when: data.address.isEmpty) {
                                Text("e.g., 75001 Paris, France").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        DatePicker("Start Time", selection: $data.startTime, displayedComponents: .hourAndMinute)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                        
                        DatePicker("End Time", selection: $data.endTime, displayedComponents: .hourAndMinute)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                        
                        TextField("Cost", value: $data.cost, format: .currency(code: "USD"))
                            .padding()
                            .background(focusedField == .cost ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .cost)
                            .keyboardType(.decimalPad)
                            .placeholder(when: data.cost == 0) {
                                Text("e.g., 25.00").foregroundColor(.gray.opacity(0.6))
                            }
                        
                        Toggle("Pre-booked Activity", isOn: $data.isBooked)
                            .padding(.vertical, 8)
                        
                        if data.isBooked {
                            TextField("Booking Reference", text: $data.bookingReference)
                                .padding()
                                .background(focusedField == .bookingReference ? Color(.systemGray6) : Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                )
                                .focused($focusedField, equals: .bookingReference)
                                .placeholder(when: data.bookingReference.isEmpty) {
                                    Text("e.g., ACT123456").foregroundColor(.gray.opacity(0.6))
                                }
                        }
                        
                        TextField("Notes", text: $data.notes, axis: .vertical)
                            .padding()
                            .background(focusedField == .notes ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .notes)
                            .lineLimit(3...6)
                            .placeholder(when: data.notes.isEmpty) {
                                Text("Additional notes...").foregroundColor(.gray.opacity(0.6))
                            }
                    }
                }
            }
        }
    }
}
