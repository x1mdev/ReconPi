
For serving directories of static assets, Revel provides the **static** built in module,
which contains a single
[Static](https://godoc.org/github.com/revel/modules/static/app/controllers#Static)
controller.  

[Static.Serve](https://godoc.org/github.com/revel/modules/static/app/controllers#Static.Serve) action takes two parameters:
 `(file path relative to app)`, `(exact file name)`

[Static.ServeModule](https://godoc.org/github.com/revel/modules/static/app/controllers#Static.ServeModule) action takes three parameters:
`(module name)`, `(file path relative to app)`, `(exact file name)`

[Static.ServeDir](https://godoc.org/github.com/revel/modules/static/app/controllers#Static.ServeDir) action takes one parameter:
`(file path relative to app)`


## Config

The [`static`](https://godoc.org/github.com/revel/modules/static/app/controllers) module
is optional **is** enabled by default. 

By default when you create a new project the following
configuration options are set in the file:

```ini
module.static = github.com/revel/modules/static
```

Additionally, these will be set in routes `conf/routes`:

```
	GET    /public/*filepath            Static.Serve("public")
	GET    /favicon.ico                 Static.Serve("public","img/favicon.png")
    GET     /public/*filepath           Static.ServeDir("public")
    GET     /public                     Static.ServeDir("public")
```

The syntax used for defining
a route is `Controller.Action(prefix,filepath)`. So the word `public`
has nothing to do with visibility, it follows the default 
directory

* `prefix` (string) - A (relative or absolute) path to the asset root.
* `filepath` (string) - A relative path that specifies the requested file.

**Bad example**

	GET    /img/icon.png                Static.Serve("public", "img/icon.png") << space causes error

<div class="alert alert-warning">
Important:<br>For the two parameters version of <code>Static.Serve</code>, blank spaces are not allowed between
<code>"</code> and <code>,</code> due to how <a href="http://golang.org/pkg/encoding/csv/"><code>encoding/csv</code></a> works.
</div>
<div class="alert alert-danger">Static content can only be served from within the application root for security reasons. To include `external assets` consider symbolic links or a git submodule</div>

## Best Practices
Although Revel does serve out static content in the most efficient way it can, it 
makes more sense for your web server to serve the static files directly. 