import os
import cloudinary as cloudinary
from flask import Flask, json, jsonify
from flask_cors import CORS, cross_origin
from flask_cors.core import RegexObject
from flask_restful import Api, Resource, reqparse
import cloudinary.uploader
import werkzeug
import pyodbc
from check_doc_content import verificar_documento

app = Flask(__name__)
cors = CORS(app)
app.config['CORS_HEADERS'] = 'Content-Type'
api = Api(app)

connection_string=('Driver={SQL Server};'
                    'Server=GLADOS\MSSQLSERVER01;'
                    'Database=Northwind;'
                    'Trusted_Connection=yes;')

class ValidateFile(Resource):
    def db_validate(self, people):      
        conn = pyodbc.connect('Driver={SQL Server};'
                              'Server=GLADOS\MSSQLSERVER01;'
                              'Database=Northwind;'
                              'Trusted_Connection=yes;')
        
        for person in people: 
            cursor = conn.cursor()
            row = None
            if person.cpf:
                row = cursor.execute("EXECUTE AS USER = 'app';  SELECT * FROM People where CPF = '" + person.cpf + "'").fetchone()
            if row:
                person.flagAutorizacao = row.flag_documento
        
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
        parser.add_argument('emancipado', type=bool)
        parser.add_argument('responsavel', type=bool)
        parser.add_argument('cpfResponsavel', type=str)
        parser.add_argument('parentesco', type=int)
        parser.add_argument('file', type=werkzeug.datastructures.FileStorage, location='files')
        args = parser.parse_args()
        cpf = args['cpf']
        acao = args['acao']
        emancipado = args['emancipado']
        responsavel = args['responsavel']
        if(acao == 'optin'):
            if (emancipado):
                cloudinary.config(cloud_name='dhrv1rlbn', api_key='646476471328262',
                                api_secret='r6ajics1Nskx_53e7AZhxYKlP2Q')
                upload_result = None
                file_to_upload = args['file']
                if file_to_upload:
                    upload_result = cloudinary.uploader.upload(file_to_upload)
                    cursor.execute("EXECUTE AS USER = 'app'; UPDATE dbo.People SET documento = '" +upload_result["url"]+ "' WHERE CPF = '"+ cpf +"';")
            if (responsavel):
                cpfResponsavel = args['cpfResponsavel']
                parentesco = args['parentesco']

                respRow = None
                respRow = cursor.execute("EXECUTE AS USER = 'app';  SELECT * FROM People where CPF = '" + cpfResponsavel + "'").fetchone()

                if respRow:
                    cursor.execute("EXECUTE AS USER = 'app'; UPDATE dbo.People SET responsavel = " + str(respRow.CustomerID) + ", parentescoID = " + str(parentesco) + " WHERE CPF = '"+ cpf +"';")
            cursor.execute("EXECUTE AS USER = 'app'; UPDATE dbo.People SET flag_documento = 1 WHERE CPF = '"+ cpf +"';")
            conn.commit()

        elif(acao == 'optout'):
            if (emancipado):
                cloudinary.config(cloud_name='dhrv1rlbn', api_key='646476471328262',
                                api_secret='r6ajics1Nskx_53e7AZhxYKlP2Q')
                upload_result = None
                file_to_upload = args['file']
                if file_to_upload:
                    upload_result = cloudinary.uploader.upload(file_to_upload)
                    cursor.execute("EXECUTE AS USER = 'app'; UPDATE dbo.People SET documento = '" +upload_result["url"]+ "' WHERE CPF = '"+ cpf +"';")
            if (responsavel):
                cpfResponsavel = args['cpfResponsavel']
                parentesco = args['parentesco']

                respRow = None
                respRow = cursor.execute("EXECUTE AS USER = 'app';  SELECT * FROM People where CPF = '" + cpfResponsavel + "'").fetchone()

                if respRow:
                    cursor.execute("EXECUTE AS USER = 'app'; UPDATE dbo.People SET responsavel = " + str(respRow.CustomerID) + ", parentescoID = " + str(parentesco) + " WHERE CPF = '"+ cpf +"';")
            cursor.execute("EXECUTE AS USER = 'app';  UPDATE dbo.People SET flag_documento = 0 WHERE CPF = '"+ cpf +"';")
            conn.commit()
        
        row = None
        row = cursor.execute("EXECUTE AS USER = 'app';  SELECT * FROM People where CPF = '" + cpf + "'").fetchone()

        if row:
            return jsonify({'resultData':{'flag':row.flag_documento}})

        else:
            return jsonify({'error':True, 'msg':'CPF não cadastrado'})


class EmailMarketing(Resource):
    def db_eml(self):      
        conn = pyodbc.connect(connection_string)

        cursor = conn.cursor()
        retorno = ''
        rows = cursor.execute("EXECUTE AS USER = 'sales1';  SELECT Email FROM Customers").fetchall()
        for row in rows:
            retorno = retorno + row.Email + ' ; '
        return retorno

    @cross_origin()
    def get(self):
        return jsonify({'resultData':self.db_eml()}) 


api.add_resource(ValidateFile, "/validatefile")
api.add_resource(Acao, "/changeflag")
api.add_resource(EmailMarketing, "/emailmarketing")

if __name__ == "__main__":
    app.run(debug=True)