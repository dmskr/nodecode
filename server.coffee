global.express = require('express')
global.connect = require('connect')
global.sugar = require("sugar")
global.mongo = require('mongoskin')
global.fs = require('fs')
global.passport = require('passport')
global.LocalStrategy = require('passport-local').Strategy
global.bcrypt = require('bcrypt')
global.crypto = require('crypto')
global.querystring = require('querystring')
global.exec = require('child_process').exec
global.nodemailer = require('nodemailer')
global.URI = require('url')
global.Path = require('path')
global.async = require('async')

global.Code = express()
Code.root = __dirname
Code.settings.port = 8081

global.server = require('http').createServer(Code)
global.isServer = true

# Setup SMTP
Code.settings.email = {
  auth: {
    host: "",
    secureConnection: false,
    port: 111,
    auth: {
      user: "",
      pass: ""
    }
  }
}

global.smtp = nodemailer.createTransport("SMTP", Code.settings.email.auth)

# Cache timestamps
Code.locals.tsjs = Code.locals.tscss = Date.create().getTime()

# Environment
require("./config/environment")

# Applications
require("./config/applications")

# Run the server
env = (process.env.NODE_ENV || 'development').capitalize()
server.listen(Code.settings.port)
console.log("Http server listening on http://0.0.0.0:8081")
console.log("NodeCode server started in #{env} environment")

