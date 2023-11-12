//
//  MainView.swift
//  WordScramble
//
//  Created by Yasser Bal on 12/11/2023.
//

import SwiftUI

struct MainView: View {
    @ObservedObject private var vm = MainViewModel()
    
    @State private var newWordIsAdded:Bool = false
    
    var body: some View {
        NavigationStack{
            VStack{
                List{
                    Section{
                        TextField("Enter your word", text:
                                    $vm.newWordInput)
                        .autocorrectionDisabled()
                    }
                    Section{
                        ForEach(vm.words,id:\.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Spacer()
                                Text(word)
                            }
                        }
                    }
                }
                HStack{
                    Text("Score: \(vm.score)")
                    Spacer()
                    Text("High score: \(vm.highScore)")
                }.padding(.horizontal,40)
                    .padding(.top)
            }
            .onSubmit(vm.addWord)
            .onAppear(perform:vm.newGame)
            .navigationTitle(vm.rootWord?.capitalized ?? "Starting game")
            .toolbar {
                Button("New game", action: vm.newGame)
            }
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
