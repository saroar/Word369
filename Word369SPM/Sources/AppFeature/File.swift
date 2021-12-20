////
////  File.swift
////
////
////  Created by Saroar Khandoker on 25.11.2021.
////
//
//import ComposableArchitecture
//import CoreData
//
///**
// Namespace for structs of classes annotated with AsValue.
//*/
//public enum ThreadSafe {
//    /**
//     The struct equivalent of Account. Use this data structure if you want an instance of Account with
//     value type semantics.
//    */
//    public struct Account: Hashable, Identifiable, Model {
//
//        /**
//         The NSFetchRequest of MyApp.Account.
//        */
//        public static var fetchRequest: NSFetchRequest<MyApp.Account> {
//            return MyApp.Account.fetchRequest()
//        }
//
//        public var id: ThreadSafe.Account {
//            return self
//        }
//
//        /**
//         The NSManagedObjectID of the Core Data entity this struct represents if that entity is managed by a persistent store. Otherwise this is nil,
//         meaning the Core Data entity this represents is currently unmanaged.
//        */
//        public var objectID: NSManagedObjectID?
//
//        /**
//         Identical property of Account's name.
//        */
//        public var name: String?
//        /**
//         Identical property of Account's startingBalance.
//        */
//        public var startingBalance: Double
//        /**
//         Identical property of Account's transactions.
//        */
//        public var transactions: Set<Transaction>?
//
//        /**
//          Transforms the Account struct into its mirrored NSManagedObject subclass
//          - parameter context: NSManagedObjectContext where the generated entity is inserted to.
//          - returns: An Account with identical properties as this instance.
//        */
//        public func asEntity(in context: NSManagedObjectContext) -> MyApp.Account  {
//            let entity: MyApp.Account = MyApp.Account(context: context)
//            entity.name = self.name
//            entity.startingBalance = self.startingBalance
//            entity.transactions = Set(self.transactions?.map { $0.asEntity(in: context)} ?? [])
//            return entity
//        }
//    }
//
//extension Account {
//
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Account> {
//        return NSFetchRequest<Account>(entityName: "Account")
//    }
//
//    @NSManaged public var name: String?
//    @NSManaged public var startingBalance: Double
//    @NSManaged public var transactions: Set<Transaction>?
//
//}
//
//public struct AccountState: Equatable {
//    public var accounts: [ThreadSafe.Account]
//}
//
//public enum AccountAction: Equatable {
//    case addAccount(ThreadSafe.Account)
//    case deleteAccount(NSManagedObjectID)
//    case fetchAccounts
//    case getAccounts(Result<[ThreadSafe.Account], Error>)
//    case updateAccount(ThreadSafe.Account, NSManagedObjectID)
//
//    public static func == (lhs: AccountAction, rhs: AccountAction) -> Bool {
//        switch (lhs, rhs) {
//            case let (.addAccount((lValue)), .addAccount((rValue))):
//                return lValue == rValue
//            case (.fetchAccounts, .fetchAccounts):
//                return true
//            case let (.getAccounts(.success(lValue)), .getAccounts(.success(rValue))):
//                return lValue == rValue
//            case let (.getAccounts(.failure(lValue)), .getAccounts(.failure(rValue))):
//                return lValue.localizedDescription == rValue.localizedDescription
//                case let (.updateAccount(lValue, lID), .updateAccount(rValue, rID)):
//                return lValue.name == rValue.name && lID == rID
//            case let (.deleteAccount(lValue), .deleteAccount(rValue)):
//                return lValue == rValue
//            default:
//                return false
//        }
//    }
//}
//
//public struct AccountEnvironment {
//    public var backgroundQueue: AnySchedulerOf<DispatchQueue>
//    public var mainQueue: AnySchedulerOf<DispatchQueue>
//    public var repository: AccountRepository
//}
//
//public let accountReducer = Reducer<AccountState, AccountAction, AccountEnvironment> {
//    (state: inout AccountState, action: AccountAction, env: AccountEnvironment) -> Effect<AccountAction, Never> in
//    switch action {
//        case .addAccount(let newAccount):
//            return env.repository.create(model: newAccount)
//                .subscribe(on: env.backgroundQueue)
//                .receive(on: env.mainQueue)
//                .catchToEffect()
//                .map { _ in AccountAction.fetchAccounts }
//
//        case .deleteAccount(let id):
//            return env.repository.deleteModel(by: id)
//                .subscribe(on: env.backgroundQueue)
//                .receive(on: env.mainQueue)
//                .catchToEffect()
//                .map { _ in AccountAction.fetchAccounts }
//
//        case .fetchAccounts:
//            return env.repository.getAll()
//                .subscribe(on: env.backgroundQueue)
//                .receive(on: env.mainQueue)
//                .catchToEffect()
//                .map(AccountAction.getAccounts)
//
//        case .getAccounts(let result):
//            if case let .success(accounts) = result {
//                state.accounts = accounts
//            }
//            return .none
//
//        case let .updateAccount(account, id):
//            return env.repository.update(model: account, id: id)
//                .subscribe(on: env.backgroundQueue)
//                .receive(on: env.mainQueue)
//                .catchToEffect()
//                .map { _ in AccountAction.fetchAccounts }
//    }
//}
//
//public final class AccountRepository: Repository {
//
//    public init(context: NSManagedObjectContext) {
//        self.context = context
//    }
//
//    // MARK: Stored Properties
//    public let context: NSManagedObjectContext
//
//    // MARK: Methods
//
//    public func getAll() -> Effect<[ThreadSafe.Account], Error> {
//        let context = self.context
//        return Effect<[ThreadSafe.Account], Error>.future { [context] (result: @escaping (Result<[ThreadSafe.Account], Error>) -> Void) -> Void in
//            context.performAndWait { [context] () -> Void in
//                result(
//                    Result<[ThreadSafe.Account], Error> {
//                        let accounts = try context.fetch(RepositoryModel.fetchRequest)
//                        return accounts.map(\.asValue)
//                    }
//                )
//            }
//        }
//    }
//
//    public func create(model: ThreadSafe.Account) -> Effect<Void, Error> {
//        let context = self.context
//        return Effect<Void, Error>.result { [context] () -> Result<Void, Error> in
//            Result<Void, Error> {
//                _ = model.asEntity(in: context)
//                try context.save()
//            }
//        }
//    }
//
//    public func deleteModel(by id: NSManagedObjectID) -> Effect<Void, Error> {
//        let context = self.context
//        return Effect<Void, Error>.result { [context] () -> Result<Void, Error> in
//            Result<Void, Error> {
//                let object = context.object(with: id)
//                context.delete(object)
//                try context.save()
//            }
//        }
//    }
//
//    public func update(model: ThreadSafe.Account, id: NSManagedObjectID) -> Effect<Void, Error> {
//        let context = self.context
//        return Effect<Void, Error>.result { [context] () -> Result<Void, Error> in
//            Result<Void, Error> {
//                guard let databaseModel = context.object(with: id) as? Account else { fatalError() }
//                databaseModel.name = model.name
//                try context.save()
//            }
//        }
//    }
//
//}
