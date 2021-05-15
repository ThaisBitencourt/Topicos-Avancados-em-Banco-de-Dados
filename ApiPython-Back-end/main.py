from os import error
from flask import Flask, jsonify, request, abort
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
            row = cursor.execute("EXECUTE AS USER = 'app';  SELECT * FROM People where CPF = " + person.cpf + "'").fetchone()
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
        
        

class Acao(Resource):
    @cross_origin()
    def post(self):
        conn = pyodbc.connect('Driver={SQL Server};'
                              'Server=GLADOS\MSSQLSERVER01;'
                              'Database=Northwind;'
                              'Trusted_Connection=yes;')
        cursor = conn.cursor() 
        parser = reqparse.RequestParser()
        parser.add_argument('cpf', type=str, required=True, help="Insira um CPF para alterar ou verificar o status da autorização.")
        parser.add_argument('acao', type=str)
        args = parser.parse_args()
        cpf = args['cpf']
        acao = args['acao']
        if(acao == 'optin'):
            cursor.execute("EXECUTE AS USER = 'app'; UPDATE dbo.People SET flag_documento = 1 WHERE CPF = '"+ cpf +"';")
            conn.commit()

        elif(acao == 'optout'):
            cursor.execute("EXECUTE AS USER = 'app';  UPDATE dbo.People SET flag_documento = 0 WHERE CPF = '"+ cpf +"';")
            conn.commit()
            
        row = cursor.execute("EXECUTE AS USER = 'app';  SELECT * FROM People where CPF = '" + cpf + "'").fetchone()

        if row:
            return jsonify({'resultData':{'flag':row.flag_documento}})

        else:
            return jsonify({'error':True, 'msg':'CPF não cadastrado'})

api.add_resource(ValidateFile, "/validatefile")
api.add_resource(Acao, "/changeflag")

if __name__ == "__main__":
    app.run(debug=True)