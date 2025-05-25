import os
import traceback # Adicione esta linha!
from flask import Flask, request, jsonify
from flask_mysqldb import MySQL

app = Flask(__name__)

# Configurações do Banco de Dados
app.config['MYSQL_HOST'] = os.environ.get('MYSQL_HOST', 'localhost')
app.config['MYSQL_USER'] = os.environ.get('MYSQL_USER', 'root')
app.config['MYSQL_PASSWORD'] = os.environ.get('MYSQL_PASSWORD', 'admin') # Mude para sua senha
app.config['MYSQL_DB'] = os.environ.get('MYSQL_DB', 'habit_tracker')

mysql = MySQL(app)

@app.route('/habits', methods=['POST'])
def add_habit():
    try:
        data = request.json
        name = data['name']
        count_method = data['count_method']
        completion_method = data['completion_method']
        description = data.get('description')
        target_quantity = data.get('target_quantity')
        target_days_per_week = data.get('target_days_per_week')

        # Validações básicas (pode ser mais robusto)
        if count_method not in ['daily', 'weekly', 'monthly']:
            return jsonify({'error': 'Invalid count_method. Must be daily, weekly, or monthly.'}), 400
        if completion_method not in ['quantity', 'minutes']:
            return jsonify({'error': 'Invalid completion_method. Must be quantity or minutes.'}), 400

        if (completion_method == 'quantity' or completion_method == 'minutes') and target_quantity is None:
            return jsonify({'error': 'target_quantity is required for quantity or minutes completion methods.'}), 400

        if count_method in ['weekly', 'monthly'] and target_days_per_week is None:
            return jsonify({'error': 'target_days_per_week is required for weekly or monthly habits.'}), 400

        cursor = mysql.connection.cursor()
        cursor.execute(
            "INSERT INTO habits (name, description, count_method, completion_method, target_quantity, target_days_per_week) VALUES (%s, %s, %s, %s, %s, %s)",
            (name, description, count_method, completion_method, target_quantity, target_days_per_week)
        )
        mysql.connection.commit()
        
        habit_id = cursor.lastrowid
        cursor.close()
        
        return jsonify({'message': 'Habit added successfully!', 'id': habit_id}), 201
    except KeyError as e:
        return jsonify({'error': f'Missing data: {e}'}), 400
    except Exception as e:
        # Mantive a impressão aqui para o caso de outros erros no POST, embora o principal foco seja o GET
        print(f"Erro no POST /habits: {e}")
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

# Adicione esta rota em app.py
@app.route('/habits', methods=['GET'])
def get_habits():
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT id, name, description, count_method, completion_method, target_quantity, target_days_per_week, created_at FROM habits")
        habits = cursor.fetchall() # Isso retorna uma lista de tuplas de hábitos, ou uma lista vazia se não houver hábitos

        habits_list = []
        # Verifica se há uma descrição do cursor (ou seja, se a consulta retornou colunas)
        if cursor.description: # <-- ADICIONE ESTA CONDIÇÃO AQUI
            column_names = [desc[0] for desc in cursor.description]
            for habit_tuple in habits:
                habits_list.append(dict(zip(column_names, habit_tuple)))

        cursor.close()

        return jsonify(habits_list), 200
    except Exception as e:
        print(f"Erro ao obter hábitos: {e}")
        traceback.print_exc()
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)