import SwiftUI

enum Direction {
    case up
    case down
}

@available(iOS 14, macOS 11.0, *)
public struct SwiftUIWheelPicker: View {
    @Binding var selectedIndex: Int
    var items: [String]
    var circleSize: Double
    @State private var radius : Double = 150
    @State private var direction = Direction.up
    @State private var degree : Double = 90.0

    var selectedDegree: Double {
        90.0 + Double(360/items.count) * Double(selectedIndex)
    }
    
    public init(selectedIndex: Binding<Int>, items: [String] = [], circleSize: Double){
        self._selectedIndex = selectedIndex
        self.items = items
        self.circleSize = circleSize
    }
        
    public var body: some View {
        ZStack{
            let anglePerCount = Double.pi * 2.0 / Double(items.count)
            let drag = DragGesture()
                .onEnded { value in
                    let impactHeavy = UIImpactFeedbackGenerator(style: .light)
                    impactHeavy.impactOccurred()
                    if value.startLocation.y > value.location.y + 10 {
                        direction = .up
                    } else if value.startLocation.y < value.location.y - 10  {
                        direction = .down
                    }
                    withAnimation(.spring()) {
                        if direction == .down {
                            degree -= Double(360/items.count)
                            if selectedIndex == 0 {
                                selectedIndex = items.count-1
                            } else {
                                selectedIndex -= 1
                            }
                        } else  {
                            degree += Double(360/items.count)
                            if selectedIndex == items.count-1 {
                                selectedIndex = 0
                            } else {
                                selectedIndex += 1
                            }
                        }
                    }
                }

            ZStack {
                Circle()
                    // .fill(.clear)
                    // .strokeBorder(.gray, lineWidth: 1)

                ForEach(0 ..< items.count, id: \.self) { index in
                    let angle = Double(index) * anglePerCount
                    let xOffset = CGFloat(radius * sin(angle))
                    let yOffset = CGFloat(radius * cos(angle))
                    Text("\(items[index])")
                        .rotationEffect(Angle(degrees: -degree))
                        .offset(x: xOffset, y: yOffset )
                        .font(Font.system(size: index == selectedIndex  ? 60 : 32))
                }
            }
            .rotationEffect(Angle(degrees: degree))
            .gesture(drag)
            .offset(x: circleSize / 2 )
            .onAppear() {
                radius = circleSize / 2
                degree += Double(360/items.count) * Double(selectedIndex)
            }
        }
        .frame(width: circleSize, height: circleSize * 2)
        .clipped(antialiased: true)
    }
    
}
