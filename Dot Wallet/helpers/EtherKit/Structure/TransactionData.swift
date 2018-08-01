struct TransactionData {
    let currencyName: String
    let currencySymbol: String
    let amount: String
    let timestamp: String
    let hash: String
    let from: String
    let to: String
    let isError: Bool
}

struct TokenTransactionData: Decodable {
    let tokenName: String
    let tokenSymbol: String
    let tokenDecimal: String
    let timestamp: String
    let hash: String
    let from: String
    let to: String
    var value: String
    let gas: String
    let gasPrice: String
    let contractAddress: String
    let cumulativeGasUsed: String
    let gasUsed: String
    let confirmations: String
    
    enum CodingKeys: String, CodingKey {
        case tokenName
        case tokenSymbol
        case tokenDecimal
        case timestamp = "timeStamp"
        case hash
        case from
        case to
        case value
        case gas
        case gasPrice
        case contractAddress
        case cumulativeGasUsed
        case gasUsed
        case confirmations
    }
}

struct GeneralTransactionData: Decodable {
    let timestamp: String
    let hash: String
    let from: String
    let to: String
    var value: String
    let gas: String
    let gasPrice: String
    let isError: String
    let contractAddress: String
    let cumulativeGasUsed: String
    let gasUsed: String
    let confirmations: String
    
    enum CodingKeys: String, CodingKey {
        case timestamp = "timeStamp"
        case hash
        case from
        case to
        case value
        case gas
        case gasPrice
        case isError
        case contractAddress
        case cumulativeGasUsed
        case gasUsed
        case confirmations
    }
}

public struct ERC20Token:Codable {
    let name:String?
    let symbol:String?
    let contractAddress:String?
    let decimal:String?
    let imageURL:String?
    let balance:String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case symbol
        case contractAddress
        case decimal
        case imageURL
        case balance
    }
}

