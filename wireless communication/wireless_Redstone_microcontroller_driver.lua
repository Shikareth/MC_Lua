local r = component.proxy(component.list("redstone")())
local m = component.proxy(component.list("modem")())

local server = "mac address"
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

local function enable(side)
  if side == nil then
    for k,v in pairs(state) do
      state[k] = true
      r.setOutput(sides[k], 15)
    end
  else
    state[side] = true
    r.setOutput(sides[side], 15)
  end
end

local function disable(side)
  if side == nil then
    for k,v in pairs(state) do
      state[k] = false
      r.setOutput(sides[k], 0)
    end
  else
    state[side] = true
    r.setOutput(sides[side], 0)
  end
end

local function timer(side, time, mode)
  if mode then
    enable(side)
    sleep(time)
    disable(side)
  else
    disable(side)
    sleep(time)
    enable(side)
  end
end

local function toogle(side)
  if side == nil then
    for k,v in pairs(state) do
      state[k] = not state[k]
      if state[k]
        enable(k)
      else
        disable(k)
      end
    end
  else
    state[side] = not state[side]
    if state[side]
      enable(side)
    else
      disable(side)
    end
  end
end

local function stateToBinary()
  local sum = 0
  for k,v in pairs(state) do
    local b = 0
    if v then b = 1 end
    sum = sum + b * math.pow(2,(sides[k]))
  end
  return sum
end  

local function toBoolean(string)
  if string == "true" then
    return true
  elseif string == "false" then
    return false
  else
    return nil
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
--           Main Routine             --
----------------------------------------

openPort(4216)

repeat
  local evt = table.pack(computer.pullSignal())
  if evt[1] == "modem_message" and evt[3] == server then 
    if evt[6] == "enable" then
      enable(evt[7])
    elseif evt[6] == "disable" then
      disable(evt[7])
    elseif evt[6] == "toggle" then
      toggle(evt[7])
    elseif evt[6] == "timer" then
      timer(evt[7], tonumber(evt[8]), toBoolean(evt[9]))
    end
    m.send(evt[3], 4216, tostring(stateToBinary()))
    computer.beep(100)
  end
until evt[1] == "interrupted"
