import SwiftUI

extension View {

    func loading(isShowing: Binding<Bool>, _ text: Text = Text("Loading...")) -> some View {
        LoadingView(isShowing: isShowing,
              presenting: { self },
              text: text)
    }

}

struct LoadingView<Presenting>: View where Presenting: View {

    /// The binding that decides the appropriate drawing in the body.
    @Binding var isShowing: Bool
    /// The view that will be "presenting" this toast
    let presenting: () -> Presenting
    /// The text to show
    let text: Text

    var body: some View {

        GeometryReader { geometry in

            ZStack(alignment: .center) {

                self.presenting()
                 .blur(radius: self.isShowing ? 1 : 0)
                
                
                /// black back
                if self.isShowing {
                    
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                }
                    

                VStack {
                    self.text
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .transition(.slide)
                .opacity(self.isShowing ? 1 : 0)

            }

        }
        

    }
}
