require 'socket'
require 'securerandom'
require 'base64'
require 'json'
class Janl
  @server_port = 48042
  @port = 48043
  @soc = nil

  def init
    # addr = ['255.255.255.255', @server_port]
    addr = ['<broadcast>', 48042]
    @soc = UDPSocket.new
    @soc.setsockopt(Socket::SOL_SOCKET, Socket::SO_BROADCAST, true)
    packet = {type: :public_key_request, id: SecureRandom.uuid(), data: ""}
    data = JSON.generate(packet)

    @soc.send(Base64.encode64(data), 0, addr[0], addr[1])
    data, _addr = @soc.recvfrom(1024)

    r = Base64.decode64(data)
    response = JSON.parse(r)
    key = OpenSSL::PKey::RSA.new(response["data"])

    log = {time: Time.new().to_i(), level: :debug, verbosity: 1, message: "hello world"}
    lpacket = {
      type: :log,
      id: SecureRandom.uuid(),
      data: Base64.encode64(key.public_encrypt(JSON.generate(log)))
    }
    @soc.send(Base64.encode64(JSON.generate(lpacket)), 0, addr[0], addr[1])

    @soc.close()
  end
end

j = Janl.new()
j.init()
