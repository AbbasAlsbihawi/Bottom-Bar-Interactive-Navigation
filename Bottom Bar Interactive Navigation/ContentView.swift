//
//  ContentView.swift
//  Bottom Bar Interactive Navigation
//
//  Created by Abbas on 27/11/2024.
//

import SwiftUI

@Observable
class NavigationHelper :NSObject ,UIGestureRecognizerDelegate{
    var path : NavigationPath = .init()
    var  popProgress : CGFloat = 1.0

    // properties
    private var isAdded : Bool = false
    private var navController : UINavigationController?


    
    func addPopGestureListener(_ controller :UINavigationController) {
        guard !isAdded else { return }
        controller.interactivePopGestureRecognizer?.addTarget(self, action: #selector(handlePopGesture))
        navController = controller
        // optional
        controller.interactivePopGestureRecognizer?.delegate = self
        isAdded = true

    }

    @objc 
    func handlePopGesture(){
        if let  completionProgress = navController?.transitionCoordinator?.percentComplete, let state = navController?.interactivePopGestureRecognizer?.state,navController?.viewControllers.count == 1 {
             popProgress = completionProgress
            if state == .ended || state == .cancelled {
                if completionProgress > 0.5 {
                   popProgress = 1
                }  else {
                    popProgress = 0
                }
            }
            
        }
    }
    /// this will make interactive pop gesture work only when there is more than one view controller in the navigation stack
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
         navController?.viewControllers.count ?? 0 > 1
    }
    
}

struct ContentView: View {
    var navigationHelper = NavigationHelper()

    var body: some View {
        VStack(spacing:0){
            @Bindable var bindableHelper = navigationHelper
            NavigationStack(path: $bindableHelper.path){
                List{
                    Button{
                     navigationHelper.path.append("Post1")
                    } label: {
                        Text("Post 1")
                        .foregroundStyle(Color.primary)
                    }  
                }
                .navigationTitle("Home")
                .navigationDestination(for: String.self){ navigationTitle in
                    List{
                        Button{
                         navigationHelper.path.append("Post1")
                        } label: {
                            Text("Post 1")
                            .foregroundStyle(Color.primary)
                        }
                    }
                    .navigationTitle(navigationTitle)
                    .toolbarVisibility(.hidden, for: .navigationBar)
                }
            } 
            .ViewExtractor{  
                if let navController = $0.next as? UINavigationController  {
                    navigationHelper.addPopGestureListener(navController)
                }
                
            }
            CustomBottomBar() 
        }
        .environment(navigationHelper)
    }
}

struct CustomBottomBar: View {
     
    @Environment(NavigationHelper.self) private  var navigationHelper
    @State private var selectedTab: TabModel = .home
    var body: some View {
        HStack(spacing:0){
            let blur = (1 - navigationHelper.popProgress) * 3
            let scale = (1 - navigationHelper.popProgress) * 0.1


            ForEach(TabModel.allCases, id: \.self) { tab in
                Button {
                    if tab == .newPost {
                        
                    }else{
                        selectedTab = tab
                    }
                }  label: {
                    Image(systemName: tab.rawValue)
                        .font(.title3)
                        .foregroundStyle(selectedTab == tab || tab == .newPost ? Color.primary : Color.gray)
                        .blur(radius: tab != .newPost ? blur : 0)
                        .scaleEffect(tab == .newPost ? 1.5: 1 - scale )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .contentShape(.rect)
                }
                .opacity(tab != .newPost ?  navigationHelper.popProgress : 1)
                .overlay{
                    ZStack{
                    if tab == .home {
                         Button{ 
                         }
                            label: {
                               Image(systemName: "exclamationmark.bubble")
                               .font(.title3)
                               .foregroundStyle(selectedTab == tab ? Color.primary : Color.gray)
                             
                    } 
                    }
                    if tab == .settings {
                         Button{ 
                         }
                            label: {
                               Image(systemName: "ellipsis.circle.fill")
                               .font(.title3)
                               .foregroundStyle(selectedTab == tab ? Color.primary : Color.gray)   
                    } 
                 }
                 }
                 .opacity(1 - navigationHelper.popProgress)
                }
            }
        }
        .onChange(of: navigationHelper.path) {oldValue, newValue in
            guard newValue.isEmpty || oldValue.isEmpty else { return}
            if newValue.count > oldValue.count {
                 navigationHelper.popProgress = 0.0
            }else{ 
                navigationHelper.popProgress = 1.0
            }  
        }
        .animation(.easeInOut(duration: 0.25), value: navigationHelper.popProgress)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}




enum TabModel:String ,CaseIterable {
    case home = "house.fill"
    case search = "magnifyingglass"
    case newPost = "plus.app.fill"
    case notification = "bell.fill"
    case settings = "gearshape.fill"
}
