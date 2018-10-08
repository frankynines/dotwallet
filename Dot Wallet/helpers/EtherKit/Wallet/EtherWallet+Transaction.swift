import web3swift
import BigInt
import SwiftyJSON
import PromiseKit

public protocol TransactionService {
    func sendEtherSync(to address: String, amount: String, password: String) throws -> String
    func sendEtherSync(to address: String, amount: String, password: String, gasPrice: String?) throws -> String
    func sendEther(to address: String, amount: String, password: String, completion: @escaping (String?) -> ())
    func sendEther(to address: String, amount: String, password: String, gasPrice: String?, completion: @escaping (String?) -> ())
    func sendTokenSync(to toAddress: String, contractAddress: String, amount: String, password: String, decimal: Int) throws -> String
    func sendTokenSync(to toAddress: String, contractAddress: String, amount: String, password: String, decimal: Int, gasPrice: String?) throws -> String
    func sendToken(to toAddress: String, contractAddress: String, amount: String, password: String, decimal:Int, completion: @escaping (String?) -> ())
    func sendToken(to toAddress: String, contractAddress: String, amount: String, password: String, decimal:Int, gasPrice: String?, completion: @escaping (String?) -> ())
    
    func getTransactionHistory(address:String, completion: @escaping ([JSON]?) -> ())
    
    func getEthereumContract(contractAddress:String, methodName:String, methodParams:[Any?]) throws -> web3.web3contract?
    
    func sendContractMethod(methodName:String,
                            methodParams:[Any?],
                            pass:String,
                            gasPrice:Int,
                            gasLimit:Int,
                            completion: @escaping (Bool?, String?) -> ())

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
            return result.transaction.txhash!
        case .failure(let error):
            print(error)
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
            return result.hash
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

        let url = NSURL(string: etherscanURL + "/api?module=account&action=txlist&address="+address+"&startblock=0&endblock=99999999&page=1&offset=100&sort=asc&apikey=Y2DRKI11G7A6NY61TKRYKVJ2HFXVAFHKRE")
        
        URLSession.shared.dataTask(with: (url as URL?)!, completionHandler: {(data, response, error) -> Void in
            if data == nil {
                return
            }
            if (try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary) != nil {
                let json = JSON(data!)
                let result = json["result"].arrayValue
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }).resume()
    }
    
    public func getEthereumContract(contractAddress:String, methodName:String, methodParams:[Any?]) throws -> web3.web3contract?{
        
        let contractEAddress = EthereumAddress(contractAddress)
        
        do {
            let keystore = try loadKeystore()
            let keystoreManager = KeystoreManager([keystore])
            web3Main.addKeystoreManager(keystoreManager)
        } catch {
            throw ContractError.malformedKeystore

        }
        
        options.from = EthereumAddress(address!)
        
        guard let contractABI = try! self.getContractABI() else {
            throw ContractError.invalidABI
        }
        
        if let contract = web3Main.contract(contractABI, at: contractEAddress){
            return contract
        }
        
        throw ContractError.networkFailure
    }

    
    public func sendContractMethod(methodName:String,
                                   methodParams:[Any?],
                                   pass:String,
                                   gasPrice:Int,
                                   gasLimit:Int,
                                   completion: @escaping (Bool?, String?) -> ()){
        
        let contractAddress = "0xA12d5111CB7fD6C285Faa81530eB5c4dfCEA51E7"
        
        guard let contract = try! self.getEthereumContract(contractAddress: contractAddress, methodName: methodName, methodParams: methodParams) else {
            completion(false, "Contract Failed")
            return
        }
        
        //SET OPTIONS
        var options = Web3Options.defaultOptions()
        options.gasPrice = BigUInt(gasPrice)
        options.gasLimit = BigUInt(gasLimit)
        options.from = EthereumAddress(address!)
        options.to = EthereumAddress(contractAddress)
        
        guard let contractMethod = contract.method(methodName, parameters: methodParams as [AnyObject], extraData: Data(), options: options) else {
            completion(false, "Contract Method Failed, Check Parameters")
            return
        }
        
       //Increase Nonce
        let latestNonce = contractMethod.assemble(options: options, onBlock: "latest")
        switch latestNonce {
        case .success(let nonce):
            contractMethod.transaction.nonce = 102
        case .failure(_):
            completion(false, latestNonce.error?.localizedDescription)
        }
        
        //CALL CONTRACT METHOD
        let contractCall = contractMethod.send(password: pass, options: options, onBlock: "latest")
        
        switch contractCall {
            case .success(let result):
                completion(true, result.hash)
            case .failure(_):
                completion(false, contractCall.error?.localizedDescription)
        }
        
    }
    
    internal func getContractABI()throws -> String?{
        
        if let path = Bundle.main.path(forResource: "DotCollectible", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let json = try! JSON(data: data)
                return json.rawString() // RETURN
            } catch {
                throw error
            }
        }
        return WalletError.networkFailure.localizedDescription
    }
    
}
