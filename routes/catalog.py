from flask import Blueprint, render_template, request, jsonify
from sqlalchemy import text
from flask_login import login_required
from app import db

catalog_bp = Blueprint('catalog', __name__)

# 📚 Página principal del catálogo (HTML)
@catalog_bp.route('/catalog', methods=['GET'])
@login_required
def catalog_page():
    try:
        genre = request.args.get('genre')
        content_type = request.args.get('type')

        # Si hay filtros aplicados
        if genre:
            sql = text("SELECT get_content_by_genre(:g);")
            result = db.session.execute(sql, {'g': genre}).scalar()
        else:
            sql = text("SELECT get_catalog();")
            result = db.session.execute(sql).scalar()

        # Convertir resultado JSON a lista de Python
        if result:
            contents = result if isinstance(result, list) else result
        else:
            contents = []

        return render_template('catalog.html', contents=contents, genre=genre, content_type=content_type)

    except Exception as e:
        return jsonify({'error': str(e)}), 500


# 🔎 API: Buscar contenido por palabra clave
@catalog_bp.route('/api/search', methods=['GET'])
def api_search():
    query = request.args.get('q', '')
    try:
        sql = text("SELECT search_contents_json(:query, 20);")
        result = db.session.execute(sql, {'query': query}).scalar()
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500
