# Wake::Assets

This module helps you render links to assets managed using
[wake](http://github.com/jcoglan/wake). It's easy to set up and works with any
Ruby web framework.


## Installation

```
$ gem install wake-assets
```


## Usage

These examples are based on the [wake example build
config](https://github.com/jcoglan/wake#usage).

#### At boot time

When your app boots, create an instance of `Wake::Assets` and keep this object
around through the lifetime of the app process. For example, in Rails:

```ruby
require 'wake/assets'

dev = Rails.env.development?

$wake = Wake::Assets.new(
  :wake  => File.expand_path('node_modules/.bin/wake', Rails.root),
  :root  => File.expand_path('public', Rails.root),
  :mode  => dev ? :sources : :targets,
  :cache => !dev
)
```

The options are:

* `:wake` - the path to your `wake` executable
* `:root` - the document root of your application
* `:mode` - `:sources` if you want to render links to source files, `:targets`
  if you want optimised files
* `:cache` - whether to cache `wake` metadata files in memory, recommended in
  production but not in development

#### At request time

On each request, create a renderer from your `Assets` instance. In Rails, you
might do this with a helper:

```ruby
module AssetsHelper
  CONFIG_PATH = File.expand_path('package.json', Rails.root)
  ASSET_HOSTS = JSON.parse(File.read(CONFIG_PATH))['wake']['css']['hosts']

  def assets
    @assets ||= $wake.renderer(
      :builds => {
        'css'        => request.ssl? ? 'ssl' : 'min',
        'javascript' => 'min',
        'binary'     => 'min'
      },
      :hosts  => ASSET_HOSTS[Rails.env][request.ssl? ? 'https' : 'http'],
      :inline => false
    )
  end
end
```

The options are:

* `:builds` - which build to use for each asset type, the default for each is
  `min`
* `:hosts` - the set of asset hosts to use for rendering links, the default is
  an empty list
* `:inline` - whether to render assets inline so the browser does not make
  additional requests for them, default is `false`

#### In your templates

With this helper in place, you can render links to JavaScript, CSS and images:

```ruby
assets.include_js 'scripts.js'
# => '<script type="text/javascript" src="/assets/scripts-bb210c6.js"></script>'

assets.include_css 'style.css'
# => '<link rel="stylesheet" type="text/css" href="/assets/styles-5a2ceb1.css">'

assets.include_image 'logo.png', :html => {:alt => 'Logo'}
# => '<img src="/assets/logo-2fa8d38.png" alt="Logo">'
```

You can pass the `:inline` option to any of these to override the per-request
`:inline` setting:

```ruby
assets.include_js 'scripts.js', :inline => true
# => '<script type="text/javascript">alert("Hello, world!")</script>'
```


## License

(The MIT License)

Copyright (c) 2013 James Coglan, Songkick

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the 'Software'), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

