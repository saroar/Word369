//
//  WelcomeView.swift
//  
//
//  Created by Saroar Khandoker on 22.11.2021.
//

import SwiftUI
import ComposableArchitecture

public struct WelcomeState: Equatable {
  var selectedPage = 0
  @BindableState var startHour = Calendar.current
    .date(bySettingHour: 9, minute: 00, second: 0, of: Date())!
  @BindableState var endHour = Calendar.current
    .date(bySettingHour: 20, minute: 00, second: 0, of: Date())!

  var wordReminderCounter: Int = 9
  var name: String = ""

  public init() {}

}

extension WelcomeState{
  var view: WelcomeView.ViewState {
    get { .init(state: self) }
    set {
      self.selectedPage = newValue.selectedPage
      self.startHour = newValue.startHour
      self.endHour = newValue.endHour
      self.wordReminderCounter = newValue.wordReminderCounter
      self.name = newValue.name
    }
  }
}

public enum WelcomeAction: BindableAction, Equatable {
  case binding(BindingAction<WelcomeState>)

  case selectedPageButtonTapped

  case incrementWordReminderButtonTapped
  case decrementWordReminderButtonTapped

  case incrementStartHourButtonTapped
  case decrementStartHourButtonTapped

  case incrementEndHourButtonTapped
  case decrementEndHourButtonTapped

}

extension WelcomeAction {
  init(action: WelcomeView.ViewAction) {
    switch action {
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

    }
  }
}

public struct WelcomeEnvironment {}
extension WelcomeEnvironment {
  static public var live: WelcomeEnvironment = .init()
}

public let welcomeReducer = Reducer<
  WelcomeState, WelcomeAction, WelcomeEnvironment
> { state, action, environment in

  switch action {

  case .binding:
    return .none

  case .selectedPageButtonTapped:
    if state.selectedPage >= 0 {
      withAnimation { state.selectedPage += 1 }
    }

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

    return .none

  case .decrementStartHourButtonTapped:
    state.startHour = Calendar.current
      .date(byAdding: .hour, value: -1, to: state.startHour)!

    return .none

  case .incrementEndHourButtonTapped:
    state.endHour = Calendar.current
      .date(byAdding: .hour, value: 1, to: state.endHour)!

    return .none
  case .decrementEndHourButtonTapped:
    state.endHour = Calendar.current
      .date(byAdding: .hour, value: -1, to: state.endHour)!

    return .none

  }
}
.binding()

struct WelcomeView: View {

  @Environment(\.scenePhase) private var scenePhase

  let store: Store<WelcomeState, WelcomeAction>

  struct ViewState: Equatable {

    var selectedPage = 0
    @BindableState var startHour = Calendar.current
      .date(bySettingHour: 9, minute: 00, second: 0, of: Date())!
    @BindableState var endHour = Calendar.current
      .date(bySettingHour: 20, minute: 00, second: 0, of: Date())!

    var wordReminderCounter: Int = 9
    var name: String = ""

    public init(state: WelcomeState) {
      self.selectedPage = state.selectedPage
      self.startHour = state.startHour
      self.endHour = state.endHour
      self.wordReminderCounter = state.wordReminderCounter
      self.name = state.name
    }

  }

  enum ViewAction: BindableAction {
    case binding(BindingAction<ViewState>)
    case selectedPageButtonTapped

    case incrementWordReminderButtonTapped
    case decrementWordReminderButtonTapped

    case incrementStartHourButtonTapped
    case decrementStartHourButtonTapped

    case incrementEndHourButtonTapped
    case decrementEndHourButtonTapped
  }

  public init(store: Store<WelcomeState, WelcomeAction>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(self.store.scope(state: ViewState.init, action: WelcomeAction.init )) { viewStore in
      VStack {
        Image(systemName: "clock.arrow.2.circlepath")
          .resizable()
          .scaledToFill()
          .frame(width: 150, height: 150, alignment: .center)

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
        .padding()

      }
      .onChange(of: scenePhase) { phase in
        switch phase {
        case .background:
          print("background")
        case .inactive:
          print("inactive")
        case .active:
          print("active")
        @unknown default:
          print("default")
        }
      }
    }
  }

}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
      WelcomeView(
        store: Store(
          initialState: WelcomeState(),
          reducer: welcomeReducer,
          environment: WelcomeEnvironment())
      )
    }
}
