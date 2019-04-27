#!/usr/bin/env ruby

require './lib/homebus_app'
require './lib/homebus_app_options'

class MyAppOptions < HomeBusAppOptions
  def app_options(op)
    help_chastise   = 'Bad zoot!'
    help_everything = 'Make me one with everything'
    help_sammich    = 'Make me a sammich'

    op.separator 'Example options'
    op.on('-c', '--chastise SOMEONE', help_chastise);
    op.on('-e', '--everything',       help_everything);
    op.on('-s', '--sammich',          help_sammich);
    op.separator ''
  end

  def name
    'test app'
  end

  def version
    '0.0.1'
  end
end

class MyApp < HomeBusApp
  def setup!

  end

  def work!

  end
end


hbao = MyAppOptions.new

hba = HomeBusApp.new hbao.options
