Code.apps = {} if !Code.apps

apps = Code.apps
files = fs.readdirSync("#{Code.root}/app").findAll (name) ->
  name != '.' && name != '..'

files.each (name) ->
  apps[name] ||= {}
  apps[name].controller ||= {}
  
  # Setup public/private/admin controllers
  ['admin', 'public', 'private'].each (role) ->
    path = "#{Code.root}/app/#{name}/#{role}_controller"
    if fs.existsSync("#{path}.coffee")
      apps[name].controller[role] = require(path)

  # Setup default model if exist
  model = "#{Code.root}/app/#{name}/#{name.singularize()}"
  if fs.existsSync("#{model}.coffee")
    require(model)

# Additional models
require "#{Code.root}/app/shared/keywords"

# Additional controllers out of public/private/admin scheme
apps.users.controller.sessions = require("../app/users/sessions_controller")

# Util function used in routes
global.require_user = (req, res, next) ->
  return next(new Error(401)) if !req.user
  next()

global.require_admin = (req, res, next) ->
  return next(new Error(401)) if !req.user or !req.user.admin
  next()

# Set routes
files.each (name) ->
  apps[name].routes = require("../app/#{name}/routes")
  apps[name].routes.route(Code)

# The 404 Route (ALWAYS Keep this as the last route)
if Code.apps.shared
  Code.get('/*', Code.apps.shared.controller.public.notFound)
  Code.post('/*', Code.apps.shared.controller.public.notFound)


