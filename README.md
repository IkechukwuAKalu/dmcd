# Distributed Morse Code Decoder (DMCD)

This is a morse code decoder written in Elixir which can be run as either a single node or as an erlang cluster.

When running as an erlang cluster, data is replicated across all available nodes in the cluster (this is an assumed requirement).

## Setup

It is assumed you have Elixir installed and running on your machine. Before running the app or tests, you need to export the port the HTTP server should listen to. To do this, run the following command in your terminal session:

```bash
$ export DMCD_PORT=<PORT_NUMBER>
```

Other variables you can export are given below:
- `DMCD_MESSAGE_TTL` - time in milliseconds that each message should be stored in memory before it gets burned (deleted)

Next, run the following command to fetch the app dependencies

```bash
$ mix deps.get
```

After the dependencies are fetched, run the following command to compile the project:

```bash
$ mix compile
```

To run the unit tests (ensure you have exported the application port number),

```bash
$ mix test
```

## Running the App
This app was desinged to run as an erlang cluster. To start a cluster, we need to start multiple nodes and connect them to each other.

### Start the different Nodes
To start the app as a node, run `iex --sname <NODE_NAME>@<HOSTNAME> -S mix`

Example:
```bash
$ iex --sname node1@localhost -S mix # Start Node 1
$ iex --sname node2@localhost -S mix  # Start Node 2
```
NB: You should start each node in a separate terminal session

### Connect the nodes
After you start the differnt nodes, you need to connect them to communicate with each other. Inside the `iex` terminal session that was entered by running the `iex --sname <NODE_NAME>@<HOSTNAME> -S mix` command, run the following elixir command `Node.connect(NODE)` where NODE is the other node you want to connect to.

For example, assuming you start nodes `node1@localhost` and `node2@localhost`. In the `node2@localhost` terminal session, you can connect to `node1@localhost` by running the code below:

```elixir
> Node.connect(:node1@localhost)
```
Note: Assuming you have 5 nodes: A, B, C, D & E. If node A is connected to nodes B, D, E. Connecting node C to A will connect node C to node A and also connect node C to nodes B, D, E - you don't have to manually connect to each of the other nodes.

### Send HTTP Requests
After connecting the nodes, you can now begin to send HTTP requests to the REST API endpoints.

Examples (assuming you're running 3 nodes on ports `4000`, `4001` and `4002`):
```bash
# create a new decode "session"
$ curl -X POST http://localhost:​4000​/new
{"id": "123"}

# send the Morse codes in sequence
$ curl -X PUT -d '{"code": "...."}' http://localhost:​4000​/decode/123
$ curl -X PUT -d '{"code": "."}' http://localhost:​4001​/decode/123
$ curl -X PUT -d '{"code": "​.-..​"}' http://localhost:​4002​/decode/123
$ curl -X PUT -d '{"code": ".--."}' http://localhost:​4000​/decode/123

# output the result
$ curl http://localhost:​4001​/decode/123
{"text": "HELP"}
```

    ==

## Some Design Decisions
There are ways this project can be improved. But since this is not expected to be a production ready solution, I have kept it simple. Some design decisions have been outlined below.

- A process is spawned for each new message which sleeps for a specified duration before proceeding to delete the message. This is not the most efficient approach as many messages with long time-to-lives would mean the app would have many spawned processes. For a better solution, [Redis](https://redis.io/) could be used as the data store because it is fast and has a key auto expiry feature.
  
- Data is replicated across all nodes in the cluster to avoid data loss if a node goes down. But there is still an issue with the current implementation because if for some reason a node gets isolated in the cluster due to network partitions or any other reason, data would become inconsistent across the cluster. A soultion to this would be to employ a consensus algorithm such as [Raft](https://raft.github.io/).