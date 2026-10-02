--!strict
--!native
--!optimize 2
local Signal = {}

type connection = (...any) -> ()
type connections = {connection}

type signal_data = {
	connections: connections,
	threads: {thread},
}

local signal_data = {}

function Signal.new(): number
	local signal_id = #signal_data + 1
	signal_data[signal_id] = {
		connections = {},
		threads = {},
	}

	return signal_id
end

function Signal.fire(signal: number, ...)
	local data: signal_data = signal_data[signal]
	if data then
		for i = 1, #data.connections do
			task.spawn(data.connections[i], ...)
		end
	end
end

function Signal.connect(signal: number, callback: connection): (() -> ())?
	local data: signal_data = signal_data[signal]
	if data then
		table.insert(data.connections, callback)

		return function()
			local index = table.find(data.connections, callback)
			if index then
				table.remove(data.connections, index)
			end
		end
	end

	return nil
end

function Signal.once(signal: number, callback: connection): (() -> ())?
	local data: signal_data = signal_data[signal]
	if data then
		local connection: any;
		connection = Signal.connect(signal, function(...)
			task.spawn(callback, ...)
			if connection then
				connection()
				connection = nil :: any
			end
		end)
	end

	return nil
end

function Signal.wait(signal: number): ...any
	local data: signal_data = signal_data[signal]
	if data then
		local thread = coroutine.running()
		table.insert(data.threads, thread)

		local connection; connection = Signal.once(signal, function(...)
			local index = table.find(data.threads, thread)
			if index then
				table.remove(data.threads, index)
			end
			coroutine.resume(thread, ...)
		end)

		return coroutine.yield()
	end
end

function Signal.disconnectAll(signal: number)
	local data: signal_data = signal_data[signal]
	if data then
		data.connections = {}

		for i = 1, #data.threads do
			coroutine.resume(data.threads[i], nil)
		end

		data.threads = {}
	end
end

function Signal.destroy(signal: number)
	Signal.disconnectAll(signal)
	signal_data[signal] = nil
end

return Signal
