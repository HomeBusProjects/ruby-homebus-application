#!/usr/bin/env ruby

require './lib/homebus_app'
require './lib/homebus_app_options'
require 'mqtt'
require 'json'

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
    value = {
      foo: 'bar',
      timestamp: Time.now.to_i
    }

    @mqtt.publish '/example', value.to_json, true
    sleep 30
  end

  def manufacturer
    'HomeBus'
  end

  def model
    'Example'
  end

  def friendly_name
    'Example'
  end

  def friendly_location
    'HomeBus Core'
  end

  def serial_number
    ''
  end

  def pin
    ''
  end

  def devices
       [ {
        friendly_name: 'System Ticker',
        friendly_location: 'The Core',
        update_frequency: 1000,
        accuracy: 10,
        precision: 100,
        wo_topics: [ 'tick' ],
        ro_topics: [],
        rw_topics: []
         } ]
  end
end


hbao = MyAppOptions.new

hba = MyApp.new hbao.options
hba.run!

