# Mongo::Logger.logger defaults to Mongoid.logger, which IS Rails.logger (the
# same object) - so touching its level would silence normal Rails request
# logs too. Give the driver its own logger instead, set after Mongoid's
# railtie assigns Mongo::Logger.logger = Mongoid.logger in its own
# after_initialize (a regular initializer here would run too early and get
# overwritten).
#
# WARN+ still surfaces real connection problems; only the driver's debug-level
# chatter (SDAM/topology changes, per-command STARTED/SUCCEEDED lines) is quieted.
Rails.application.config.after_initialize do
  mongo_logger = Logger.new($stdout)
  mongo_logger.level = Logger::WARN
  Mongo::Logger.logger = mongo_logger
end
