require("../../shared/specs/helpers")

describe "Users Public Controller", ->
  describe "new", ->
    it "should render signup public template", (done) ->
      res.render = (template) ->
        template.should.eql Code.root + '/app/users/public/signup.jade'
        done()
      Code.apps.users.controller.public.new req, res, next


