//
//  DetailView.swift
//  Transcribe
//
//  Created by Claudia Maciel on 8/19/20.
//  Copyright © 2020 Chad-Claudia-Matt. All rights reserved.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var noteController: NoteController
    @EnvironmentObject var audioRecorder: AudioRecorder
    
    var note: Note
    @State private var isShareSheetShowing = false
    @State private var showingAlert = false
    
    @State private var messageTextFieldContents = ""
    @State private var titleTextFieldContents = ""
    @State private var categoryTextFieldContents = ""
    
    var index: Int {return noteController.previewNotes.firstIndex(where: {$0.id == note.id})!}
    
    var body: some View {
        
        VStack {
            if note.title == "New Note" {
                VStack{
                    Form {
                        HStack {
                            Text("    Title     ").bold()
                            Divider()
                            TextField("Enter Title", text: $titleTextFieldContents)
                        }
                        HStack {
                            Text("Message").bold()
                            Divider()
                            TextView(text: $messageTextFieldContents).frame(numLines: 4)
                        }
                        HStack {
                            Text("Category").bold()
                            Divider()
                            TextField("Enter Category", text: $categoryTextFieldContents)
                        }
                        HStack {
                            Button(action: shareButton) {
                                Text("Share Message")
                            }
                            Spacer()
                            Button(action: saveButton2) {
                                Text("Save")
                            }
                            .alert(isPresented: $showingAlert) {
                                Alert(title: Text("\(note.title) is saved"), message: Text("You can continue editing"), dismissButton: .default(Text("Okay")))
                            }
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                }
            } else {
                Form {
                    HStack {
                        Text("    Title   ").bold()
                        Divider()
                        TextField("title", text: $titleTextFieldContents)
                    }.onAppear(perform: loadItemText)
                    HStack {
                        Text("Message").bold()
                        Divider()
                        TextView(text: $messageTextFieldContents).frame(numLines: 4)
                    }.onAppear(perform: loadItemText)
                    HStack {
                        Text("Category").bold()
                        Divider()
                        TextField("category", text: $categoryTextFieldContents)
                    }.onAppear(perform: loadItemText)
                    HStack {
                        Button(action: shareButton) {
                            Text("Share Message")
                        }
                        Spacer()
                        Button(action: saveButton) {
                            Text("Save")
                        }
                        .alert(isPresented: $showingAlert) {
                            Alert(title: Text("\(note.title) is saved"), message: Text("You can continue editing"), dismissButton: .default(Text("Okay")))
                        }
                    }.buttonStyle(BorderlessButtonStyle())
                }
            }

            RecordingsView(note: note)
                .padding(.top)
            
            Spacer()
            RecordView(note: note)
        }
        .navigationBarTitle(Text(note.title), displayMode: .inline)
    }
    
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func shareButton() {
        let url = self.getDocumentDirectory().appendingPathComponent("\(self.note.title).txt")
        
        do {
            try self.note.bodyText.write(to: url, atomically: true, encoding: .utf8)
            let input = try String(contentsOf: url)
            print(input)
        } catch {
            print(" Unable to write to file \(error.localizedDescription)")
        }
        
        isShareSheetShowing.toggle()
        
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true, completion: nil)
    }

    func saveButton() {
        self.noteController.updateTitle(for: self.note, to: self.titleTextFieldContents)
        self.noteController.updateMessage(for: self.note, to: self.messageTextFieldContents)
        self.noteController.updateCategory(for: self.note, to: self.categoryTextFieldContents)
        
        self.showingAlert = true
    }

    func saveButton2() {
        let newNote = Note(title: titleTextFieldContents, bodyText: messageTextFieldContents, audioFilename: "", category: categoryTextFieldContents)
        self.noteController.add(newNote)
        self.showingAlert = true
    }

    func loadItemText() {
        messageTextFieldContents = note.bodyText
        titleTextFieldContents = note.title
        categoryTextFieldContents = note.category
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(note: noteWithRecordings)
            .environmentObject(NoteController())
            .environmentObject(AudioRecorder())
            .environmentObject(AudioPlayer())
    }
}

let noteWithRecordings = Note(title: "First Note", bodyText: "This is my first note, this is so cool. SwiftUI is awesome!", audioFilename: "audioFile1.mp3", category: "First Note", recordings: [
    Recording(audioFileURL: URL(string: "a")!, textTranscript: "The quick brown fox jumps over the lazy dog.", duration: 23)
])
