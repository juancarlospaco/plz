import net, asyncdispatch, tables, xmltree, parsexml, xmlparser

type
  State* = enum              ## Remote proc call state
    Correct                  ## OK state
    ErrorMethodNotRegistered ## Request proc is not registered
    ErrorParam               ## Param type error, cannot be unpacked to registered type
    ErrorRet                 ## Ret type error, cannot be unpacked to required type
    ErrorExecution           ## Any expection raised during remote proc execution

  RpcClient* = ref RpcClientObj ## Rpc client ref type
  RpcClientObj* = object        ## Rpc client obj type
    socket: Socket
    address: string
    port: Port

proc newRpcClient*(address: string, port: Port): RpcClient =
  ## Create a RPC Client instance connecting to ``address:port``.
  new(result)
  result.socket = newSocket()
  result.address = address
  result.port = port

proc sendLine(client: Socket, msg: string) =
  client.send(msg & "\c\L")

proc sendLine(client: RpcClient, msg: string) =
  client.socket.sendLine(msg)

proc recvLine(client: RpcClient): TaintedString =
  result = TaintedString""
  client.socket.readLine(result)

proc call* [T, U](client: RpcClient, name: string, param: string, ret: var U): State =
  ## Sync style remote proc call
  ##
  ## client: Rpc client
  ## name: Remote proc registered name
  ## param: Remote proc param
  ## ret: Remote proc return value
  ##
  ## return value: Remote call procedure state, *not* remote proc return value.
  ##               If everything is ok, return Correct. Other error state, please
  ##               refer to rpc_type module.
  client.socket.connect(client.address, client.port)
  client.sendLine(name)
  client.sendLine(param)

  var state: State
  state = parseXml(client.recvLine())

  if state != Correct:
    return state

  var error: int
  try:
    error = parseXml(client.recvLine())
  except:
    return ErrorRet

  client.socket.close()
