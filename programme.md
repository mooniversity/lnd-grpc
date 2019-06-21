# Training Outline

### 1. Environment

1. The environment we are going to use today is an instance of vscode hosted by gitpod, which means it wil have python 3 already installed and includes a terminal we can run LND inside.

    1. We have aliased 'python' to 'python3' and 'pip' to 'pip3' for you so there is no danger of accidentally using python2

    1. The LND binary has also already been downloaded and unzipped by the docker image setup scripts and it will have started up automatically for you too and begun syncing.

1. As we are only going to run through the RPC library, not create a sample application, we are going to use the python REPL today so I am going to close the top and side windows, `alt-shift-c`, and reopen the terminal `cmd+j`

    1. I will also reposition this terminal window as we will use horizontally split terminal for the tutorial so that we can see LNDs logs along with the results of our commands.

1. In the LND terminal tab you can see that quite a lot has been happening. If you've run LND before you will recognise this log output as LND syncing. We can see a number of activities happening: `Processing blocks`, `verifying block headers` and the occasional `cfheader` queries. This is what we expect to see at this stage.

    1. If we scroll up to the top we can see how this all began; the shell executed the startup scripts we defined at the project level.

    1. Where the output changes format we can tell that LND was started.

    1. We can see various bit of information here...

    1. We can also see that it is `Waiting for wallet encryption password`, which it is prompting us to use `lncli` to create, so this seems like a good time to move onto some RPC control, as this is something we can do via python RPC.

----

### 2. Install lnd_grpc

1. We start in our command terminal, and first we need to install the lnd-grpc python module. As this is hosted on the 'pip' python package installer, it is super easy to install:

    ```bash
    pip install lnd_grpc
    ```
  
1. The last line after running this command should read that it has successfully installed lnd-grpc and its dependencies.
  
----

### 3. Initialise the rpc connection
1. Now we are ready to connect to LND's RPC using python.

1. Open a python REPL from the terminal simply by typing `python` into the prompt. A REPL is basically a live code evaluator which runs and executes your code line by line, each time you finish a statement. The REPL is usually clever-enough to know when you are entering a multi-line code fragment, vs when you are trying to execute code as it has some understanding of python syntax.

1. With the REPL open we need to import the `Client` class from the lnd_grpc package. This class holds all the RPC methods you need to interact with LND as is a super-class encompassing various different RPC servers, which I will explain in more detail later. 
    
    ```python
    from lnd_grpc import Client
    ```

1. Now we are ready to create a new client object called 'lnd'. We will issue our commands to LND via this object and it will handle creating the Google RPC connection channels and stubs for us automatically. `Client` can take a number of arguments at instantiation, but as we have LND installed in default location and using default data directory, all we need to pass it is the `network='testnet'` flag which indicates we want to run on testnet -- we're not going to be that reckless yet! 
    
    ```python
    lnd = Client(network='testnet')
    ```  
1. Now that we have a client object, it is probably a good time to open a browser tab with all the LND RPC commands for later use: [lnd-grpc-api-reference](https://api.lightning.community/?python#lnd-grpc-api-reference). The way that lnd_grpc has been constructed, each method is available to the `Client` class by converting the 'CamelCase' name to 'lowercase_with_underscores', so `WalletBalance` would become `wallet_balance` in lowercase.

  You can also access the built-in docstring help using standard Python `help(Class.method)` syntax, but it's possible for the docstrings to become outdated, and they are less detailed than the api reference, so I would recommend using the online resource.

----

### 4. Initialise LND with a new wallet via `WalletUnlocker` Service

1. If you recall, when we checked the output of LND earlier it said ```Waiting for wallet encryption password. Use `lncli create` to create a wallet, `lncli unlock` to unlock an existing wallet, or `lncli changepassword` to change the password of an existing wallet and unlock it.```

1. As we have not created a wallet before, we first need to initialise one.

1. To initialise a new LND wallet you must first provide or generate a seed. This seed is what your private keys are derived from. To get LND to generate a seed, you can provide your own if you have another truly random method of generating one which you are happy with, is as simple as calling `gen_seed()`:

    ```python
    seed = lnd.gen_seed()
    ```
    
1. If you look at the API documentation we can see what optional parameters we could have provided to this method, and also a look at what we expect to receive back.

1. Next we initialise the wallet. This creates the wallet itself using the seed, unlocks it and also generates the various macaroons which which we use to authenticate our commands when using gRPC:

    ```python
    lnd.init_wallet(wallet_password='password', cipher_seed_mnemonic=seed.cipher_seed_mnemonic)
    ```

1. Once the wallet has been initialised for the first time, LND will do a quick re-scan of the blockchain for transactions related to the wallet. The reason for this is because we might be recovering an already used wallet -- if we had provided a seed that we had already used before instead of the freshly generated one. If that was the case you might want to alter the `recovery_window` parameter at the same time. In the case of a new wallet, it predictably won't find anything of interest to it and the re-scan should be very fast.
    
1. Its important to note that once the wallet has been created you won't need to run `init_wallet` again, but you *will* need to _unlock_ your wallet after restarting the lnd daemon. If you leave LND daemon running but simply restart the python REPL then the wallet will not lock, and you won't even need to issue unlock RPC commands to resume RPC control.

1. We can unlock a locked wallet with the `unlock_wallet` command with the `wallet_password` argument:

    ```python
    lnd.unlock_wallet(wallet_password='password')
    ```
    
    1. When the wallet seed is stored on your system it is encrypted and the wallet password is simply the key to decrypt the seed.

    1. Unlocking the wallet also starts the Lightning RPC server.

----

### 5. Check the connection to Lightning Service

1. Generating a seed, initialising a wallet and unlocking a wallet are all handled by the `WalletUnlocker` RPC server, which has limited capability. When the wallet is unlocked successfully the `Lightning` RPC server will be started, and in fact the `WalletUnlocker` service will become unavailable. If you want to see what this might look like, you can try to call a `get_info()` from LND while the wallet is still locked: you should see a `status = StatusCode.UNIMPLEMENTED` grpc error. This is the tell-tale sign that the GRPC server you are trying to talk to is offline or un-contactable.

1. With that in mind, we can check that the Lightning RPC server has started up as expected after unlocking the wallet, and better still, that we can connect to and control it from our python Client object.

1. A simple and non-destructive way to test that we can access it is by using `lnd.get_info()` which should return some general info about the node.

    ```python
    lnd.get_info()
    ```
  
  1. If this returns some general info on the node then we are unlocked and good to proceed. If it says it's unavailable, then the wallet is likely still locked or not yet created.

----

### 6. Get testnet Bitcoins

1. With the Lightning RPC server available we are ready to receive some test-bitcoins into our wallet. However there is slight limitation on first run and subsequent re-connections: we have to make sure that we are synced to the network and more importantly fully caught up to the current block. This can be established by testing the result of:

    ```python
    lnd.get_info().synced_to_chain
    ```
    
    ... which should return `True` if synced.

    1. I would note that GRPC has a long-known quirk whereby it hardcodes an `omitempty` setting, which means that False booleans and zero integers are not returned by default, and there is in fact no way to correct this yet! However, if you are aware of the attribute you want to test, you can still test it and it will display the correct result. This is why when you run `get_info()` you might not see a `synced_to_chain` attribute at all if it's False! However, you _will_ see it when it's True, or if you test it directly using:
    
1. When we are synced, we can generate a new receive address using the `new_address` method:

    ```python
    addr = lnd.new_address('p2wkh')
    ```
  
    1. The two receive address types in LND are Pay To Witness Key Hash and Nested Pay To Witness Key Hash.
  
    1. If you going to send from a reasonably modern wallet which supports sending to bech32 addresses you can use the `p2wkh` address type, but if you happen to need compatibility with an outdated wallet which can't handle sending to bech32 yet, then you can use `np2wkh` which embeds a `p2wkh` address inside an older `P2SH` address format and who's real full name for this reason is `P2SH-P2WPKH`. Get a new wallet would be my advice in this case!
    
1. With our address we can now receive some testnet bitcoin. If you have some testnet bitcoin on a mobile device then I would recommend copying your address into an online QR code generator such as [qr code generator](https://www.the-qrcode-generator.com), making sure to use 'text mode' and not something that will automatically add "www." and ".com" to it. Otherwise you cna use regular copy and paste.

    1. If you don't have any testnet bitcoin, you can get some from Coinfaucet.eu's [testnet faucet](https://coinfaucet.eu/en/btc-testnet/)
 
    You can display your address in a copy-friendly format be accessing the address attribute directly:
    
    ```python
    addr.address 
    ```
    
1. Wait for confirmations. Unfortunately testnet blocktimes can be between 1 minute and 20 minutes due to its nature of people testing minig equipment on there, so hopefully we don't have to wait long. You can check whether your coins are confirmed using `lnd.wallet_balance()` which will show it as `unconfirmed` or `confirmed balance` when it has seen it on the network.

----

### 7. Connecting to peers and opening a channel

1. In the meantime we can connect to some peers. There are two peer connection methods in lnd-grpc, one which is the default lnd RPC command `connect_peer` and one which simplifies address entry, `connect`. connect_peer requires a ln.LightningAddress object as argument, whereas `connect` allows you to pass the address in the commonly found string format as `node_pubkey@host:port`.

    Let's connect to Lightning Labs' [Testnet Lightning Faucet](https://faucet.lightning.community) using the `connect` method today:

    ```python
    lnd.connect('0270685ca81a8e4d4d01beec5781f4cc924684072ae52c507f8ebe9daf0caaab7b@159.203.125.125')
    ```
    
    1. Note that connecting is *not* the same as opening a channel, it is simply a networking-level connection, but it helps to find peers using ip addresses in case you do not have the full network graph info (or they do not appear in your network graph).

1. You can see which peers you are connected to at any time using
    ```python
    lnd.list_peers()
    ```

1. You can find more testnet peers on [1ml-testnet](https://1ml.com/testnet) to connect to as above if you want to try a few more.

----

### 8. Opening a channel

1. Next up is to finally open a channel with a peer. As we are already `connect`-ed to them, we only need to provide the pub_key and local funding amount to start.

1. We will start with the synchronous version of open channel, which, although it blocks the thread while it open the channel, returns the result for us automatically to see success or failure.

1. As we are using hex-encoded node_pubkeys (as returned by `get_info` or found online), we must be careful to use the `node_pubkey_string` argument, rather than `node_pubkey` which is expecting bytes!

1. To cheat a current limitation of the network that is not initially having any inbound liquidity, and make sure we can both send and receive funds, we will open a balanced channel with Lightning Labs' [Testnet Lightning Faucet](https://faucet.lightning.community) by pushing, or giving for *free*, some satoshis to their side during channel open. This is equivalent to giving them free money on mainnet, so to get inbound capacity and the ability to receive on there you should *not* do this and shoudl instead investigate other means such as using Lightning's "Loop In" or buying inbound liquidity off a provider.

    ```python
    lnd.open_channel_sync(node_pubkey_string='0270685ca81a8e4d4d01beec5781f4cc924684072ae52c507f8ebe9daf0caaab7b', local_funding_amount=500000, push_sat=250000)
    ```
    
1. If successful, you will see the funding txid returned in the terminal, and can also check the output of `lnd.list_channels()` to see if you now have channel open to their pubkey.

    ```python
    lnd.list_channels()
    ```

    1. Once you have opened the channel to them, you can easily have them open a second (balanced) one back to you by can using the form on their website to request they initiate opening a channel with you.
    
----

### 9. Create an invoice

1. Now we want to make a payment. Although direct 'key_send'/'sphinx send' is technically possible on mainnet today, we will use the standard invoice-payment lightning model

1. First, the receiver must create an invoice. This is easily done with `lnd.add_invoice()` which needs no additional parameters, not even a value! However conventionally the receiver requests a 'value' at least. A zero-value invoice can have any amount paid to it otherwise... It's useful to add a memo to the invoice both for yourself, and because this will get passed as part of the invoice to the recipient.

    ```python
    invoice = lnd.add_invoice(value=5000, memo='test invoice from ?')
    invoice
    ```
    
1. You can see the r_hash ('payment hash') as raw bytes, and the hex-encoded payment request along with the add_index. As the creator of the invoice, we also know the preimage ('r_preimage) and various other details, which we can expose by looking up the invoice by the payment hash. To avoid bytes conversions and other issues, we will simply reference the `invoice`'s .r_hash attribute in the lookup_invoice() method:

    ```python
    lnd.lookup_invoice(r_hash=invoice.r_hash)
    ```
    
    This will reveal the preimage, which is what we will reveal to the sender, upon receiving their "promise to pay".
    
----

### 10. Pay an invoice

1. First we need to share these BOLT11-encoded payment requests. This is ually done via other channels, e.g. through a web interface, as we have none, we can use google docs again: [invoice payment_requests](https://docs.google.com/spreadsheets/d/1eXq1bJFH_5I6ID2kpeJBdOkN5RMQCZmIug3GTgN2G6Y/edit#gid=1809562352)

1. Once you have retrieved the payment request of the invoice you wish to pay, and especially for this method we have used of communicating them where there is a good chance they might get mixed up, it is a good idea to decode the payment request and check that it is as you expect.
   
    ```python
    lnd.decode_pay_req(pay_req="payment_request_string")
    ```
    
1. The payment request is similarly decoded and checked using the `lncli` workflow, except it appears to happen automatically when you use their `payinvoice` command - you are prompted to confirm the description, amount and destination.

1. If the payment request is correct, then we can pay the invoice using `send_payment()` command:

    ```python
    lnd.send_payment_sync(payment_request="payment_request_string")
    ```
    
1. If successful, the payment preimage (r_preimage) will be displayed, along with the payment_hash (r_hash) and the route. If it fails, an appropriate error will be returned in full.

----

### 11. Backup

1. Now that we have opened some channels, it's the perfect time to back them up. LND has static channel backups (SCB) which, although not perfect, is the best option we have to offer at this stage.

  **1. Note that the below is specifically a channel backup and restore process. To backup and restore on-chain funds, only the `cipher_seed_mnemonic`. The `wallet_password` only encrypts this wallet on the disk. ***

1. SCB protocol will attempt to recover on-chain and payment channel balances, although only on-chain is fully guaranteed.

1. Although LND will create a `channel.backup` file automatically, it might not always be up to date. Make an up-to-date version using:

    ```python
    backup = lnd.export_all_channel_backups()
    ```
  
  **1. As we are not writing this backup to disk, only storing as a variable, be sure not to close this Notebook Window if you want to test a full delete and restore! ***
    
1. Next it makes sense to verify that the backup will work, which you can do using:

    ```python
    lnd.verify_chan_backup(multi_chan_backup=backup.multi_chan_backup)
    ```
    
1. If you want to test the full workflow, you can try to delete the channel database and restore it:

1. Stop LND (ctrl+c in its terminal window), and then delete the channel.db using

    ```bash
    rm ~/.lnd/data/graph/testnet/channel.db
    ```
  
1. Now you can restart LND in the terminal using the same command used in 2. above. Switch back to the Jupyter Notebook and try to unlock the wallet using the same 'lnd' object -- it should still work even though LND node has been restarted:

    ```python
    lnd.unlock_wallet(wallet_password='password')
    ```
    (or whatever password you chose in 5.)

1. If the wallet unlocks, you can check that your previously-opened channels are not lost from the database: 

    ```python
    lnd.list_channels()
    ```
    should return nothing.
    
1. Now lets try the restore:

    ```python
    lnd.restore_chan_backup(multi_chan_backup=backup.multi_chan_backup.multi_chan_backup)
    ```
  
  If successful, it will still take a while for LND to recover the funds back into the on-chain wallet. The SCB protocol (more specifically the Data Loss Protection [DLP] protocol) requests that the channel partner force closes the channel. Before they do though, they'll send over the channel reestablishment handshake message which contains the unrevoked commitment point which we need to derive keys (will be fixed in BOLT 1.1 by making the key static) to sweep our funds.
  
1. We can observe the log in the terminal session running LND to try and watch for the SCB process to complete. The first step takes around 60 seconds, but after that requires some on-chain confirmations, so total time can vary. A selection of lines to watch for in the log as progress: 

    ```bash
    'Inserting 1 SCB channel shells into DB'
    'Broadcasting force close transaction'
    'Publishing sweep tx'
    '...a contract has been fully resolved!'
    ```
    
1. As a result of successful backup restore, all funds will be returned to the on-chain wallet (minus transaction fees), and the channels will be marked as 'recovered' and not allowed to be re-used.

1. You can also subscribe to `channel.backup` status changes using `lnd.subscribe_channel_backups()` to stimulate backup process, or write a shell script to manually monitor the `channel.backup` file on the filesystem itself, e.g. [this script](https://gist.github.com/alexbosworth/2c5e185aedbdac45a03655b709e255a3).

  The Raspiblitz project also has a lot of neat shell scripts for things like this.
  
----

### 12. Threading of streaming 'subscription' RPCs

1. There are multiple 'subscribe' RPC calls which setup a server-client stream to notify the client of new events. As they are implemented, these will naturally block the single Python GIL thread, so we must setup threads to run these sanely.

  ```python
  import threading
  def sub_invoices():
      for response in lnd.subscribe_invoices():
          print('\n\n-------\n')
          print(f'New invoice from subscription:\n{response}\n\n')
  
  invoice_sub = threading.Thread(target=sub_invoices, daemon=True)
  invoice_sub.start()
  ```
  
1. Once the thread has started, you can create a new invoice and watch the subscription detect it.

  Note that due to using REPL/Jupyter Notebook, we will see both the return of `add_invoice()` command, and also the `print()` from our subscription which shows some double information. Usually you would be adding these invoices to a queue or database.

  ```python
  lnd.add_invoice(value=500)
  ```
  
  The same process can be used for `subscribe_transactions()`, `subscribe_channel_events()` and `subscribe_channel_graph()`. The number of threads is limited only by your CPU, but for low computation threads like most of these, the number could be some 000's
  
----

### 13. Hold Invoices

1. Quite a complicated workflow, where the main difference from normal invoice process is that the receiver does not have to settle the invoice immediately -- they can 'refuse' the payment.

1. This creates some extra requirements on the programming side, as

     i) receiver must monitor for 'payment' of the invoice (before deciding whether to settle),
    
     ii) the sender's `pay_invoice()` command will block indefinitely, until the receiver decides to settle and
    
     iii) the receiver needs to settle when they are happy to do so.

1. As we need to generate our own preimage, we need to generate 32 random bytes and also get the sha256 hash digest. Python has a nice library called secrets for generating random bytes:

  **Recipient step:**

  ```python
  from hashlib import sha256
  from secrets import token_bytes

  def random_32_byte_hash():
      """
      Can generate an invoice preimage and corresponding payment hash
      :return: 32 byte sha256 hash digest, 32 byte preimage
      """
      preimage = token_bytes(32)
      _hash = sha256(preimage)
      return _hash.digest(), preimage
  
  # generate a hash and preimage
  _hash, preimage = random_32_byte_hash()
  ```
  
 1. The recipient can now generate the hold invoice, manually supplying the sha256 hash we generated as the invoice hash:
 
   **Recipient step:**
 
  ```python
  invoice = lnd.add_hold_invoice(memo='pytest hold invoice', hash=_hash, value=1001)
  ```
  
  As before, we will need to exchange this out of band, so paste the payment request string and some identifier into the google sheet.

1. Now we can define the functions we will need to thread:

  **Recipient step:**
  
  ```python
  def inv_sub_worker(_hash):
      for _response in lnd.subscribe_single_invoice(_hash):
          print(f'\n\nInvoice subscription update:\n{_response}\n')
  ```
  
  **Sender step:**
  
  ```python
  def pay_hold_inv_worker(payment_request):
      lnd.pay_invoice(payment_request=payment_request)
  ```
  
1. Now we can begin the payment sequence. First the recipient should subscribe to updates for the invoice so they know when they've received payment:

  **Recipient step:**
  
  ```python
  # setup the thread
  inv_sub = threading.Thread(target=inv_sub_worker, name='inv_sub',
                             args=[_hash, ], daemon=True)
  
  # start the subscription thread
  inv_sub.start()
  ```
  
  You can check if the thread has started properly with `inv_sub.is_alive()`
  
1. Now the sender can make the payment. As mentioned above, this will block until settled, so its useful to run in a thread too. Retrieve the payment_request string from the google sheet.

  **Sender step:**
  
  ```python
  # setup the pay thread
  pay_inv = threading.Thread(target=pay_hold_inv_worker, args=[payment_request="payment_request", ])
  
  # Start the pay thread
  pay_inv.start()
  ```

1. At this stage, the recipient should see the print from their subscription thread that the invoice has had an update. Now the ball is in their court as they can choose to settle or cancel the invoice. Lets look at these two options.

  **Recipient step, option 1 - settle invoice:**
  
  ```python
  # to settle, we can just call settle_invoice() with the preimage
  lnd.settle_invoice(preimage=_preimage)
  ```
  
  **Reciepient step, option 2 - cancel payment:**
  
  ```python
  # to cancel invoice we call cancel_invoice() with the hash of the preimage (payment_hash)
  lnd.cancel_invoice(payment_hash=_hash)
  ```
  
1. After settling or canceling, the recipient should receive the appropriate response from their invoice subscription (and possibly the return of the settle/cancel call itself).

1. The sender's `pay_inv()` thread will then also return. It will include either a populated `payment_error` field indicating failure, or a populated `payment_preimage` field, indicating the payment was settled successfully. 

----

### Advanced Challenges

#### Route-finding

1. See if you can find a route to 03933884aaf1d6b108397e5efe5c86bcf2d8ca8d2f700eda99db9214fc2712b134 for about 3000 satoshis

    1. If not, choose a new, well-conneted node from [1ml-testnet](https://1ml.com/testnet), connect to them and open an appropriately-sized channel.
    
    1. Try searching for a route again.

1. Get a new invoice from this node, hint: the node pubkey is that of [Starblocks](https://starblocks.acinq.co/#/), so visit their website and proceed to buy a coffee.

1. When you have your invoice for the coffee, decode the payment request just to double check the node_pubkey is the same (and that they didn't change node pub_key since writing of this guide!)

1. Don't just pay the payment request, using the route that you've saved, pay the invoice using `send_to_route()` or `send_to_route_sync()` command, passing in the route that you recovered earlier.

----

#### Channel balancing:

1. Get an invoice which will allow you to deplete a channel and empty it (hint: you must reserve 1% of a channel capacity, so you can never fully deplete)

1. Open a new channel with a new peer that has 1.5x the capacity of the first

1. Try to find a route from your newly-funded channel, back to yourself at your original, now almost empty, channel

1. Make a payment along the route with a value of 50% the capacity of the original channel. Now you should have two balanced channels!

----

#### Bi-directional payment channel sphinx send

1. Stop the jupyter notebook kernel (don't need to close the workbook)

1. From the terminal, remove current version of lnd-grpc install using pip, `pip uninstall --user lnd-grpc`

1. Change to the home directory, clone the lnd-grpc source code from git and enter the clone directory:

  `cd ~; git clone https://github.com/willcl-ark/lnd_grpc.git; cd lnd_grpc`

1. Checkout WIP branch 'send_payment_sphinx':

  `git checkout send_payment_sphinx`
  
1. install this branch as an editable package:

  `pip install -e .`

1. This branch includes a change to the asynchronous `send_payment()` method so that it will accept an arbitrary request generator. Check the source code [here](https://github.com/willcl-ark/lnd_grpc/blob/send_payment_sphinx/lnd_grpc/lightning.py#L408) or at L408 of lnd_grpc/lightning.py in your own editor to get an idea of the function. An example generator can be found right above it at L400.

1. It also expands the SendPayment protocol message to include the `key_send` attribute, which enables you to send to a node's (public) key directly.

1. `key_send` or 'sphinx send' payments need both sender and final node to both have the option compiled in and enabled at this stage.

1. Attempt a sphinx send using the `send_payment(key_send=node_pubkey)` RPC call.

1. Create a custom request generator to use with a sphinx `send_payment` call which will send a payment of 20 satoshis every 20 seconds for 1 minute.

