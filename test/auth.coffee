should = require 'should'
nock = require 'nock'
EtcdAuth = require '../src/auth'

# Set env var to skip timeouts
process.env.RUNNING_UNIT_TESTS = true

# Helpers
auth = { user: 'root', pass: 'root' }
getNock = (host = 'http://127.0.0.1:4001') ->
  nock(host)

describe 'Basic functions', ->
  etcd = new EtcdAuth

  checkVal = (done) ->
    (err, val) ->
      val.should.containEql { value: "value" }
      done err, val

  describe '#setUserPass()', ->
    it 'should set username and password for etcd api authentication', () ->
      etcd.setUserPass(auth)
      etcd.auth.user.should.equal auth.user
      etcd.auth.pass.should.equal auth.pass
    it 'should able to clean out username and password', () ->
      etcd.setUserPass()
      etcd.should.not.have.property auth

  describe '#authStatus()', ->
    it 'should return auth status from etcd', (done) ->
      response = '{"enabled": true}'
      getNock()
        .get('/v2/auth/enable')
        .reply(200, response)
      etcd.authStatus (err, val) ->
        val.enabled.should.equal true
        done err, response

  describe '#enableAuth()', ->
    it 'should enable auth', (done) ->
      getNock()
        .put('/v2/auth/enable')
        .reply(200)
      etcd.enableAuth done

  describe '#disableAuth()', ->
    it 'should disable auth', (done) ->
      getNock()
        .delete('/v2/auth/enable')
        .reply(200)
      etcd.disableAuth done

    it 'should use basicAuth', (done) ->
      response = '{"enabled": true}'
      getNock()
        .delete('/v2/auth/enable')
        .basicAuth(auth)
        .reply(200, response)
      etcd.setUserPass(auth)
      etcd.disableAuth done

  describe '#users()', ->
    it 'should return user list from etcd', (done) ->
      getNock()
        .get('/v2/auth/users')
        .reply(200, '{"value":"value"}')
      etcd.users 'key', checkVal done

    it 'should send options to etcd as request url', (done) ->
      getNock()
        .get('/v2/auth/users?recursive=true')
        .reply(200, '{"value":"value"}')
      etcd.users { recursive: true }, checkVal done

  describe '#createUser()', ->
    it 'should create user', (done) ->
      getNock()
        .put('/v2/auth/users/username')
        .reply(200, '{"value":"value"}')
      etcd.createUser 'username', '{"value":"value"}', checkVal done

  describe '#updateUser()', ->
    it 'should update user', (done) ->
      getNock()
        .put('/v2/auth/users/username')
        .reply(200, '{"value":"value"}')
      etcd.updateUser 'username', '{"value":"value"}', checkVal done

  describe '#getUser()', ->
    it 'should return an user entry from etcd', (done) ->
      getNock()
        .get('/v2/auth/users/username')
        .reply(200, '{"value":"value"}')
      etcd.getUser 'username', checkVal done

    it 'should callback with error on error', (done) ->
      getNock()
        .get('/v2/auth/users/username')
        .reply(404, {"errorCode": 100, "message": "User not found"})
      etcd.getUser 'username', (err, val) ->
        err.should.be.instanceOf Error
        err.error.errorCode.should.equal 100
        err.message.should.equal "User not found"
        done()

  describe '#rmUser()', ->
    it 'should remove user', (done) ->
      getNock()
        .delete('/v2/auth/users/username')
        .reply(200, '{"value":"value"}')
      etcd.rmUser 'username', checkVal done

  describe '#roles()', ->
    it 'should return role list from etcd', (done) ->
      getNock()
        .get('/v2/auth/roles')
        .reply(200, '{"value":"value"}')
      etcd.roles 'key', checkVal done

    it 'should send options to etcd as request url', (done) ->
      getNock()
        .get('/v2/auth/roles?recursive=true')
        .reply(200, '{"value":"value"}')
      etcd.roles { recursive: true }, checkVal done

  describe '#createRole()', ->
    it 'should create role', (done) ->
      getNock()
        .put('/v2/auth/roles/rolename')
        .reply(200, '{"value":"value"}')
      etcd.createRole 'rolename', '{"value":"value"}', checkVal done

  describe '#updateRole()', ->
    it 'should update role', (done) ->
      getNock()
        .put('/v2/auth/roles/rolename')
        .reply(200, '{"value":"value"}')
      etcd.updateRole 'rolename', '{"value":"value"}', checkVal done

  describe '#getRole()', ->
    it 'should return an role entry from etcd', (done) ->
      getNock()
        .get('/v2/auth/roles/rolename')
        .reply(200, '{"value":"value"}')
      etcd.getRole 'rolename', checkVal done

    it 'should callback with error on error', (done) ->
      getNock()
        .get('/v2/auth/roles/rolename')
        .reply(404, {"errorCode": 100, "message": "Role not found"})
      etcd.getRole 'rolename', (err, val) ->
        err.should.be.instanceOf Error
        err.error.errorCode.should.equal 100
        err.message.should.equal "Role not found"
        done()

  describe '#rmRole()', ->
    it 'should remove role', (done) ->
      getNock()
        .delete('/v2/auth/roles/rolename')
        .reply(200, '{"value":"value"}')
      etcd.rmRole 'rolename', checkVal done