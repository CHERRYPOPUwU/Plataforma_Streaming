from flask import Blueprint, render_template, abort
from flask_login import login_required
from sqlalchemy import text
from app import db

content_bp = Blueprint('content', __name__)

@content_bp.route('/content/<int:id>')
@login_required
def content_detail(id):
    result = db.session.execute(text("SELECT get_content_details(:cid);"), {"cid": id})
    content = result.scalar()
    if not content:
        abort(404)
    return render_template('content_detail.html', content=content)
