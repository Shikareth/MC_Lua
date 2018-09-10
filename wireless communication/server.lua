----------------------------------------
--        Wireless Mainframe       --
----------------------------------------

local component = require("component")
local event = require("event")

local packets = {}

function initializeServer(port)
  if not component.modem.isOpen(port) then
    if not component.modem.open(port) then
      print("Failed to poen port. Check network card")
      return
    end
    io.write("port: ", port, " is open\n")
  end
  print("Server started")
  component.modem.broadcast(port, Server started")
end

function push(...)
  local packet = {...}
  local source = packet[3]
  io.write("\n, source, "\t", packet[6])
  table.insert(packets, {source, packet[6]})
end

function pull()
  local packet = table.remove(packets, 1)
  if packet[2] == "resetAE" then
    os.execute(pwd.."proc/resetAE")
  elseif packet[2] == "spawner" then
    os.execute(pwd.."proc/spawner")
  elseif packet[2] == "voidoreminer" then
    os.execute(pwd.."proc/voidoreminer")
  elseif packet[2] == "ack" then
    computer.beep(1000)
  end
end

----------------------------------------
--         Main Procedure       --
----------------------------------------

os.execute("clear")
initializeServer(4216)
repeat
  local evt = table.pack(event.pull())
  if evt[1] == modem_message" then
    push(table.unpack(vet))
    pull()
  end
until evt[1] == "interrupted"