# frozen_string_literal: true

require_relative 'config/database/connection'
require_relative 'config/main'

DB = Config::Database::Connection.new.db

run DiscoOcto
