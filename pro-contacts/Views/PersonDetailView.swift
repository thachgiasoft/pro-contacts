//
//  PersonDetailView.swift
//  pro-contacts
//
//  Created by Fiyinfoluwa Adebayo on 15/01/2020.
//  Copyright © 2020 Kompilab Limited. All rights reserved.
//

import SwiftUI

struct PersonDetailView: View {
    var person: Person

    @EnvironmentObject var session: FirebaseSession

    @State private var openEditForm: Bool = false
    @State private var openMail: Bool = false
    @State private var openWhatsapp: Bool = false
    @State private var confirmDelete: Bool = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            VStack(alignment: .center, spacing: 20) {
                ZStack(alignment: .center) {
                    Circle()
                        .fill(Color("gray"))
                        .frame(width: 100, height: 100, alignment: .center)
                    HStack(spacing: 0) {
                        Text(person.firstName.prefix(1).uppercased())
                        Text(person.lastName.prefix(1).uppercased())
                    }
                    .font(Font.custom("HelveticaNeue-Medium", size: 40))
                    .foregroundColor(Color.white)
                }

                Text("\(person.suffix) \(person.firstName) \(person.lastName)")
                    .font(Font.custom(Constants.Font.titleMed, size: 18))
                    .foregroundColor(Color("text"))

                Group {
                    if !person.country.isEmpty {
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "mappin")
                                .imageScale(.medium)
                            Text(person.country)
                                .font(Font.custom(Constants.Font.main, size: 16))
                                .foregroundColor(Color("text"))
                        }
                    }
                }

                VStack {
                    TextRowNoTitle(content: person.jobTitle)
                    TextRowNoTitle(content: person.department)
                    TextRowNoTitle(content: person.company)
                }
                .font(Font.custom(Constants.Font.main, size: 14))
                .foregroundColor(Color("gray"))

                HStack(alignment: .center, spacing: 30) {
                    Button(action: { Functions().phoneCallAction("\(self.person.phoneCode)\(self.person.phoneNumber)") }) {
                        VStack(alignment: .center, spacing: 10) {
                            Image(systemName: "phone.fill")
                                .imageScale(.large)
                                .accessibility(label: Text("Call"))
                        }
                    }

                    Group {
                        if !person.email.isEmpty {
                            Button(action: { self.openMail.toggle() }) {
                                VStack(alignment: .center, spacing: 10) {
                                    Image(systemName: "envelope.fill")
                                        .imageScale(.large)
                                        .accessibility(label: Text("Email"))
                                }
                                .alert(isPresented: self.$openMail) {
                                    Alert(
                                        title: Text("Compose Mail"),
                                        message: Text("Send an email to \(self.person.firstName) on \(self.person.email)?"),
                                        primaryButton: .default(Text("Yes")) {
                                            Functions().openUrl("mailto:\(self.person.email)")
                                        },
                                        secondaryButton: .cancel())
                                }
                            }
                        }
                    }

                    VStack(alignment: .center, spacing: 5) {
                        Image("whatsapp.dk")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .onTapGesture {
                                self.openWhatsapp.toggle()
                        }
                    }
                    .alert(isPresented: self.$openWhatsapp) {
                        Alert(
                            title: Text("Open WhatsApp"),
                            message: Text("Message \(self.person.firstName) on \(self.person.phoneNumber)?"),
                            primaryButton: .default(Text("Open")) {
                                Functions().openUrl("https://api.whatsapp.com/send?phone=234\(self.person.phoneNumber)")
                            },
                            secondaryButton: .cancel())
                    }
                }
                .accentColor(Color("text"))

                HStack {
                    Spacer()
                }.padding(0)
            }

            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Spacer()
                }

                TextRow(label: "Phone", content: "\(person.phoneCode) \(person.phoneNumber)")
                TextRow(label: "Email", content: person.email)
                TextRow(label: "Website", content: person.website)

                Text("Work")
                    .font(Font.custom(Constants.Font.title, size: 14))
                    .foregroundColor(Color("text"))
                    .padding(.top, 10)
                Group {
                    TextRow(label: "Job Title", content: person.jobTitle)
                    TextRow(label: "Department", content: person.department)
                    TextRow(label: "Company", content: person.company)
                    TextRow(label: "Industry", content: person.industry)
                    TextRow(label: "Work Mail", content: person.workEmail)
                    TextRow(label: "Work Phone", content: "\(person.workPhoneCode)\(person.workPhoneNumber)")
                }.padding(.leading, 10)

                Text("Social Profiles")
                    .font(Font.custom(Constants.Font.title, size: 14))
                    .foregroundColor(Color("text"))
                    .padding(.top, 10)
                Group {
                    SocialRow(type: "skype", content: person.skype)
                    SocialRow(type: "linkedin", content: person.linkedin)
                    SocialRow(type: "github", content: person.github)
                    SocialRow(type: "medium", content: person.medium)
                    SocialRow(type: "twitter", content: person.twitter)
                    SocialRow(type: "facebook", content: person.facebook)
                    SocialRow(type: "instagram", content: person.instagram)
                }.padding(.horizontal, 10)

                Group {
                    TextRow(label: "Notes", content: person.notes)

                    VStack(alignment: .leading, spacing: 5) {
                        Label(text: "Created On")
                        Text(Functions().parseEpochTime(person.createdAt))
                            .font(Font.custom(Constants.Font.main, size: 14))
                            .foregroundColor(Color("gray"))
                    }

                    if (person.createdAt != person.updatedAt) {
                        VStack(alignment: .leading, spacing: 5) {
                            Label(text: "Modified On")
                            Text(Functions().parseEpochTime(person.updatedAt))
                                .font(Font.custom(Constants.Font.main, size: 14))
                                .foregroundColor(Color("gray"))
                        }
                    }
                }
            }
            .padding()

            Button(action: {
                self.confirmDelete.toggle()
            }) {
                HStack(alignment: .center, spacing: 10) {
                    Spacer()
                    Text("Delete Contact")
                    Spacer()
                }
                .alert(isPresented: self.$confirmDelete) {
                    Alert(
                        title: Text("Delete Contact"),
                        message: Text("Permanently delete \(self.person.firstName) \(self.person.lastName) from your professional contacts?"),
                        primaryButton: .destructive(Text("Delete Now")) {
                            self.session.deleteContact(id: self.person.id)
                        },
                        secondaryButton: .cancel())
                }
            }
            .font(Font.custom(Constants.Font.main, size: 14))
            .foregroundColor(Color("danger"))
            .padding()
            .background(Color("danger").opacity(0.05))
            .cornerRadius(10)
            .padding()
        }
        .navigationBarItems(
            trailing: Button(action: { self.openEditForm.toggle() }) {
                Text("Edit")
            }
        )
        .sheet(isPresented: $openEditForm, content: {
            PersonFormView(person: self.person)
                .environmentObject(FirebaseSession())
        })
    }
}

struct TextRowNoTitle: View {
    var content: String

    var body: some View {
        Group {
            if !content.isEmpty {
                Text(content)
            }
        }
    }
}

struct TextRow: View {
    var label: String
    var content: String

    var body: some View {
        Group {
            if !content.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Label(text: label)
                    Text(content)
                        .font(Font.custom(Constants.Font.main, size: 16))
                        .foregroundColor(Color("text"))
                }
            }
        }
    }
}

struct SocialRow: View {
    var type: String
    var content: String

    var body: some View {
        Group {
            if !content.isEmpty {
                HStack(alignment: .center, spacing: 5) {
                    Image(type)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20, alignment: .center)
                    Text("instagram medium twitter".contains(type) ? "@\(content)" : content)
                        .font(Font.custom(Constants.Font.main, size: 14))
                        .foregroundColor(Color("social.\(type)"))
                    Spacer()
                    Group {
                        if type != "skype" {
                            Image(systemName: "arrow.up.right")
                                .imageScale(.large)
                                .foregroundColor(Color("gray"))
                        }
                    }
                }
                .padding(10)
                .onTapGesture {
                    Functions().openSocialUrl(self.type, self.content)
                }
            }
        }
    }
}

struct PersonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailView(person: Person.init(firstName: "", lastName: "", email: "", phoneNumber: "", createdAt: 0, updatedAt: 0))
    }
}
