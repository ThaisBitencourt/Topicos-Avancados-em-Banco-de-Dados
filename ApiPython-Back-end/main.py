from flask import Flask
from flask_restful import Api, Resource, reqparse
import werkzeug
from check_doc_content import verificar_documento

app = Flask(__name__)
api = Api(app)


class HelloWorld(Resource):
    def get(self):
        return "Hello World"

    def post(self):
        parse = reqparse.RequestParser()
        parse.add_argument('file', type=werkzeug.datastructures.FileStorage, location='files')
        args = parse.parse_args()
        file = args['file']
        file.save(file.filename)
        return verificar_documento(file.filename)


api.add_resource(HelloWorld, "/helloworld")

if __name__ == "__main__":
    app.run(debug=True)