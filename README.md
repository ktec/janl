# NetLogger

Just another Network Logger

# Warning
This was built for a very specific purpose. I made best attempts to secure
packets that are transferred, but this is inherently insecure by nature. You probably
dont want to use this.
```
1) The client first sends a message on the broadcast address requesting a public key.
2) the server responds to that request with its public key.
3) the client stores this public key.
4) the client then encodes all messages with this key
5) the server decodes all messages with it's private key.
6) all messages are stored (unencrypted) in a sqlite3 database.
```

## Setup
On some machine that you'd like to be the server do:
```bash
./generate_keys.sh
```

## Usage
In one IEx session do:

```elixir
{:ok, _} = NetLogger.Server.start_link([])
```  

then in another session do:
```elixir
{:ok, client} = NetLogger.UDP.Client.start_link()
NetLogger.UDP.Client.ping(client)

# This log should show up on the first session.
NetLogger.UDP.Client.log(client, %NetLogger.Log{message: "hello world", time: :os.system_time, level: :debug, verbosity: 1})  
```
