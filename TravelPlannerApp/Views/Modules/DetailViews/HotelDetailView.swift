import SwiftUI

struct HotelDetailView: View {
    @Binding var data: HotelData
    @FocusState private var focusedField: HotelField?
    
    enum HotelField {
        case hotelName, roomType, address, cost, notes
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Hotel Information")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Hotel Name", text: $data.hotelName)
                            .padding()
                            .background(focusedField == .hotelName ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                            )
                            .focused($focusedField, equals: .hotelName)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Room Type", text: $data.roomType)
                            .padding()
                            .background(focusedField == .roomType ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .focused($focusedField, equals: .roomType)
                            .placeholder(when: data.roomType.isEmpty) {
                                Text("e.g., Standard King, Suite").foregroundColor(.gray.opacity(0.6))
                            }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Hotel Address", text: $data.address, axis: .vertical)
                            .padding()
                            .background(focusedField == .address ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .lineLimit(2...4)
                            .focused($focusedField, equals: .address)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Stay Dates")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    DatePicker("Check-in Date", selection: $data.checkInDate, displayedComponents: .date)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.6), lineWidth: 1.1)
                        )
                    
                    DatePicker("Check-out Date", selection: $data.checkOutDate, displayedComponents: .date)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Additional Details")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Cost:")
                                .font(.body)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        TextField("0.00", value: $data.cost, format: .currency(code: "USD"))
                            .padding()
                            .background(focusedField == .cost ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .keyboardType(.decimalPad)
                            .focused($focusedField, equals: .cost)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Notes", text: $data.notes, axis: .vertical)
                            .padding()
                            .background(focusedField == .notes ? Color(.systemGray6) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                            )
                            .lineLimit(3...6)
                            .focused($focusedField, equals: .notes)
                            .placeholder(when: data.notes.isEmpty) {
                                Text("Additional notes...").foregroundColor(.gray.opacity(0.6))
                            }
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Booking Status")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Hotel Booked:")
                                .font(.body)
                                .fontWeight(.medium)
                            Spacer()
                            Toggle("", isOn: $data.isBooked)
                                .toggleStyle(SwitchToggleStyle(tint: .blue))
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                        )
                        
                        if data.isBooked {
                            VStack(alignment: .leading, spacing: 8) {
                                TextField("Booking Reference", text: $data.bookingReference)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                    )
                                    .placeholder(when: data.bookingReference.isEmpty) {
                                        Text("e.g., HOTEL123456").foregroundColor(.gray.opacity(0.6))
                                    }
                            }
                        }
                    }
                }
            }
        }
    }
}