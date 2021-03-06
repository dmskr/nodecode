process.env.NODE_ENV = 'test'
chai = require('chai')

require('../../../server')
DatabaseCleaner = require('database-cleaner')

Object.merge global,
  databaseCleaner: new DatabaseCleaner('mongodb')
  should: chai.should()

request = null
beforeEach (done) ->
  databaseCleaner.clean Code.db, (err) ->
    return done(err) if(err)

    request = global.request
    global.req =
      params: {}
      query: {}
      body: {}
      flash: ->

    global.res =
      render: ->
      redirect: ->
      setHeader: ->

    global.next = (err) -> throw err if err
    done()

afterEach (done) ->
  global.request = request
  done()

global.shouldHaveCreatedAt = (collection) ->
  it "should store createdAt when saved for first time", (done) ->
    Code.db[collection].save { something: 'Ya!' }, (err, record) ->
      should.exist(record.createdAt)
      done()

  it "should not refresh createdAt if already provided", (done) ->
    time = (1).hourFromNow()
    Code.db[collection].save { some: 'Yo!', createdAt: time }, (err, record) ->
      return done(err) if err
      record.createdAt.should.eql(time)
      done()

global.shouldHaveUpdatedAt = (collection) ->
  it "should always insert updatedAt", (done) ->
    time = (1).hourFromNow()
    Code.db[collection].save { some: 'Yo!', updatedAt: time }, (err, record) ->
      return done(err) if err
      should.exist(record.updatedAt)
      record.updatedAt.should.not.eql(time)
      done()

global.shouldHaveRoutes = (routes, user, collection) ->
  app = null
  beforeEach ->
    app = express()
    app.apps = Object.clone(Code.apps, true)

  Object.keys(routes).each (key) ->
    [method, url] = key.split(' ')
    [collection, controller, action] = routes[key].split('.')
    it "#{method.toUpperCase()} #{url} should match #{routes[key]}", (done) ->
      app.apps[collection].controller[controller][action] = -> done()
      app.apps[collection].routes.route(app)
      app.handle Object.merge(req, { method: method, url: url, user: user }), res, next

global.shouldNotHaveRoutes = (routes, user, collection) ->
  app = null
  beforeEach ->
    app = express()
    app.apps = Object.clone(Code.apps, true)

  routes.each (route) ->
    [method, url] = route.split(' ')
    it "#{method.toUpperCase()} #{url} should return error 401", (done) ->
      app.apps[collection].routes.route(app)
      app.handle Object.merge(req, { method: method, url: url }), res, (err) ->
        err.should.eql new Error(401)
        done()

global.testPagingFor = (params) ->
  collection = params.collection
  action = params.action or "index"
  sort = params.sort or "createdAt"
  beforeEach (done) ->
    async.times 150, ((index, next) ->
      entity = title: index
      entity[sort] = Date.create(index)
      Code.db[collection].save entity, (err, result) ->
        return done(err)  if err
        next()
    ), done

  it "should render 100 entities only", (done) ->
    res.render = (template, options) ->
      options.data.length.should.eql 100
      done()
    Code.apps[collection].controller.admin[action] req, res, next

  it "should show 0 page by default", (done) ->
    res = render: (view, params) ->
      params.data.first()[sort].should.eql Date.create(149)
      done()
    Code.apps[collection].controller.admin[action] req, res, next

  it "should return total number of entities", (done) ->
    res.render = (view, params) ->
      params.total.should.eql 150
      done()
    Code.apps[collection].controller.admin[action] req, res, next

  it "should render requested page", (done) ->
    req.query = page: "1"
    res.render = (view, params) ->
      params.data.length.should.eql 50
      done()
    Code.apps[collection].controller.admin[action] req, res, next

  it "should return currently selected page", (done) ->
    req.query = page: "1"
    res.render = (view, params) ->
      params.page.should.eql 1
      done()
    Code.apps[collection].controller.admin[action] req, res, next

