import flask

from flask import Flask, request, make_response
app = Flask(__name__)

@app.route("/")  # $routeSetup="/"
def hello_world():  # $routeHandler
    return "Hello World!"

from flask.views import MethodView

class MyView(MethodView):

    def get(self, user_id): # $f-:routeHandler
        if user_id is None:
            # return a list of users
            pass
        else:
            # expose a single user
            pass

the_view = MyView.as_view('my_view')

app.add_url_rule('/the/', defaults={'user_id': None},  # $routeSetup="/the/"
                 view_func=the_view, methods=['GET',])

@app.route("/dangerous")  # $routeSetup="/dangerous"
def dangerous():  # $routeHandler
    return request.args.get('payload')

@app.route("/dangerous-with-cfg-split")  # $routeSetup="/dangerous-with-cfg-split"
def dangerous2():  # $routeHandler
    x = request.form['param0']
    if request.method == "POST":
        return request.form['param1']
    return None

@app.route("/unsafe")  # $routeSetup="/unsafe"
def unsafe():  # $routeHandler
    first_name = request.args.get('name', '')
    return make_response("Your name is " + first_name)

@app.route("/safe")  # $routeSetup="/safe"
def safe():  # $routeHandler
    first_name = request.args.get('name', '')
    return make_response("Your name is " + escape(first_name))

@app.route("/hello/<name>")  # $routeSetup="/hello/<name>"
def hello(name):  # $routeHandler $routedParameter=name
    return make_response("Your name is " + name)

@app.route("/foo/<path:subpath>")  # $routeSetup="/foo/<path:subpath>"
def foo(subpath):  # $routeHandler $routedParameter=subpath
    return make_response("The subpath is " + subpath)

@app.route("/multiple/")  # $routeSetup="/multiple/"
@app.route("/multiple/foo/<foo>")  # $routeSetup="/multiple/foo/<foo>"
@app.route("/multiple/bar/<bar>")  # $routeSetup="/multiple/bar/<bar>"
def multiple(foo=None, bar=None):  # $routeHandler $routedParameter=foo $routedParameter=bar
    return make_response("foo={!r} bar={!r}".format(foo, bar))

@app.route("/complex/<string(length=2):lang_code>")  # $routeSetup="/complex/<string(length=2):lang_code>"
def complex(lang_code):  # $routeHandler $routedParameter=lang_code
    return make_response("lang_code {}".format(lang_code))

if __name__ == "__main__":
    app.run(debug=True)
