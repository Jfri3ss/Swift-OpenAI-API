import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @State private var isSubscribing = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Text("Subscribe to access the AI Chatbot")
                .font(.largeTitle)
                .padding()
                .multilineTextAlignment(.center)

            Text("Subscribe for $4.99 per week to use the chatbot.")
                .font(.subheadline)
                .padding()
                .multilineTextAlignment(.center)

            Button(action: {
                purchaseSubscription()
            }) {
                Text("Subscribe with Apple Pay")
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 250, height: 50)
                    .background(Color.pink)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(isSubscribing)

            if isSubscribing {
                ProgressView()
                    .padding()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Subscription"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    func purchaseSubscription() {
        isSubscribing = true

        // Load your product request
        let productIdentifiers = Set(["CompassSub567890"])
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = SubscriptionManager.shared
        request.start()
    }
}

class SubscriptionManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = SubscriptionManager()

    override private init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    var product: SKProduct?

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if let subscriptionProduct = response.products.first {
            self.product = subscriptionProduct
            buyProduct(subscriptionProduct)
        }
    }

    func buyProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                // Unlock content
                SKPaymentQueue.default().finishTransaction(transaction)
                DispatchQueue.main.async {
                    // Notify user of successful subscription
                    // Update UI or app state accordingly
                }
            case .failed:
                // Handle error
                if let error = transaction.error {
                    DispatchQueue.main.async {
                        // Notify user of error
                    }
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            case .restored:
                // Restore purchases
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }
}

struct AdvisingTabView: View {
    @State private var isSubscribed = false

    var body: some View {
        NavigationView {
            if isSubscribed {
                ChatView()
            } else {
                SubscriptionView()
                    .onAppear {
                        // Check subscription status
                        checkSubscriptionStatus()
                    }
            }
        }
    }

    func checkSubscriptionStatus() {
        // Implement your logic to check subscription status
        // Set `isSubscribed` accordingly
    }
}

struct ChatView: View {
    @EnvironmentObject var viewModelLoading: ViewModel
    @ObservedObject var viewModel = ViewModel()

    var body: some View {
        VStack {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.messages.filter { $0.role != .system }, id: \.id) { message in
                        messageView(message: message)
                    }
                }
            }
            .padding()

            HStack {
                TextField("Ask here...", text: $viewModel.currentInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    viewModel.sendMessage()
                }) {
                    Text("Send")
                        .padding()
                        .frame(height: 36)
                        .background(Color.pink)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(20)
        }
        .background(
            ZStack {
                Image(systemName: "sparkles.tv.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .opacity(0.1)
                    .edgesIgnoringSafeArea(.all)

                Text("Hello, How can I help you today?")
                    .foregroundColor(.gray)
                    .font(.headline)
                    .padding(.top, 120)
            }
        )
    }

    func messageView(message: Message) -> some View {
        HStack {
            if message.role == .user {
                Text(message.content)
                    .padding(10)
                    .background(Color.pink)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                Spacer()
            } else {
                Spacer()
                Text(message.content)
                    .padding(10)
                    .background(Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
