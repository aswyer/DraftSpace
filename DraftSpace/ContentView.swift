//
//  ContentView.swift
//  DraftSpace
//
//  Created by Andrew Sawyer on 2/11/23.
//



import SwiftUI
import RealityKit
import ARKit
import Sliders

extension Color {
    static let lightGray = Color(red: 220/255, green:220/255, blue: 220/255)
    static let mauve = Color(red: 77/255, green:14/255, blue:60/255)
}

struct ContentView: View {
    @ObservedObject var model: MainModel
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(model: model)
                .edgesIgnoringSafeArea(.all)
                .gesture(
                    MagnificationGesture()
                        .onChanged({ newValue in
                            model.size = min(
                                max(0.05, model.size + Float(newValue.magnitude - 1)/50),
                                0.8
                            )
                        })
                )
            
            VStack(){
                HStack{
                    Text("\(model.size)")
                    Spacer()
                    Picker("",selection: $model.viewType) {
                        Text("AR").tag(ViewType.AR)
                        Text("3D").tag(ViewType.ThreeD)
                    }.pickerStyle(SegmentedPickerStyle())
                        .padding()
                        .frame(maxWidth:200)
                    Spacer()
                    Button {
                        model.reset()
                    } label: {
                        Image(systemName: "trash.fill").font(.largeTitle)
                    }

                    SettingsButton(model: model)
                }.padding()
                Spacer()
                HStack() {
                    Spacer()
                    ActionButton(model: model)
                        .padding()
                    DepthSlider(model: model, sliderHeight: 0)
                        .padding()
                        .frame(maxWidth: 50, maxHeight:150)
                    
                }
                HStack(){
                    ToolBar(model: model)
                }
                .padding()
                
            }
        }.accentColor(model.baseColor)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(model: MainModel())
    }
}

struct ToolBar: View {
    @ObservedObject var model: MainModel
    @State private var rotation = 0.0
    var body: some View {
        HStack{
            ForEach(ToolType.allCases, id: \.self) { buttonType in
                Button{
                    withAnimation(.easeIn) {
                        if(model.canChangeTool) {
                            model.buttonSelected = buttonType
                        }
                    }
                } label: {
                    Image(systemName: buttonType.imageName)
                        .font(Font.system(.largeTitle))
                }
                .padding()
                .background(buttonType == model.buttonSelected ? .thickMaterial: .ultraThinMaterial)
                .clipShape(Capsule())
                
                .padding()
                
            }
            Divider().frame(maxHeight:60).padding()
            HStack{
                ColorPicker("",selection: $model.objectColor)
                    .labelsHidden()
                    .padding()
                Group() {
                    switch(model.buttonSelected) {
                    case .sphere:
                        Button(""){}
                    case .cube:
                        Button(""){}
                    case .text:
                        TextField("Text:", text: $model.text)
                    case .pencil:
                        Button(""){}
                    case .highlighter:
                        Button(""){}
                    case .mouse:
                        Button{
                            withAnimation() {
                                model.moveSelected.toggle()
                                model.canChangeTool.toggle()
                                rotation = 180
                            }
                        }label: {
                            if(!model.moveSelected) {
                                Image(systemName: "arrow.up.and.down.and.arrow.left.and.right" ).font(.largeTitle)
                            }
                            else {
                                Image(systemName: "x.circle")
                                    .font(.largeTitle)
                                    .foregroundColor(.red)
                            }
                            
                            
                        }.padding()
                        
                        
                    }
                }.transition(.scale)
            }.background(.ultraThinMaterial)
                .clipShape(Capsule())
        }
        .padding()
        //  .background(.red)
        .cornerRadius(20)
        .padding()
    }
    
    
}

struct DepthSlider: View {
    @ObservedObject var model: MainModel
    
    var sliderHeight: CGFloat
    
    var body: some View {
        
        ValueSlider(value: $model.depth, in: 0.1...1)
            .valueSliderStyle(
                VerticalValueSliderStyle(track: VerticalRangeTrack(view: Capsule().foregroundColor(.clear))
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                    .frame(width:30)
                )
            )
    }
}

struct ActionButton: View {
    @ObservedObject var model: MainModel
    @State var isDrawing = false
    var body: some View {
        Button {
            switch (model.buttonSelected) {
            case ToolType.pencil:
                if isDrawing {
                    model.stopDrawing()
                } else {
                    model.startDrawing()
                }
                isDrawing = !isDrawing
                
            case ToolType.mouse:
                onRelease()
                if(model.moveSelected) {
                    withAnimation(){
                        model.moveSelected.toggle()
                        model.canChangeTool.toggle()
                    }
                }
            case ToolType.highlighter:
                onRelease()
            case ToolType.sphere:
                model.confirmPlacement()
            case ToolType.text:
                model.confirmPlacement()
            case ToolType.cube:
                model.confirmPlacement()
            }
            
        }
    label: {
        Image(systemName:"button.programmable")
            .font(Font.system(size:65))
    }
        
        // .background(.ultraThinMaterial)
        
    }
    func onPress() {
        
    }
    func onRelease() {
        
    }
}

struct SettingsButton: View {
    @ObservedObject var model: MainModel
    @State private var rotation = 0.0
    @State private var showingPopover = false
    var body: some View {
        Button() {
            rotation += 180
            showingPopover = true
            
        } label: {
            Image(systemName: "gearshape.fill").font(.largeTitle)
        }
        .rotationEffect(.degrees(rotation))
        .animation(.interpolatingSpring(stiffness: 170, damping: 8).delay(0.1), value: rotation)
        .popover(isPresented: $showingPopover) {
            VStack(alignment: .leading){
                Text("Objects Placed: \(model.objectsPlaced)")
                    .padding()
                Text("Colloborators: \(model.collborators)")
                    .padding()
                ColorPicker("Choose your color:",selection:$model.baseColor)
                    .padding()
            }.padding()
            
        }
    }
}
