require("../../shared/specs/helpers")

describe "Sessions Controller", ->
  describe "new", ->
    it "should render login template", (done) ->
      res.render = (template) ->
        template.should.eql Code.root + '/app/users/public/login.jade'
        done()
      Code.apps.users.controller.sessions.new(req, res, next)

  describe "create", ->

  describe "del", ->
    it "should call req.logout to remove user's cookie", (done) ->
      req.logout = done
      Code.apps.users.controller.sessions.del req, res, next

    it "should redirect back to root", (done) ->
      req.logout = ->
      res.redirect = (url) ->
        url.should.eql '/'
        done()
      Code.apps.users.controller.sessions.del req, res, next

