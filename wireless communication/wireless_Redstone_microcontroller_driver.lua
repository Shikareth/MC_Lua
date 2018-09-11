local m = component.proxy(component.list("modem")())
local r = component.proxy(component.list("redstone")())

local server = "mac address"
local port = 4216
local sides = { bottom = 0, front = 1, back = 2, top = 3, right = 4, left = 5 }
local state = { bottom = false,  front = false, back = false, top = false, right = false, left = false }

----------------------------------------
--             Functions              --
----------------------------------------

local function sleep(timeout)
  local deadline = computer.uptime() + (timeout or 0)
  repeat
    computer.pullSignal(deadline - computer.uptime())
  until computer.uptime() >= deadline
end

function state2number(x)
  if x then
    return 15
  elseif not x then
    return 0
  else
    return nil
  end
end

function toboolean(x)
  if type(x) == "number" then
    if x == 1 then return true end
    if x == 0 then return false end
    return nil
  elseif type(x) == "string" then
    if x == "true" then return true end
    if x == "false" then return false end
    return nil
  end
  assert(false, "invalid type")
end

function enable(t)
  if t[1] == nil then
    for k,v in pairs(sides) do
      if k ~= "n" then
        state[k] = true
        r.setOutput(v,15)
      end
    end
  else
    for k,v in pairs(t) do
      if k ~= "n" then      
        state[v] = true
        r.setOutput(sides[v], 15)
      end
    end
  end
end

function disable(t)
  if t[1] == nil then
    for k,v in pairs(sides) do
      if k ~= "n" then
        state[k] = false
        r.setOutput(v,0)
      end
    end
  else
    for k,v in pairs(t) do
      if k ~= "n" then      
        state[v] = false
        r.setOutput(sides[v], 0)
      end
    end
  end
end

function toggle(t)
  if t[1] == nil then
    for k,v in pairs(sides) do
      if k ~= "n" then
        state[k] = not state[k]
        r.setOutput(v,state2number(state[k]))
      end
    end
  else
    for k,v in pairs(t) do
      if k ~= "n" then      
        state[v] = not state[v]
        r.setOutput(sides[v], state2number(state[v]))
      end
    end
  end
end

function timer(t)
  local time = tonumber(t[1])
  local mode = toboolean(t[2])
  for i=1,2,1 do table.remove(t, 1) end
  if mode then
    enable(t)
    sleep(time)
    disable(t)
  else
    disable(t)
    sleep(time)
    enable(t)
  end
end

function openPort(port)
  if not m.isOpen(port) then  
    m.open(port)
    computer.beep(1000)
    computer.beep(2000)
    computer.beep(1000)
  end
end

----------------------------------------
--            Main Routine            --
----------------------------------------

openPort(port)
repeat 
  local evt = table.pack(computer.pullSignal())
  local type = evt[1]
  local from = evt[3]
  local cmd = evt[6]
  local result = true
  if type == "modem_message" then
    for i=1,6,1 do
      table.remove(evt, 1)
    end
    --print("Type: ",type)
    --print("From: ",from)
    --print("CMD : ",cmd)
    --print(table.unpack(evt))
    if cmd == "enable" then
      enable(evt)
    elseif cmd == "disable" then
      disable(evt)
    elseif cmd == "toggle" then
      toggle(evt)
    elseif cmd == "timer" then
      if #evt < 2 then 
        result = false
      else
        timer(evt)
      end
    else
      result = false
    end
    if result then
      m.send(tostring(from), port, "ack")
    else
      m.send(tostring(from), port, "error")
    end
  end
until type == "interrupted"