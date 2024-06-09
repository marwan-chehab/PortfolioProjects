# app.py

from flask import Flask, jsonify, render_template
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

def create_connection():
    try:
        connection = mysql.connector.connect(
            host='35.180.203.161',
            user='remote_user',       # Replace with your remote username
            password='remote_password', # Replace with your remote password
            database='home'
        )
        if connection.is_connected():
            return connection
    except Error as e:
        print(f"Error while connecting to MySQL: {e}")
        return None

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/data')
def data():
    connection = create_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute("SELECT * FROM ampere ORDER BY date DESC LIMIT 1")
    result = cursor.fetchone()
    connection.close()
    return jsonify(result)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
