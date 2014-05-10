require "../../shared/specs/helpers"

describe "User", ->
  describe 'skin save', ->
    shouldHaveCreatedAt('users')
    shouldHaveUpdatedAt('users')

    describe "Keywords", ->
      fromText = null
      beforeEach ->
        fromText = Code.db.keywords.fromText

      afterEach ->
        Code.db.keywords.fromText = fromText

      it "should call keywords.fromText on username", (done) ->
        Code.db.keywords.fromText = (text, callback) ->
          text.should.eql "Monkey Coder monkey@zoo.com"
          fromText text, callback

        Code.db.users.save
          username: "Monkey Coder"
          email: "monkey@zoo.com"
        , (err, user) ->
          user.keywords.should.eql [
            "monkey"
            "coder"
            "zoo"
            "com"
          ]
          done()

      it "should skip username if not specified", (done) ->
        Code.db.users.save
          email: "monkey@zoo.com"
        , (err, user) ->
          user.keywords.should.eql [
            "monkey"
            "zoo"
            "com"
          ]
          done()

  describe "autocomplete", ->
    beforeEach (done) ->
      async.each [
        {
          username: "Monkey Coder"
          email: "monkey@coder.com"
        }
        {
          username: "Orangutan"
          email: "orangutan@monkey.com"
        }
      ], ((user, next) ->
        Code.db.users.save user, next
      ), done

    it "should return empty array if no text provided", (done) ->
      Code.db.users.autocomplete "", (err, users) ->
        should.not.exist err
        users.should.eql []
        done()

    it "should find user by if term is metioned in display name and / or email", (done) ->
      Code.db.users.autocomplete "Coder", (err, users) ->
        should.not.exist err
        users.length.should.eql 1
        users.first().username.should.eql "Monkey Coder"
        done()

    it "should find user by if term is metioned in display name and / or email", (done) ->
      Code.db.users.autocomplete "Monkey", (err, users) ->
        should.not.exist err
        users.length.should.eql 2
        users[1].email.should.eql "orangutan@monkey.com"
        done()

    it "should find user by full email", (done) ->
      Code.db.users.autocomplete "monkey@coder.com", (err, users) ->
        should.not.exist err
        users.length.should.eql 1
        users[0].email.should.eql "monkey@coder.com"
        done()

  describe "validate", ->
    it "should return error on username if username is absent", (done) ->
      Code.db.users.validate {}, (err, results) ->
        should.exist results.username
        done()

    it "should return error on password if password is absent", (done) ->
      Code.db.users.validate {}, (err, results) ->
        should.exist results.password
        done()

    it "should return error on email if email doesn't look like email", (done) ->
      Code.db.users.validate
        username: 'monkey'
        email: "something"
      , (err, results) ->
        return done(err) if err
        should.exist results.email
        done()

    it "should not return eny errors if email does exist and look just ok", (done) ->
      Code.db.users.validate
        email: "monkey@zoo.com"
        username: "Monkey Zilla"
        password: "secret"
      , (err, results) ->
        return done(err) if err
        results.should.eql {}
        done()

    it "should return an error if confirmation password does not match the password itself", (done) ->
      Code.db.users.validate
        password: "secret"
        confirmationPassword: "supersecret"
      , (err, results) ->
        should.exist results.password
        done()

    it "should return an error if confirmation password does exist, but empty", (done) ->
      Code.db.users.validate
        password: "secret"
        confirmationPassword: ""
      , (err, results) ->
        should.exist results.password
        done()

    it "should not return any errors if confirmation password does not exist at all", (done) ->
      Code.db.users.validate
        password: "secret"
      , (err, results) ->
        should.not.exist results.confirmationPassword
        done()

  describe "hashPassword", ->
    it "should return immediately if password is undefined", (done) ->
      Code.db.users.hashPassword undefined, (err, password) ->
        return done(err)  if err
        should.not.exist password
        done()

