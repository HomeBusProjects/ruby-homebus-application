# Ruby HomeBus Application Class

**This repo is deprecated. Its functionality has been folded into the [ruby-homebus](https://github.com/HomeBusProjects/ruby-homebus) gem.**

This class does most of the repetitive work for Ruby HomeBus applications.

## Usage

### HomeBusAppOptions

The `HomeBusAppOptions` class is a base class that implements common options for all `HomeBusApp` applications.

Upon intialization it calls its own `app_options` method, passing it an `OptionParser` object. Override this method in your own subclass in order to add options.

You should also provide `name` and `version` methods to  return the name and version of your application.

```
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
```

# License

You may use this code according to the  terms of the [MIT License](https://romkey.mit-license.org/).
