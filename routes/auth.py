from flask import Blueprint, render_template, redirect, url_for, request, flash
from flask_login import login_user, logout_user, login_required
from werkzeug.security import generate_password_hash, check_password_hash
from models import db, Account

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        user = Account.query.filter_by(email=email).first()
        if user and check_password_hash(user.password_hash, password):
            login_user(user)
            flash('Inicio de sesión exitoso ✅', 'success')
            return redirect(url_for('index'))
        else:
            flash('Correo o contraseña incorrectos ❌', 'danger')

    return render_template('login.html')


@auth_bp.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']
        confirm = request.form['confirm']

        if password != confirm:
            flash('Las contraseñas no coinciden', 'warning')
            return redirect(url_for('auth.register'))

        if Account.query.filter_by(email=email).first():
            flash('El correo ya está registrado', 'danger')
            return redirect(url_for('auth.register'))

        hashed = generate_password_hash(password)
        new_user = Account(email=email, password_hash=hashed)
        db.session.add(new_user)
        db.session.commit()

        flash('Registro exitoso 🎉 Ahora puedes iniciar sesión', 'success')
        return redirect(url_for('auth.login'))

    return render_template('register.html')


@auth_bp.route('/logout')
@login_required
def logout():
    logout_user()
    flash('Sesión cerrada correctamente 👋', 'info')
    return redirect(url_for('auth.login'))
