import SwiftUI

struct TimelineHourView: View {
    let hour: Int
    let entry: Entry?
    let category: Category?
    let onAddEdit: () -> Void
    
    var timeString: String {
        return String(format: "%02d:00", hour)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Text(timeString)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .frame(width: 50, alignment: .trailing)
                .padding(.top, 12)
            
            VStack {
                Circle()
                    .fill(entry != nil ? Color(hex: category?.colorHex ?? "#808080") : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
                    .padding(.top, 14)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 2)
            }
            
            Button(action: onAddEdit) {
                HStack {
                    if let entry = entry {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(category?.name ?? "Unknown")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: category?.colorHex ?? "#ffffff"))
                                Spacer()
                                Text("\(entry.score)/100")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                            }
                            
                            if !entry.notes.isEmpty {
                                Text(entry.notes)
                                    .font(.footnote)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            
                            if !entry.tags.isEmpty {
                                HStack {
                                    ForEach(entry.tags.split(separator: ","), id: \.self) { tag in
                                        Text(tag.trimmingCharacters(in: .whitespaces))
                                            .font(.caption2)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.secondary.opacity(0.2))
                                            .cornerRadius(4)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(12)
                    } else {
                        HStack {
                            Text("No entry")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(12)
                    }
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(minHeight: 80)
    }
}
