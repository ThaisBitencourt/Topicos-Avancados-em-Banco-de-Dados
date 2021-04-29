from flask import Flask, jsonify
from flask_cors import CORS, cross_origin
from flask_restful import Api, Resource, reqparse
import werkzeug
import pyodbc
from check_doc_content import verificar_documento

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'
api = Api(app)



class ValidateFile(Resource):
    def db_validate(self, people):
        conn = pyodbc.connect('Driver={SQL Server};'
                              'Server=GDYLQX2;'
                              'Database=Northwind;'
                              'Trusted_Connection=yes;')

        for person in people: 
            cursor = conn.cursor()
            row = cursor.execute('SELECT * FROM People where CPF = ' + person.cpf).fetchone()
            print(row)
            if row:
                person.flagAutorizacao = row.flag_documento
            print(row)
        
        return [person.serialize() for person in people]
    
    @cross_origin()
    def post(self):
        parse = reqparse.RequestParser()
        parse.add_argument('file', type=werkzeug.datastructures.FileStorage, location='files')
        args = parse.parse_args()
        file = args['file']
        file.save(file.filename)
        return jsonify({'resultData':self.db_validate(verificar_documento(file.filename))}) 
        
        

api.add_resource(ValidateFile, "/validatefile")

if __name__ == "__main__":
    app.run(debug=True)
