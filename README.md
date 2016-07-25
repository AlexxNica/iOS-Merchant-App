# iOS-Merchant-App

iOS app for merchants to receive Bitcoin to a specific address.

# Building
Install pods:

    pod install
  
Open the project in Xcode

    open Merchant.xcworkspace
  
# Receiving Bitcoin

The app subscribes to its address through the websocket. When an amount is charged, the websocket opens. The transaction hash is obtained from the message received by the websocket when funds are received to the address. The hash and address are used to query for the result (https://blockchain.info/q/txresult/$tx_hash/$address), which is compared to the amount received. Payment is considered insufficient when the amount received is 1 or more satoshi less than the amount requested, in which case the app requests an additional payment to make up for the difference.
