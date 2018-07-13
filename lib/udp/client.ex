defmodule NetLogger.UDP.Client do
  use GenServer
  use NetLogger.UDP
  alias NetLogger.Packet
  alias __MODULE__, as: State
  require Logger
  defstruct [:socket, :public_key, :request_id, :from, :host]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def ping(pid, data, timeout \\ 5000) do
    packet = Packet.new(UUID.uuid1, :ping, data)
    GenServer.call(pid, {:packet, packet, timeout}, timeout + 500)
  end

  def log(pid, %NetLogger.Log{} = log, timeout \\ 5000) do
    packet = Packet.new(UUID.uuid1, :log, Jason.encode!(log))
    GenServer.call(pid, {:packet, packet, timeout}, timeout + 500)
  end

  def terminate(_reason, state) do
    :gen_udp.close(state.socket)
  end

  def init(opts) do
    port = Keyword.get(opts, :port, @port + 1)
    case :gen_udp.open(port, [:binary, {:broadcast, true}, {:active, true}]) do
      {:ok, socket} ->
        id = UUID.uuid1
        packet = Packet.new(id, :public_key_request, to_string(node()))
        :gen_udp.send(socket, @bcast, @port, Packet.encode(packet))
        {:ok, %State{socket: socket, public_key: nil, request_id: id, host: nil}}
      {:error, :eaddrinuse} -> init(Keyword.put(opts, :port, port+1))
      {:error, _} = err -> err
    end
  end

  def handle_info({:udp, _socket, host_addr, @port, response_packet}, %{public_key: nil, request_id: id} = state) do
    case Packet.decode(response_packet) do
      %Packet{id: ^id, type: :public_key_response, data: data} ->
        [public] = :public_key.pem_decode(data)
        public_key = :public_key.pem_entry_decode(public)
        Logger.debug "Got public key!"
        {:noreply, %{state | public_key: public_key, request_id: nil, host: host_addr}}
      o ->
        Logger.debug "Ignoring packet #{inspect o} no public key."
        {:noreply, %{state | host: host_addr}}
    end
  end

  def handle_info({:udp, _socket, _addr, @port, response_packet}, %{from: nil} = state) do
    Logger.debug "Ignoring packet: #{inspect Packet.decode(response_packet)} - no from."
    {:noreply, state}
  end

  def handle_info({:udp, _socket, _addr, @port, response_packet}, state) do
    GenServer.reply(state.from, Packet.decode(response_packet))
    {:noreply, %{state | request_id: nil, from: nil}}
  end

  def handle_info({:timeout, id, from}, %{request_id: id, from: from} = state) do
    GenServer.reply(from, {:error, :timeout})
    {:noreply, %{state | request_id: nil, from: nil}}
  end

  def handle_info({:timeout, _id, _from}, state) do
    {:noreply, state}
  end

  def handle_call({:packet, _packet, _}, _from, %{public_key: nil} = state) do
    {:reply, {:error, :not_connected}, state}
  end

  def handle_call({:packet, packet, timeout}, from, state) do
    packet = %{packet | data: NetLogger.Crypto.encrypt(packet.data, state.public_key)}
    :gen_udp.send(state.socket, @bcast, @port, Packet.encode(packet))
    Process.send_after(self(), {:timeout, packet.id, from}, timeout)
    {:noreply, %{state | request_id: packet.id, from: from}}
  end
end
