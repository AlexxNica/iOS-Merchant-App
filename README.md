# iOS-Merchant-App

iOS app for merchants to receive Bitcoin

## Building

The app is in `App/Merchant`

Install pods:

    cd App/Merchant/
    pod install
 
Open the project in Xcode:

    open Merchant.xcworkspace

## Receiving Bitcoin

Merchants can register a Bitcoin address to receive payments. The app subscribes to the address through the blockchain.info websocket. When an amount is charged, the websocket opens. The transaction hash is obtained from the message received by the websocket when funds are received to the address. The hash and address are used to query for the result (`https://blockchain.info/q/txresult/$tx_hash/$address`), which is compared to the amount received. Payment is considered insufficient when the amount received is 1 or more satoshi less than the amount requested, in which case the app requests an additional payment to make up for the difference.
