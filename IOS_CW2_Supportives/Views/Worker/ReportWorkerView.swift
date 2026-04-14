// ReportWorkerView.swift
// IOS_CW2_Supportives

import SwiftUI
import Combine


struct ReportWorkerView: View {
    let worker: Worker
    let onSubmit: (String, String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var selectedReason: ReportReason? = nil
    @State private var details: String               = ""
    @State private var submitted                     = false

    var body: some View {
        NavigationStack {
            if submitted {
                // Confirmation
                VStack(spacing: SPSpacing.xl) {
                    Spacer()
                    ZStack {
                        Circle().fill(Color.spEmerald.opacity(0.1)).frame(width: 90, height: 90)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 48)).foregroundStyle(Color.spEmerald)
                    }
                    VStack(spacing: SPSpacing.sm) {
                        Text("Report Submitted").font(SPFont.title3()).foregroundStyle(Color.spSlate900)
                        Text("Thank you for helping keep Supportives safe.\nWe'll review your report within 24 hours.")
                            .font(SPFont.callout()).foregroundStyle(Color.spSlate600).multilineTextAlignment(.center)
                    }
                    PrimaryButton(title: "Done") { dismiss() }
                        .frame(maxWidth: 220)
                    Spacer()
                }
                .padding(SPSpacing.xl)
            } else {
                Form {
                    Section {
                        // Worker info
                        HStack(spacing: SPSpacing.md) {
                            WorkerAvatarView(worker: worker, size: 44, showBadge: false)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Reporting: \(worker.name)")
                                    .font(SPFont.headline()).foregroundStyle(Color.spSlate900)
                                Text("Please choose the reason below.")
                                    .font(SPFont.footnote()).foregroundStyle(Color.spSlate600)
                            }
                        }
                    }

                    Section("Reason for Report") {
                        ForEach(ReportReason.allCases) { reason in
                            HStack {
                                Label(reason.rawValue, systemImage: reason.icon)
                                    .foregroundStyle(Color.spSlate900)
                                Spacer()
                                if selectedReason == reason {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.spIndigo)
                                }
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { selectedReason = reason }
                        }
                    }

                    Section("Additional Details (Optional)") {
                        TextEditor(text: $details)
                            .frame(minHeight: 80)
                            .font(SPFont.callout())
                            .foregroundStyle(Color.spSlate900)
                    }

                    Section {
                        Button("Submit Report") { submit() }
                            .font(SPFont.headline())
                            .foregroundStyle(selectedReason == nil ? Color.spSlate600 : Color.spRose)
                            .frame(maxWidth: .infinity)
                            .disabled(selectedReason == nil)
                    }
                }
                .navigationTitle("Report Provider")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }.foregroundStyle(Color.spIndigo)
                    }
                }
            }
        }
    }

    private func submit() {
        guard let reason = selectedReason else { return }
        onSubmit(reason.rawValue, details)
        withAnimation(.spring()) { submitted = true }
    }
}
