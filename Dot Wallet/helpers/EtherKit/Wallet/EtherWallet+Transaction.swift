import web3swift
import BigInt
import SwiftyJSON

public protocol TransactionService {
    func sendEtherSync(to address: String, amount: String, password: String) throws -> String
    func sendEtherSync(to address: String, amount: String, password: String, gasPrice: String?) throws -> String
    func sendEther(to address: String, amount: String, password: String, completion: @escaping (String?) -> ())
    func sendEther(to address: String, amount: String, password: String, gasPrice: String?, completion: @escaping (String?) -> ())
    func sendTokenSync(to toAddress: String, contractAddress: String, amount: String, password: String, decimal: Int) throws -> String
    func sendTokenSync(to toAddress: String, contractAddress: String, amount: String, password: String, decimal: Int, gasPrice: String?) throws -> String
    func sendToken(to toAddress: String, contractAddress: String, amount: String, password: String, decimal:Int, completion: @escaping (String?) -> ())
    func sendToken(to toAddress: String, contractAddress: String, amount: String, password: String, decimal:Int, gasPrice: String?, completion: @escaping (String?) -> ())
    
    //TRX History
    func getTransactionHistory(address:String, completion: @escaping ([JSON]?) -> ())
    
    func getTokenOwner(fromAddress:String, contractAddress:String, tokenID:String)
    func sendERC721Token(toAddress:String, contractAddress:String, tokenID:String, completion: @escaping (Bool) -> ())

}

extension EtherWallet: TransactionService {
    public func sendEtherSync(to address: String, amount: String, password: String) throws -> String {
        return try sendEtherSync(to: address, amount: amount, password: password, gasPrice: nil)
    }
    
    public func sendEtherSync(to address: String, amount: String, password: String, gasPrice: String?) throws -> String {
        guard let toAddress = EthereumAddress(address) else { throw WalletError.invalidAddress }
        let keystore = try loadKeystore()
        
        let etherBalance = try etherBalanceSync()
        guard let etherBalanceInDouble = Double(etherBalance) else { throw WalletError.conversionFailure }
        guard let amountInDouble = Double(amount) else { throw WalletError.conversionFailure }
        guard etherBalanceInDouble >= amountInDouble else { throw WalletError.notEnoughBalance }
        
        let keystoreManager = KeystoreManager([keystore])
        web3Main.addKeystoreManager(keystoreManager)
        
        if let gasPrice = gasPrice {
            options.gasPrice = BigUInt(gasPrice)
        }
        options.value = Web3.Utils.parseToBigUInt(amount, units: .eth)
        
        let intermediateSend = web3Main.contract(Web3.Utils.coldWalletABI, at: toAddress, abiVersion: 2)!.method(options: options)!
        let sendResult = intermediateSend.send(password: password)
        switch sendResult {
        case .success(let result):
            guard let txHash = result["txhash"] else { throw WalletError.networkFailure }
            return txHash
        case .failure(_):
            throw WalletError.networkFailure
        }
    }
    
    public func sendEther(to address: String, amount: String, password: String, completion: @escaping (String?) -> ()) {
        sendEther(to: address, amount: amount, password: password, gasPrice: nil, completion: completion)
    }
    
    public func sendEther(to address: String, amount: String, password: String, gasPrice: String?, completion: @escaping (String?) -> ()) {
        DispatchQueue.global().async {
            let txHash = try? self.sendEtherSync(to: address, amount: amount, password: password, gasPrice: gasPrice)
            DispatchQueue.main.async {
                completion(txHash)
            }
        }
    }
    
    public func sendTokenSync(to toAddress: String, contractAddress: String, amount: String, password: String, decimal: Int) throws -> String {
        return try sendTokenSync(to: toAddress, contractAddress: contractAddress, amount: amount, password: password, decimal: decimal, gasPrice: nil)
    }
    
    public func sendTokenSync(to toAddress: String, contractAddress: String, amount: String, password: String, decimal: Int, gasPrice: String?) throws -> String {
        guard let tokenAddress = EthereumAddress(contractAddress) else { throw WalletError.invalidAddress }
        guard let fromAddress = address else { throw WalletError.accountDoesNotExist }
        guard let fromEthereumAddress = EthereumAddress(fromAddress) else { throw WalletError.invalidAddress }
        guard let toEthereumAddress = EthereumAddress(toAddress) else { throw WalletError.invalidAddress }
        
        let keystore = try loadKeystore()
        let keystoreManager = KeystoreManager([keystore])
        web3Main.addKeystoreManager(keystoreManager)
        
        var options = Web3Options.defaultOptions()
        options.from = fromEthereumAddress
        
        if let gasPrice = gasPrice {
            options.gasPrice = BigUInt(gasPrice)
        }
        options.gasLimit = BigUInt(defaultGasLimitForTokenTransfer)
        
        guard let tokenAmount = Web3.Utils.parseToBigUInt(amount, decimals: decimal) else { throw WalletError.conversionFailure }
        let parameters = [toEthereumAddress, tokenAmount] as [AnyObject]
        guard let contract = web3Main.contract(Web3.Utils.erc20ABI, at: tokenAddress, abiVersion: 2) else { throw WalletError.contractFailure }
        guard let contractMethod = contract.method("transfer", parameters: parameters, options: options) else { throw WalletError.contractFailure }
        
        let contractCall =  contractMethod.send(password: password, onBlock: "latest")
        switch contractCall {
        case .success(let result):
            guard let txHash = result["txhash"] else { throw WalletError.networkFailure }
            return txHash
        case .failure(_):
            throw WalletError.networkFailure
        }
    }
    
    public func sendToken(to toAddress: String, contractAddress: String, amount: String, password: String, decimal: Int, completion: @escaping (String?) -> ()) {
        sendToken(to: toAddress, contractAddress: contractAddress, amount: amount, password: password, decimal: decimal, gasPrice: nil, completion: completion)
    }
    
    public func sendToken(to toAddress: String, contractAddress: String, amount: String, password: String, decimal:Int, gasPrice: String?, completion: @escaping (String?) -> ()) {
        DispatchQueue.global().async {
            let txHash = try? self.sendTokenSync(to: toAddress, contractAddress: contractAddress, amount: amount, password: password, decimal: decimal, gasPrice: gasPrice)
            DispatchQueue.main.async {
                completion(txHash)
            }
        }
    }
    
    public func getTransactionHistory(address:String, completion: @escaping ([JSON]?) -> ()){
        print("Get TX History")
        let url = NSURL(string: etherscanURL + "/api?module=account&action=txlist&address="+address+"&startblock=0&endblock=99999999&page=1&offset=100&sort=asc&apikey=Y2DRKI11G7A6NY61TKRYKVJ2HFXVAFHKRE")
        
        //fetching the data from the url
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            if data == nil {
                return
            }
            if (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary) != nil {
                let json = JSON(data!)
                let result = json["result"].arrayValue
                print(result.count)
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }).resume()
    }
    
    public func getTokenOwner(fromAddress:String, contractAddress:String, tokenID:String){
        let contractEAddress = EthereumAddress(contractAddress)
        
        let web3Main = Web3.InfuraMainnetWeb3() // USED TO GET MAIN NET TOKEN INFO
        
        if let contract = web3Main.contract(erc721ABI, at: contractEAddress) {
            
            let params = [tokenID] as [AnyObject]
            let contractMethod = contract.method("ownerOf", parameters: params, extraData: Data(), options: options)
            
            let callResult = contractMethod?.call(options: nil)
            guard case .success(let package)? = callResult else {
                return
            }
            
            let owner = package["_owner"] as! EthereumAddress
            print(owner.address)
        }
    }
    
    public func sendERC721Token(toAddress:String, contractAddress:String, tokenID:String, completion: @escaping (Bool) -> ()){
        
        let contractEAddress = EthereumAddress(contractAddress)
        let web3Main = Web3.InfuraMainnetWeb3() // USED TO GET MAIN NET TOKEN INFO
        
        do {
            let keystore = try loadKeystore()
            let keystoreManager = KeystoreManager([keystore])
            web3Main.addKeystoreManager(keystoreManager)
        } catch {
            print(error.localizedDescription)
            return
        }
       
        var options = Web3Options.defaultOptions()
        options.from = EthereumAddress(address!)
        options.gasLimit = BigUInt(500000)
        options.gasPrice = Web3.Utils.parseToBigUInt("3", units: .Gwei)
        options.to = contractEAddress
    
        
        if let contract = web3Main.contract(erc721ABI, at: contractEAddress) {
            
            let params = [ EthereumAddress(address!), EthereumAddress(toAddress), tokenID] as [AnyObject]
            let contractMethod = contract.method("transferFrom", parameters: params, extraData: Data(), options: options)
            
            let contractCall =  contractMethod?.send(password: "", options: options, onBlock: "latest")
            
            switch contractCall {
            case .success(let result)?:
                print(result["txhash"])
                completion(true)
            case .failure(_)?:
                completion(false)
                //throw WalletError.networkFailure
            case .none:
                completion(false)
            }
        }
    }
    
   
    
    
    
}
