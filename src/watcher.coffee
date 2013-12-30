{EventEmitter} = require 'events'

# A eventemitter for watching changes on a given key for etcd.
# Emits:
# 	'change' - on value change
# 	'reconnect' - on errors/timeouts
# 	'<etcd action>' - the etcd action that triggered the watcher (set, delete, etc)..
#
# 	Automatically reconnects and backs off on errors.
#
class Watcher extends EventEmitter

	constructor: (@etcd, @key, @index = null, @options = {}) ->
		@retryAttempts = 0
		@_watch()

	_watch: () =>
		if @index is null
			@etcd.watch @key, @options, @_respHandler
		else
			@etcd.watchIndex @key, @index, @options, @_respHandler

	_respHandler: (err, val) =>
		if val?.node?.modifiedIndex?
			@retryAttempts = 0
			@index = val.node.modifiedIndex + 1
			@emit 'change', val
			@emit val.action, val if val.action?
			@_watch()
		else if err isnt null
			@emit 'reconnect', { error: err, reconnectcount: @retryAttempts }
			@_retry()
		else
			@emit 'error', "Received unexpected response '#{val}'"
			@_watch()

	_retry: () =>
		setTimeout @_watch, 500 * @retryAttempts
		@retryAttempts++

exports = module.exports = Watcher
