# auth.py
from flask import Blueprint, render_template, redirect, url_for, flash, request
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import login_user, logout_user, login_required, current_user
from models import db, Account, Profile
from forms import RegisterForm, LoginForm

auth_bp = Blueprint('auth', __name__, template_folder='templates')

@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    form = RegisterForm()
    if form.validate_on_submit():
        email = form.email.data.lower().strip()
        password = form.password.data

        if Account.query.filter_by(email=email).first():
            flash('El email ya está registrado.', 'danger')
            return redirect(url_for('auth.register'))

        hashed = generate_password_hash(password)  # pbkdf2:sha256 por defecto
        acc = Account(email=email, password_hash=hashed)
        db.session.add(acc)
        db.session.commit()

        # Crear perfil por defecto
        profile = Profile(account_id=acc.id, name='Principal')
        db.session.add(profile)
        db.session.commit()

        flash('Cuenta creada correctamente. Inicia sesión.', 'success')
        return redirect(url_for('auth.login'))

    return render_template('register.html', form=form)


@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if current_user.is_authenticated:
        return redirect(url_for('index'))
    form = LoginForm()
    if form.validate_on_submit():
        email = form.email.data.lower().strip()
        password = form.password.data
        user = Account.query.filter_by(email=email).first()
        if user and check_password_hash(user.password_hash, password):
            login_user(user, remember=form.remember.data)
            # actualizar last_login
            from datetime import datetime
            user.last_login = datetime.utcnow()
            db.session.commit()

            next_page = request.args.get('next')
            flash('Bienvenido/a', 'success')
            return redirect(next_page or url_for('index'))
        flash('Credenciales inválidas', 'danger')

    return render_template('login.html', form=form)


@auth_bp.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Sesión cerrada', 'info')
    return redirect(url_for('index'))
