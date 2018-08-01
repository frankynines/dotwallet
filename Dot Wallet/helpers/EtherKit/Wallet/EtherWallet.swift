import web3swift
import BigInt

public class EtherWallet {
    private static let shared = EtherWallet()
    public static let account: AccountService = EtherWallet.shared
    public static let balance: BalanceService = EtherWallet.shared
    public static let transaction: TransactionService = EtherWallet.shared
    public static let tokens: TokenService = EtherWallet.shared
    
    public let web3Main = Web3.InfuraRopstenWeb3() // Change to MainNet when Launch
    let etherscanURL = "https://api-ropsten.etherscan.io" // Change to MainNet when Launch
    let tokenImageSrcURL = "https://raw.githubusercontent.com/trustwallet/tokens/master/images/"
    let keystoreDirectoryName = "/keystore"
    let keystoreFileName = "/key.json"
    let defaultGasLimitForTokenTransfer = 100000
    
    var options: Web3Options
    var keystoreCache: EthereumKeystoreV3?
    
    private init() {
        options = Web3Options.defaultOptions()
        options.gasLimit = BigUInt(defaultGasLimitForTokenTransfer)
        setupOptionsFrom()
    }
    
    func setupOptionsFrom() {
        if let address = address {
            options.from = EthereumAddress(address)
        } else {
            options.from = nil
        }
    }
}
