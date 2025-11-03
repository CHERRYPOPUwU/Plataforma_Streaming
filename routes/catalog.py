from flask import Blueprint, render_template, jsonify, request
from flask_login import login_required
from sqlalchemy import text
from app import db

catalog_bp = Blueprint('catalog', __name__)

# 📚 Obtener todo el catálogo
@catalog_bp.route('/catalog', methods=['GET'])
def get_catalog():
    try:
        sql = text("SELECT get_catalog();")
        result = db.session.execute(sql).scalar()
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# 🎬 Obtener detalles de un contenido específico
@catalog_bp.route('/content/<int:content_id>', methods=['GET'])
def get_content_details(content_id):
    try:
        sql = text("SELECT get_content_details(:cid);")
        result = db.session.execute(sql, {'cid': content_id}).scalar()
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# 🔎 Buscar contenido por título, género o tipo
@catalog_bp.route('/search', methods=['GET'])
def search_contents():
    query = request.args.get('q', '')
    try:
        sql = text("SELECT search_contents_json(:query);")
        result = db.session.execute(sql, {'query': query}).scalar()
        return jsonify(result), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500