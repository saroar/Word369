//
//  WelcomeView.swift
//  
//
//  Created by Saroar Khandoker on 22.11.2021.
//

import SwiftUI
import ComposableArchitecture
import ComposableUserNotifications
import WordFeature
import UserDefaultsClient
import SharedModels
import UserNotifications

public enum WelcomeTag: Equatable {
  case l, a, b
}

public struct WelcomeState: Equatable {
  
  @BindableState var selectedPage = WelcomeTag.l
  @BindableState var startHour = Calendar.current
    .date(bySettingHour: 9, minute: 00, second: 0, of: Date())!
  @BindableState var endHour = Calendar.current
    .date(bySettingHour: 20, minute: 00, second: 0, of: Date())!
  
  var wordReminderCounter: Int = 9
  @BindableState var name: String = ""
  @BindableState var isNameValid: Bool = false
  @BindableState var isBothLanguageEqual: Bool = true
  @BindableState var isContinueButtonValid: Bool = false
  
  @BindableState var currentLngCode = LanguageCode.bangla
  @BindableState var learnLangCode = LanguageCode.english
  
  public init() {}
  
}

extension WelcomeState {
  var view: WelcomeView.ViewState {
    get { .init(state: self) }
    set {
      // should be only bindable action
      self.selectedPage = newValue.selectedPage
      self.startHour = newValue.startHour
      self.endHour = newValue.endHour
      self.name = newValue.name
    }
  }
}

public enum WelcomeAction: BindableAction, Equatable {
  case onApper
  case binding(BindingAction<WelcomeState>)
  
  case selectedPageButtonTapped
  
  case incrementWordReminderButtonTapped
  case decrementWordReminderButtonTapped
  
  case incrementStartHourButtonTapped
  case decrementStartHourButtonTapped
  
  case incrementEndHourButtonTapped
  case decrementEndHourButtonTapped
  
  case moveToWordView
  
  case currentSelectedLanguage(LanguageCode)
  case learnSelectedLanguage(LanguageCode)
}

extension WelcomeAction {
  init(action: WelcomeView.ViewAction) {
    switch action {
    case .onApper:
      self = .onApper
      
    case let .binding(bindingAction):
      self = .binding(bindingAction.pullback(\WelcomeState.view))
      
    case .selectedPageButtonTapped:
      self = .selectedPageButtonTapped
      
    case .incrementWordReminderButtonTapped:
      self = .incrementWordReminderButtonTapped
      
    case .decrementWordReminderButtonTapped:
      self = .decrementWordReminderButtonTapped
      
    case .incrementStartHourButtonTapped:
      self = .incrementStartHourButtonTapped
      
    case .decrementStartHourButtonTapped:
      self = .decrementStartHourButtonTapped
      
    case .incrementEndHourButtonTapped:
      self = .incrementEndHourButtonTapped
      
    case .decrementEndHourButtonTapped:
      self = .decrementEndHourButtonTapped
      
    case .moveToWordView:
      self = .moveToWordView

    case let .currentSelectedLanguage(lang):
      self = .currentSelectedLanguage(lang)
      
    case let .learnSelectedLanguage(lang):
      self = .learnSelectedLanguage(lang)
      
    }
  }
}

public struct WelcomeEnvironment {
  
  var userNotificationClient: UserNotificationClient
  var userDefaultsClient: UserDefaultsClient
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var backgroundQueue: AnySchedulerOf<DispatchQueue>
  
  public init(
    userNotificationClient: UserNotificationClient,
    userDefaultsClient: UserDefaultsClient,
    mainQueue: AnySchedulerOf<DispatchQueue>,
    backgroundQueue: AnySchedulerOf<DispatchQueue>) {
      self.userNotificationClient = userNotificationClient
      self.userDefaultsClient = userDefaultsClient
      self.mainQueue = mainQueue
      self.backgroundQueue = backgroundQueue
    }
}

extension WelcomeEnvironment {
  static public var live: WelcomeEnvironment = .init(
    userNotificationClient: .live,
    userDefaultsClient: .live(),
    mainQueue: .main,
    backgroundQueue: .main
  )
  
  static public var mock: WelcomeEnvironment = .init(
    userNotificationClient: .mock(),
    userDefaultsClient: .noop,
    mainQueue: .immediate,
    backgroundQueue: .immediate
  )
}

public let welcomeReducer = Reducer<
  WelcomeState, WelcomeAction, WelcomeEnvironment
> { state, action, environment in
  
  switch action {
    
  case .onApper:
      print(UserDefaults.currentLanguage)
    
      if UserDefaults.currentLanguage.name.isEmpty {
        state.currentLngCode = LanguageCode.list
          .filter { $0.code == Locale.current.regionCode?.lowercased() }
          .first ?? LanguageCode.bangla
          
          UserDefaults.currentLanguage = state.currentLngCode
      } else {
        state.currentLngCode = UserDefaults.currentLanguage
      }

    state.isBothLanguageEqual = state.currentLngCode == LanguageCode.english
    state.isContinueButtonValid = state.isBothLanguageEqual
    
    return .merge(
      environment.userDefaultsClient
        .setInteger(state.startHour.hour, UserDefaultKeys.startHour.rawValue)
        .fireAndForget(),
      
      environment.userDefaultsClient
        .setInteger(state.endHour.hour, UserDefaultKeys.endHour.rawValue)
        .fireAndForget()
    )
    
    
  case .binding(\.$name):
    state.name = String(state.name.prefix(9))
    state.isNameValid = state.name.count >= 6

    state.isContinueButtonValid = !state.isNameValid
    UserDefaults.username = state.name
    
    return environment.userDefaultsClient
      .setString(state.name, UserDefaultKeys.userName.rawValue)
      .receive(on: environment.mainQueue)
      .fireAndForget()
    
  case .binding:
    return .none
    
  case .selectedPageButtonTapped:
    switch state.selectedPage {
    case .l:
      withAnimation { state.selectedPage = .a }
      state.isContinueButtonValid = !state.isNameValid
      return .none
    case .a:
      withAnimation { state.selectedPage = .b }
      
      return .none
    case .b:
      return .merge(
        environment.userDefaultsClient
          .setBool(true, UserDefaultKeys.isWelcomeScreensFillUp.rawValue)
          .fireAndForget(),
        Effect(value: WelcomeAction.moveToWordView)
          .receive(on: environment.mainQueue.animation())
          .eraseToEffect()
      )
    }
    
  case .moveToWordView:
    return .none
    
  case .incrementWordReminderButtonTapped:
    state.wordReminderCounter += 1
    return .none
    
  case .decrementWordReminderButtonTapped:
    state.wordReminderCounter -= 1
    return .none
    
  case .incrementStartHourButtonTapped:
    state.startHour = Calendar.current
      .date(byAdding: .hour, value: 1, to: state.startHour)!
    
    let startHour = Calendar.current.component(.hour, from: state.startHour)
    
    return environment.userDefaultsClient
      .setInteger(startHour, UserDefaultKeys.startHour.rawValue)
      .fireAndForget()
    
  case .decrementStartHourButtonTapped:
    state.startHour = Calendar.current
      .date(byAdding: .hour, value: -1, to: state.startHour)!
    
    let startHour = Calendar.current.component(.hour, from: state.startHour)
    
    return environment.userDefaultsClient
      .setInteger(startHour, UserDefaultKeys.startHour.rawValue)
      .fireAndForget()
    
  case .incrementEndHourButtonTapped:
    state.endHour = Calendar.current
      .date(byAdding: .hour, value: 1, to: state.endHour)!
    let endHour = Calendar.current.component(.hour, from: state.endHour)
    
    return environment.userDefaultsClient
      .setInteger(endHour, UserDefaultKeys.endHour.rawValue)
      .fireAndForget()
    
  case .decrementEndHourButtonTapped:
    state.endHour = Calendar.current
      .date(byAdding: .hour, value: -1, to: state.endHour)!
    
    let endHour = Calendar.current.component(.hour, from: state.endHour)
    return environment.userDefaultsClient
      .setInteger(endHour, UserDefaultKeys.endHour.rawValue)
      .fireAndForget()
        
  case let .currentSelectedLanguage(lang):
    state.currentLngCode = lang
    UserDefaults.currentLanguage = lang
    state.isBothLanguageEqual = state.learnLangCode == lang
    state.isContinueButtonValid = state.isBothLanguageEqual
    
    return .none
    
  case let .learnSelectedLanguage(lang):
    state.learnLangCode = lang
    UserDefaults.learnLanguage = lang
    state.isBothLanguageEqual = state.currentLngCode == lang
    state.isContinueButtonValid = state.isBothLanguageEqual
    
    return .none

  }
}
.binding()

struct WelcomeView: View {
  
  let store: Store<WelcomeState, WelcomeAction>
  
  struct ViewState: Equatable {
    
    @BindableState var selectedPage: WelcomeTag
    @BindableState var startHour: Date
    @BindableState var endHour: Date
    
    var wordReminderCounter: Int
    @BindableState var name: String
    @BindableState var isNameValid: Bool
    
    @BindableState var currentLngCode: LanguageCode
    @BindableState var learnLangCode: LanguageCode
    @BindableState var isBothLanguageEqual: Bool
    @BindableState var isContinueButtonValid: Bool
    
    public init(state: WelcomeState) {
      self.selectedPage = state.selectedPage
      self.startHour = state.startHour
      self.endHour = state.endHour
      self.wordReminderCounter = state.wordReminderCounter
      self.name = state.name
      self.isNameValid = state.isNameValid
      self.currentLngCode = state.currentLngCode
      self.learnLangCode = state.learnLangCode
      self.isBothLanguageEqual = state.isBothLanguageEqual
      self.isContinueButtonValid = state.isContinueButtonValid
    }
    
  }
  
  enum ViewAction: BindableAction {
    case onApper
    case binding(BindingAction<ViewState>)
    case selectedPageButtonTapped
    
    case incrementWordReminderButtonTapped
    case decrementWordReminderButtonTapped
    
    case incrementStartHourButtonTapped
    case decrementStartHourButtonTapped
    
    case incrementEndHourButtonTapped
    case decrementEndHourButtonTapped
    
    case moveToWordView
    
    case currentSelectedLanguage(LanguageCode)
    case learnSelectedLanguage(LanguageCode)
  }
  
  public init(store: Store<WelcomeState, WelcomeAction>) {
    self.store = store
  }
  
  var body: some View {
    WithViewStore(self.store.scope(state: ViewState.init, action: WelcomeAction.init )) { viewStore in
      ZStack(alignment: .bottomTrailing) {
        TabView(selection: viewStore.binding(\.$selectedPage)) {
          WelcomeViewL(store: store).tag(WelcomeTag.l)
          WelcomeViewA(store: store).tag(WelcomeTag.a)
          WelcomeViewB(store: store).tag(WelcomeTag.b)
        }
        .tabViewStyle(PageTabViewStyle())
        
        Button {
          viewStore.send(.selectedPageButtonTapped)
        } label: {
          Text("Continue").font(.title3)
            .foregroundColor(.white)
            .frame(height: 10, alignment: .center)
            .padding()
        }
        .background(Color.orange)
        .clipShape(Capsule())
        .frame(height: 40, alignment: .center)
        .padding(.trailing, 16)
        .padding(.vertical, 16)
        .disabled(viewStore.state.isContinueButtonValid)
        .opacity(viewStore.state.isContinueButtonValid ? 0 : 1)
      }
      .onAppear { viewStore.send(.onApper) }
    }
    .debug()
  }
  
}

//struct WelcomeView_Previews: PreviewProvider {
//  static var previews: some View {
//    WelcomeView(
//      store: Store(
//        initialState: WelcomeState(),
//        reducer: welcomeReducer,
//        environment: WelcomeEnvironment())
//    )
//  }
//}

struct WelcomeViewA: View {
  
  let store: Store<WelcomeState, WelcomeAction>
  
  public init(store: Store<WelcomeState, WelcomeAction>) {
    self.store = store
  }
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Image(systemName: "pencil")
          .resizable()
          .scaledToFit()
          .padding(40)
        
        HStack {
          Image(systemName: "person")
            .resizable()
            .scaledToFit()
            .frame(width: 40, height: 40, alignment: .leading)
            .padding()
          Text("Enter your name please!").font(.title)
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
          
        }
        
        TextField("Sara", text: viewStore.binding(\.$name))
          .font(.title)
          .textFieldStyle(RoundedBorderTextFieldStyle())
        Spacer()
      }
      .padding()
    }
  }
}

struct WelcomeViewB: View {
  
  let store: Store<WelcomeState, WelcomeAction>
  
  public init(store: Store<WelcomeState, WelcomeAction>) {
    self.store = store
  }
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Image(systemName: "timelapse")
          .resizable()
          .scaledToFit()
          .padding(.top, 16)
        
        Text("\(viewStore.name) set your Words reminders")
          .font(.largeTitle)
          .layoutPriority(1)
          .lineLimit(nil)
          .multilineTextAlignment(.center)
          .fixedSize(horizontal: false, vertical: true)
          .padding()
        
        HStack {
          Text("How many")
          
          HStack {
            Button {
              viewStore.send(.decrementWordReminderButtonTapped)
            } label: {
              Image(systemName: "minus.square").font(.largeTitle)
            }
            
            Text("\(viewStore.state.wordReminderCounter)x")
              .font(.title)
              .lineLimit(nil)
              .multilineTextAlignment(.center)
              .minimumScaleFactor(0.75)
              .fixedSize(horizontal: true, vertical: false)
            
            Button {
              viewStore.send(.incrementWordReminderButtonTapped)
            } label: {
              Image(systemName: "plus.square").font(.largeTitle)
            }
          }
          .layoutPriority(1)
          .padding()
          
        }
        .font(.title2)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .background(Color.orange)
        .clipShape(Capsule())
        .padding(.horizontal)
        
        HStack {
          VStack {
            
            Button { viewStore.send(.incrementStartHourButtonTapped) } label: {
              Image(systemName: "plus").font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 30)
            }
            .padding()
            .background(Color(red: 0, green: 0, blue: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            
            DatePicker(
              LocalizedStringKey("Start Hour"),
              selection: viewStore.binding(\.$startHour),
              displayedComponents: [.hourAndMinute])
            
            Button { viewStore.send(.decrementStartHourButtonTapped) } label: {
              Image(systemName: "minus").font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 30)
            }
            .padding()
            .background(Color(red: 0, green: 0, blue: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .frame(maxWidth: .infinity)
            
          }
          
          HStack {
            Divider()
          }
          .frame(height: 200)
          
          VStack {
            
            Button {
              viewStore.send(.incrementEndHourButtonTapped)
            } label: {
              Image(systemName: "plus").font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 30)
            }
            .padding()
            .background(Color(red: 0, green: 0, blue: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            
            DatePicker(
              LocalizedStringKey("End Hour"),
              selection: viewStore.binding(\.$endHour),
              displayedComponents: [.hourAndMinute])
            
            Button {
              viewStore.send(.decrementEndHourButtonTapped)
            } label: {
              Image(systemName: "minus").font(.title)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: 30)
            }
            .padding()
            .background(Color(red: 0, green: 0, blue: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .frame(maxWidth: .infinity)
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.bottom, 100)
        
      }
    }
  }
}

struct WelcomeViewC: View {
  
  let store: Store<WelcomeState, WelcomeAction>
  
  public init(store: Store<WelcomeState, WelcomeAction>) {
    self.store = store
  }
  
  var body: some View {
    WithViewStore(self.store) { viewStore in
      VStack {
        Image(systemName: "sun.min")
          .resizable()
          .scaledToFit()
          .padding()
        
        Spacer()
      }
      .padding()
    }
  }
}


struct WelcomeViewL: View {
  
  let store: Store<WelcomeState, WelcomeAction>
  
  public init(store: Store<WelcomeState, WelcomeAction>) {
    self.store = store
  }
  
  func countryFlag(countryCode: String) -> String {
    let base = 127397
    var tempScalarView = String.UnicodeScalarView()
    for i in countryCode.utf16 {
      if let scalar = UnicodeScalar(base + Int(i)) {
        tempScalarView.append(scalar)
      }
    }
    return String(tempScalarView)
  }
  
  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      
      VStack {
        Text("Language choice").font(.largeTitle).bold()
          .padding()

        Menu(content: {
            ForEach(LanguageCode.list, id: \.self) { item in
              Button {
                viewStore.send(.currentSelectedLanguage(item))
              } label: {
                Text(item.description)
              }
            }
        }, label: {
          HStack {
            Text("Current")
              .font(.largeTitle)
              .foregroundColor(Color.green)
            Spacer()
            Text(countryFlag(countryCode: viewStore.currentLngCode.code.uppercased()))
              .font(.title)
            Text("⇡ \(viewStore.currentLngCode.nativeName.capitalized)").font(.title)
          }
        })
        
        Divider()
        
        Menu(content: {
            ForEach(LanguageCode.list, id: \.self) { item in
              Button {
                viewStore.send(.learnSelectedLanguage(item))
              } label: {
                Text(item.description)
              }
            }

        }, label: {
          HStack {
            Text("Learn")
              .font(.largeTitle)
              .foregroundColor(Color.green)
            Spacer()
            Text(countryFlag(countryCode: viewStore.learnLangCode.code.uppercased()))
              .font(.title)
            Text("⇡ \(viewStore.learnLangCode.nativeName.capitalized)").font(.title)
          }
        })
        
      }
      .padding()
    }
    
  }
  
}

extension UserDefaults {
  // MARK: - Words
  @UserDefaultPublished(UserDefaultKeys.currentLanguage.rawValue, defaultValue: LanguageCode.empty)
  public static var currentLanguage: LanguageCode

  @UserDefaultPublished(UserDefaultKeys.learnLanguage.rawValue, defaultValue: LanguageCode.empty)
  public static var learnLanguage: LanguageCode
}
