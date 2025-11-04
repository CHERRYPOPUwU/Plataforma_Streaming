import os
from flask import Flask, render_template, redirect, url_for, request, flash, session
from config import Config
from models import db
from models.models import Account, Profile, Content, Watchlist, Rating, Genre, ContentGenre
from flask_login import LoginManager, login_user, login_required, logout_user, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime
from sqlalchemy import or_, func, text
from routes.auth import auth_bp 

#Importar blueprints
from routes.auth import auth_bp
from routes.catalog import catalog_bp
from routes.content import content_bp



def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    db.init_app(app)

    login_manager = LoginManager()
    login_manager.login_view = 'auth.login'
    login_manager.init_app(app)

    @login_manager.user_loader
    def load_user(user_id):
        return Account.query.get(int(user_id))

    # registrar blueprints
    app.register_blueprint(auth_bp)
    app.register_blueprint(catalog_bp)
    app.register_blueprint(content_bp)

    @app.route('/')
    def index():
        # mostrar últimos contenidos
        contents = Content.query.order_by(Content.created_at.desc()).limit(12).all()
        return render_template('index.html', contents=contents)

    # ---------- AUTH ----------
    @app.route('/register', methods=['GET','POST'])
    def register():
        if request.method == 'POST':
            email = request.form['email']
            password = request.form['password']
            if Account.query.filter_by(email=email).first():
                flash('Email ya registrado', 'danger')
                return redirect(url_for('register'))
            hashed = generate_password_hash(password)
            acc = Account(email=email, password_hash=hashed)
            db.session.add(acc)
            db.session.commit()
            flash('Cuenta creada. Inicia sesión.', 'success')
            return redirect(url_for('login'))
        return render_template('register.html')

    @app.route('/login', methods=['GET','POST'])
    def login():
        if request.method == 'POST':
            email = request.form['email']
            password = request.form['password']
            user = Account.query.filter_by(email=email).first()
            if user and check_password_hash(user.password_hash, password):
                login_user(user)
                # update last_login
                user.last_login = datetime.utcnow()
                db.session.commit()
                return redirect(url_for('index'))
            flash('Credenciales inválidas', 'danger')
        return render_template('login.html')

    @app.route('/logout')
    @login_required
    def logout():
        logout_user()
        return redirect(url_for('index'))

    # ---------- SEARCH ----------
    @app.route('/search')
    def search():
        q = request.args.get('q', '').strip()
        genre = request.args.get('genre')
        query = Content.query
        if q:
            like = f'%{q}%'
            query = query.filter(or_(Content.title.ilike(like), Content.synopsis.ilike(like), Content.original_title.ilike(like)))
        if genre:
            query = query.join(ContentGenre).join(Genre).filter(Genre.id == int(genre))
        results = query.order_by(Content.year.desc()).limit(50).all()
        genres = Genre.query.order_by(Genre.name).all()
        return render_template('search.html', contents=results, q=q, genres=genres)

    # ---------- CONTENT DETAIL ----------
    @app.route('/content/<int:content_id>')
    def content_detail(content_id):
        content = Content.query.get_or_404(content_id)
        return render_template('content_detail.html', content=content)

    # ---------- PROFILE / WATCHLIST ----------
    @app.route('/profiles')
    @login_required
    def profiles():
        profiles = current_user.profiles
        return render_template('profiles.html', profiles=profiles)

    @app.route('/profile/<int:profile_id>/watchlist')
    @login_required
    def watchlist(profile_id):
        profile = Profile.query.get_or_404(profile_id)
        items = Watchlist.query.filter_by(profile_id=profile_id).join(Content).order_by(Watchlist.added_at.desc()).all()
        return render_template('watchlist.html', profile=profile, items=items)

    @app.route('/profile/<int:profile_id>/watchlist/add/<int:content_id>', methods=['POST'])
    @login_required
    def add_watchlist(profile_id, content_id):
        if Profile.query.get(profile_id).account_id != current_user.id:
            flash('No autorizado', 'danger'); return redirect(url_for('index'))
        exists = Watchlist.query.filter_by(profile_id=profile_id, content_id=content_id).first()
        if exists:
            flash('Ya está en la lista', 'info'); return redirect(url_for('content_detail', content_id=content_id))
        item = Watchlist(profile_id=profile_id, content_id=content_id)
        db.session.add(item)
        db.session.commit()
        flash('Añadido a Mi lista', 'success')
        return redirect(url_for('content_detail', content_id=content_id))

    # ---------- RATINGS (crea y dispara trigger en BD para recalcular promedio) ----------
    @app.route('/profile/<int:profile_id>/rate/<int:content_id>', methods=['POST'])
    @login_required
    def rate_content(profile_id, content_id):
        profile = Profile.query.get_or_404(profile_id)
        if profile.account_id != current_user.id:
            flash('No autorizado', 'danger'); return redirect(url_for('index'))
        score = int(request.form.get('score', 0))
        review_text = request.form.get('review_text', '')
        if score < 1 or score > 5:
            flash('Puntaje inválido', 'danger'); return redirect(url_for('content_detail', content_id=content_id))
        rating = Rating(profile_id=profile_id, content_id=content_id, score=score, review_text=review_text)
        db.session.add(rating)
        db.session.commit()  # aquí el trigger en BD actualizará rating_avg/rating_count
        flash('Gracias por tu valoración', 'success')
        return redirect(url_for('content_detail', content_id=content_id))

    # ---------- Stored procedure example: get_content_json ----------
    @app.route('/api/content/<int:content_id>/json')
    def api_content_json(content_id):
        sql = text("SELECT get_content_by_id_json(:cid) as data")
        res = db.session.execute(sql, {'cid': content_id}).fetchone()
        if res:
            return res[0]  # devuelve JSON desde la función PG
        return {}, 404

    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port) 
    return app

if __name__ == '__main__':
    app = create_app()
