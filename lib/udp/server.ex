defmodule NetLogger.UDP.Server do
  use GenServer
  use NetLogger.UDP
  alias NetLogger.{Packet, PacketHandler}
  alias __MODULE__, as: State
  require Logger
  defstruct [socket: nil, private_key: nil]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def terminate(_reason, state) do
    :gen_udp.close(state.socket)
  end

  def init([]) do
    {:ok, socket} = :gen_udp.open(@port, [:binary, {:active, true}])
    {:ok, %State{socket: socket, private_key: NetLogger.Crypto.private()}}
  end

  def handle_info({:udp, socket, addr, port, request_packet}, state) do
    case Packet.decode(request_packet) do
      %Packet{id: id, type: :public_key_request, data: _node_str} ->
        Logger.info "Sending public key to #{inspect addr} port: #{port}"
        data = NetLogger.Crypto.public_key_pem()
        response_packet = Packet.new(id, :public_key_response, data)
        :gen_udp.send(socket, addr, port, Packet.encode(response_packet))
        {:noreply, state}
      packet -> handle_packet(packet, addr, port, state)
    end
  end

  def handle_packet(packet, addr, port, state) do
    handler_id = Enum.join([elem(addr, 0), elem(addr, 1), elem(addr, 2), elem(addr, 3), port], ".")
    packet = %{packet | data: NetLogger.Crypto.decrypt(packet.data, state.private_key)}
    reply_packet = PacketHandler.handle_packet(handler_id, packet)
    if reply_packet do
      response = Packet.encode(reply_packet)
      :gen_udp.send(state.socket, addr, port, response)
    end
    {:noreply, state}
  end
end
