# Interface to Etcd2 Auth API
# https://github.com/coreos/etcd/blob/master/Documentation/auth_api.md

Etcd = require './index'
class EtcdAuth extends Etcd

  # Set username and password
  # Usage:
  #   .setUserPass(username, password)
  setUserPass: (auth = null) ->
    if auth?
        @auth = {
            user: auth.username || auth.user
            pass: auth.password || auth.pass
        }
    else
        @auth = null
    @auth

  # Get auth status
  # Usage:
  #   .authStatus(callback)
  authStatus: (callback) ->
    opt = @_prepareOpts "auth/enable"
    @client.get opt, callback

  # Enable auth
  # Usage:
  #   .enableAuth(callback)
  # 200 OK
  # 401 Bad Request (if root user has not been created)
  # 409 Conflict (already enabled)
  enableAuth: (callback) ->
    opt = @_prepareOpts "auth/enable"
    @client.put opt, callback

  # Disable auth
  # Usage:
  #   .disableAuth(callback)
  # 200 OK
  # 401 Unauthorized (if not a root user)
  # 409 Conflict (already disabled)
  disableAuth: (callback) ->
    opt = @_prepareOpts "auth/enable"
    @client.delete opt, callback

  # Get a list of users
  # Usage:
  #   .users(callback)
  #   .users({recursive: true}, callback)
  users: (options, callback) ->
    [options, callback] = @_argParser options, callback
    opt = @_prepareOpts "auth/users", "/v2", null, options
    @client.get opt, callback

  # Create Or Update A User
  # Usage:
  #   .createUser("username", "value", callback)
  # Value:
  #  * Starting password and roles when creating. 
  #  * Grant/Revoke/Password filled in when updating (to grant roles, revoke roles, or change the password).
  createUser: (username, value, options, callback) ->
    [options, callback] = @_argParser options, callback
    opt = @_prepareOpts ("auth/users/" + @_stripSlashPrefix username), "/v2", value, options
    @client.put opt, callback

  addUser: @::createUser
  updateUser: @::createUser

  # Get a user
  # Usage:
  #   .getUser("username", callback)
  #   .getUser("username", {recursive: true}, callback)
  getUser: (username, options, callback) ->
    [options, callback] = @_argParser options, callback
    opt = @_prepareOpts ("auth/users/" + @_stripSlashPrefix username), "/v2", null, options
    @client.get opt, callback


  #Create Or Update A User

  # Remove a user
  # Usage:
  #   .rmUser("username", callback)
  #   .rmUser("username", {recursive: true}, callback)
  rmUser: (username, options, callback) ->
    [options, callback] = @_argParser options, callback
    opt = @_prepareOpts ("auth/users/" + @_stripSlashPrefix username), "/v2", null, options
    @client.delete opt, callback

  delUser: @::rmUser

  # Get a list of roles
  # Usage:
  #   .roles(callback)
  #   .roles({recursive: true}, callback)
  roles: (options, callback) ->
    [options, callback] = @_argParser options, callback
    opt = @_prepareOpts "auth/roles", "/v2", null, options
    @client.get opt, callback

  # Create Or Update A Role
  # Usage:
  #   .createRole("rolename", "value", callback)
  # Value:
  #  * Starting password and roles when creating. 
  #  * Grant/Revoke/Password filled in when updating (to grant roles, revoke roles, or change the password).
  createRole: (rolename, value, options, callback) ->
    [options, callback] = @_argParser options, callback
    opt = @_prepareOpts ("auth/roles/" + @_stripSlashPrefix rolename), "/v2", value, options
    @client.put opt, callback

  addRole: @::createRole
  updateRole: @::createRole

  # Get a role
  # Usage:
  #   .getRole("rolename", callback)
  #   .getRole("rolename", {recursive: true}, callback)
  getRole: (rolename, options, callback) ->
    [options, callback] = @_argParser options, callback
    opt = @_prepareOpts ("auth/roles/" + @_stripSlashPrefix rolename), "/v2", null, options
    @client.get opt, callback


  #Create Or Update A Role

  # Remove a role
  # Usage:
  #   .rmRole("rolename", callback)
  #   .rmRole("rolename", {recursive: true}, callback)
  rmRole: (rolename, options, callback) ->
    [options, callback] = @_argParser options, callback
    opt = @_prepareOpts ("auth/roles/" + @_stripSlashPrefix rolename), "/v2", null, options
    @client.delete opt, callback

  delRole: @::rmRole



exports = module.exports = EtcdAuth
