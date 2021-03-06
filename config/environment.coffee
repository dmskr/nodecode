skinstore = require('connect-mongoskin')
cookieParser = require('cookie-parser')
session = require('express-session')
bodyParser = require('body-parser')
flash = require('connect-flash')
serveStatic = require('serve-static')
poweredBy = require('connect-powered-by')
morgan  = require('morgan')
methodOverride = require('method-override')

app = Code
app.set('views', app.root + "/app")
app.set('view options', { layout: false })
app.use(bodyParser())
app.use(cookieParser())

[database, port] = if app.settings.env == 'production'
  ['nodecode', 8081]
else if app.settings.env == 'test'
  ['nodecode_test', 8082]
else
  ['nodecode_dev', 8081]

mongourl = "mongodb://localhost:27017/#{database}?auto_reconnect=true"
app.db = mongo.db(mongourl, safe: true)

app.set('port', port)

app.use(session(
  cookie:
    secure: false
    maxAge: 86400000000
    expires: (1).yearFromNow()
    httpOnly: false
  store: new skinstore(app.db)
  secret: "*vr6ylm(4bjeq^xuay@u(q0%@5hevcf=d1-prij_qu2_mg&r1q"
  key: 'nodecode.sid'
))

app.use(flash())
app.use(serveStatic("static"))
app.use(poweredBy(null))
app.use (req, res, next) ->
  original = res.render
  res.render = (template, options, callback) ->
    opts = Object.merge(options || {}, { flash: req.flash() })
    original.call res, template, opts, callback
  next()

app.use(morgan(format: 'dev'))
app.use(passport.initialize())
app.use(passport.session())
app.use(methodOverride())

